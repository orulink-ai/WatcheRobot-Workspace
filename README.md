# WatcheRobot Firmware Workspace

这个目录是 WatcheRobot 固件开发的 workspace/meta repo，用来统一管理项目级配置、Codex skills、SkillHub 和多仓库协作脚本。

## 目录结构

```text
watcheRobot_Firmware/
  .agents/
    skills/       # 项目级 Codex skills
    skillhub/     # 可视化 SkillHub 页面
  .codex/
    device-map.example.toml
    local/        # 本机端口和临时配置，不提交
  scripts/
    status-all.ps1
    validate-skills.ps1
    pull-all.ps1
  WatcheRobot_esp32/  # ESP32 独立 Git 仓库
  WatcheRobot_stm32/  # STM32 独立 Git 仓库
```

## 提交边界

- ESP32 源码改动：进入 `WatcheRobot_esp32` 仓库单独提交。
- STM32 源码改动：进入 `WatcheRobot_stm32` 仓库单独提交。
- Skills、SkillHub、workspace 脚本和配置模板：进入本 meta repo 提交。
- 每个人自己的 COM 口、盘符、临时日志和本机缓存：放在 `.codex/local/`，不要提交。

## 常用命令

查看三个仓库状态：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\status-all.ps1
```

校验项目 skills：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-skills.ps1
```

拉取 meta repo 和两个子仓库：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\pull-all.ps1
```

列出本机串口：

```powershell
yarn ports
```

构建并烧录 STM32 Debug 固件：

```powershell
yarn stm32
```

查看 STM32 本地 CLI / USART1 日志：

```powershell
yarn stm32:monitor COM18
```

构建并烧录 ESP32-S3 固件：

```powershell
yarn esp32 COM23
```

查看 ESP32-S3 日志。默认使用 `idf.py monitor --force-color`，会按 ESP-IDF 日志等级显示颜色：

```powershell
yarn esp32:monitor COM23
```

如果只需要普通串口直读，可以使用 raw 模式：

```powershell
yarn esp32:monitor COM23 -Raw
```

配置 `.codex/local/device-map.toml` 后，`yarn stm32:monitor`、`yarn esp32` 和 `yarn esp32:monitor` 可以省略 COM 口。

打开 SkillHub：

```text
.agents\skillhub\index.html
```

## 设备映射

复制 `.codex/device-map.example.toml` 到 `.codex/local/device-map.toml`，按本机实际端口填写：

```toml
[devices.esp32-s3]
firmware = "s3"
port = "COM23"

[devices.stm32-f103]
firmware = "stm32"
port = "COM18"
```

如果 Windows 重新编号串口，只改 `.codex/local/device-map.toml`。
