# AGENTS.md

每次提交 commit 时，使用规范、详细的中文描述。

每次编写代码时，注意 TDD 测试驱动、代码规范和解耦合。

## Workspace 规则

- 当前目录是 meta repo，只管理 `.agents/`、`.codex/` 模板、workspace 脚本、文档和子仓库引用。
- 子仓库采用 submodule/gitlink 方式纳入根仓库；不要把子仓库源码展开提交到根仓库。
- App 客户端代码在 `WatcheRobot_app` 仓库中单独提交。
- 桌面客户端代码在 `WatcheRobot_client` 仓库中单独提交。
- 服务端代码在 `WatcheRobot_server` 仓库中单独提交。
- ESP32 代码在 `WatcheRobot_esp32` 仓库中单独提交。
- STM32 代码在 `WatcheRobot_stm32` 仓库中单独提交。
- 不要把个人端口、个人路径、临时日志或本机缓存提交到 Git。
- 涉及多个子仓库的功能，分别在对应仓库提交，并在 commit body 中互相说明配套提交关系。
