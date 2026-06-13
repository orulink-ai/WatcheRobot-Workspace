# Goal Completion Audit

This file audits the active user goal against current repository evidence. It exists to prevent Codex or sub-agents from marking the goal complete based on partial progress, green local checks, or a plausible-looking final report.

Current self-reflection score: 99/100.

Do not mark the goal complete until every launch gate is passed and the final reports are updated with current evidence.

## Requirement Map

| Requirement | Current evidence | Status | Remaining condition |
| --- | --- | --- | --- |
| Implement the self-contained open-source community delivery plan | `docs/open-source-delivery-plan.md`, root Word reference plan, `scripts/test-delivery-plan-structure-contract.ps1`, `scripts/test-plan-docx-contract.ps1`, `scripts/audit-docx-render-prerequisites.ps1`, `scripts/test-docx-render-prerequisites-audit.ps1` | Near complete locally | Keep the Markdown plan and root Word reference plan aligned after every plan edit; DOCX render prerequisites must either pass for visual QA or remain explicitly recorded as unavailable rather than being treated as completed visual review. |
| Preserve the product name as WatcheRobot | `docs/product-name-policy.md`, `scripts/test-product-name-policy.ps1`, README/docs naming checks | Locally guarded | Do not reintroduce legacy public spelling in new public docs. |
| Keep WOS-01 through WOS-45 covered | `scripts/test-wos-coverage.ps1`, `scripts/test-wos-evidence-trace.ps1`, final readiness reports, delivery plan matrix, WOS evidence trace | Locally guarded | Keep WOS-01 through WOS-45 in plan and final reports after every update, with non-empty status, evidence, and remaining-blocker cells. |
| Use TDD / verification-driven execution | `scripts/check-open-source-readiness.ps1 -SkipGradle`, contract tests, evidence collector | Locally guarded | Continue adding a failing check before new readiness guarantees. |
| Self-reflection score every round | `docs/self-reflection-log.md`, `docs/open-source-readiness-final.md`, `docs/open-source-readiness-final.zh-CN.md`, `scripts/test-self-reflection-log.ps1`, `scripts/test-readiness-score-contract.ps1` | Locally guarded | Keep the self-reflection score evidence-bound. |
| Launch gates all passed | `docs/open-source-launch-gates.md`, `docs/launch-gate-closeout-plan.md`, `docs/launch-evidence-request-pack.md`, `scripts/audit-open-source-launch-gates.ps1` | Not complete | Close all unavailable launch gates with real evidence; owner decisions must include OQ-001 through OQ-009 exactly once, and each passed gate must also have the matching `docs/launch-evidence/*.md` file at `Status: Passed` with complete owner/date/environment/evidence/result/follow-up fields, a concrete traceable source marker in `Evidence`, and no pending tokens. |

## Current Blocking Gates

The goal cannot be marked complete while any of these launch gates remains unavailable:

- owner decisions
- final license
- community entrance
- approved demo asset
- github admin state
- release manifest
- java and app gradle
- clean-machine validation
- hardware smoke validation

Use [Launch Gate Closeout Plan](launch-gate-closeout-plan.md) to assign each gate to an owner, evidence file, closeout action, and pass signal. Use [Launch Evidence Request Pack](launch-evidence-request-pack.md) when asking owners, admins, release owners, QA, or firmware testers for reply fields.

## Field-Level Launch Gate Evidence Required Before Completion

The completion audit must not pass by checking only the 9 gate names. Before the goal can be marked complete, each gate must include the concrete fields below in the matching launch evidence file and final reports.

| Gate | Evidence fields that must be proven |
| --- | --- |
| owner decisions | OQ-001 through OQ-009 exactly once; owner; valid non-future `YYYY-MM-DD` date; final decision; concrete traceable `Evidence / link`; Closed status. |
| final license | SPDX license identifier; root LICENSE path; subrepo license impact; hardware / structure file license scope; third-party dependency compatibility; temporary license placeholder removal. |
| community entrance | official community URL; access status; moderation owner; response window; fallback contact; README community link; GitHub Discussions setting or equivalent route. |
| approved demo asset | approved media URL or repository path; asset type; public usage rights; source owner; README Demo section replacement; docs/assets/README.md placement/reference; caption approval. |
| github admin state | issue template URLs; PR template URL; synced label list; good first issue URLs; GitHub Discussions or official community route URL; open-source readiness workflow visibility; main branch protection; branch protection required checks; scripts/audit-github-readiness.ps1 output. |
| release manifest | unique artifact names; JSON boolean artifact required values; artifact path_or_url values as http(s) URLs or traceable repository/build file paths; SHA-256 checksums; semantic release version; release_url; workspace/App/desktop/server/ESP32/STM32 component refs; passed readiness / hardware smoke / clean-machine check results. |
| java and app gradle | java -version; JAVA_HOME; Android SDK path/version; exact Gradle command from `WatcheRobot_app/android`; Gradle task/build variant; Gradle command exit code; Gradle output log path; Metro / React Native command if used; signing secrets are not included; OQ-009 legacy identifier decision. |
| clean-machine validation | fresh clone directory; root commit hash; git submodule status --recursive; OS/tool versions; completed `docs/quick-start.md`; `scripts/check-open-source-readiness.ps1 -SkipGradle` output; `scripts/test-open-source-examples.ps1` output; no local cache reuse. |
| hardware smoke validation | device ID / hardware revision; firmware versions; power supply and safety setup; BLE ping / servo / expression / Wi-Fi ready / AI reminder expected ACK / observed result; serial/app logs. |

