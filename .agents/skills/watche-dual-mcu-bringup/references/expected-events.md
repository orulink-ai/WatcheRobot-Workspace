# 预期事件

双串口会话完成后，需要解释日志时使用本文件。

## 日志模式前提

默认 STM32 `Debug` 固件是安静模式，可能没有 `STM32_OBS`。如果会话目标是诊断 STM32 UART2 RX、协议帧解析或 HELLO/ACK/NACK/FAULT 细节，应使用 `Engineering` preset 构建和烧录 STM32，例如给 helper 传 `-Stm32Preset Engineering`。

## 健康链路层级

- `STM32_OBS evt=boot`
  - STM32 Engineering/Stress 固件正在运行，且 `USART1` 结构化观测日志可用。
- `STM32_OBS evt=uart2_rx_arm`
  - STM32 已启用 `USART2 RX DMA + IDLE`。
- `STM32_OBS evt=uart2_rx_preview`
  - STM32 在板内 UART2 链路上看到了字节。
- `MCU_OBS evt=hello_req`
  - ESP32 协议启动流程尝试发起握手。
- `MCU_OBS evt=hello_rsp`
  - STM32 协议侧回应了握手。
- `MCU_OBS evt=baseline_restore_begin`
  - ESP32 进入握手后的 baseline restore 步骤。
- `MCU_OBS evt=ready`
  - ESP32 认为 MCU link 运行路径已经就绪。

## 有用的部分状态

- 只有 `STM32_OBS evt=stats event_count=0`
  - STM32 存活且日志可用，但 UART2 流量没有进入 RX 回调。
- 出现 `STM32_OBS evt=uart2_rx_preview`，但没有 `MCU_OBS evt=hello_rsp`
  - 字节到达了 STM32，但协议层没有产生有效响应。
- ESP32 普通文本日志显示 `MCU link not fully ready`，但没有 `MCU_OBS`
  - 应用已经运行，但抓取窗口没有观察到结构化协议事件。
- 出现 `MCU_OBS evt=hello_rsp`，但没有 `evt=ready`
  - 重点检查 baseline restore 或 ready-gating 逻辑。

## 当前测试台日志

在当前 checkout 中，查看以下目录下的最新会话日志：

```text
<esp32-root>\.codex\local\logs\<user-or-run>\stm32-uart2-bringup\esp32-s3--stm32-f103\
```

做信号汇总时使用最新的 `merged.log`；需要判断事件顺序时使用 `timeline.ndjson`。
