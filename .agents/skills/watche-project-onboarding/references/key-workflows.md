# 关键工作流

## 常用 skill 路由

| 场景 | 优先调用 |
| --- | --- |
| 新人了解全项目 workspace、仓库边界、常用入口 | `watche-project-onboarding` |
| App 客户端启动、测试、平台运行 | 根目录 `yarn app:*` 指令，必要时进入 `WatcheRobot_app` |
| 桌面客户端开发、类型检查、构建 | 根目录 `yarn desktop:*` 指令，必要时进入 `WatcheRobot_client/Watcher Desktop App` |
| 服务端启动、测试、调试 | 根目录 `yarn server:*` 指令，必要时进入 `WatcheRobot_server` |
| ESP32-S3 构建、烧录、监控 | `watche-s3-flash-monitor` |
| ESP32-S3 构建/烧录底层排障 | `watcher-esp32s3-build-flash` |
| 直接烧录 ESP32 release ZIP | `watche-s3-release-binary-flash` |
| STM32F103 构建、定位固件、烧录 | `watcher-stm32-build-flash` |
| ESP32 + STM32 双 MCU 联调台架 | `watche-dual-mcu-bringup` |
| GIF/飞书动画表/AnimPack/SD 卡动画资源 | `watche-design-animation-import` |
| 合并前鲁棒性审查 | `embedded-pr-robustness-review` |
| 阶段性交付、中文 commit、push、PR | `stage-delivery` |

## 教学原则

- onboarding skill 负责解释什么时候使用哪个入口，不复制专项 skill 的完整流程。
- 如果新人要实际执行某个专项任务，切换到对应 skill，由对应 skill 负责细节。
- 如果新人只是了解项目，讲清楚入口、风险和验收标准即可。

## 脚本导览规则

- 新人问“有哪些脚本”时，先按目标解释脚本类别，不要全量递归扫描仓库。
- 需要找脚本时，只做定向查找，例如 workspace 脚本、App scripts、桌面端 scripts、服务端 scripts、ESP32 工程脚本、STM32 工程脚本。
- 解释脚本时必须说明：用途、输入、输出、风险、是否会修改设备或文件。
- 对会烧录、删除、覆盖、发布的脚本，要先确认新人理解影响范围。
- 新人需要学习 yarn 指令、调试脚本和 skill 路由时，读取 `debug-scripts-and-skills.md`。

## 推荐学习顺序

1. 仓库边界和提交规则。
2. 快速判断该用 yarn 指令、脚本还是 skill。
3. 新人负责方向的启动、测试、构建或烧录入口。
4. App、桌面端、服务端和固件之间的联调边界。
5. 双 MCU 联调思路。
6. 动画资源和发布二进制流程。
7. 阶段性交付和 PR 审查流程。

## 代码修改纪律

- 编写代码前先明确要验证的行为，按 TDD 思路定义最小测试或验证目标。
- 保持模块边界清晰，避免把协议、硬件驱动、业务状态机和临时调试代码耦合在一起。
- 端到端改动要分别考虑 App/桌面端 UI、服务端协议和固件行为，不要让某一端隐式依赖未记录的本地配置。
- 涉及并发、内存生命周期、协议边界、状态机、存储、OTA、看门狗、硬件资源时，合并前调用 `embedded-pr-robustness-review`。
