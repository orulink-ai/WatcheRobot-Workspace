# BLE Control Minimal

This example sends a small JSON message to the current WatcheRobot BLE service.

Protocol evidence:

- Service UUID: `00FF`
- Characteristic UUID: `FF01`
- Payload: JSON object
- Source: `WatcheRobot_esp32/firmware/s3/docs/BLE_GATT_PROTOCOL_BRIDGE.md`

## Install

```powershell
python -m pip install bleak
```

## Ping

```powershell
python ble_control_minimal.py --name ESP_ROBOT --command ping
```

Dry run without BLE hardware or the `bleak` dependency:

```powershell
python ble_control_minimal.py --command ping --dry-run
```

## Servo

```powershell
python ble_control_minimal.py --name ESP_ROBOT --command servo-x --angle 90
```

## AI Status / Expression Payload

```powershell
python ble_control_minimal.py --name ESP_ROBOT --command ai-status --status happy --image-name happy
```

## Raw JSON

```powershell
python ble_control_minimal.py --name ESP_ROBOT --json '{"type":"sys.ping","data":{}}'
```

For Windows shells where inline JSON quoting is inconvenient, write a file and use:

```powershell
python ble_control_minimal.py --name ESP_ROBOT --json-file payload.json
```

## Expected Result

- `ping` should produce `sys.pong`, `PONG`, or an equivalent cached response.
- `servo-x` should move the X axis on a connected test device.
- `ai-status` should update the current status / expression only on firmware that accepts `evt.ai.status` through the selected BLE route.
- In `--dry-run` mode, the script prints the JSON payload without scanning or connecting.

Manual hardware verification is still required before marking this example public-ready.
