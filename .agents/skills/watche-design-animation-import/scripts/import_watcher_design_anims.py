#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
import zipfile
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any

try:
    from PIL import Image, ImageSequence
except ImportError:
    Image = None
    ImageSequence = None


def discover_default_repo_root() -> Path:
    env_value = os.environ.get("WATCHE_S3_FIRMWARE_ROOT") or os.environ.get("WATCHE_ESP32_FIRMWARE_ROOT")
    if env_value:
        return Path(env_value)

    current = Path.cwd().resolve()
    for candidate in (current, *current.parents):
        if (candidate / "tools" / "generate_anim_assets.py").is_file():
            return candidate
        nested = candidate / "WatcheRobot_esp32" / "firmware" / "s3"
        if (nested / "tools" / "generate_anim_assets.py").is_file():
            return nested

    skill_file = Path(__file__).resolve()
    for candidate in skill_file.parents:
        nested = candidate / "WatcheRobot_esp32" / "firmware" / "s3"
        if (nested / "tools" / "generate_anim_assets.py").is_file():
            return nested

    return Path.cwd()


DEFAULT_REPO_ROOT = discover_default_repo_root()
DEFAULT_DESIGN_ROOT = os.environ.get("WATCHE_DESIGN_ROOT") or os.environ.get("WATCHER_DESIGN_ROOT") or ""
DEFAULT_FEISHU_BASE_TOKEN = os.environ.get("FEISHU_BASE_TOKEN") or os.environ.get("LARK_BASE_TOKEN") or ""
DEFAULT_FEISHU_TABLE_ID = os.environ.get("FEISHU_TABLE_ID") or os.environ.get("LARK_TABLE_ID") or ""
DEFAULT_DESIGN_ROOT_TIMEOUT_SECONDS = 20
DEFAULT_FEISHU_TIMEOUT_SECONDS = 30
LEGACY_ALIASES = {
    "watcher-boot": "boot",
    "watcher-happy": "happy",
    "watcher-error": "error",
    "watcher-bluetooth": "bluetooth",
    "watcher-speaking": "speaking",
    "watcher-listening": "listening",
    "watcher-processing": "processing",
    "watcher-standby": "standby",
    "watcher-thinking": "thinking",
    "watcher-custom1": "custom1",
    "watcher-custom2": "custom2",
    "watcher-custom3": "custom3",
    "watcher-processing2": "custom3",
    "watcher-standby1": "standby1",
    "watcher-standby2": "standby2",
    "watcher-standby3": "standby3",
    "watcher-standby4": "standby4",
    "watcher-disconnect": "disconnect",
    "watcher-shock": "shock",
    "watcher-sunglasses": "sunglasses",
    "watcher-sad": "sad",
    "watcher-get": "get",
    "watcher-smile": "smile",
    "watcher-recharge": "recharge",
    "watcher-speechless": "speechless",
    "watcher-concentration": "concentration",
    "watcher-fondle-love": "fondle_love",
    "watcher-fondle-anger": "fondle_anger",
    "watcher-blink": "blink",
}
ARCHIVE_SUFFIXES = {".zip", ".7z", ".rar"}
SUPPORTED_ARCHIVE_SUFFIXES = {".zip"}


@dataclass(frozen=True)
class GifCandidate:
    source_label: str
    path: Path
    stem: str
    size_bytes: int
    width: int | None = None
    height: int | None = None
    frame_count: int | None = None
    first_delays_ms: tuple[int | None, ...] = ()


def normalize_key(value: str) -> str:
    normalized = value.strip().lower()
    normalized = normalized.replace("_", "-").replace(" ", "-")
    normalized = re.sub(r"-+", "-", normalized)
    return normalized


def build_registered_key_map(registered_types: list[str]) -> dict[str, str]:
    return {normalize_key(anim_type): anim_type for anim_type in registered_types}


def canonicalize_target(value: str, registered_key_map: dict[str, str]) -> str:
    key = normalize_key(value)
    return registered_key_map.get(key, key)


