# Motion Guide

## Current Sources

- BLE servo command: `ctrl.servo.angle`
- App protocol builder: `WatcheRobot_app/src/modules/bluetooth/protocol/bleProtocol.ts`
- ESP32 BLE bridge: `WatcheRobot_esp32/firmware/s3/docs/BLE_GATT_PROTOCOL_BRIDGE.md`
- STM32 staged state: `WatcheRobot_stm32/README.md`

## Minimal BLE Servo Command

```json
{
  "type": "ctrl.servo.angle",
  "data": {
    "x_deg": 90,
    "duration_ms": 300,
    "command_id": "servo-001"
  }
}
```

Rules from the current protocol:

- Use exactly one of `x_deg` or `y_deg`.
- Degree range is `0..180`.
- `duration_ms` range is `0..5000`.
- `90` is the neutral logical position for the current mounting.

## Minimal Motion Example

See `examples/send-motion-minimal`.

## Public Documentation Gaps

- Motion file naming and action-file format still need final public documentation.
- STM32 motion coverage must be described according to the current STM32 README, not assumed complete.
