# Send Motion Minimal

This example reuses the BLE control sender to send a safe servo movement.

## Run

```powershell
python ..\ble-control-minimal\ble_control_minimal.py --name ESP_ROBOT --command servo-x --angle 90 --duration-ms 300
```

## Manual Smoke Test

1. Flash a firmware build that supports JSON-over-BLE.
2. Power the device with safe servo power.
3. Run the command above.
4. Confirm the X axis moves or the firmware returns an ACK.

If the device returns `sys.nack`, inspect the reason and compare it with `docs/motion-guide.md`.
