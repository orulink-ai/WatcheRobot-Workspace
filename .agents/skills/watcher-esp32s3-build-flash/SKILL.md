---
name: watcher-esp32s3-build-flash
description: ESP32-S3 源码构建/烧录的底层排障指南。常规一键烧录和监控优先使用 `watche-s3-flash-monitor`；只有当用户需要手动分析 ESP-IDF 环境、构建产物、`idf.py`/`esptool` 参数、端口绑定缓存、依赖解析、源码构建失败或烧录失败细节时，才使用本 skill。
---

# ESP32-S3 构建与烧录

## 概览

用于 WatcheRobot ESP32 侧固件的底层排障。ESP-IDF 工程位于 `<project-root>\firmware\s3`，目标芯片是 `esp32s3`，构建会生成 bootloader、partition table、app binary、语音模型和 SPIFFS/storage 等多镜像烧录集合。

常规“烧一下 ESP32”“刷机并看日志”“清理串口再烧录”不要优先使用本 skill；使用 `watche-s3-flash-monitor`。本 skill 保留为底层手册，处理 wrapper 失败、构建失败、端口识别异常、依赖异常和需要手动 `esptool` 的情况。

除非用户明确要求，不改固件代码。构建或烧录前，说明将要执行的动作；涉及硬件烧录时保持可确认、可回退。

## 路径变量

运行时发现路径，不写死机器路径：

- `<project-root>`：本机 `WatcheRobot_esp32` 仓库根目录。
- `<project-dir>`：`<project-root>\firmware\s3`。
- `<build-dir>`：`<project-dir>\build`。
- `<esp-idf-root>`：ESP-IDF 安装目录。
- `<export-script>`：ESP-IDF PowerShell 引导脚本，通常是 `<esp-idf-root>\export.ps1`。
- `<PORT>`：ESP32-S3 实际串口，例如 `COM5`。
- `<cache-file>`：本机环境缓存，`$env:USERPROFILE\.codex\watcher-esp32s3-build-flash.local.json`。

## 环境缓存

为提速可以使用缓存，但使用前必须验证路径仍然有效。缓存只保存本机事实，不提交进仓库。

推荐字段：

```json
{
  "project_root": "<project-root>",
  "project_dir": "<project-root>\\firmware\\s3",
  "build_dir": "<project-root>\\firmware\\s3\\build",
  "esp_idf_root": "<esp-idf-root>",
  "export_script": "<esp-idf-root>\\export.ps1",
  "last_good_port": "<PORT>",
  "last_good_mac": "<MAC>",
  "port_binding_status": "valid"
}
```

每次运行：

1. 如果 `<cache-file>` 存在，先读取。
2. 只有 `project_dir\CMakeLists.txt` 存在时才复用 `project_dir`。
3. 只有 `export_script` 存在时才复用；如果当前 shell 已有 `idf.py --version`，可跳过加载。
4. `last_good_port` 只能当优先候选。烧录前必须用 `esptool chip_id` 验证。
5. 缓存值验证失败就忽略并重新发现。
6. 构建或烧录成功后，更新已验证路径、端口和 MAC。

## 项目布局

- 仓库根：`<project-root>`
- ESP-IDF 工程：`<project-root>\firmware\s3`
- 工程入口：`<project-root>\firmware\s3\CMakeLists.txt`
- App 入口：`<project-root>\firmware\s3\main\app_main.c`
- 分区表：`<project-root>\firmware\s3\partitions.csv`
- 构建输出：`<project-root>\firmware\s3\build`
- Release 资源：`<project-root>\firmware\s3\release`
- Windows helper：`<project-root>\firmware\s3\flash-monitor.cmd`

## 定位项目

先确定 `<project-root>`。如果缓存里的 `project_dir` 有效，从它反推 `<project-root>`。否则：

1. 当前目录可能在仓库内时运行：

   ```powershell
   git rev-parse --show-toplevel
   ```