## Required Completion Commands

Run these before considering the goal complete:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-open-source-readiness.ps1 -SkipGradle
powershell -ExecutionPolicy Bypass -File .\scripts\collect-open-source-evidence.ps1 -SkipGradle
powershell -ExecutionPolicy Bypass -File .\scripts\audit-docx-render-prerequisites.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-docx-render-prerequisites-audit.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-wos-evidence-trace.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-self-reflection-log.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-launch-gates.ps1 -RequirePassed
```

Search anchors: `scripts/check-open-source-readiness.ps1 -SkipGradle`, `scripts/collect-open-source-evidence.ps1 -SkipGradle`, `scripts/audit-docx-render-prerequisites.ps1`, `scripts/audit-open-source-launch-gates.ps1 -RequirePassed`.

## Strict Final Review Command Set

The commands above are enough for local continuation while Java, GitHub admin access, hardware, and release artifacts are unavailable. They are not enough to mark the active goal complete. A final launch review must also run or attach fresh evidence for this stricter command set:

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

The first command is the full Gradle-inclusive readiness check. Do not use only `-SkipGradle` for final completion once the Java / Android launch evidence is supposed to be closed.

Strict final review search anchors: `scripts/check-open-source-readiness.ps1`, `scripts/test-goal-completion-audit.ps1`, `scripts/test-readiness-score-contract.ps1`, `scripts/test-wos-coverage.ps1`, `scripts/test-wos-evidence-trace.ps1`, `scripts/test-open-source-launch-gates.ps1`, `scripts/test-release-manifest-validation.ps1`, `scripts/validate-release-manifest.ps1 -Manifest <final-manifest>`, `scripts/audit-github-readiness.ps1`, `scripts/audit-open-source-launch-gates.ps1 -RequirePassed`, `git diff --check`, `git -C WatcheRobot_app diff --check`.

## Evidence Freshness Rule

Final completion evidence must be current to the same final review round that recommends completion. Do not close a launch gate from stale screenshots, stale logs, stale owner replies, old web snapshots, old command output, or old release artifact notes unless that evidence is revalidated with date, owner, environment, and command/output link in the matching `docs/launch-evidence/*.md` file and final reports.

This rule does not invent an expiration window. It requires the final reviewer to prove that each piece of evidence still matches the current repository state, current GitHub settings, current release artifacts, current App/firmware builds, and current hardware behavior before marking the active goal complete.

## Authoritative Evidence Hierarchy

Use this hierarchy whenever evidence sources disagree:

1. Same-round strict audit outputs, current command output, and `docs/launch-evidence/*.md` files with `Status: Passed` and complete required fields are authoritative for launch gate status.
2. Current GitHub admin/API evidence, current release manifest validation, clean-machine transcript, App Gradle log, and hardware smoke logs are authoritative for their own gate fields.
3. Final readiness reports, README sections, WOS tables, handoff docs, and sub-agent work orders are derived summaries. They must match the authoritative evidence; they cannot close a gate by themselves.

If there is contradictory evidence or a source-of-truth conflict, launch evidence files override final reports, and the reviewer must keep the related gate unavailable or failed until the conflict is reconciled in the authoritative evidence and then reflected back into the summaries.

When Java and Android tooling are available before the final review, also run the full Gradle-inclusive readiness check during normal continuation:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-open-source-readiness.ps1
```

## Completion Rule

Do not mark the goal complete when local readiness passes but launch gates remain unavailable. Local readiness proves the documentation, examples, governance files, and contract checks are internally consistent; it does not prove public launch completion.

The goal may be marked complete only when:

1. The launch gate audit passes in strict mode.
2. The evidence collector has no failed checks and no unresolved launch-blocking unavailable checks.
3. The final readiness reports reflect the same evidence.
4. The root Word reference plan and Markdown delivery plan remain aligned.
5. DOCX render prerequisites are either available and visual QA is recorded, or the unavailable prerequisites are explicitly reported by `scripts/audit-docx-render-prerequisites.ps1` and not treated as completed visual review.
