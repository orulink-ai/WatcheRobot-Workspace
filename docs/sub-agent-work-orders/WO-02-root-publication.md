# WO-02: Root Publication

| Field | Instruction |
| --- | --- |
| Primary agent | Release Agent |
| Start condition | The user explicitly asks to stage, commit, push, or publish root readiness work. |
| Scope | Publish only root workspace docs, scripts, templates, examples, and the allowed Word reference plan for WatcheRobot open-source readiness. |
| Inputs | `docs/remote-publication-runbook.md`, `docs/sub-agent-handoff.md`, root `git status --short --ignored`, and current diff. |
| Allowed actions | Use narrow `git add <path>` commands from the runbook, inspect staged diffs, run publication hygiene checks, and create a detailed Chinese commit only if asked. |
| Do not | Do not use broad `git add .`, stage dirty subrepos, stage local exports, stage unrelated root `.docx` files, or include helper caches. |
| Required verification | `scripts/audit-publication-hygiene.ps1`, `scripts/test-publication-hygiene.ps1`, `git diff --cached --check`, and `scripts/check-open-source-readiness.ps1 -SkipGradle`. |
| Stop and escalate | Stop if unrelated files enter the staged diff, a subrepo source tree appears as root content, or launch evidence is missing. |
| Deliverable | Staged root-only diff summary or a publication-blocked report with exact files to review. |
| Self-score note | Publication can improve operational readiness, but it does not make the goal 100/100 without external gate evidence. |

Keep TODO/TBD/PLACEHOLDER markers intact unless an owner decision or real evidence closes them.
