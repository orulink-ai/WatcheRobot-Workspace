# WatcheRobot

WatcheRobot 是一个开源桌面具身智能机器人项目，覆盖移动 App、桌面端、本地 AI / Server 运行时、ESP32-S3 固件、STM32 固件、BLE 配网、表情动画、动作控制和创作者示例。

> 当前状态：EVT / 开源准备中。公开范围、License、社区入口和最终 Demo 素材仍在确认中，见 [Open Questions](docs/open-questions.md)。

## Demo

PLACEHOLDER：公开发布前，需要在这里放入已确认可公开使用的产品图、GIF 或视频链接。

当前可供内部复核的本地素材入口：

- 桌面机器人资源：`WatcheRobot_client/Watcher Desktop App/src/design-system/resources/robot/`
- App 截图：`WatcheRobot_app/docs/images/`
- 动画资源和 AnimPack 文档：`WatcheRobot_esp32/firmware/s3/assets/gif/`

以上素材在完成产品、品牌和授权确认前，不应直接作为公开 README 素材发布。

## 适合谁

- 想快速理解 WatcheRobot 架构、运行 App / 桌面端的开发者。
- 想编译、烧录和调试 ESP32-S3 / STM32 固件的硬件玩家。
- 想接入 ASR、LLM、TTS、OpenClaw 或二次开发 AI 工作流的 AI 应用开发者。
- 想体验桌面机器人、表情、动作和基础连接流程的早期用户。

## 可以做什么

- 通过 React Native App 使用 BLE 控制 WatcheRobot。
- 使用 Tauri 桌面端完成设置、AI 配置、硬件连接和控制。
- 运行本地 Server，处理 ASR、LLM、TTS、OpenClaw、提醒和硬件 / WebSocket 编排。
- 构建、烧录和检查 ESP32-S3 固件，覆盖 BLE、Wi-Fi、摄像头、语音、显示、动画、OTA 和舵机集成。
- 构建和测试 STM32 固件，用于机身板和本地外设 bring-up。
- 创建或改造表情、动作指令和最小 BLE 示例。

## 从这里开始

| 需求 | 入口 |
| --- | --- |
| 了解整个项目 | [开发者文档](docs/README.md) / [中文开发者文档](docs/README.zh-CN.md) |
| 最快跑通 | [Quick Start](docs/quick-start.md) |
| 看架构和数据流 | [Architecture](docs/architecture.md) |
| 检查工具版本 | [Toolchain Matrix](docs/toolchain-matrix.md) |
| 了解开源范围 | [Open Source Scope](docs/open-source-scope.md) |
| 查看硬件 / 结构件资源 | [Hardware and Structure Map](docs/hardware-structure-map.md) |
| 查看未决问题 | [Open Questions](docs/open-questions.md) |
| 查看当前准备度 | [Open Source Readiness Final](docs/open-source-readiness-final.md) / [中文摘要](docs/open-source-readiness-final.zh-CN.md) |
| 验证公开发布准备度 | [Public Launch Validation Runbook](docs/public-launch-validation.md) |

## 仓库结构

根仓库是 meta workspace，只管理项目级文档、脚本、模板和子仓库引用。产品源码仍在独立子仓库 / gitlink 中维护。

| 模块 | 路径 | 职责 | 默认分支 | 是否需要配套使用 |
| --- | --- | --- | --- | --- |
| Workspace | `.` | 项目级文档、脚本、模板和子仓库引用 | 当前分支 | 是，作为公开入口和编排层 |
| Mobile App | `WatcheRobot_app` | React Native BLE 控制 App | `dev` | 移动端 BLE 流程需要 |
| Desktop App | `WatcheRobot_client` | Tauri 桌面端和打包工作区 | `main` | 主要设置 / 控制入口 |
| Server | `WatcheRobot_server` | Python WebSocket / AI 编排服务 | `main` | 本地 AI 和桌面运行时需要 |
| ESP32 Firmware | `WatcheRobot_esp32` | ESP32-S3 固件 | `main` | 设备固件需要 |
| STM32 Firmware | `WatcheRobot_stm32` | STM32F103 固件 | `dev` | 机身板 / 协处理路径需要 |

## 快速克隆

```powershell
git clone <repo-url>
cd WatcheRobot-Workspace
git submodule update --init --recursive
yarn status
```

完整步骤见 [docs/quick-start.md](docs/quick-start.md)。

## 常用命令

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

设备相关 COM 口应放在 `.codex/local/device-map.toml`，不要提交到 Git。

## 核心开发入口

| 主题 | 入口 |
| --- | --- |
| App | [WatcheRobot_app/README.md](WatcheRobot_app/README.md) |
| 桌面端 | [WatcheRobot_client/README.md](WatcheRobot_client/README.md) |
| Server | [WatcheRobot_server/README.md](WatcheRobot_server/README.md) |
| ESP32 固件 | [WatcheRobot_esp32/README.md](WatcheRobot_esp32/README.md) |
| STM32 固件 | [WatcheRobot_stm32/README.md](WatcheRobot_stm32/README.md) |
| BLE / Wi-Fi 配网 | [Provisioning](docs/provisioning.md) |
| 动作 | [Motion Guide](docs/motion-guide.md) |
| 表情 | [Expression Guide](docs/expression-guide.md) |
| AI 接入 | [AI Integration](docs/ai-integration.md) |
| 硬件和结构件开放范围 | [Open Source Scope](docs/open-source-scope.md) |
| Demo 素材审核清单 | [Demo Asset Checklist](docs/demo-asset-checklist.md) |
| 示例 | [examples/README.md](examples/README.md) |

## 开源和社区

| 主题 | 入口 |
| --- | --- |
| License 决策 | [LICENSE-TBD.md](LICENSE-TBD.md) |
| 贡献指南 | [CONTRIBUTING.md](CONTRIBUTING.md) |
| 行为准则 | [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) |
| 安全说明 | [SECURITY.md](SECURITY.md) |
| 维护者 | [Maintainers](docs/maintainers.md) |
| 分支策略 | [Branch Policy](docs/branch-policy.md) |
| 发布策略 | [Release Policy](docs/release-policy.md) |
| GitHub Labels | [GitHub Labels](docs/github-labels.md) |
| GitHub 设置清单 | [GitHub Settings Checklist](docs/github-settings-checklist.md) |
| 社区启动计划 | [Community Launch Plan](docs/community-launch-plan.md) |
| Good First Issues | [Good First Issues](docs/good-first-issues.md) |
| Showcase | [Showcase](docs/showcase.md) |

社区入口尚未最终确认。在确认前，公开反馈先使用 GitHub Issues；最终官方渠道记录在 [docs/open-questions.md](docs/open-questions.md)。

## 贡献边界

- 根仓库只提交 workspace 文档、脚本、`.agents/`、`.codex/` 模板和子仓库引用。
- App 代码在 `WatcheRobot_app` 中单独提交。
- 桌面端代码在 `WatcheRobot_client` 中单独提交。
- Server 代码在 `WatcheRobot_server` 中单独提交。
- ESP32 固件在 `WatcheRobot_esp32` 中单独提交。
- STM32 固件在 `WatcheRobot_stm32` 中单独提交。
- 跨仓库工作需要在各自仓库分别提交，并在 commit body 中互相说明配套关系。

除非目标仓库另有要求，提交信息应使用规范、详细的中文描述。
