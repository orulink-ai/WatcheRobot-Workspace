# WatcheRobot Examples

These examples are intentionally small. They are meant to help outside developers understand the protocol before reading the full App/Desktop/Firmware code.

| Example | Purpose | Status |
| --- | --- | --- |
| `ble-control-minimal` | Connect to BLE `00FF / FF01`, send `sys.ping` or a servo command | Local dry-run passes, requires hardware smoke test |
| `send-motion-minimal` | Send a minimal motion / servo command | Draft, requires hardware smoke test |
| `switch-expression-minimal` | Switch a robot expression / AI status | Local payload dry-run passes through `ble-control-minimal`, requires firmware route compatibility check |
| `ai-reminder-minimal` | Exercise the local server scheduled-intent path | Local dry-run passes, can be run once server is started |
| `creator-template-minimal` | Starting structure for creator examples | Draft |

## Test Rule

Every example must include:

- dependencies
- command line
- expected output
- failure handling
- manual smoke test

Run local example checks:

```powershell
powershell -ExecutionPolicy Bypass -File ..\scripts\test-open-source-examples.ps1
```

Do not claim an example is fully verified until it has been tested on hardware.