def add_mapping_alias(mapping: dict[str, str], alias: str | None, target: str | None) -> None:
    if alias is None or target is None:
        return
    alias = alias.strip()
    target = target.strip()
    if not alias or not target:
        return
    mapping[normalize_key(alias)] = normalize_key(target)


def parse_date_folder_name(name: str) -> datetime | None:
    match = re.fullmatch(r"(\d{4})\.(\d{2})\.(\d{2})", name)
    if not match:
        return None
    try:
        return datetime(int(match.group(1)), int(match.group(2)), int(match.group(3)))
    except ValueError:
        return None


LATEST_DATE_DIR_PROBE = r"""
import re
import sys
from datetime import datetime
from pathlib import Path

root = Path(sys.argv[1])
if not root.is_dir():
    raise SystemExit(f"Design root does not exist or is not a directory: {root}")

candidates = []
for child in root.iterdir():
    if not child.is_dir():
        continue
    match = re.fullmatch(r"(\d{4})\.(\d{2})\.(\d{2})", child.name)
    if match is None:
        continue
    try:
        parsed = datetime(int(match.group(1)), int(match.group(2)), int(match.group(3)))
    except ValueError:
        continue
    candidates.append((parsed, child))

if not candidates:
    raise SystemExit(f"No YYYY.MM.DD design folders found under {root}")

candidates.sort(key=lambda item: item[0])
print(candidates[-1][1])
"""


def find_latest_date_dir_direct(design_root: Path) -> Path:
    if not design_root.is_dir():
        raise SystemExit(f"Design root does not exist or is not a directory: {design_root}")

    candidates: list[tuple[datetime, Path]] = []
    for child in design_root.iterdir():
        if not child.is_dir():
            continue
        parsed = parse_date_folder_name(child.name)
        if parsed is not None:
            candidates.append((parsed, child))

    if not candidates:
        raise SystemExit(f"No YYYY.MM.DD design folders found under {design_root}")

    candidates.sort(key=lambda item: item[0])
    return candidates[-1][1]


def find_latest_date_dir(design_root: Path, timeout_seconds: int) -> Path:
    if timeout_seconds <= 0:
        return find_latest_date_dir_direct(design_root)

    command = [sys.executable, "-c", LATEST_DATE_DIR_PROBE, str(design_root)]
    proc = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    deadline = time.monotonic() + timeout_seconds
    while proc.poll() is None:
        if time.monotonic() >= deadline:
            try:
                if os.name == "nt":
                    subprocess.run(
                        ["taskkill", "/F", "/T", "/PID", str(proc.pid)],
                        stdout=subprocess.DEVNULL,
                        stderr=subprocess.DEVNULL,
                        timeout=5,
                    )
                else:
                    proc.kill()
            except Exception:
                proc.kill()
            raise SystemExit(
                "Timed out while scanning the design root "
                f"after {timeout_seconds}s: {design_root}\n"
                "VPN/DNS or WebDAV may be unhealthy. Re-run with an explicit source folder, "
                'for example: --source-date-dir "Z:\\设计\\动画表情文件\\watcher\\2026.04.28"'
            )
        time.sleep(0.05)

    stdout_bytes, stderr_bytes = proc.communicate()
    stdout = stdout_bytes.decode("utf-8", errors="replace")
    stderr = stderr_bytes.decode("utf-8", errors="replace")
    if proc.returncode != 0:
        detail = (stderr or stdout or "").strip()
        if detail:
            raise SystemExit(detail)
        raise SystemExit(f"Unable to scan design root: {design_root}")

    latest = stdout.strip()
    if not latest:
        raise SystemExit(f"Unable to resolve latest design folder under: {design_root}")
    return Path(latest)


def read_project_version(repo_root: Path) -> str:
    cmake_path = repo_root / "CMakeLists.txt"
    text = cmake_path.read_text(encoding="utf-8", errors="replace")
    match = re.search(r'set\s*\(\s*PROJECT_VER\s+"?([^"\)\s]+)"?\s*\)', text)
    if not match:
        return "v0.2.6"
    return match.group(1)


