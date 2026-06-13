# Launch Evidence Request Pack

This pack is a copy-ready request sheet for closing the remaining WatcheRobot public-launch gates. It helps owners, repository admins, release owners, QA, and firmware testers answer with the exact evidence Codex and sub-agents need.

This pack does not close any launch gate by itself.

Do not mark `Status: Passed` from this pack alone. A gate can pass only after the owner response or observed test result is copied into the authoritative file and the launch gate audit confirms it.

For copy-ready per-gate messages, use [Launch Evidence Owner Requests](launch-evidence-owner-requests.md). Search anchor: `docs/launch-evidence-owner-requests.md`.

Authoritative files:

- `docs/owner-decision-record.md`
- `docs/open-source-launch-gates.md`
- `docs/launch-gate-closeout-plan.md`
- `docs/launch-evidence/README.md`
- `scripts/audit-open-source-launch-gates.ps1`

## How To Use

1. Send only the relevant row or section to the owner.
2. Ask the owner to return the required fields without guessing missing facts.
3. Update `docs/owner-decision-record.md` first when the reply is a decision, and only close a row when its date is a valid non-future `YYYY-MM-DD` and its `Evidence / link` has a concrete traceable source marker.
4. Create a file under `docs/launch-evidence/` only after the check was actually run or the admin evidence was actually observed.
5. Run `powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-quality-fixtures.ps1`.
6. Run `powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-launch-gates.ps1`.
7. Run `powershell -ExecutionPolicy Bypass -File .\scripts\check-open-source-readiness.ps1 -SkipGradle`.

If no reply arrives, keep the gate unavailable and keep TODO/TBD/PLACEHOLDER markers in the public docs.

## Owner Decision Requests

| Decision | Owner role | Reply must include | Evidence to attach | Gates affected |
| --- | --- | --- | --- | --- |
| OQ-001 | Product / legal owner | Final root, desktop, server, STM32, hardware, and structure license strategy. | Written approval, legal review note, issue comment, or release checklist. | owner decisions; final license |
| OQ-002 | Product / community owner | Official public community route and moderation owner. | GitHub Discussions setting, public URL, support email, forum URL, or launch note. | owner decisions; community entrance |
| OQ-003 | Product / design owner | Approved README first-screen media file or URL. | Asset path, public media URL, design approval note, or launch checklist. | owner decisions; approved demo asset |
| OQ-004 | Product owner | Public timing language for open source, Makuake, beta, and production. | Product roadmap approval, launch plan, issue comment, or release note. | owner decisions |
| OQ-005 | Hardware owner | Public scope for BOM, wiring, STL, STEP, CAD, URDF, and assembly files. | Hardware release checklist, exported file list, issue comment, or approval note. | owner decisions; hardware smoke validation |
| OQ-006 | Project owner | Public maintainers, responsibility areas, and expected response windows. | Maintainer approval note, team roster, issue comment, or launch checklist. | owner decisions |
| OQ-007 | Product / legal owner | License or consent model for user submissions. | Consent template, legal note, issue comment, or contribution policy update. | owner decisions |
| OQ-008 | Repository admin | Remote GitHub settings owner and admin action plan. | `gh` output, GitHub settings screenshots, audit output, or checklist sign-off. | owner decisions; github admin state |
| OQ-009 | App owner | Whether legacy internal `WatcherRobotAPP` identifiers are renamed now, deferred, or kept as technical identifiers. | App owner issue comment, build result, migration approval, or release checklist. | owner decisions; java and app gradle; clean-machine validation |

## Launch Evidence Requests

