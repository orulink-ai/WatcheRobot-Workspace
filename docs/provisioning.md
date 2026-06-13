# BLE and Wi-Fi Provisioning

## Protocol Source of Truth

- BLE bridge: `WatcheRobot_esp32/firmware/s3/docs/BLE_GATT_PROTOCOL_BRIDGE.md`
- App BLE module: `WatcheRobot_app/src/modules/bluetooth/README.md`
- Desktop hardware flow: `WatcheRobot_client/Watcher Desktop App/docs/`

## Current BLE Carrier

| Item | Value |
| --- | --- |
| Service UUID | `00FF` |
| Characteristic UUID | `FF01` |
| Properties | `READ`, `WRITE`, `NOTIFY` |
| Recommended MTU | `247` |
| Payload | JSON object over one characteristic |

## Key Message Types

| Message | Purpose |
| --- | --- |
| `sys.ping` | connection probe |
| `ctrl.servo.angle` | single-axis servo control |
| `ctrl.motion.jog` | jog-style motion control |
| `ctrl.motion.stop` | stop motion |
| `evt.ai.status` | AI / behavior status downlink |
| `ctrl.robot.state.set` | set robot state |
| `cfg.wifi.set` | send Wi-Fi SSID/password |
| `cfg.wifi.get` | read Wi-Fi status |
| `cfg.wifi.clear` | clear stored Wi-Fi |

## Ready State

Device UI text is documented by the ESP32 BLE bridge:

- `Ready!`: cloud session is available.
- `BLE Ready`: BLE local control is available.
- `BLE Ready but no WiFi`: BLE is connected but Wi-Fi is not configured.

## Acceptance Checklist

- [ ] Desktop can scan for WatcheRobot BLE devices.
- [ ] Desktop can send Wi-Fi credentials over BLE.
- [ ] Device reports or displays a ready state after provisioning.
- [ ] Desktop blocks progression until Wi-Fi send result is known.
- [ ] Previously provisioned device can be recognized after restart.
- [ ] Failure paths document timeout, offline device, and invalid password behavior.

TODO(owner/date): Confirm the final public copy for desktop auto-recognition and failure recovery timing.
