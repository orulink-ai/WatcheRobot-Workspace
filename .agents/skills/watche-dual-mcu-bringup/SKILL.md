---
name: watche-dual-mcu-bringup
description: 在当前项目 checkout 中构建、烧录、重启并验证 WatcheRobot ESP32 + STM32 双 MCU 联调台架。当用户用自然语言要求编译、跳过编译、烧录、跳过烧录、重启、采集 ESP32+STM32 合并串口日志，想查看 `MCU_OBS` / `STM32_OBS`，或排查 ESP32 与 STM32 之间 UART2 握手流量缺失时使用。优先使用项目设备映射、ESP32 仓库中的 `tools\stm32_bringup_session.py`、ESP32 烧录脚本和 STM32 OpenOCD 烧录。
---

# 双 MCU 联调

优先使用项目已有入口，不要手写一套并行联调流程。

## 使用场景

- 用户想同时构建或烧录 ESP32 和 STM32。
- 用户想只重启一侧或两侧，不重新烧录。
- 用户想在 `.codex/local/logs/` 下采集一次新的双串口 session。
- 用户想诊断为什么缺少 `MCU_OBS` 或 `STM32_OBS`。
- 用户想验证 ESP32 到 STM32 的 UART2 流量是否到达。

## 台架默认值

- 工作区根目录：包含 `.agents\skills`，以及 `WatcheRobot_esp32` / `WatcheRobot_stm32` 的目录。
- ESP32 仓库：默认 `<workspace-root>\WatcheRobot_esp32`，也可用 `-EspRepoRoot` 覆盖。
- STM32 仓库：默认 `<workspace-root>\WatcheRobot_stm32`，也可用 `-Stm32RepoRoot` 覆盖。
- 设备映射：默认 `<esp32-root>\.codex\local\device-map.toml`，也可用 `CODEX_DEVICE_MAP_PATH` 覆盖。
- 默认别名：`esp32-s3`、`stm32-f103`
- 默认 session feature：`stm32-uart2-bringup`
- 默认 ESP32 构建目录：`firmware\s3\build-esp32s3-local`

## 标准命令

用户要执行完整台架流程时，运行本 skill 的 helper：

```powershell
powershell -ExecutionPolicy Bypass -File "<skill-dir>\scripts\run-dual-mcu-bringup.ps1"
```

常用参数：

```powershell
powershell -ExecutionPolicy Bypass -File "<skill-dir>\scripts\run-dual-mcu-bringup.ps1" -DurationSec 30
powershell -ExecutionPolicy Bypass -File "<skill-dir>\scripts\run-dual-mcu-bringup.ps1" -SkipEsp32Build
powershell -ExecutionPolicy Bypass -File "<skill-dir>\scripts\run-dual-mcu-bringup.ps1" -SkipStm32Build -SkipStm32Flash
powershell -ExecutionPolicy Bypass -File "<skill-dir>\scripts\run-dual-mcu-bringup.ps1" -SkipEsp32Flash
powershell -ExecutionPolicy Bypass -File "<skill-dir>\scripts\run-dual-mcu-bringup.ps1" -RestartStm32 -RestartEsp32
```

## 自然语言映射

把用户表达转换为 wrapper 参数，不要要求用户自己拼开关。

- `编译` / `build`：不要添加对应 `-Skip*Build`。
- `不编译` / `跳过编译`：添加 `-SkipStm32Build` 和/或 `-SkipEsp32Build`。
- `烧录` / `flash`：不要添加对应 `-Skip*Flash`。
- `不烧录` / `跳过烧录`：添加 `-SkipStm32Flash` 和/或 `-SkipEsp32Flash`。
- `重启` / `reset` / `restart`：添加 `-RestartStm32` 和/或 `-RestartEsp32`。
- `只重启`：添加 `-SkipStm32Build -SkipEsp32Build -SkipStm32Flash -SkipEsp32Flash -RestartStm32 -RestartEsp32`；除非用户明确要抓日志，否则加 `-SkipSession`。

常见翻译：

- `只编译`：`-SkipStm32Flash -SkipEsp32Flash -SkipSession`
- `只烧录`：`-SkipStm32Build -SkipEsp32Build -SkipSession`
- `只重启`：`-SkipStm32Build -SkipEsp32Build -SkipStm32Flash -SkipEsp32Flash -RestartStm32 -RestartEsp32 -SkipSession`
- `重启两边然后抓 20 秒日志`：`-SkipStm32Build -SkipEsp32Build -SkipStm32Flash -SkipEsp32Flash -RestartStm32 -RestartEsp32 -DurationSec 20`
- `只编译 STM32，重启 ESP32`：`-SkipEsp32Build -SkipStm32Flash -SkipEsp32Flash -RestartEsp32 -SkipSession`

