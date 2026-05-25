# WatcheRobot-Workspace

这个仓库是 WatcheRobot 项目的 workspace/meta repo，用来统一管理项目级配置、Codex skills、workspace 脚本、文档和多个产品子仓库的入口。

根仓库不直接混合各子项目源码提交。App、桌面端、服务端、ESP32 固件、STM32 固件都按独立 Git 仓库管理；根仓库负责记录它们的位置、常用命令和协作边界。

当前采用“submodule/gitlink 组合式 monorepo”组织方式：根仓库统一入口和项目级自动化，各产品子仓库保留独立历史、分支和发布节奏。

## 目录结构

```text
WatcheRobot-Workspace/
  .agents/
    skills/                 # 项目级 Codex skills
    skillhub/               # 可视化 SkillHub 页面
  .codex/
    device-map.example.toml
    local/                  # 本机端口和临时配置，不提交
  scripts/                  # workspace 级脚本，子仓库清单在 workspace-repos.ps1
  WatcheRobot_app/          # React Native App 客户端，独立 Git 仓库
  WatcheRobot_client/       # Tauri 桌面客户端，独立 Git 仓库
  WatcheRobot_server/       # Python 服务端，独立 Git 仓库
  WatcheRobot_esp32/        # ESP32-S3 固件，独立 Git 仓库
  WatcheRobot_stm32/        # STM32F103 固件，独立 Git 仓库
```

## 子仓库

| 模块 | 路径 | 说明 | 默认分支 |
| --- | --- | --- | --- |
| Workspace | `.` | 项目级配置、脚本、文档和 submodule/gitlink 管理 | 当前分支 |
| Mobile App | `WatcheRobot_app` | React Native 蓝牙控制 App | `dev` |
| Desktop App | `WatcheRobot_client` | Tauri 桌面客户端 | `main` |
| Server | `WatcheRobot_server` | Python WebSocket/AI 服务端 | `main` |
| ESP32 Firmware | `WatcheRobot_esp32` | ESP32-S3 固件 | `main` |
| STM32 Firmware | `WatcheRobot_stm32` | STM32F103 固件 | `dev` |

## 提交边界

- Workspace 脚本、`.agents/`、`.codex/` 模板、根 README 和子仓库引用：在根仓库提交。
- App 客户端改动：进入 `WatcheRobot_app` 仓库单独提交。
- 桌面客户端改动：进入 `WatcheRobot_client` 仓库单独提交。
- 服务端改动：进入 `WatcheRobot_server` 仓库单独提交。
- ESP32 固件改动：进入 `WatcheRobot_esp32` 仓库单独提交。
- STM32 固件改动：进入 `WatcheRobot_stm32` 仓库单独提交。
- 涉及多个子仓库的配套功能，分别在对应仓库提交，并在 commit body 中说明配套提交关系。
- 每个人自己的 COM 口、盘符、临时日志、本机缓存和私有环境变量不要提交。

## 初始化

克隆根仓库后初始化所有子仓库：

```powershell
git submodule update --init --recursive
```

如果已经手动拉取了子仓库，可以先检查状态。提交根仓库整理改动时，需要把 `.gitmodules` 和对应子仓库 gitlink 一起纳入根仓库提交：

```powershell
yarn status
```

## 更新代码

日常同步整个 workspace 时，优先使用项目脚本：

```powershell
yarn pull
```

`yarn pull` 会依次更新根仓库和 `WatcheRobot_app`、`WatcheRobot_client`、`WatcheRobot_server`、`WatcheRobot_esp32`、`WatcheRobot_stm32` 等子仓库。某个仓库存在未提交改动时，脚本只会执行 fetch，不会直接 pull，避免覆盖本地修改。

只需要拉取远端信息、不合并代码时使用：

```powershell
yarn pull:fetch
```

注意：在根目录直接执行 `git pull` 只会更新 workspace/meta repo 本身，以及根仓库记录的子仓库 gitlink 指针；它不会自动把每个子仓库源码都更新到远端最新分支。

如果需要让子仓库 checkout 到根仓库当前记录的固定提交，使用：

```powershell
git submodule update --init --recursive
```

如果需要让每个子仓库跟随各自配置分支更新到最新提交，使用 `yarn pull`。

## 常用命令

查看所有仓库状态：

```powershell
yarn status
```

拉取根仓库和子仓库。遇到 dirty working tree 时只会 fetch，避免覆盖本地改动：

```powershell
yarn pull
```

只 fetch 不 pull：

```powershell
yarn pull:fetch
```

校验项目 skills：

```powershell
yarn skills:validate
```

列出本机串口：

```powershell
yarn ports
```

## App 客户端

```powershell
yarn app:start
yarn app:android
yarn app:ios
yarn app:lint
yarn app:test
```

## 桌面客户端

```powershell
yarn desktop:dev
yarn desktop:typecheck
yarn desktop:build
```

## 服务端

直接用当前 Python 环境启动：

```powershell
yarn server
```

使用服务端仓库自带的 Windows 检查脚本启动：

```powershell
yarn server:start:checked
```

运行服务端测试：

```powershell
yarn server:test
```

## 固件

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

### SD 卡动画资源

把最新生成的 ESP32-S3 AnimPack 资源同步到已插入电脑的 SD 卡：

```powershell
yarn sd
```

脚本会自动选择唯一已挂载的可移动盘，并把最新 `WatcheRobot_esp32/firmware/s3/release/*/sdcard/anim` 镜像到 `<sd-root>/anim`。如果电脑上有多个可移动盘，需要显式指定目标盘：

```powershell
yarn sd F:
```

同步前只做检查、不写入文件：

```powershell
yarn sd:check
```

需要先重新生成 AnimPack 再同步时：

```powershell
yarn sd:generate F:
```

详细说明见 [docs/sd-card-assets.md](docs/sd-card-assets.md)。

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