def parse_generator_types(repo_root: Path) -> list[str]:
    generator = repo_root / "tools" / "generate_anim_assets.py"
    if not generator.is_file():
        raise SystemExit(f"Animation generator not found: {generator}")
    text = generator.read_text(encoding="utf-8", errors="replace")
    match = re.search(r"ANIM_TYPES\s*=\s*\[(.*?)\]", text, flags=re.S)
    if not match:
        raise SystemExit(f"Unable to parse ANIM_TYPES from: {generator}")
    types = [first or second for first, second in re.findall(r'"([^"]+)"|\'([^\']+)\'', match.group(1))]
    if not types:
        raise SystemExit(f"ANIM_TYPES is empty in: {generator}")
    return types


def detect_lv_color_swap(repo_root: Path) -> bool:
    for rel in ("sdkconfig", "sdkconfig.defaults"):
        path = repo_root / rel
        if not path.is_file():
            continue
        for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
            if line.strip() == "CONFIG_LV_COLOR_16_SWAP=y":
                return True
    return False


def load_mapping(path: Path | None) -> dict[str, str]:
    mapping: dict[str, str] = {}
    if path is None:
        return mapping

    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise SystemExit(f"Mapping JSON must be an object: {path}")

    for key, value in data.items():
        if isinstance(value, str):
            mapping[normalize_key(key)] = normalize_key(value)
        elif isinstance(value, list):
            target = normalize_key(key)
            for item in value:
                if not isinstance(item, str):
                    raise SystemExit(f"Mapping list entries must be strings: {path}")
                mapping[normalize_key(item)] = target
        else:
            raise SystemExit(f"Mapping values must be strings or string arrays: {path}")
    return mapping


def feishu_cell_text(value: Any) -> str | None:
    if value is None:
        return None
    if isinstance(value, str):
        return value
    if isinstance(value, (int, float, bool)):
        return str(value)
    return None


def feishu_file_names(value: Any) -> list[str]:
    names: list[str] = []
    if isinstance(value, list):
        for item in value:
            if isinstance(item, dict) and isinstance(item.get("name"), str):
                names.append(item["name"])
            elif isinstance(item, str):
                names.append(item)
    elif isinstance(value, dict) and isinstance(value.get("name"), str):
        names.append(value["name"])
    elif isinstance(value, str):
        names.append(value)
    return names


def strip_watcher_prefix(value: str) -> str:
    stripped = value.strip()
    for prefix in ("watcher-", "watcher_", "watcher "):
        if stripped.lower().startswith(prefix):
            return stripped[len(prefix) :]
    return stripped


def resolve_lark_cli_command(cli: str) -> list[str]:
    def command_for_path(path: Path) -> list[str]:
        if path.suffix.lower() == ".ps1":
            return ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(path)]
        return [str(path)]

    cli_path = Path(cli)
    if cli_path.exists():
        return command_for_path(cli_path)

    candidate_names = [cli, f"{cli}.cmd", f"{cli}.exe", f"{cli}.ps1"]
    for name in candidate_names:
        resolved = shutil.which(name)
        if resolved:
            return command_for_path(Path(resolved))

    appdata = os.environ.get("APPDATA")
    if appdata:
        npm_dir = Path(appdata) / "npm"
        for name in (f"{cli}.cmd", f"{cli}.exe", f"{cli}.ps1", cli):
            candidate = npm_dir / name
            if candidate.exists():
                return command_for_path(candidate)

    raise SystemExit(f"Unable to locate {cli}; install lark-cli or pass --feishu-cli <path>")


