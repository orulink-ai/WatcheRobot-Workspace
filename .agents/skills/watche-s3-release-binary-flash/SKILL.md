---
name: watche-s3-release-binary-flash
description: 不编译源码，直接烧录 WatcheRobot ESP32-S3 打包好的 release 二进制 ZIP。当用户要求烧录二进制版本、发布包、release ZIP、打包固件、指定版本包，或给出类似 37 这种表示 COM37 的串口号时使用。
---

# Watche S3 Release 二进制烧录

这个 skill 用于烧录 `WatcheRobot_esp32` 仓库里的 Windows release ZIP，不走源码构建流程。

## 适用范围

- 用于 `firmware\s3\release\...\WatcheRobot-S3-...-esp32s3.zip` 发布包。
- 适用于“烧录二进制版本”“烧录发布包”“刷 release 包”“flash binary”“flash release zip”“烧录 37”等请求。
- 裸数字端口如 `37` 视为 `COM37`。
- 除非用户明确要求从源码构建，否则不要使用 `idf.py build`、`flash-monitor.cmd` 或源码烧录流程。

## 首选入口

从 skill 运行 wrapper：

```powershell
powershell -ExecutionPolicy Bypass -File "<skill-dir>\scripts\invoke-release-flash.ps1" -Port 37
```

wrapper 会解析仓库根目录，把 `37` 规范化为 `COM37`，并调用：

```powershell
tools\flash-release.cmd flash --port COM37
```

只有用户要求看烧录后日志时才加 `-Monitor`：

```powershell
powershell -ExecutionPolicy Bypass -File "<skill-dir>\scripts\invoke-release-flash.ps1" -Port COM37 -Monitor -MonitorSeconds 20
```

用户指定 ZIP 或版本时使用 `-Zip`：

```powershell
powershell -ExecutionPolicy Bypass -File "<skill-dir>\scripts\invoke-release-flash.ps1" -Port COM37 -Zip "<repo-root>\firmware\s3\release\v0.2.6\WatcheRobot-S3-v0.2.6-esp32s3.zip"
```

## 流程

1. 定位 repo root。优先用 `git rev-parse --show-toplevel`；否则向上查找同时包含 `tools\flash-release.cmd` 和 `firmware\s3\release` 的目录。
2. 用户给 `37` 时规范化为 `COM37`，给 `COM37` 时保持不变。
3. 用户指定 release 版本时选择对应 `WatcheRobot-S3-<version>-esp32s3.zip`；否则让 `tools.win_flasher` 选择扫描到的最新 release ZIP。
4. 如果没给端口，运行 wrapper 的 `-ListPorts`。若只有一个设备就使用；若多个端口，问用户要烧录哪个 COM。
5. 对明确烧录请求直接执行 wrapper。只有用户要求 dry run 或解释时才只描述命令。
6. 如果依赖缺失 `esptool`、`serial` 或 `rich`，用 `-InstallDeps` 重跑，或执行：

   ```powershell
   python -m pip install -r tools\win_flasher\requirements.txt
   ```

7. 成功后总结所用 ZIP/版本、COM 口和是否运行 monitor。

## 直接仓库命令

只有 wrapper 不适用时才直接使用：

```powershell
cd "<repo-root>"
tools\flash-release.cmd flash --port COM37
```

列出 release 包：

```powershell
cd "<repo-root>"
python -m tools.win_flasher list-releases
```

列出端口：

```powershell
cd "<repo-root>"
python -m tools.win_flasher list-ports
```

烧录指定 ZIP：

```powershell
cd "<repo-root>"
tools\flash-release.cmd flash --zip "<zip-path>" --port COM37
```

## 失败处理

- `未安装 esptool`：安装 `tools\win_flasher\requirements.txt` 后重跑同一命令。
- `检测到多个串口`：列出端口并询问具体 COM，除非用户已经给出端口。
- `未扫描到 release ZIP`：列出 `firmware\s3\release`，如果没有 `*-esp32s3.zip`，请用户给 ZIP 路径。
- `could not open port`、`Access is denied`、`SerialException`：报告端口被占用或不可用；未经用户确认不要切换到其他端口。
- 任何 `esptool` 非零退出都表示烧录未完成；总结失败命令上下文和最后的关键错误行。

## 回复格式

- 执行前说明规范化后的端口，以及使用最新 release 还是指定 ZIP。
- 执行中保持输出简洁，不复述大段 `esptool` 日志，除非错误需要。
- 执行后报告成功，或说明具体失败来源：依赖安装、release ZIP 解析、串口访问或 `esptool` 烧录。
