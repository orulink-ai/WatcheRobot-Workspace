# Contributing to WatcheRobot

Thanks for helping improve WatcheRobot. This workspace uses multiple repositories, so the first contribution step is choosing the correct place to change.

## Choose the Right Repository

| Change type | Repository |
| --- | --- |
| Workspace docs, scripts, `.agents/`, `.codex`, submodule references | Root workspace |
| Mobile app | `WatcheRobot_app` |
| Desktop app | `WatcheRobot_client` |
| Server / AI runtime | `WatcheRobot_server` |
| ESP32-S3 firmware | `WatcheRobot_esp32` |
| STM32 firmware | `WatcheRobot_stm32` |

Cross-repository changes must be split into separate commits in each repository. Mention the paired commits in each commit body.

## Before You Open a PR

1. Read the relevant README and docs entry from `docs/README.md`.
2. Keep the change focused on one behavior or documentation topic.
3. Run the smallest relevant check:
   - root workspace: `yarn status`
   - app: `yarn app:lint` / `yarn app:test`
   - desktop: `yarn desktop:typecheck`
   - server: `yarn server:test`
   - ESP32: firmware build or documented smoke test
   - STM32: documented build / host test where available
4. Do not commit personal ports, local paths, logs, caches, API keys, signing secrets, or private certificates.

## Commit Style

Use standard, detailed Chinese commit messages. Include:

- what changed
- why it changed
- how it was verified
- cross-repository relationship, if any

Example:

```text
docs: 补充开源入口与 examples 验收说明

- 增加 docs/README.md 作为开发者文档总入口
- 串联 BLE、动作和表情最小示例
- 验证 README 链接和 examples README 存在
```

## Pull Request Checklist

- [ ] I changed the correct repository.
- [ ] I did not include local secrets, logs, caches, or personal machine paths.
- [ ] I updated docs when behavior or setup changed.
- [ ] I ran the relevant test or smoke check.
- [ ] I described cross-repository dependencies in the PR body.
- [ ] I recorded unresolved product decisions as `TODO`, `TBD`, or `PLACEHOLDER` instead of guessing.

## Good First Issues

Suggested starter tasks are tracked in `docs/open-source-readiness-baseline.md` and `docs/github-labels.md`. Maintainers should open them as GitHub Issues before public launch.