def load_feishu_mapping(
    cli: str,
    base_token: str,
    table_id: str,
    view_id: str | None,
    identity: str,
    limit: int,
    english_field: str,
    gif_field: str,
    text_field: str,
    timeout_seconds: int,
) -> tuple[dict[str, str], int]:
    command = resolve_lark_cli_command(cli) + [
        "base",
        "+record-list",
        "--base-token",
        base_token,
        "--table-id",
        table_id,
        "--as",
        identity,
        "--limit",
        str(limit),
    ]
    if view_id:
        command.extend(["--view-id", view_id])

    try:
        completed = subprocess.run(
            command,
            check=True,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=timeout_seconds if timeout_seconds > 0 else None,
        )
    except subprocess.TimeoutExpired as exc:
        raise SystemExit(
            "Timed out while reading Feishu mapping "
            f"after {timeout_seconds}s.\n"
            "VPN/DNS or Feishu authorization may be unhealthy. Run `lark-cli auth login` "
            "for manual authorization, or pass --mapping-json <file> to use a local mapping."
        ) from exc
    except subprocess.CalledProcessError as exc:
        detail = (exc.stderr or exc.stdout or "").strip()
        raise SystemExit(
            "Failed to read Feishu mapping with lark-cli.\n"
            "Run `lark-cli auth login` for manual authorization, or pass --mapping-json <file> "
            f"to use a local mapping.\n{detail}"
        ) from exc

    try:
        payload = json.loads(completed.stdout)
    except json.JSONDecodeError as exc:
        raise SystemExit(
            "lark-cli returned a non-JSON Feishu mapping response.\n"
            "Run `lark-cli auth login` for manual authorization, or pass --mapping-json <file> "
            "to use a local mapping."
        ) from exc
    if not payload.get("ok"):
        raise SystemExit(f"lark-cli record-list failed: {completed.stdout}")

    data = payload.get("data", {})
    fields = data.get("fields", [])
    rows = data.get("data", [])
    if not isinstance(fields, list) or not isinstance(rows, list):
        raise SystemExit("Unexpected lark-cli record-list response shape")

    try:
        english_index = fields.index(english_field)
        gif_index = fields.index(gif_field)
        text_index = fields.index(text_field)
    except ValueError as exc:
        raise SystemExit(
            f"Feishu table is missing one of required fields: {text_field}, {english_field}, {gif_field}"
        ) from exc

    mapping: dict[str, str] = {}
    for row in rows:
        if not isinstance(row, list):
            continue
        target = feishu_cell_text(row[english_index] if english_index < len(row) else None)
        if target is None or target.strip() == "":
            continue

        add_mapping_alias(mapping, target, target)

        text = feishu_cell_text(row[text_index] if text_index < len(row) else None)
        if text:
            add_mapping_alias(mapping, text, target)
            add_mapping_alias(mapping, strip_watcher_prefix(text), target)

        gif_value = row[gif_index] if gif_index < len(row) else None
        for file_name in feishu_file_names(gif_value):
            add_mapping_alias(mapping, file_name, target)
            add_mapping_alias(mapping, Path(file_name).stem, target)

    return mapping, len(rows)


def inspect_gif(path: Path, source_label: str) -> GifCandidate:
    width = height = frame_count = None
    delays: tuple[int | None, ...] = ()
    if Image is not None and ImageSequence is not None:
        with Image.open(path) as image:
            width, height = image.size
            frame_count = 0
            delay_values: list[int | None] = []
            for frame in ImageSequence.Iterator(image):
                if frame_count < 5:
                    delay_values.append(frame.info.get("duration", image.info.get("duration")))
                frame_count += 1
            delays = tuple(delay_values)

    return GifCandidate(
        source_label=source_label,
        path=path,
        stem=path.stem,
        size_bytes=path.stat().st_size,
        width=width,
        height=height,
        frame_count=frame_count,
        first_delays_ms=delays,
    )


