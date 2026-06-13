"""Minimal WatcheRobot Server scheduled-intent example.

This intentionally uses only the Python standard library so it can run in a
fresh checkout after the local server is started.
"""

from __future__ import annotations

import argparse
import json
import urllib.error
import urllib.request


def post_json(url: str, payload: dict[str, object]) -> dict[str, object]:
    data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
    request = urllib.request.Request(
        url,
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=10) as response:
        body = response.read().decode("utf-8", errors="replace")
    parsed = json.loads(body)
    if not isinstance(parsed, dict):
        raise ValueError("server response was not a JSON object")
    return parsed


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-url", default="http://127.0.0.1:8766")
    parser.add_argument("--text", default="Remind me to drink water in one minute")
    parser.add_argument("--source", default="desktop")
    parser.add_argument("--dry-run", action="store_true", help="Print the request without contacting the server")
    args = parser.parse_args()

    url = args.base_url.rstrip("/") + "/api/admin/scheduled-intents"
    payload = {"text": args.text, "source": args.source}

    if args.dry_run:
        print(json.dumps({"url": url, "payload": payload}, ensure_ascii=False, indent=2))
        return

    try:
        response = post_json(url, payload)
    except urllib.error.URLError as exc:
        raise SystemExit(f"request failed: {exc}") from exc

    print(json.dumps(response, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