| Gate | Recipient | Required reply or observed evidence | Target evidence file | Verification command |
| --- | --- | --- | --- | --- |
| owner decisions | Product / legal / design / hardware / community owners | Every OQ-001 through OQ-009 row exists exactly once and has owner, valid non-future `YYYY-MM-DD` date, final decision, concrete traceable `Evidence / link`, and `Closed` status; missing/duplicate/unexpected IDs and generic approval text or `command output was reviewed` are rejected. | `docs/owner-decision-record.md` and `docs/launch-evidence/owner-decisions.md` | `powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-record.ps1`; `powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-quality-fixtures.ps1` |
| final license | Product / legal owner | Final license evidence records the SPDX license identifier, root `LICENSE` path, affected subrepo license impact, hardware / structure file license scope, third-party dependency compatibility note, final files approved, and temporary license placeholder removal. | root `LICENSE`, affected docs, and `docs/launch-evidence/final-license.md` | `powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-launch-gates.ps1` |
| community entrance | Product / community owner | README uses a concrete official community URL or verified GitHub Discussions setting or equivalent route, with access status, moderation owner, response window, fallback contact, and README community link recorded. | README, `docs/community-launch-plan.md`, and `docs/launch-evidence/community-entrance.md` | `powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-launch-gates.ps1` |
| approved demo asset | Product / design owner | README hero or Demo section uses an approved media URL or repository path with asset type, public usage rights, source owner, README Demo section replacement, `docs/assets/README.md` placement/reference, caption approval, and no placeholder media text. | README, `docs/demo-asset-checklist.md`, and `docs/launch-evidence/demo-asset.md` | `powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-launch-gates.ps1` |
| github admin state | Repository admin | Remote issue template URLs, PR template URL, synced label list, good first issue URLs, Discussions or official community route URL, open-source readiness workflow visibility, main branch protection, and branch protection required checks are verified remotely. | `docs/launch-evidence/github-admin.md` | `powershell -ExecutionPolicy Bypass -File .\scripts\audit-github-readiness.ps1` |
| release manifest | Release owner | Required desktop and ESP32 artifacts have unique names, JSON boolean `required` values, artifact `path_or_url` values that are http(s) URLs or traceable repository/build file paths plus SHA-256 checksums, optional STM32 artifact is complete if published, the release date is valid and non-future, `release_url` is an http(s) URL, workspace/App/desktop/server/ESP32/STM32 component refs are commit hashes or semantic version tags, and readiness / hardware smoke / clean-machine check results are all `passed`. | `docs/launch-evidence/release-artifacts.md` and final manifest | `powershell -ExecutionPolicy Bypass -File .\scripts\validate-release-manifest.ps1 -Manifest <final-manifest>` |
| java and app gradle | App owner | `java -version`, `JAVA_HOME`, Android SDK path/version, exact Gradle command from `WatcheRobot_app/android`, Gradle task and build variant, Gradle command exit code, Gradle output log path, Metro / React Native command if used, confirmation that signing secrets are not included in shared evidence, and the OQ-009 legacy identifier decision are recorded. | `docs/launch-evidence/app-gradle.md` | `powershell -ExecutionPolicy Bypass -File .\scripts\check-open-source-readiness.ps1` |
| clean-machine validation | QA owner | Fresh clone directory, root commit hash, recursive submodule status, OS/tool versions, completed Quick Start path, readiness output, example dry-run output, and no-local-cache evidence are recorded. | `docs/launch-evidence/clean-machine.md` | `powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-launch-gates.ps1` |
| hardware smoke validation | Firmware / QA owner | Device ID / hardware revision, firmware versions, power supply and safety setup, BLE ping, servo, expression, Wi-Fi provisioning ready state, AI reminder flow, serial/app logs, and expected ACK / observed result are recorded on a safe powered device. | `docs/launch-evidence/hardware-smoke.md` | `powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-launch-gates.ps1` |

## Reply Template

```text
Request ID:
Owner:
Date: valid non-future YYYY-MM-DD
Decision or observed result:
Evidence link or command output: traceable URL, repository path, exact command, issue/PR number, screenshot/log path, checklist path, commit hash, checksum value, or artifact URL
Affected files approved:
Remaining risk:
Can this close the gate? Yes / No
```

## After A Reply Arrives

- Keep the original owner reply or observed command output available as evidence.
- Update `docs/owner-decision-record.md` before changing public promises; `Closed` rows must use valid non-future dates and concrete traceable `Evidence / link` values.
- Update affected docs in the same change set.
- Use files under `docs/launch-evidence/templates/` only after the corresponding check is actually performed.
- Run `powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-quality-fixtures.ps1`.
- Run `powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-request-pack.ps1`.
- Run `powershell -ExecutionPolicy Bypass -File .\scripts\check-open-source-readiness.ps1 -SkipGradle`.
