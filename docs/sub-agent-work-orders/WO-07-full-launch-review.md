# WO-07: Full Launch Review

| Field | Instruction |
| --- | --- |
| Primary agent | Main Agent + QA Agent |
| Start condition | Root/App changes are merged or ready to publish, and all owner, admin, release, clean-machine, App, and hardware evidence files exist. |
| Scope | Prove whether WatcheRobot open-source launch readiness is actually complete. |
| Inputs | `docs/goal-completion-audit.md`, `docs/open-source-launch-gates.md`, `docs/launch-gate-closeout-plan.md`, `docs/open-source-readiness-final.md`, and all files under `docs/launch-evidence/`. |
| Allowed actions | Run strict launch audit, compare evidence to every WOS row, update final reports, and only then decide whether the active goal can be marked complete. |
| Do not | Do not accept indirect evidence, old snapshots, draft templates, or local-only readiness as proof of public launch completion. |
| Required verification | `scripts/audit-open-source-launch-gates.ps1 -RequirePassed`, `scripts/collect-open-source-evidence.ps1 -SkipGradle`, `scripts/check-open-source-readiness.ps1 -SkipGradle`, the full Gradle-inclusive readiness check `scripts/check-open-source-readiness.ps1`, and `scripts/test-goal-completion-audit.ps1`. |
| Stop and escalate | Stop if any WOS row lacks current evidence, any launch gate remains unavailable, or final reports disagree with audit output. |
| Deliverable | Final launch review report, strict audit output, evidence collector summary, and a justified self-score. |
| Self-score note | 100/100 is allowed only when strict launch gates pass and no TODO/TBD/PLACEHOLDER blocks public launch. |

## Launch Gate Checklist

Every gate below must have matching `Status: Passed` evidence with no pending tokens before this work order can recommend completion:

- owner decisions:
- final license:
- community entrance:
- approved demo asset:
- github admin state:
- release manifest:
- java and app gradle:
- clean-machine validation:
- hardware smoke validation:

This work order is the only route that can support marking the active goal complete.

## Strict Final Review Command Set

Run or attach fresh evidence for every command below before recommending `100/100` or marking the active goal complete:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-open-source-readiness.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\collect-open-source-evidence.ps1 -SkipGradle
powershell -ExecutionPolicy Bypass -File .\scripts\test-goal-completion-audit.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-readiness-score-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-wos-coverage.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-wos-evidence-trace.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-open-source-launch-gates.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-release-manifest-validation.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\validate-release-manifest.ps1 -Manifest <final-manifest>
powershell -ExecutionPolicy Bypass -File .\scripts\audit-github-readiness.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-launch-gates.ps1 -RequirePassed
git diff --check
git -C WatcheRobot_app diff --check
```

The first command is the full Gradle-inclusive readiness check. `-SkipGradle` remains acceptable only for continuation rounds where Java / Android evidence is still unavailable; it is not final completion proof.

Strict final review search anchors: `scripts/check-open-source-readiness.ps1`, `scripts/test-goal-completion-audit.ps1`, `scripts/test-readiness-score-contract.ps1`, `scripts/test-wos-coverage.ps1`, `scripts/test-wos-evidence-trace.ps1`, `scripts/test-open-source-launch-gates.ps1`, `scripts/test-release-manifest-validation.ps1`, `scripts/validate-release-manifest.ps1 -Manifest <final-manifest>`, `scripts/audit-github-readiness.ps1`, `scripts/audit-open-source-launch-gates.ps1 -RequirePassed`, `git diff --check`, `git -C WatcheRobot_app diff --check`.

## Evidence Freshness Rule

Use evidence from the same final review round whenever recommending completion. Do not accept stale screenshots, stale logs, stale owner replies, old web snapshots, old command output, or old release artifact notes unless each item is revalidated with date, owner, environment, and command/output link in the matching launch evidence file and final reports.

If freshness cannot be proven, leave the related launch gate unavailable and keep the self-score below `100/100`.

## Authoritative Evidence Hierarchy

Treat final reports, README sections, WOS tables, this work order, and handoff docs as derived summaries. They must be updated from same-round strict audit output, current command output, and `docs/launch-evidence/*.md` evidence files; they do not close gates by themselves.

For source-of-truth conflict handling: launch evidence files override final reports. If there is contradictory evidence between a summary and a launch evidence file, strict audit output, current GitHub admin/API evidence, release manifest validation, clean-machine transcript, App Gradle log, or hardware smoke log, keep the related gate unavailable or failed until the authoritative evidence is reconciled and the derived summaries are corrected.
