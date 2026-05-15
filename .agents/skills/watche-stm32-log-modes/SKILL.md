---
name: watche-stm32-log-modes
description: 管理 WatcheRobot STM32F103 固件的串口日志模式。当用户要求减少 STM32 串口刷屏、切换安静/工程/压测日志、查看或恢复 `STM32_OBS`、判断 USART1 输出是否必要，或排查普通 Debug 固件为什么没有结构化观测日志时使用。
---

# STM32 日志模式

## 使用场景

使用本 skill 的情况：

- 用户反馈 STM32 侧 USART1 日志刷屏，影响手工调试。
- 用户需要在普通调试、协议工程观测和压测之间选择固件构建模式。
- 用户想看 `STM32_OBS`、`MCU_OBS`、USART2 RX DMA/IDLE 或协议握手细节。
- 用户问某类 STM32 输出是否需要保留、是否可以关闭。
- 双 MCU bring-up 会话缺少 `STM32_OBS`，需要判断是固件模式选择问题还是链路问题。

不要在以下情况使用：

- 只烧录 STM32 固件，不涉及日志策略时，优先使用 `watcher-stm32-build-flash`。
- 同时构建、烧录、重启、采集 ESP32 + STM32 日志时，优先使用 `watche-dual-mcu-bringup`，并按本 skill 选择 STM32 preset。

## 模式定义

- `Debug`：默认日常调试模式。保留启动 banner、CLI 输出和关键错误；关闭高频 `STM32_OBS`、`servo_apply`、`touch_event` 自动观测和 `POWER5V SERVO PROBE`。
- `Engineering`：工程观测模式。定义 `WATCHER_ENGINEERING_LOGS=1`，打开完整 `STM32_OBS`，用于协议联调、UART2 bring-up、HELLO/ACK/NACK/FAULT 排查。
- `Stress`：压测模式。定义 `WATCHER_STRESS_BUILD=1`，保留压测模拟器和压力统计；不要作为日常固件。
- `Release`：正式构建模式。禁止开启 `WATCHER_ENGINEERING_LOGS` 和 `WATCHER_STRESS_BUILD`。

## 关键开关

在 `WatcheRobot_stm32\User\Config\app_config.h` 中确认：

- `APP_COPROC_OBS_LOG_ENABLE`：完整协处理器观测日志，默认只由 `WATCHER_ENGINEERING_LOGS` 或 `WATCHER_STRESS_BUILD` 打开。
- `APP_COPROC_SERVO_APPLY_LOG_ENABLE`：ESP32 下发舵机动作后的 `servo_apply` 输出，默认跟随观测日志。
- `APP_COPROC_TOUCH_EVENT_LOG_ENABLE`：观测关闭时是否仍单独打印 `touch_event`，默认关闭。
- `APP_COPROC_ERROR_LOG_ENABLE`：USART2 UART error、RX DMA rearm failed、RX queue overflow 这类关键错误，默认保留。
- `APP_POWER5V_SERVO_PROBE_ENABLE`：POWER 5V 上电后驱动舵机探针，默认关闭；只在硬件 bring-up 明确需要时打开。

## 执行流程

1. 确认用户目标是“减少噪声”还是“增强观测”。
2. 在 `WatcheRobot_stm32` 仓库检查当前开关和 CMake preset：
   - `rg -n "WATCHER_ENGINEERING_LOGS|APP_COPROC_OBS_LOG_ENABLE|APP_COPROC_TOUCH_EVENT_LOG_ENABLE|APP_POWER5V_SERVO_PROBE_ENABLE" CMakeLists.txt CMakePresets.json User\Config\app_config.h`
3. 如果用户要日常手工调试，使用 `Debug`：
   - `cmake --preset Debug`
   - `cmake --build --preset Debug`
4. 如果用户要 `STM32_OBS` 或协议观测，使用 `Engineering`：
   - `cmake --preset Engineering`
   - `cmake --build --preset Engineering`
5. 如果通过双 MCU helper 采集并需要 STM32 结构化观测，传入：
   - `-Stm32Preset Engineering`
6. 如果用户反馈仍然刷屏，先按输出前缀归因：
   - `STM32_OBS`：检查是否误用 `Engineering` 或 `Stress` 固件。
   - `MCU_OBS`：这是 ESP32 侧结构化日志，应到 ESP32 侧处理。
   - `========== POWER5V SERVO PROBE ==========`：检查 `APP_POWER5V_SERVO_PROBE_ENABLE`。
   - CLI 表格输出：通常是用户输入命令触发，不属于自动刷屏。
7. 修改开关后至少验证：
   - `cmake --build --preset Debug`
   - `cmake --build --preset Engineering`
   - `ctest --preset HostDebug`

## 交付标准

完成时应说明：

- 当前选择的 STM32 日志模式。
- 会保留哪些 USART1 输出、关闭哪些自动输出。
- 如果需要 `STM32_OBS`，使用哪个 preset 或 helper 参数。
- 已执行的构建/测试命令，以及是否存在与本次变更无关的 warning。
