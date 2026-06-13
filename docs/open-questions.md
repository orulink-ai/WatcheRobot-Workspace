# Open Questions

This file records decisions that must not be guessed by Codex or sub-agents.

| ID | Topic | Question | Current placeholder | Owner | Status |
| --- | --- | --- | --- | --- | --- |
| OQ-001 | License | Which license should the root workspace, desktop client, server, and STM32 firmware use? | `LICENSE-TBD.md` | Product / legal owner | Open |
| OQ-002 | Community | What is the official public community entrance: GitHub Discussions, Discord, email, forum, Feishu/Lark, or another channel? | README says GitHub Issues until confirmed | Product / community owner | Open |
| OQ-003 | Demo | Which product photo, GIF, or video is approved for the README hero area? | README Demo section uses `PLACEHOLDER` | Product / design owner | Open |
| OQ-004 | Roadmap dates | What public dates may be used for open source, Makuake, beta, and production phases? | Roadmap uses phase-only language | Product owner | Open |
| OQ-005 | Hardware openness | Which BOM, wiring, STL, STEP, CAD, URDF, and assembly files may be published externally? | Docs list known local files and mark unconfirmed files as TBD | Hardware owner | Open |
| OQ-006 | Maintainers | Who are the named public maintainers and expected response windows? | `docs/maintainers.md` uses role placeholders | Project owner | Open |
| OQ-007 | Showcase rights | What license or consent model should user-submitted demos, shells, animations, and tutorials use? | Showcase uses TBD language | Product / legal owner | Open |
| OQ-008 | GitHub admin settings | Who will enable Discussions, labels, branch protection, and repository settings after push? | `docs/github-settings-checklist.md` and `.github/labels.json` | Repository admin | Open |
| OQ-009 | App internal rename | Should internal React Native / native target identifiers be renamed from legacy `WatcherRobotAPP` to `WatcheRobot`? | `docs/app-internal-rename-plan.md` | App owner | Open |

Rule: if a fact is not confirmed here or in repository evidence, use `TODO`, `TBD`, or `PLACEHOLDER` instead of inventing content.

Final owner-approved answers should be recorded in [Owner Decision Record](owner-decision-record.md).
