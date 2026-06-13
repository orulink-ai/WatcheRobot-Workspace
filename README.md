# WatcheRobot

[中文说明](README.zh-CN.md)

WatcheRobot is an open-source desktop embodied AI robot project. It brings together a mobile app, desktop client, local AI/server runtime, ESP32-S3 firmware, STM32 firmware, BLE provisioning, animated expressions, motion control, and creator-facing examples.

> Status: EVT / open-source preparation. Public scope, license, community entrance, and final demo assets are being confirmed. See [Open Questions](docs/open-questions.md).

## Demo

PLACEHOLDER(product/design owner): Add the verified product photo, GIF, or video link here before public launch.

Existing local assets that may be reviewed for public use:

- Desktop robot resources: `WatcheRobot_client/Watcher Desktop App/src/design-system/resources/robot/`
- App screenshots: `WatcheRobot_app/docs/images/`
- Animation assets and AnimPack docs: `WatcheRobot_esp32/firmware/s3/assets/gif/`

Do not publish unapproved assets from these folders until they are checked for product, brand, and license readiness.

## What You Can Build

- For developers: understand the full workspace, run the App / desktop client, and contribute docs or code.
- For hardware builders: build, flash, and debug ESP32-S3 / STM32 firmware and hardware bring-up paths.
- For AI application developers: connect ASR, LLM, TTS, OpenClaw, and local automation workflows.
- For early users: try the desktop robot, expressions, motion, and basic connection flows.

## Main Capabilities

- Control WatcheRobot from a React Native mobile app over BLE.
- Use the Tauri desktop client as the main setup, AI configuration, hardware connection, and control surface.
- Run the local server for ASR, LLM, TTS, OpenClaw execution, reminders, and hardware/websocket orchestration.
- Build, flash, and inspect ESP32-S3 firmware for BLE, Wi-Fi, camera, voice, display, animation, OTA, and servo integration.
- Build and test STM32 firmware for the body board and local peripheral bring-up path.
- Create or adapt expressions, motion commands, and minimal BLE examples.

## Start Here

| Need | Entry |
| --- | --- |
| Understand the whole project | [Developer Docs](docs/README.md) |
| Run the fastest path | [Quick Start](docs/quick-start.md) |
| See architecture and data flow | [Architecture](docs/architecture.md) |
| Check tool versions | [Toolchain Matrix](docs/toolchain-matrix.md) |
| Understand open-source scope | [Open Source Scope](docs/open-source-scope.md) |
| Review hardware / structure resources | [Hardware and Structure Map](docs/hardware-structure-map.md) |
| Track open decisions | [Open Questions](docs/open-questions.md) |
| Review readiness status | [Open Source Readiness Final](docs/open-source-readiness-final.md) / [Chinese summary](docs/open-source-readiness-final.zh-CN.md) |
| Review readiness baseline | [Readiness Baseline](docs/open-source-readiness-baseline.md) |
| Validate launch readiness | [Public Launch Validation Runbook](docs/public-launch-validation.md) |

## Repository Map

This root repository is a meta workspace. Product source code remains in independent submodules / gitlinks.

| Module | Path | Role | Default branch | Use together? |
| --- | --- | --- | --- | --- |
| Workspace | `.` | Project-level docs, scripts, templates, and submodule references | current branch | Yes, as the public entry and orchestration layer |
| Mobile App | `WatcheRobot_app` | React Native BLE control app | `dev` | Needed for mobile BLE workflows |
| Desktop App | `WatcheRobot_client` | Tauri desktop client and packaged desktop workspace | `main` | Main setup/control surface |
| Server | `WatcheRobot_server` | Python WebSocket / AI orchestration server | `main` | Needed for local AI and desktop runtime flows |
| ESP32 Firmware | `WatcheRobot_esp32` | ESP32-S3 firmware | `main` | Needed for device firmware |
| STM32 Firmware | `WatcheRobot_stm32` | STM32F103 firmware | `dev` | Needed for body-board / coprocessor path |

## Quick Clone

```powershell
git clone <repo-url>
cd WatcheRobot-Workspace
git submodule update --init --recursive
yarn status
```

For full setup, use [docs/quick-start.md](docs/quick-start.md).

## Common Commands

```powershell
yarn status
yarn pull
yarn app:start
yarn app:android
yarn desktop:dev
yarn server:start:checked
yarn esp32:build
yarn stm32
```

Device-specific COM ports should stay in `.codex/local/device-map.toml` and must not be committed.

## Core Development Paths

| Topic | Entry |
| --- | --- |
| Mobile app | [WatcheRobot_app/README.md](WatcheRobot_app/README.md) |
| Desktop app | [WatcheRobot_client/README.md](WatcheRobot_client/README.md) |
| Server | [WatcheRobot_server/README.md](WatcheRobot_server/README.md) |
| ESP32 firmware | [WatcheRobot_esp32/README.md](WatcheRobot_esp32/README.md) |
| STM32 firmware | [WatcheRobot_stm32/README.md](WatcheRobot_stm32/README.md) |
| BLE / Wi-Fi provisioning | [Provisioning](docs/provisioning.md) |
| Motion guide | [Motion Guide](docs/motion-guide.md) |
| Expression guide | [Expression Guide](docs/expression-guide.md) |
| AI integration | [AI Integration](docs/ai-integration.md) |
| Hardware and structure scope | [Open Source Scope](docs/open-source-scope.md) |
| Demo asset approval checklist | [Demo Asset Checklist](docs/demo-asset-checklist.md) |
| Examples | [examples/README.md](examples/README.md) |

## Open Source and Community

| Topic | Entry |
| --- | --- |
| License decision | [LICENSE-TBD.md](LICENSE-TBD.md) |
| Contributing | [CONTRIBUTING.md](CONTRIBUTING.md) |
| Code of Conduct | [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) |
| Security | [SECURITY.md](SECURITY.md) |
| Maintainers | [Maintainers](docs/maintainers.md) |
| Branch policy | [Branch Policy](docs/branch-policy.md) |
| Release policy | [Release Policy](docs/release-policy.md) |
| GitHub labels | [GitHub Labels](docs/github-labels.md) |
| GitHub settings checklist | [GitHub Settings Checklist](docs/github-settings-checklist.md) |
| Community launch plan | [Community Launch Plan](docs/community-launch-plan.md) |
| Good first issues | [Good First Issues](docs/good-first-issues.md) |
| Showcase | [Showcase](docs/showcase.md) |

Community entrance is not confirmed yet. Until then, use GitHub Issues for public feedback and track the final official channel in [docs/open-questions.md](docs/open-questions.md).

## Contribution Boundaries

- Root workspace docs, scripts, `.agents/`, `.codex/` templates, and submodule references are committed in this repository.
- App changes are committed inside `WatcheRobot_app`.
- Desktop changes are committed inside `WatcheRobot_client`.
- Server changes are committed inside `WatcheRobot_server`.
- ESP32 firmware changes are committed inside `WatcheRobot_esp32`.
- STM32 firmware changes are committed inside `WatcheRobot_stm32`.
- Cross-repository work must be committed separately in each repository and cross-referenced in commit bodies.

All commits should use detailed, standard Chinese descriptions unless the receiving repository explicitly requires another format.