2. 只有输出目录包含 `<project-root>\firmware\s3\CMakeLists.txt` 时才接受。
3. 如果 Git 不可用或检查失败，从当前目录向上找 `firmware\s3\CMakeLists.txt`。
4. 仍找不到时，询问用户本机 `WatcheRobot_esp32` 路径。
5. 路径可能包含空格，命令中用引号：

   ```powershell
   cd "<project-root>\firmware\s3"
   ```

## ESP-IDF 环境

使用 ESP-IDF v5.2.1 或兼容的 5.2.x。按以下顺序加载：

1. 如果 `idf.py --version` 已可用，使用当前 shell。
2. 如果 `$env:IDF_PATH` 存在且有 `export.ps1`，dot-source 它。
3. 检查常见 Windows 安装路径：

   ```text
   C:\Espressif\frameworks\esp-idf-v5.2.1\export.ps1
   C:\Espressif\frameworks\esp-idf\export.ps1
   ```

4. 仍找不到时，询问用户 ESP-IDF 安装路径。

Windows 加载示例：

```powershell
$IsWindows = $true
. "<export-script>"
```

如果依赖解析失败，或 `IDF_COMPONENT_REGISTRY_URL` 指向 `file:///C:/Espressif/registry;default`，先清掉当前 shell 的错误覆盖：

```powershell
Remove-Item Env:\IDF_COMPONENT_REGISTRY_URL -ErrorAction SilentlyContinue
Remove-Item Env:\IDF_COMPONENT_STORAGE_URL -ErrorAction SilentlyContinue
```

永久清理用户级覆盖：

```powershell
[Environment]::SetEnvironmentVariable("IDF_COMPONENT_REGISTRY_URL", $null, "User")
[Environment]::SetEnvironmentVariable("IDF_COMPONENT_STORAGE_URL", $null, "User")
```

## 构建流程

默认输出保持简洁：报告执行命令并总结成功或关键失败。普通构建不要打开串口 monitor。

在 `<project-dir>` 下运行：

```powershell
cd "<project-root>\firmware\s3"
idf.py set-target esp32s3
idf.py build
```

`idf.py set-target esp32s3` 会配置芯片目标，可能重生成 `sdkconfig`。干净工程或切换目标后通常需要执行一次。

构建成功会输出 `Project build complete. To flash, run:`。预期产物：

```text
<build-dir>\bootloader\bootloader.bin
<build-dir>\partition_table\partition-table.bin
<build-dir>\WatcheRobot-S3.bin
<build-dir>\srmodels\srmodels.bin
<build-dir>\storage.bin
<build-dir>\flash_args
```

## 烧录流程

默认只烧录，不打开 monitor。只有用户要求日志、启动验证、debug 或 `monitor` 时才监控。

Windows 候选串口：

```powershell
[System.IO.Ports.SerialPort]::GetPortNames()
```

端口选择规则：

1. 如果缓存的 `last_good_port` 当前存在，先测试：

   ```powershell
   python -m esptool --chip esp32s3 -p <PORT> -b 115200 chip_id
   ```

2. 只有报告 `Chip is ESP32-S3` 时才使用缓存端口。如果缓存了 `last_good_mac`，还要要求 MAC 匹配。
3. 缓存端口不存在、连不上、不是 ESP32-S3、MAC 不同，或用户说不是目标端口时，取消绑定：清空 `last_good_port`、`last_good_mac`，设置 `port_binding_status=invalid`。
4. 取消绑定后再扫描所有 COM 口的 `esptool chip_id`。
5. 只发现一个 ESP32-S3 时使用它并更新缓存。
6. 发现多个 ESP32-S3 时，优先匹配缓存 MAC；否则询问用户按端口或 MAC 选择。
7. 不要假设 `COM1` 是 ESP32-S3。除非它通过 `esptool chip_id`，否则低优先级。
8. 自动检测不清楚时，让用户拔插设备，对比前后端口列表。

首选烧录命令：

```powershell
idf.py -p <PORT> flash
```

用户要求 live log 或 debug 时：

```powershell
idf.py -p <PORT> flash monitor
```

