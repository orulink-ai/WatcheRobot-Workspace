#!/usr/bin/env python3
"""Read-only context collector for embedded PR robustness reviews."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Iterable


SOURCE_SUFFIXES = {".c", ".cc", ".cpp", ".h", ".hpp", ".S", ".s"}


RISK_RULES: list[tuple[str, tuple[str, ...], tuple[str, ...]]] = [
    ("mcu-link-protocol", ("components/protocols/mcu_link/", "mcu_link", "mcu_frame", "mcu_cobs", "mcu_crc"), ("host ctest", "idf.py build")),
    ("wire-protocol", ("components/protocols/", "ws_client", "ble_service", "discovery"), ("protocol/parser tests", "idf.py build")),
    ("hal-hardware", ("components/hal/", "components/drivers/"), ("hardware smoke", "idf.py build")),
    ("service-state", ("components/services/",), ("service-level smoke", "idf.py build")),
    ("animation-display", ("anim_service", "hal_display", "lvgl", "display_ui", "assets/gif", "spiffs"), ("display/asset smoke", "idf.py build")),
    ("camera-media", ("hal_camera", "camera_service", "ws_camera_gateway"), ("camera gateway test", "hardware smoke", "idf.py build")),
    ("startup-recovery", ("main/app_main.c", "main/stress_mode", "main/mem_monitor"), ("boot log review", "idf.py build")),
    ("config-partition", ("sdkconfig", "Kconfig", "partitions.csv", "CMakeLists.txt", "idf_component.yml"), ("clean build", "config review")),
    ("storage-ota", ("ota_service", "nvs", "spiffs", "sd", "fatfs", "partition"), ("power-loss/recovery review", "idf.py build")),
]


TOKEN_RULES: list[tuple[str, tuple[str, ...]]] = [
    ("memory-lifetime", ("malloc", "calloc", "realloc", "free(", "heap_caps_", "ps_malloc", "memcpy", "memmove", "strncpy", "snprintf")),
    ("concurrency", ("Semaphore", "Mutex", "xQueue", "xTask", "portENTER_CRITICAL", "portEXIT_CRITICAL", "volatile", "atomic", "timer")),
    ("isr-task-boundary", ("ISR", "FromISR", "intr", "gpio_isr", "esp_timer", "callback")),
    ("protocol-parsing", ("payload_len", "frame", "crc", "cobs", "seq", "ref_seq", "opcode", "command")),
    ("error-recovery", ("ESP_FAIL", "ESP_ERR", "timeout", "retry", "recover", "fallback", "safe-default", "watchdog", "wdt")),
]


def run_git(repo: Path, args: list[str], check: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", "-C", str(repo), *args],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=check,
    )


def split_lines(text: str) -> list[str]:
    return [line for line in text.splitlines() if line.strip()]


def changed_files(repo: Path, base: str | None) -> list[str]:
    files: set[str] = set()
    commands = [
        ["diff", "--name-only"],
        ["diff", "--cached", "--name-only"],
    ]
    if base:
        commands.append(["diff", "--name-only", f"{base}...HEAD"])
    for command in commands:
        result = run_git(repo, command)
        if result.returncode == 0:
            files.update(split_lines(result.stdout))
    return sorted(files)


def diff_text(repo: Path, base: str | None) -> str:
    chunks: list[str] = []
    for label, command in (
        ("unstaged", ["diff", "--unified=0"]),
        ("staged", ["diff", "--cached", "--unified=0"]),
        ("base", ["diff", "--unified=0", f"{base}...HEAD"] if base else []),
    ):
        if not command:
            continue
        result = run_git(repo, command)
        if result.returncode == 0 and result.stdout.strip():
            chunks.append(f"--- {label} diff ---\n{result.stdout}")
    return "\n".join(chunks)


def classify_by_path(path: str) -> list[str]:
    lowered = path.replace("\\", "/").lower()
    risks: list[str] = []
    for risk, needles, _tests in RISK_RULES:
        if any(needle.lower() in lowered for needle in needles):
            risks.append(risk)
    return risks


def classify_by_diff(text: str) -> list[str]:
    lowered = text.lower()
    risks: list[str] = []
    for risk, tokens in TOKEN_RULES:
        if any(token.lower() in lowered for token in tokens):
            risks.append(risk)
    return risks


def suggested_tests(risks: Iterable[str]) -> list[str]:
    tests: set[str] = set()
    risk_set = set(risks)
    for risk, _needles, risk_tests in RISK_RULES:
        if risk in risk_set:
            tests.update(risk_tests)
    if not tests and risk_set:
        tests.add("idf.py build")
    return sorted(tests)


def todo_hits(repo: Path, files: Iterable[str]) -> list[dict[str, object]]:
    hits: list[dict[str, object]] = []
    pattern = re.compile(r"\b(TODO|FIXME|HACK|XXX)\b", re.IGNORECASE)
    for rel in files:
        path = repo / rel
        if not path.is_file() or path.suffix not in SOURCE_SUFFIXES:
            continue
        try:
            for idx, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
                if pattern.search(line):
                    hits.append({"file": rel, "line": idx, "text": line.strip()[:160]})
        except OSError:
            continue
    return hits


def public_api_changes(files: Iterable[str], diff: str) -> list[str]:
    changed_headers = [path for path in files if Path(path).suffix in {".h", ".hpp"}]
    signatures: list[str] = []
    signature_re = re.compile(r"^\+(?!\+)\s*(?:[A-Za-z_][\w\s\*\(\),]*\s+)?[A-Za-z_]\w*\s*\([^;{}]*\)\s*;", re.MULTILINE)
    for match in signature_re.finditer(diff):
        signatures.append(match.group(0)[1:].strip())
    result = [f"header changed: {path}" for path in changed_headers]
    result.extend(f"added/changed declaration: {sig}" for sig in signatures[:20])
    return result[:40]


def detect_project(repo: Path) -> dict[str, bool]:
    return {
        "esp_idf": (repo / "CMakeLists.txt").exists() and ((repo / "sdkconfig.defaults").exists() or (repo / "main").exists()),
        "watche_s3_shape": (repo / "components" / "protocols" / "mcu_link").exists() and (repo / "main" / "app_main.c").exists(),
        "mcu_link_host_tests": (repo / "components" / "protocols" / "mcu_link" / "test_support" / "host" / "CMakeLists.txt").exists(),
        "camera_gateway_test": (repo / "tools" / "ws_camera_gateway_test.py").exists(),
    }


def build_report(git_root: Path, review_root: Path, base: str | None) -> dict[str, object]:
    git_root = git_root.resolve()
    review_root = review_root.resolve()
    status_result = run_git(git_root, ["status", "--short"])
    files = changed_files(git_root, base)
    diff = diff_text(git_root, base)
    path_risks = sorted({risk for path in files for risk in classify_by_path(path)})
    token_risks = classify_by_diff(diff)
    all_risks = sorted(set(path_risks + token_risks))
    project = detect_project(review_root)
    tests = suggested_tests(all_risks)
    if project["esp_idf"]:
        tests = sorted(set(tests + ["idf.py build"]))
    if project["mcu_link_host_tests"] and "mcu-link-protocol" in all_risks:
        tests = sorted(set(tests + ["cmake/ctest in components/protocols/mcu_link/test_support/host"]))
    if project["camera_gateway_test"] and "camera-media" in all_risks:
        tests = sorted(set(tests + ["python tools/ws_camera_gateway_test.py when hardware/network setup is available"]))

    return {
        "git_root": str(git_root),
        "review_root": str(review_root),
        "base": base,
        "project": project,
        "git_status_short": split_lines(status_result.stdout),
        "changed_files": files,
        "risk_domains": all_risks,
        "path_risk_domains": path_risks,
        "diff_token_risk_domains": token_risks,
        "public_api_changes": public_api_changes(files, diff),
        "todo_fixme_hits_in_changed_sources": todo_hits(git_root, files),
        "suggested_verification": tests,
        "notes": [
            "No changed files found; provide a PR branch/base or run this from a worktree with staged or unstaged changes."
            if not files
            else "Use this as triage only; manually inspect changed code and callers before reporting findings."
        ],
    }


def print_markdown(report: dict[str, object]) -> None:
    print("# PR Robustness Review Context")
    print()
    print(f"- Git root: `{report['git_root']}`")
    print(f"- Review root: `{report['review_root']}`")
    print(f"- Base: `{report['base'] or 'not provided'}`")
    print()
    print("## Project")
    for key, value in (report["project"] or {}).items():
        print(f"- {key}: {value}")
    print()
    print("## Changed Files")
    files = report["changed_files"] or []
    if files:
        for path in files:
            print(f"- `{path}`")
    else:
        print("- None detected")
    print()
    print("## Risk Domains")
    risks = report["risk_domains"] or []
    print(", ".join(f"`{risk}`" for risk in risks) if risks else "None detected")
    print()
    print("## Public API Signals")
    api = report["public_api_changes"] or []
    if api:
        for item in api:
            print(f"- {item}")
    else:
        print("- None detected")
    print()
    print("## TODO/FIXME In Changed Sources")
    hits = report["todo_fixme_hits_in_changed_sources"] or []
    if hits:
        for hit in hits:
            print(f"- `{hit['file']}:{hit['line']}` {hit['text']}")
    else:
        print("- None detected")
    print()
    print("## Suggested Verification")
    tests = report["suggested_verification"] or []
    if tests:
        for test in tests:
            print(f"- {test}")
    else:
        print("- None detected")
    print()
    print("## Notes")
    for note in report["notes"]:
        print(f"- {note}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", default=".", help="Repository/worktree path.")
    parser.add_argument("--base", help="Optional git base ref, for example origin/main.")
    parser.add_argument("--json", action="store_true", help="Emit JSON instead of Markdown.")
    args = parser.parse_args()

    review_root = Path(args.repo).resolve()
    git_root = review_root
    if not (review_root / ".git").exists():
        result = run_git(review_root, ["rev-parse", "--show-toplevel"])
        if result.returncode != 0:
            print(f"error: {review_root} is not inside a git repository", file=sys.stderr)
            return 2
        git_root = Path(result.stdout.strip())

    report = build_report(git_root, review_root, args.base)
    if args.json:
        print(json.dumps(report, indent=2, ensure_ascii=False))
    else:
        print_markdown(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
