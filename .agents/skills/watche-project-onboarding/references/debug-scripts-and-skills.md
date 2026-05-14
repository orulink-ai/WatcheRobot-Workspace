# 调试脚本和 skills 快速上手

## 教学目标

新人不只要知道项目有哪些仓库，还要能快速找到“现在这个问题应该用哪个脚本、哪个 yarn 指令、哪个 skill”。本文件用于 onboarding 中的调试工具导览。

## 快速定位原则

- 先判断任务属于 meta repo、App 客户端、桌面客户端、服务端、ESP32 仓库还是 STM32 仓库。
- 再判断目标是启动、测试、构建、烧录、监控、资源生成、日志观察、发布，还是阶段性交付。
- 优先使用项目已有 skill，因为 skill 通常包含路径识别、风险提示和项目约定。
- 只有当 skill 不覆盖或新人需要理解底层机制时，再讲具体脚本和 yarn 指令。

## yarn 指令教学方式

讲 yarn 指令时不要只列命令。每个命令都要说明：

- 所在仓库或目录。
- 解决什么问题。
- 是否会生成文件。
- 是否会连接硬件、烧录设备、覆盖资源或触发发布。
- 成功时应该看到什么结果。
- 失败时下一步该调用哪个 skill 或查看哪个日志。

## yarn 指令收集规则

当新人问“有哪些 yarn 命令”或“这个项目怎么调试”时：

- 优先查看当前任务相关仓库的 `package.json` scripts。
- 不要全量递归扫描所有目录。
- 把高频且项目特有的 yarn 指令沉淀到本文件。
- 对通用命令只解释一次，不要把 npm/yarn 基础教程写进 onboarding。

## 高频 yarn 指令清单

| 仓库/目录 | 指令 | 用途 | 风险/副作用 | 适合新人阶段 |
| --- | --- | --- | --- | --- |
| 根仓库 | `yarn status` | 查看 workspace 和所有子仓库 Git 状态 | 无写入 | 入门 |
| 根仓库 | `yarn pull` | 拉取 workspace 和子仓库；dirty 仓库只 fetch | 会访问远端；不覆盖 dirty working tree | 入门 |
| 根仓库 | `yarn skills:validate` | 校验项目 skills 格式 | 无写入 | 入门 |
| 根仓库 | `yarn app:start` | 启动 React Native Metro | 占用本地端口 | App 入门 |
| 根仓库 | `yarn app:android` | 运行 Android App | 会连接模拟器或设备并安装 App | App 实操 |
| 根仓库 | `yarn app:test` | 运行 App Jest 测试 | 无设备写入 | App 实操 |
| 根仓库 | `yarn desktop:dev` | 启动 Tauri 桌面端开发模式 | 会启动本地开发服务和桌面窗口 | 桌面端实操 |
| 根仓库 | `yarn desktop:typecheck` | 运行桌面端 TypeScript 检查 | 无写入 | 桌面端实操 |
| 根仓库 | `yarn server` | 用当前 Python 环境启动服务端 | 占用服务端端口，依赖本地配置 | 服务端实操 |
| 根仓库 | `yarn server:start:checked` | 使用服务端自带 Windows 检查脚本启动 | 可能创建/检查本地配置，依赖 conda | 服务端实操 |
| 根仓库 | `yarn server:test` | 运行服务端 pytest 测试 | 无设备写入 | 服务端实操 |
| 根仓库 | `yarn esp32 COM23` | 构建并烧录 ESP32-S3 固件 | 会改写目标设备固件 | 固件实操 |
| 根仓库 | `yarn esp32:monitor COM23` | 查看 ESP32-S3 日志 | 连接串口，占用端口 | 固件实操 |
| 根仓库 | `yarn stm32` | 构建并烧录 STM32 Debug 固件 | 会改写目标设备固件 | 固件实操 |
| 根仓库 | `yarn stm32:monitor COM18` | 查看 STM32 日志 | 连接串口，占用端口 | 固件实操 |

## skill 路由教学

新人遇到问题时，先让他用自然语言描述目标，再映射到 skill：

| 新人目标 | 推荐 skill |
| --- | --- |
| 我要理解整个 WatcheRobot workspace | `watche-project-onboarding` |
| 我要启动或测试 App/桌面端/服务端 | 根目录 `yarn app:*` / `yarn desktop:*` / `yarn server:*` |
| 我要烧录并看 ESP32 串口 | `watche-s3-flash-monitor` |
| 我要手动排查 ESP-IDF 构建或烧录细节 | `watcher-esp32s3-build-flash` |
| 我要直接烧录发布包 | `watche-s3-release-binary-flash` |
| 我要编译或烧录 STM32 | `watcher-stm32-build-flash` |
| 我要验证 ESP32 和 STM32 是否配合正常 | `watche-dual-mcu-bringup` |
| 我要导入或刷新动画资源 | `watche-design-animation-import` |
| 我要准备一次交付、提交、push 或 PR | `stage-delivery` |
| 我要合并前检查鲁棒性风险 | `embedded-pr-robustness-review` |

## 脚本安全边界

- 烧录类脚本会改变设备固件，执行前必须确认目标设备和固件来源。
- 资源生成类脚本可能覆盖产物，执行前确认输入源和输出目录。
- 发布类脚本可能影响交付物，执行前确认版本、目标仓库和产物路径。
- 清理类脚本可能删除中间产物，执行前确认不会删除新人本地未提交内容。

## 需要沉淀的问题

以下问题一旦新人问到，通常应该补充到本文件：

- 某个 yarn 指令在哪个目录运行。
- 某个脚本会不会烧录设备或覆盖文件。
- 某个调试目标应该用脚本还是 skill。
- 某个常见失败现象应该看哪个日志。
- 新人不知道如何从自然语言问题映射到工具入口。
