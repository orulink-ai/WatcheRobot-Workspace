# Owner Decision Brief

This brief turns the remaining WatcheRobot owner decisions into a copy-ready handoff. It does not replace [Owner Decision Record](owner-decision-record.md) and it does not close any gate by itself.

Codex and sub-agents must not close any launch gate from this brief alone.

If no owner reply arrives, keep the current public docs unchanged and leave the launch gate unavailable.

Authoritative tracking files:

- [Owner Decision Record](owner-decision-record.md) at `docs/owner-decision-record.md`
- [Open Questions](open-questions.md)
- [Open Source Launch Gates](open-source-launch-gates.md) at `docs/open-source-launch-gates.md`
- `scripts/audit-open-source-launch-gates.ps1`

## Decision Request Table

| Decision | Blocks | Owner role | Exact answer needed | Acceptable evidence | Files to update after approval |
| --- | --- | --- | --- | --- | --- |
| OQ-001 License | Owner decisions, Final license | Product / legal owner | Choose the root workspace, desktop client, server, STM32 firmware, and hardware / structure license strategy. | Written approval URL/path, legal review note URL/path, issue/PR number, or signed release checklist path. | Root license file, license guide, README, final readiness report |
| OQ-002 Community | Owner decisions, Official community entrance | Product / community owner | Choose the official public support and discussion route. | GitHub Discussions setting, community URL, support email, forum URL, or owner-approved launch note. | README, docs index, community launch plan, launch gate evidence |
| OQ-003 Demo | Owner decisions, Approved demo asset | Product / design owner | Approve the first-screen README image, GIF, or video link. | Asset file path, public media URL, design approval note, or launch checklist item. | README, assets guide, demo asset checklist |
| OQ-004 Roadmap dates | Owner decisions | Product owner | Approve which public timing language may be used for open source, Makuake, beta, and production phases. | Product roadmap approval URL/path, launch plan path, issue/PR number, or dated release note path. | Roadmap, README, final readiness report |
| OQ-005 Hardware openness | Owner decisions, Hardware smoke validation | Hardware owner | Confirm which BOM, wiring, STL, STEP, CAD, URDF, and assembly materials may be public. | Hardware release checklist path, exported file list path, issue/PR number, or signed approval note URL/path. | Hardware structure map, assets guide, open-source scope |
| OQ-006 Maintainers | Owner decisions | Project owner | Name public maintainers, responsibility areas, and expected response windows. | Maintainer approval note URL/path, team roster path, issue/PR number, or release checklist path. | Maintainers guide, README, final readiness report |
| OQ-007 Showcase rights | Owner decisions | Product / legal owner | Choose the license or consent model for user-submitted demos, shells, animations, and tutorials. | Consent template path, legal note URL/path, issue/PR number, or contribution policy update path. | Showcase guide, community submissions guide, contribution guide |
| OQ-008 GitHub admin settings | Owner decisions, GitHub admin state | Repository admin | Verify Discussions or equivalent route, labels, branch protection, issue templates, PR template, and good first issues on the remote repository. | `gh` output, GitHub settings screenshots, audit output, or admin checklist sign-off. | GitHub settings checklist, launch gate evidence, final readiness report |
| OQ-009 App internal rename | Owner decisions, Java / Android validation, Clean-machine validation | App owner | Decide whether legacy internal `WatcherRobotAPP` identifiers should be renamed now, deferred, or left as technical identifiers. | App owner issue/PR number, exact build validation command output, migration plan approval URL/path, or release checklist path. | App internal rename plan, App README, final readiness report |

## Handoff Rule

When an owner answers a row:

1. Update [Owner Decision Record](owner-decision-record.md) first.
2. Confirm the reply includes a valid non-future `YYYY-MM-DD` date before setting the row to `Closed`.
3. Confirm `Evidence / link` contains a concrete traceable source marker, such as a URL, repository path, exact command, screenshot/log path, issue/PR number, release checklist path, commit hash, or checksum value. A generic approval sentence or `command output was reviewed` is not enough.
4. Update the affected public docs listed in the same row.
5. Attach evidence under `docs/launch-evidence/` only after the check has really been performed.
6. Run `powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-quality-fixtures.ps1`.
7. Run `powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-launch-gates.ps1`.
8. Run `powershell -ExecutionPolicy Bypass -File .\scripts\check-open-source-readiness.ps1 -SkipGradle`.
