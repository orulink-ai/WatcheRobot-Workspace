# 新人 FAQ

## 当前目录为什么不是固件源码仓库？

当前目录是 meta repo，用来管理项目级模板、Codex skill、workspace 脚本和文档。ESP32 和 STM32 固件分别在 `WatcheRobot_esp32` 与 `WatcheRobot_stm32` 独立仓库中修改和提交。

## 我应该在哪个仓库提交？

修改 ESP32 固件就在 `WatcheRobot_esp32` 提交。修改 STM32 固件就在 `WatcheRobot_stm32` 提交。修改 onboarding、自动化 skill、workspace 文档时才在 meta repo 提交。

## 同一个功能同时改了 ESP32 和 STM32 怎么办？

分别在两个仓库提交。commit body 里说明另一侧配套提交关系、协议或行为依赖，避免只看一侧时误解改动完整性。

## 我要烧录 ESP32，用哪个入口？

常规构建、烧录、监控使用 `watche-s3-flash-monitor`。如果已有 release ZIP 且不需要编译源码，使用 `watche-s3-release-binary-flash`。底层 ESP-IDF 排障再使用 `watcher-esp32s3-build-flash`。

## 我要烧录 STM32，用哪个入口？

使用 `watcher-stm32-build-flash`。它负责识别 STM32 工程、构建固件、定位产物并烧录。

## 双 MCU 联调从哪里开始？

使用 `watche-dual-mcu-bringup`。它适合 ESP32 + STM32 台架联调，关注构建、烧录、重启、串口观察和跨 MCU 行为验证。

## 我怎么知道该用 yarn 指令、脚本还是 skill？

先用自然语言说清楚目标。如果目标是项目已有的构建、烧录、监控、联调、动画导入、发布或阶段性交付，优先使用对应 skill。如果目标是理解某个前端/工具链脚本或运行仓库内已有任务，再查看相关目录的 `package.json` scripts 或 workspace 脚本。不要在不理解副作用的情况下运行会烧录、覆盖、清理或发布的脚本。

## 没有硬件还能完成 onboarding 吗？

可以。选择只读导览路径，重点理解仓库边界、关键工作流、风险点和后续实操入口。涉及烧录或设备状态的步骤不要假装完成。

## 新人问的问题会自动写进 SOP 吗？

不会无条件写入。Agent 会判断问题是否高复用、是否阻塞项目工作、是否属于 WatcheRobot 特有约定、是否现有资料缺失。满足沉淀条件时直接更新本 skill 或 references，并在报告中说明原因。

## 哪些问题不会沉淀？

个人路径、个人串口号、一次性日志、未确认猜测、通用工具教程和敏感信息不会沉淀。需要负责人确认的内容记录到 `pending-review.md`，不能写成确定规则。
