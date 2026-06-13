# Owner Decision Record

Use this file to record final owner decisions before public launch. Codex and sub-agents must not fill these decisions with guesses.

## Decision Table

| Open question | Decision needed | Owner | Final decision | Evidence / link | Date | Status |
| --- | --- | --- | --- | --- | --- | --- |
| OQ-001 License | Root, desktop, server, STM32, hardware/structure license strategy | Product / legal owner | TBD | `LICENSE-TBD.md`, `docs/license-decision-guide.md` | TBD | Open |
| OQ-002 Community | Official public community entrance | Product / community owner | TBD | `docs/community-launch-plan.md` | TBD | Open |
| OQ-003 Demo | README hero product photo/GIF/video | Product / design owner | TBD | `docs/demo-asset-checklist.md` | TBD | Open |
| OQ-004 Roadmap dates | Public dates for open source, Makuake, beta, production | Product owner | TBD | `docs/roadmap.md` | TBD | Open |
| OQ-005 Hardware openness | BOM, wiring, STL, STEP, CAD, URDF, assembly release scope | Hardware owner | TBD | `docs/hardware-structure-map.md` | TBD | Open |
| OQ-006 Maintainers | Named maintainers and response windows | Project owner | TBD | `docs/maintainers.md` | TBD | Open |
| OQ-007 Showcase rights | License / consent model for user submissions | Product / legal owner | TBD | `docs/showcase.md`, `docs/community-submissions.md` | TBD | Open |
| OQ-008 GitHub admin settings | Discussions, labels, branch protection, repository settings | Repository admin | TBD | `docs/github-settings-checklist.md` | TBD | Open |
| OQ-009 App internal rename | Whether to rename legacy internal `WatcherRobotAPP` identifiers | App owner | TBD | `docs/app-internal-rename-plan.md` | TBD | Open |

## Acceptance Rule

A decision is complete only when:

- the final decision is written in this file;
- the owner is filled and the date is a valid non-future `YYYY-MM-DD` date;
- there is concrete traceable evidence or a link to the approving source, such as a URL, repository path, exact command, screenshot/log path, issue/PR number, release checklist path, commit hash, or checksum value. A generic approval sentence or `command output was reviewed` is not enough;
- any affected public docs or config files are updated in the same change set.

If a decision remains open, keep the corresponding public docs as TODO/TBD/PLACEHOLDER.