项目 helper 可构建、烧录并跳过 monitor：

```powershell
.\flash-monitor.cmd <PORT> -NoMonitor
```

用户明确要交互式 monitor 时：

```powershell
.\flash-monitor.cmd <PORT>
```

用户明确要求直接烧 bin 时，才用手写 `esptool`：

```powershell
python -m esptool --chip esp32s3 -b 460800 --before default_reset --after hard_reset write_flash --flash_mode dio --flash_size 16MB --flash_freq 80m 0x0 "<build-dir>\bootloader\bootloader.bin" 0x8000 "<build-dir>\partition_table\partition-table.bin" 0x10000 "<build-dir>\WatcheRobot-S3.bin" 0x410000 "<build-dir>\srmodels\srmodels.bin" 0x460000 "<build-dir>\storage.bin"
```

或在 `<build-dir>` 下：

```powershell
cd "<build-dir>"
python -m esptool --chip esp32s3 -b 460800 --before default_reset --after hard_reset write_flash "@flash_args"
```

烧录成功后，用通过 `esptool chip_id` 的端口和 MAC 更新缓存。

## 端口占用

典型错误：`Access is denied`、`PermissionError`、`could not open port COMx`、`SerialException`。

端口被占用时：

1. 不要立刻切到其他缓存端口，也不要强杀用户程序。
2. 检查可能残留的烧录或 monitor 进程：

   ```powershell
   Get-Process | Where-Object {
     $_.ProcessName -match 'python|idf|esptool|openocd'
   }
   ```

3. 只自动停止明显属于当前烧录流程或残留 ESP-IDF/esptool monitor 的进程。
4. 不自动关闭 VS Code、Arduino IDE、PlatformIO、PuTTY、MobaXterm 或通用串口工具；需要用户关闭或明确同意结束具体进程。
5. 如果有 Sysinternals `handle.exe`，可先用它定位精确占用进程：

   ```powershell
   handle.exe <PORT>
   ```

6. 释放端口后，重新对 `<PORT>` 执行 `esptool chip_id`。只有仍验证为目标 ESP32-S3/MAC 时才烧录。
7. 缓存端口释放后仍被占用或验证失败时，将绑定标记为 invalid，再扫描其他端口。
8. 用户明确要求切换端口时，先验证新端口是 ESP32-S3，再烧录或更新缓存。

## 输出策略

- 默认不打印串口 monitor 大段日志。
- discovery、build、flash 输出简洁状态。
- 成功时总结项目路径、ESP-IDF 来源、已验证端口/MAC 和烧录结果。
- 失败时给关键错误和失败命令上下文。
- 长命令产生大日志时，只总结重要行。

## 排障

- 依赖错误提到 `espressif/led_strip (2.5.4) is forbidden`：清理 `IDF_COMPONENT_REGISTRY_URL` 和 `IDF_COMPONENT_STORAGE_URL` 后重跑 `idf.py build`。
- `idf.py` 找不到：按“ESP-IDF 环境”章节找并加载 `<export-script>`。
- 烧录连接失败：确认 COM 口、数据线，必要时按住 BOOT 开始烧录，写入开始后松开。
- 端口占用或 access denied：只自动释放安全残留进程；关闭用户程序前先询问；然后重新验证端口。
- 缓存端口不是目标：取消缓存绑定，扫描所有 COM，仅切换到验证为 ESP32-S3 的端口。
- 多个 COM 口：对候选运行 `esptool chip_id`；仍不清楚时，让用户拔插设备对比新增端口。
- 多个 ESP32-S3：优先缓存 MAC；否则问用户选端口或 MAC。
- 项目路径失败：确认 `<project-root>\firmware\s3\CMakeLists.txt` 存在。
- 早先依赖错误后构建又成功：说明 `managed_components`、`dependencies.lock`、`build` 可能已有解析缓存，Ninja 可以继续。
- 完全刷新依赖时才用 `idf.py fullclean`；不要删除用户工作或无关文件。
