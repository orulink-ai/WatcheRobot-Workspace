# Expression Guide

## Current Sources

- ESP32 animation service and AnimPack docs:
  - `WatcheRobot_esp32/firmware/s3/docs/GIF_ANIMPACK_TOOLCHAIN.md`
  - `WatcheRobot_esp32/firmware/s3/assets/gif/README.md`
  - `WatcheRobot_esp32/firmware/s3/components/services/anim_service/README.md`

## Supported Source Names

The AnimPack toolchain documents canonical GIF names such as:

- `boot`
- `happy`
- `error`
- `bluetooth`
- `speaking`
- `listening`
- `processing`
- `standby`
- `thinking`
- `custom1`
- `custom2`
- `custom3`

Consult the ESP32 AnimPack documentation for the current complete list.

## Minimal Expression Command

The desktop Creator Mode dispatch model builds `evt.ai.status` payloads for expression clips. For a minimal creator-facing expression/status switch, use this payload shape where the current route accepts AI status events:

```json
{
  "type": "evt.ai.status",
  "code": 0,
  "data": {
    "status": "happy",
    "image_name": "happy",
    "detail": {
      "source": "example",
      "label": "Expression guide example"
    },
    "command_id": "expr-001"
  }
}
```

If firmware support differs for a release, update this guide and the example together. Do not document a new command as supported until it is confirmed in code or hardware smoke testing.

## Minimal Expression Example

See `examples/switch-expression-minimal`.
