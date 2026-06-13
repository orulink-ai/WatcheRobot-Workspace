# Toolchain Matrix

This matrix is compiled from current repository files and README evidence. If a version is not confirmed, it is marked as TBD.

| Area | Tool | Version / Requirement | Evidence |
| --- | --- | --- | --- |
| Root workspace | Node package runner | Yarn / npm available | `package.json` scripts |
| App | Node.js | `>= 22.11.0` | `WatcheRobot_app/README.md` |
| App | React Native | `0.84.1` | `WatcheRobot_app/README.md` |
| App | Android Studio / Xcode | Required for platform builds | `WatcheRobot_app/README.md` |
| Desktop | Node.js / npm | TBD from desktop package files | `WatcheRobot_client/README.md` |
| Desktop | Tauri | Tauri 2 | `WatcheRobot_client/README.md` |
| Desktop | Rust | Required by Tauri, exact version TBD | Desktop docs |
| Server | Python | Conda environment, Python version from `environment.yml` | `WatcheRobot_server/README.md` |
| ESP32 | ESP-IDF | `v5.2.1` | `WatcheRobot_esp32/README.md` |
| ESP32 | Python | `3.10+` for tools | `WatcheRobot_esp32/docs/getting-started.md` |
| STM32 | STM32 toolchain | CMake / CubeMX project skeleton, exact public baseline TBD | `WatcheRobot_stm32/README.md` |

TODO(owner/date): Fill exact desktop Node/Rust and STM32 toolchain versions after verifying the intended public support matrix.
