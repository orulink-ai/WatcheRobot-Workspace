# Switch Expression Minimal

This example uses the generic BLE sender from `../ble-control-minimal` to send a minimal AI status / expression payload. Firmware compatibility must still be verified per release.

## Payload

```json
{
  "type": "evt.ai.status",
  "code": 0,
  "data": {
    "status": "happy",
    "image_name": "happy",
    "detail": {
      "source": "example",
      "label": "Switch expression minimal"
    },
    "command_id": "expr-001"
  }
}
```

## Run

```powershell
python ..\ble-control-minimal\ble_control_minimal.py --name ESP_ROBOT --command ai-status --status happy --image-name happy
```

## Current Status

The desktop Creator Mode dispatch model builds `evt.ai.status` payloads for expression clips, and the server has an `evt.ai.status` handler. Hardware smoke verification is still required before this example is marked public-ready.

TODO(owner/date): Confirm which release firmware paths accept `evt.ai.status` directly over BLE versus through the desktop/server WebSocket path.