def collect_gifs(source_dir: Path, staging_dir: Path) -> tuple[list[GifCandidate], list[str], dict[str, int]]:
    candidates: list[GifCandidate] = []
    unsupported_archives: list[str] = []
    stats = {
        "source_files": 0,
        "direct_gifs": 0,
        "zip_archives": 0,
        "unsupported_archive_files": 0,
    }

    for item in sorted((path for path in source_dir.rglob("*") if path.is_file()), key=lambda path: str(path).lower()):
        stats["source_files"] += 1
        suffix = item.suffix.lower()
        if suffix == ".gif":
            stats["direct_gifs"] += 1
            candidates.append(inspect_gif(item, str(item.relative_to(source_dir))))
            continue

        if suffix not in ARCHIVE_SUFFIXES:
            continue

        if suffix not in SUPPORTED_ARCHIVE_SUFFIXES:
            stats["unsupported_archive_files"] += 1
            unsupported_archives.append(str(item.relative_to(source_dir)))
            continue

        stats["zip_archives"] += 1
        extract_root = staging_dir / item.stem
        extract_root.mkdir(parents=True, exist_ok=True)
        try:
            with zipfile.ZipFile(item) as archive:
                for info in archive.infolist():
                    if info.is_dir() or not info.filename.lower().endswith(".gif"):
                        continue
                    safe_name = Path(info.filename).name
                    if not safe_name:
                        continue
                    out_path = extract_root / safe_name
                    with archive.open(info) as source, out_path.open("wb") as target:
                        shutil.copyfileobj(source, target)
                    candidates.append(inspect_gif(out_path, f"{item.relative_to(source_dir)}::{info.filename}"))
        except zipfile.BadZipFile:
            unsupported_archives.append(f"{item.relative_to(source_dir)} (bad zip)")

    return candidates, unsupported_archives, stats


def resolve_target(stem: str, explicit_mapping: dict[str, str], registered_key_map: dict[str, str]) -> str | None:
    key = normalize_key(stem)
    if key in explicit_mapping:
        return canonicalize_target(explicit_mapping[key], registered_key_map)
    if key in registered_key_map:
        return registered_key_map[key]
    if key in LEGACY_ALIASES:
        return canonicalize_target(LEGACY_ALIASES[key], registered_key_map)
    return None


def group_candidates(
    candidates: list[GifCandidate], explicit_mapping: dict[str, str], registered_types: list[str]
) -> tuple[dict[str, list[GifCandidate]], list[GifCandidate], list[tuple[GifCandidate, str]]]:
    grouped: dict[str, list[GifCandidate]] = {}
    unmapped: list[GifCandidate] = []
    unregistered_targets: list[tuple[GifCandidate, str]] = []
    registered = set(registered_types)
    registered_key_map = build_registered_key_map(registered_types)

    for candidate in candidates:
        target = resolve_target(candidate.stem, explicit_mapping, registered_key_map)
        if target is None:
            unmapped.append(candidate)
            continue
        if target not in registered:
            unregistered_targets.append((candidate, target))
            continue
        grouped.setdefault(target, []).append(candidate)
    return grouped, unmapped, unregistered_targets


def print_gif_line(prefix: str, candidate: GifCandidate) -> None:
    dim = "unknown"
    if candidate.width is not None and candidate.height is not None:
        dim = f"{candidate.width}x{candidate.height}"
    frames = "unknown" if candidate.frame_count is None else str(candidate.frame_count)
    delays = ",".join("" if delay is None else str(delay) for delay in candidate.first_delays_ms)
    print(f"{prefix}{candidate.source_label} | stem={candidate.stem} | {dim} | frames={frames} | delays=[{delays}]")


def copy_applied_assets(grouped: dict[str, list[GifCandidate]], assets_gif_dir: Path) -> list[str]:
    applied: list[str] = []
    assets_gif_dir.mkdir(parents=True, exist_ok=True)
    for target, items in sorted(grouped.items()):
        if len(items) != 1:
            continue
        source = items[0].path
        destination = assets_gif_dir / f"{target}.gif"
        shutil.copy2(source, destination)
        applied.append(f"{items[0].source_label} -> {destination}")
    return applied


def run_checked(command: list[str], cwd: Path) -> None:
    print("+ " + " ".join(command))
    subprocess.run(command, cwd=str(cwd), check=True)


