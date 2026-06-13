# Architecture

WatcheRobot is organized as a multi-repository system with a root meta workspace.

```mermaid
flowchart LR
  User["User / Developer"]
  App["Mobile App\nReact Native"]
  Desktop["Desktop Client\nTauri + React"]
  Server["Local Server\nPython / WebSocket / AI"]
  ESP32["ESP32-S3 Firmware\nBLE / Wi-Fi / Display / Voice"]
  STM32["STM32 Firmware\nBody board / peripherals"]
  Hardware["Hardware\nServos / display / camera / audio"]

  User --> App
  User --> Desktop
  App -->|"BLE 00FF / FF01\nJSON commands"| ESP32
  Desktop -->|"BLE provisioning\ncontrol / config"| ESP32
  Desktop -->|"WebSocket / HTTP admin"| Server
  ESP32 -->|"WebSocket / media / device events"| Server
  Server -->|"TTS / control / AI status"| ESP32
  ESP32 -->|"coprocessor / UART path\nwhere applicable"| STM32
  ESP32 --> Hardware
  STM32 --> Hardware
```

## Responsibilities

| Layer | Responsibility | Repository |
| --- | --- | --- |
| Root workspace | Entry docs, scripts, submodule references, open-source governance | `.` |
| Mobile App | BLE scan/connect/control/provisioning app | `WatcheRobot_app` |
| Desktop Client | Setup, hardware connection, AI configuration, runtime UI, packaging | `WatcheRobot_client` |
| Server | ASR / LLM / TTS / OpenClaw orchestration, WebSocket and HTTP APIs | `WatcheRobot_server` |
| ESP32-S3 | Device firmware, BLE, Wi-Fi, display animations, audio, camera, OTA path | `WatcheRobot_esp32` |
| STM32 | Body-board firmware, local peripherals, protocol bring-up path | `WatcheRobot_stm32` |

## Notes

- The ESP32 firmware has a BLE JSON-over-GATT path documented in `WatcheRobot_esp32/firmware/s3/docs/BLE_GATT_PROTOCOL_BRIDGE.md`.
- The server has bilingual docs under `WatcheRobot_server/docs/`.
- STM32 is documented as a staged bring-up path and should not be described as fully complete unless verified against its current README.
