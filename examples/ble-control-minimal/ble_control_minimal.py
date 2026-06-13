"""Minimal BLE JSON command sender for WatcheRobot.

Requires:
    python -m pip install bleak

This script intentionally keeps UUIDs configurable so release branches can be
tested without rewriting the example.
"""

from __future__ import annotations

import argparse
import json
from typing import Any


DEFAULT_SERVICE_UUID = "000000ff-0000-1000-8000-00805f9b34fb"
DEFAULT_CHAR_UUID = "0000ff01-0000-1000-8000-00805f9b34fb"


def build_payload(args: argparse.Namespace) -> dict[str, Any]:
    if args.json:
        payload = json.loads(args.json)
        if not isinstance(payload, dict):
            raise ValueError("--json must decode to a JSON object")
        return payload
    if args.json_file:
        with open(args.json_file, "r", encoding="utf-8") as handle:
            payload = json.load(handle)
        if not isinstance(payload, dict):
            raise ValueError("--json-file must contain a JSON object")
        return payload
    if args.command == "ping":
        return {"type": "sys.ping", "data": {}}
    if args.command == "servo-x":
        return {
            "type": "ctrl.servo.angle",
            "data": {
                "x_deg": args.angle,
                "duration_ms": args.duration_ms,
                "command_id": "example-servo-x",
            },
        }
    if args.command == "servo-y":
        return {
            "type": "ctrl.servo.angle",
            "data": {
                "y_deg": args.angle,
                "duration_ms": args.duration_ms,
                "command_id": "example-servo-y",
            },
        }
    if args.command == "ai-status":
        return {
            "type": "evt.ai.status",
            "code": 0,
            "data": {
                "status": args.status,
                "image_name": args.image_name or args.status,
                "detail": {
                    "source": "example",
                    "label": "BLE minimal AI status example",
                },
                "command_id": "example-ai-status",
            },
        }
    raise ValueError(f"unsupported command: {args.command}")


async def find_device(name: str):
    from bleak import BleakScanner

    devices = await BleakScanner.discover(timeout=8.0)
    for device in devices:
        if device.name and name.lower() in device.name.lower():
            return device
    return None


async def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--name", default="ESP_ROBOT", help="BLE advertised name substring")
    parser.add_argument("--char", default=DEFAULT_CHAR_UUID, help="Command characteristic UUID")
    parser.add_argument("--command", choices=["ping", "servo-x", "servo-y", "ai-status"], default="ping")
    parser.add_argument("--angle", type=int, default=90)
    parser.add_argument("--duration-ms", type=int, default=300)
    parser.add_argument("--status", default="happy", help="AI status for --command ai-status")
    parser.add_argument("--image-name", default="", help="Optional expression image name")
    parser.add_argument("--json", default="", help="Raw JSON object to send instead of a built-in command")
    parser.add_argument("--json-file", default="", help="Path to a JSON object file to send")
    parser.add_argument("--dry-run", action="store_true", help="Print the payload without scanning or connecting")
    args = parser.parse_args()

    payload_dict = build_payload(args)
    if args.dry_run:
        print(json.dumps(payload_dict, ensure_ascii=False, separators=(",", ":")))
        return

    device = await find_device(args.name)
    if device is None:
        raise SystemExit(f"device matching {args.name!r} not found")

    from bleak import BleakClient

    payload = json.dumps(payload_dict, separators=(",", ":")).encode("utf-8")
    print(f"Connecting to {device.name} ({device.address})")

    async with BleakClient(device) as client:
        await client.write_gatt_char(args.char, payload, response=True)
        try:
            response = await client.read_gatt_char(args.char)
            print(response.decode("utf-8", errors="replace"))
        except Exception as exc:  # noqa: BLE read fallback varies by platform
            print(f"write completed; read fallback unavailable: {exc}")


if __name__ == "__main__":
    import asyncio

    asyncio.run(main())