def main() -> int:
    parser = argparse.ArgumentParser(description="Import WatcheRobot design animation drops into local firmware assets.")
    parser.add_argument("--repo-root", default=str(DEFAULT_REPO_ROOT))
    parser.add_argument("--design-root", default=DEFAULT_DESIGN_ROOT)
    parser.add_argument("--source-date-dir", default=None)
    parser.add_argument(
        "--design-root-timeout-seconds",
        type=int,
        default=DEFAULT_DESIGN_ROOT_TIMEOUT_SECONDS,
        help="Timeout for auto-discovering the latest YYYY.MM.DD folder under --design-root; use 0 to disable",
    )
    parser.add_argument("--mapping-json", default=None)
    parser.add_argument("--feishu-mapping", action="store_true", help="Read source-to-target mapping from Feishu table")
    parser.add_argument("--feishu-cli", default="lark-cli")
    parser.add_argument("--feishu-base-token", default=DEFAULT_FEISHU_BASE_TOKEN)
    parser.add_argument("--feishu-table-id", default=DEFAULT_FEISHU_TABLE_ID)
    parser.add_argument("--feishu-view-id", default=None, help="Optional view id; omit to read all table records")
    parser.add_argument("--feishu-as", default="bot")
    parser.add_argument("--feishu-limit", type=int, default=500)
    parser.add_argument(
        "--feishu-timeout-seconds",
        type=int,
        default=DEFAULT_FEISHU_TIMEOUT_SECONDS,
        help="Timeout for lark-cli Feishu mapping reads; use 0 to disable",
    )
    parser.add_argument("--feishu-text-field", default="文本")
    parser.add_argument("--feishu-english-field", default="对应英文")
    parser.add_argument("--feishu-gif-field", default="GIF文件")
    parser.add_argument("--write-mapping-json", default=None, help="Optional path to write the effective mapping JSON")
    parser.add_argument("--apply", action="store_true", help="Overwrite mapped assets/gif/<type>.gif files")
    parser.add_argument("--generate", action="store_true", help="Run tools/generate_anim_assets.py after apply/dry-run")
    parser.add_argument("--sync-target-root", default=None, help="Optional SD-card root such as F:\\")
    parser.add_argument("--swap", choices=["auto", "on", "off"], default="auto")
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    if not (repo_root / "tools" / "generate_anim_assets.py").is_file():
        raise SystemExit(f"Repo root does not look like firmware/s3: {repo_root}")

    if args.source_date_dir:
        source_dir = Path(args.source_date_dir).resolve()
    else:
        if not args.design_root:
            raise SystemExit("No design source was provided. Pass --source-date-dir, --design-root, or set WATCHE_DESIGN_ROOT.")
        source_dir = find_latest_date_dir(Path(args.design_root), args.design_root_timeout_seconds)

    if not source_dir.is_dir():
        raise SystemExit(f"Source date dir does not exist: {source_dir}")

    project_version = read_project_version(repo_root)
    registered_types = parse_generator_types(repo_root)
    explicit_mapping: dict[str, str] = {}
    feishu_record_count = 0
    feishu_mapping_count = 0
    if args.feishu_mapping:
        if not args.feishu_base_token or not args.feishu_table_id:
            raise SystemExit(
                "Feishu mapping requires FEISHU_BASE_TOKEN/LARK_BASE_TOKEN and "
                "FEISHU_TABLE_ID/LARK_TABLE_ID, or explicit --feishu-base-token "
                "and --feishu-table-id."
            )
        feishu_mapping, feishu_record_count = load_feishu_mapping(
            args.feishu_cli,
            args.feishu_base_token,
            args.feishu_table_id,
            args.feishu_view_id,
            args.feishu_as,
            args.feishu_limit,
            args.feishu_english_field,
            args.feishu_gif_field,
            args.feishu_text_field,
            args.feishu_timeout_seconds,
        )
        explicit_mapping.update(feishu_mapping)
        feishu_mapping_count = len(feishu_mapping)

    manual_mapping = load_mapping(Path(args.mapping_json).resolve() if args.mapping_json else None)
    explicit_mapping.update(manual_mapping)

    if args.write_mapping_json:
        mapping_path = Path(args.write_mapping_json).resolve()
        mapping_path.parent.mkdir(parents=True, exist_ok=True)
        mapping_path.write_text(json.dumps(explicit_mapping, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    assets_gif_dir = repo_root / "assets" / "gif"
    output_dir = repo_root / "release" / project_version / "sdcard" / "anim"

    if args.swap == "auto":
        use_swap = detect_lv_color_swap(repo_root)
    else:
        use_swap = args.swap == "on"

    with tempfile.TemporaryDirectory(prefix="watche_anim_import_") as temp_name:
        staging_dir = Path(temp_name)
        candidates, unsupported_archives, source_stats = collect_gifs(source_dir, staging_dir)

        grouped, unmapped, unregistered_targets = group_candidates(candidates, explicit_mapping, registered_types)
        conflicts = {target: items for target, items in grouped.items() if len(items) > 1}
        clean_grouped = {target: items for target, items in grouped.items() if len(items) == 1}
        bad_dimensions = [
            item
            for item in candidates
            if item.width is not None and item.height is not None and (item.width, item.height) != (206, 206)
        ]

        print("=== Watche design animation import report ===")
        print(f"mode: {'apply' if args.apply else 'dry-run'}")
        print(f"repo_root: {repo_root}")
        print(f"source_date_dir: {source_dir}")
        print(f"assets_gif_dir: {assets_gif_dir}")
        print(f"output_dir: {output_dir}")
        print(f"registered_types: {', '.join(registered_types)}")
        print(f"mapping_entries: {len(explicit_mapping)}")
        if args.feishu_mapping:
            print(f"feishu_records: {feishu_record_count}")
            print(f"feishu_mapping_entries: {feishu_mapping_count}")
        print(f"lv_color_16_swap: {'on' if use_swap else 'off'}")
        print(
            "source_files: "
            f"{source_stats['source_files']} "
            f"(direct_gifs={source_stats['direct_gifs']}, "
            f"zip_archives={source_stats['zip_archives']}, "
            f"unsupported_archives={source_stats['unsupported_archive_files']})"
        )
        print(f"incoming_gifs: {len(candidates)}")
        print(f"recognized_unique: {len(clean_grouped)}")
        print(f"unmapped: {len(unmapped)}")
        print(f"conflicts: {len(conflicts)}")
        print(f"unregistered_targets: {len(unregistered_targets)}")
        print(f"unsupported_archives: {len(unsupported_archives)}")
        print(f"bad_dimensions: {len(bad_dimensions)}")

        if clean_grouped:
            print("\nRecognized unique mappings:")
            for target, items in sorted(clean_grouped.items()):
                print_gif_line(f"  {target} <= ", items[0])

        if conflicts:
            print("\nConflicting mappings:")
            for target, items in sorted(conflicts.items()):
                print(f"  {target}:")
                for item in items:
                    print_gif_line("    - ", item)

        if unmapped:
            print("\nUnmapped sources:")
            for item in sorted(unmapped, key=lambda candidate: candidate.source_label):
                print_gif_line("  - ", item)

        if unregistered_targets:
            print("\nMapping targets not registered by firmware:")
            for item, target in unregistered_targets:
                print_gif_line(f"  {target} <= ", item)

        if unsupported_archives:
            print("\nUnsupported archives:")
            for archive in unsupported_archives:
                print(f"  - {archive}")

        if bad_dimensions:
            print("\nNon-206x206 GIFs:")
            for item in bad_dimensions:
                print_gif_line("  - ", item)

        if args.apply:
            if conflicts or unregistered_targets:
                raise SystemExit("Refusing to apply while conflicts or unregistered mapping targets exist")
            applied = copy_applied_assets(clean_grouped, assets_gif_dir)
            print(f"\nApplied assets: {len(applied)}")
            for line in applied:
                print(f"  - {line}")
        else:
            print("\nNo files were overwritten. Use --apply with --feishu-mapping or --mapping-json to update assets/gif.")

    if args.generate:
        command = [
            sys.executable,
            str(repo_root / "tools" / "generate_anim_assets.py"),
            "--input-dir",
            str(assets_gif_dir),
            "--output-dir",
            str(output_dir),
            "--fps",
            "10",
        ]
        if use_swap:
            command.append("--lv-color-16-swap")
        run_checked(command, repo_root)

    if args.sync_target_root:
        run_checked(
            [
                sys.executable,
                str(repo_root / "tools" / "sync_anim_sdcard.py"),
                "--source-dir",
                str(output_dir),
                "--target-root",
                args.sync_target_root,
            ],
            repo_root,
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
