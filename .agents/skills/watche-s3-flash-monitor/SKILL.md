---
name: watche-s3-flash-monitor
description: WatcheRobot S3 固件的一键 ESP-IDF 烧录和串口监控流程。当用户要求烧录、刷机、flash、program、monitor 或打开 ESP32 仓库 `firmware\s3` 的串口日志时使用。指定串口时，先用 helper 清理占用进程；未指定串口时，让项目脚本按本地规则选择目标，不要写死端口。
---

# Watche S3 烧录与监控

使用项目自带脚本，不要手写一套并行烧录流程。

## 流程

1. 确认活动工作区是 `<esp32-root>\firmware\s3`，或用户明确要操作这个固件项目。
2. 查找项目入口：
   - `<esp32-root>\firmware\s3\flash-monitor.cmd`
   - `<esp32-root>\firmware\s3\tools\flash-monitor.ps1`
3. 如果用户给了串口，先运行本 skill 的清占口 helper：

   ```powershell
   powershell -ExecutionPolicy Bypass -File "<skill-dir>\scripts\close-com-port.ps1" -Port <port>
   ```

4. 端口释放后，从固件根目录运行：

   ```powershell
   cmd /c flash-monitor.cmd <port>
   ```

5. 如果用户没给串口，让项目脚本自己解析目标：

   ```powershell
   cmd /c flash-monitor.cmd
   ```

6. 如果用户要 dry run 或先看命令：

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\tools\flash-monitor.ps1 -DryRun
   ```

7. 如果用户明确只烧录已有构建产物、跳过编译，添加 `-NoBuild`：

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\tools\flash-monitor.ps1 -NoBuild
   ```

## 操作规则

- 正常执行优先用仓库 wrapper：`flash-monitor.cmd`。
- 命令 `workdir` 设置为 `<esp32-root>\firmware\s3`。
- 第一个位置参数按串口处理，例如 `COM37`。
- 指定串口时，启动烧录前必须先运行 `scripts\close-com-port.ps1 -Port <port>`。
- 清占口 helper 要识别相关 PID、停止它们，并验证端口可打开。
- 如果 helper 仍不能释放端口，停止并报告具体进程或验证失败，不要盲目重试。
- 用户说“烧录并监控”“刷机”“flash monitor”等，并且给了串口时，直接执行，不只描述命令。
- 用户没有给串口时，默认不追问端口，先让项目 wrapper 自己解析目标。
- 如果需要设备别名，当前单板场景使用 `esp32-s3`；不要默认使用多设备 lane 代号。
- 多个 COM 口并存时，优先用 `esptool chip_id` 验证哪一个是真正的 ESP32-S3，再烧录。
- 如果项目 wrapper 缺失或损坏，修复 `flash-monitor.cmd` 或 `tools\flash-monitor.ps1`，不要另造流程。

## 附带 Helper

- `scripts\close-com-port.ps1`
  - 优先用 `handle.exe` 精确查找端口占用方。
  - 如果没有 `handle.exe`，扫描 Windows 进程命令行和窗口标题，匹配目标串口和常见串口工具：`idf.py monitor`、`idf_monitor.py`、`esptool.py`、`python`、`pwsh`、`putty`、`ttermpro`、`securecrt`、`openocd`。
  - 对匹配 PID 执行 `Stop-Process -Force`。
  - 返回前验证端口可以打开。

## 预期行为

- PowerShell 脚本从 `IDF_PATH`、`build\project_description.json` 和常见 Espressif 安装路径自动找 ESP-IDF。
- 未提供端口时，项目脚本按本地检测规则选择 active target。
- 正常路径运行 `idf.py -p <port> build flash monitor`。
- 脚本会在执行前打印解析到的项目路径、IDF 路径、串口和最终 `idf.py` 命令。

## 回复格式

- 简短说明将使用哪个串口。
- 如果指定串口，说明是否清理了占用进程，或没有发现阻塞进程。
- 执行后总结烧录命令是否成功启动。
- 如果烧录前失败，说明具体失败来源：PowerShell 初始化、ESP-IDF 加载、串口访问或 `idf.py`。
