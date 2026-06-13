# WO-01: Local Readiness Refresh

| Field | Instruction |
| --- | --- |
| Primary agent | QA Agent |
| Start condition | Any root docs, scripts, examples, templates, or readiness reports changed. |
| Scope | Refresh local WatcheRobot readiness evidence without changing external launch-gate truth. |
| Inputs | `docs/open-source-delivery-plan.md`, `docs/open-source-readiness-final.md`, `docs/open-source-readiness-final.zh-CN.md`, `docs/goal-completion-audit.md`, and `docs/sub-agent-handoff.md`. |
| Allowed actions | Run local checks, update evidence summaries, add contract tests for new local guarantees, and keep TODO/TBD/PLACEHOLDER markers registered. |
| Do not | Do not close launch gates, invent owner decisions, change the product name, or stage files. |
| Required verification | `scripts/check-open-source-readiness.ps1`, `scripts/collect-open-source-evidence.ps1 -SkipGradle`, `git diff --check`, and `git -C WatcheRobot_app diff --check`. |
| Stop and escalate | Stop if the same check fails twice, if a failure needs owner/legal/hardware/admin evidence, or if external facts are missing. |
| Deliverable | Updated readiness report, command summary, unavailable-gate list, and no unregistered public TODO/TBD/PLACEHOLDER markers. |
| Self-score note | Keep the score below 100/100 until strict launch gates pass with real evidence. |

Minimum report: changed files, pass/fail/unavailable counts, score impact, and whether any WatcheRobot naming drift was found.
