# 已知失败

构建、烧录或抓取失败时使用本文件。

## ESP32

- 会话抓取打开 ESP32 串口后，ESP32 进入 ROM download mode
  - 原因：串口打开时切换了 `DTR/RTS`。
  - 当前修复：`stm32_bringup_session.py` 打开串口时使用 `dtr=false` 和 `rts=false`。
- `-RestartEsp32` 失败并出现 `ModuleNotFoundError: No module named 'serial'`
  - 原因：当前 Python 环境没有 `pyserial`。
  - 修复：使用已经能运行 `stm32_bringup_session.py` 的同一个 Python 环境，或在当前环境安装 `pyserial`。
- `idf.py` 在旧构建目录中提示 Python 环境不匹配
  - 原因：该构建树曾用另一个 ESP-IDF Python 环境配置。
  - 当前规避：使用专门的 bring-up 构建目录 `firmware\s3\build-esp32s3-local`。
- ESP32 烧录时出现 `Could not open <port>`
  - 原因：残留的 `python`、`esptool`、monitor 或 shell 进程仍占用串口。
  - 修复：通过设备映射解析 ESP32 别名，然后运行 `<workspace-root>\.agents\skills\watche-s3-flash-monitor\scripts\close-com-port.ps1 -Port <port>`。

## STM32

- OpenOCD 报告 `libusb_open() failed with LIBUSB_ERROR_NOT_SUPPORTED`
  - 原因：ST-Link 可见，但没有绑定到兼容 WinUSB 的驱动。
  - 修复：重新安装 ST debug driver，然后再次检查 `Get-PnpDevice`。
- `Get-PnpDevice` 显示 `Problem Code 28`
  - 原因：ST-Link 驱动安装损坏。
  - 修复：修复 ST-Link 驱动，直到设备显示 `Status=OK`。
- STM32 构建在 `Core/Src/main.c` 中失败，错误为 `expected declaration or statement at end of input`
  - 原因：生成的 `while (1)` 循环缺少闭合花括号。
  - 当前测试台修复：恢复 `Core/Src/main.c` 中缺失的 `}`。

## 会话解释

- 最新会话没有 `STM32_OBS`，但有 `=== STM32 CLI Ready ===` 或 `USART2 bring-up ready`
  - 原因：STM32 可能烧录的是默认安静 `Debug` 固件。
  - 修复：如果本次需要 STM32 结构化观测，使用 `-Stm32Preset Engineering` 重新构建、烧录并采集。
- 最新会话只有 `STM32_OBS evt=stats event_count=0`
  - STM32 固件正在运行，但抓取窗口内没有 UART2 流量进入 DMA 回调。
- 最新会话只有 ESP32 普通文本日志
  - ESP32 应用正在运行，但抓取窗口中没有观察到握手事件。
- 用户要求 `只重启`，但没有采集新日志
  - 原因：`只重启` 应当默认等价于 `-SkipSession`，除非用户明确要求重启后抓日志。
