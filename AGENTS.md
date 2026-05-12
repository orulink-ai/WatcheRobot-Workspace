# AGENTS.md

每次提交 commit 时，使用规范、详细的中文描述。

每次编写代码时，注意 TDD 测试驱动、代码规范和解耦合。

## Workspace 规则

- 当前目录是 meta repo，只管理 `.agents/`、`.codex/` 模板、workspace 脚本和文档。
- ESP32 代码在 `WatcheRobot_esp32` 仓库中单独提交。
- STM32 代码在 `WatcheRobot_stm32` 仓库中单独提交。
- 不要把个人端口、个人路径、临时日志或本机缓存提交到 Git。
- 涉及两个固件仓库的功能，分别在两个仓库提交，并在 commit body 中互相说明配套提交关系。
