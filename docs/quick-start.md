# Quick Start

This quick start is a navigation path for external developers. It does not replace the detailed subrepository READMEs.

## 1. Clone the Workspace

```powershell
git clone <repo-url>
cd WatcheRobot-Workspace
git submodule update --init --recursive
yarn status
```

Expected result:

- Root workspace is checked out.
- `WatcheRobot_app`, `WatcheRobot_client`, `WatcheRobot_server`, `WatcheRobot_esp32`, and `WatcheRobot_stm32` are present.
- `yarn status` lists each repository.

## 2. Desktop Client

```powershell
yarn desktop:dev
```

Detailed entry:

- `WatcheRobot_client/README.md`
- `WatcheRobot_client/Watcher Desktop App/README.md`

If first-run AI, OpenClaw, ASR, TTS, or hardware configuration is not ready, follow the desktop docs and record missing setup in `docs/open-questions.md` only if it is a public documentation gap.

## 3. Server

```powershell
yarn server:start:checked
```

Detailed entry:

- `WatcheRobot_server/README.md`
- `WatcheRobot_server/docs/README.md`

Default development ports are documented in the server README. Real API keys must not be committed.

## 4. Mobile App

```powershell
yarn app:start
yarn app:android
```

Detailed entry:

- `WatcheRobot_app/README.md`
- `WatcheRobot_app/src/modules/bluetooth/README.md`

## 5. ESP32-S3 Firmware

```powershell
yarn esp32:build
```

Detailed entry:

- `WatcheRobot_esp32/README.md`
- `WatcheRobot_esp32/docs/getting-started.md`

Flashing requires a real COM port. Put local port mappings in `.codex/local/device-map.toml`.

## 6. STM32 Firmware

```powershell
yarn stm32
```

Detailed entry:

- `WatcheRobot_stm32/README.md`
- `WatcheRobot_stm32/Documents/STM32_v2文档入口.md`

The STM32 repository currently documents staged bring-up status. Do not assume full protocol coverage beyond its README.

## 7. Minimal Examples

Start with:

- `examples/ble-control-minimal`
- `examples/send-motion-minimal`
- `examples/switch-expression-minimal`
- `examples/creator-template-minimal`