## 标准流程

1. 从设备映射解析 `esp32-s3` 和 `stm32-f103`。映射缺失或过期时，询问用户当前 ESP32 和 STM32 的 COM 口。
2. 用 `cmake --preset Debug` 和 `cmake --build --preset Debug` 构建 STM32。
3. 用 `idf.py -B build-esp32s3-local build` 构建 ESP32。
4. 用 OpenOCD + `interface/stlink.cfg` + `target/stm32f1x.cfg` 烧录 STM32。
5. 必要时释放 ESP32 串口，然后用 `firmware\s3\tools\flash-monitor.ps1 -NoBuild` 烧录 ESP32。
6. 只有用户明确要求重启，或采集窗口前必须重启时，才 reset STM32 或 ESP32。
7. 运行 `<esp32-root>\tools\stm32_bringup_session.py`。
8. 先看 `merged.log`；需要事件顺序时再看 `timeline.ndjson`。

## 操作规则

- 默认流程优先使用本 skill 的 helper。
- 不要在 skill 里写死串口。
- 优先从项目 device map 解析别名。
- 如果 device map 缺失、不完整或失效，问用户当前 ESP32 和 STM32 的 COM 口。
- 用户给端口后，用 `-EspPort COMx -Stm32Port COMy` 重新运行；wrapper 会保存到项目 device map，方便下次复用。
- 用户只想临时覆盖、不写配置时，加 `-NoSavePorts`。
- 不要把 session 脚本当 ESP32 reset 工具，它只采集日志。
- `-RestartEsp32` 会执行 RTS-only 硬复位，并保持 `DTR` 低电平，避免进入下载模式。
- `-RestartStm32` 通过 OpenOCD `reset run` 重启 MCU。
- 只烧 ESP32 时，兄弟 skill `watche-s3-flash-monitor` 更快。
- 如果 session 只抓到 ESP32 ROM boot 信息，读取 `references/known-failures.md`，确认工具保持 `DTR/RTS` 低电平。

## 日志解读

- session 成功但不清楚含义时，读取 `references/expected-events.md`。
- 烧录或采集失败时，读取 `references/known-failures.md`。

## 端口配置

helper 的端口解析顺序：

1. 显式参数：`-EspPort COMx`、`-Stm32Port COMy`。
2. `CODEX_DEVICE_MAP_PATH`。
3. `WatcheRobot_esp32\.codex\local\device-map.toml`。
4. 询问用户当前端口。

显式提供端口时，helper 会写入：

```text
<esp32-root>\.codex\local\device-map.toml
```

配置格式：

```toml
[devices.esp32-s3]
firmware = "s3"
port = "COM10"

[devices.stm32-f103]
firmware = "stm32"
port = "COM11"
```

如果 Windows 重新编号导致保存端口失效，再次询问用户并更新同一个文件。

## 可选端口扫描

默认不自动扫描。只有用户明确要求扫描端口时，才传 `-AutoDetectPorts`。

自动检测打分规则：

- ESP32-S3 高置信特征：`VID_303A`、`Espressif`、`ESP32`、`USB JTAG/serial`、`USB Serial/JTAG`。
- STM32 高置信特征：`VID_0483`、`STMicroelectronics`、`STLink`、`ST-Link`、`STM32 Virtual COM`。
- 共享低置信 USB-UART 特征：`CP210`、`VID_10C4`、`CH340`、`CH341`、`VID_1A86`、`USB-SERIAL`、`USB Serial`。
- 蓝牙串口和主板 `COM1/COM2` 这类 ACPI 端口要忽略或大幅降权。

只有唯一正分候选，或最高分明显领先第二候选时，才接受自动识别；否则停止并询问明确端口。

## 回复格式

- 说明使用的别名和端口。
- 说明 STM32 构建、STM32 烧录、ESP32 烧录、session 采集是否成功。
- session 结果总结 `merged.log` 中信号最高的观察，例如：
  - `STM32_OBS evt=stats event_count=0`
  - 只有 `MCU_OBS evt=hello_req`，没有 `hello_rsp`
  - 有 `hello_rsp`，但没有 `ready`
  - 只有普通文本日志，没有结构化观察事件
