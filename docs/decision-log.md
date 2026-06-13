# Decision Log

This file records confirmed decisions for open-source preparation. Do not add assumptions here.

| Date | Decision | Evidence / Owner | Impact |
| --- | --- | --- | --- |
| 2026-06-10 | Public product name is `WatcheRobot`. | User correction in this thread. | New public docs must use `WatcheRobot`; historical repository names may remain. |
| 2026-06-10 | Root repository remains a meta workspace. | `AGENTS.md`, `.gitmodules`, current README. | Do not expand subrepository source into root commits. |
| 2026-06-10 | Unknown public facts must be asked or marked as placeholders. | User instruction. | License, community, demo, roadmap dates, and open hardware scope must not be guessed. |
| 2026-06-10 | App public display name should be `WatcheRobot`, while high-risk internal target/module names may remain until a dedicated rename task. | Current React Native / iOS target structure uses `WatcherRobotAPP`. | Update public README/display names now; avoid breaking native project identifiers during this pass. |
