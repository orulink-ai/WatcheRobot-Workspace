# WatcheRobot S3 风险地图

审查 `firmware/s3` 或 WatcheRobot ESP32-S3 固件相关 PR 时使用本文件。

## 仓库结构

- `main/app_main.c`：启动编排、服务依赖顺序、全局恢复路径、MCU link 事件路由和安全默认值。
- `components/hal/*`：显示、音频、摄像头、按键、舵机等面向硬件的所有权。
- `components/protocols/*`：MCU link、BLE、WebSocket、发现协议、wire format 和外部输入。
- `components/services/*`：应用服务、状态缓存、事件分发、OTA、动画、摄像头、运动、电源、传感器和 LED 行为。
- `components/utils/*`：启动动画、Wi-Fi 和共享工具。
- `tools/*`：本地验证、资产流程和 gateway 工作流。

## MCU Link 与协议

针对 `components/protocols/mcu_link`：

- 审查 COBS framing、CRC 检查、帧长度边界、半帧缓存、粘包处理，以及坏字节后的解析器重同步。
- 检查 `seq` 和 `ref_seq` 在 ACK、motion_done、传感器事件、hello、重试、超时和重复帧中的行为。
- 确认启动、链路丢失、hello 协商或恢复期间，状态转换不会死锁。
- 涉及解析器、帧格式、CRC、COBS 或状态机变更时，尽量要求 host tests。

针对 WebSocket、BLE、发现协议和 camera gateway 代码：

- 把所有远端 payload 都视为不可信。
- 检查消息大小限制、二进制/文本路由、重连行为、队列压力和日志频率。
- 在慢网络、断连、stop/start 竞争下验证媒体流相关变更。

## 服务层

针对 `components/services/*`：

- 判断共享状态前，先识别服务 owner task 或回调上下文。
- 检查 latest-frame/latest-state 缓存语义，尤其是覆盖行为和 stale-state 有效标志。
- 确认事件处理器能容忍重复、缺失、延迟和乱序事件。
- 检查服务初始化顺序，以及 HAL/protocol 依赖失败时的行为。
- 对 motion、power、sensor 和 LED 服务，确认 MCU link 不可用时命令会安全失败。

## HAL 与硬件

针对 `components/hal/*`：

- 检查 pin、bus、DMA、timer、LEDC、I2S、I2C、SPI、UART 和 camera/display 的所有权。
- 确认 HAL API 定义了调用方的缓冲区所有权、阻塞行为和任务安全性。
- 检查 init/deinit 幂等性、部分失败清理和外设缺失行为。
- 修改 pin、bus config、clocking、DMA buffer、电源/复位或外设生命周期时，要求硬件冒烟证据。

## 动画、显示、LVGL、SD 与 PSRAM

针对 `components/services/anim_service`、`components/hal/hal_display`、LVGL、SD 和生成动画资产：

- 检查 LVGL 线程亲和性，以及非 UI 任务中的显示调用。
- 验证 PSRAM 分配大小、帧尺寸、RGB565 字节序、cache 生命周期，以及 SD/asset 加载失败时的降级。
- 检查 SPI、SD、display、camera 争用，以及可能饿死 watchdog 敏感任务的长操作。
- 确认动画切换、warm preview、hot cache 和 stop/start 路径不会使用已释放缓冲区。

## 启动与恢复

针对 `main/app_main.c`：

- 审查服务启动顺序、安全默认 baseline、watchdog 影响，以及 MCU link、display、Wi-Fi、camera、SD 或 audio 初始化失败时的恢复行为。
- 检查全局回调不会在启动顺序无法保证时假设服务已经初始化。
- 确认降级模式在日志中可观测，并且不会反复重启。

## 推荐验证

- 一般固件变更：`idf.py build`。
- MCU link 核心变更：运行 `components/protocols/mcu_link/test_support/host` 下的 host CMake/CTest，再跑固件构建。
- 面向硬件的变更：固件构建，加 flash/monitor 启动日志，并用相关 WatcheRobot skill 做定向冒烟。
- Camera/WebSocket 变更：影响 gateway 路径时运行 `tools/ws_camera_gateway_test.py`。
- 动画资产或运行时变更：资产生成检查，加设备显示冒烟和 SD/PSRAM 日志。
