# Launch Gate Closeout Plan

This plan turns the current public-launch blockers into a concrete action queue for owners, repository admins, release owners, QA, and firmware testers.

This plan does not close gates by itself.

Do not create passed evidence without observed results.

Primary commands:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-launch-gates.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\collect-open-source-evidence.ps1 -SkipGradle
```

Search anchors: `scripts/audit-open-source-launch-gates.ps1`, `scripts/collect-open-source-evidence.ps1 -SkipGradle`.

Evidence templates live in `docs/launch-evidence/templates/`. Copy a template into `docs/launch-evidence/` only after the real check has been run and observed.

Use `docs/launch-evidence-request-pack.md` before asking an owner, admin, release owner, QA, or firmware tester for launch evidence. The request pack helps collect the right reply fields, but it does not close gates by itself.

Use `docs/launch-evidence-owner-requests.md` when you need copy-ready messages for the owner, admin, release, QA, or firmware tester.

Every passed launch gate must have its corresponding evidence file with `Status: Passed`, complete owner/date/environment/evidence/result/follow-up fields, traceable evidence, and no pending tokens. README, license, release manifest, or remote GitHub state changes are necessary inputs, but they do not close a gate without the matching launch evidence file.

## Closeout Queue

| Gate | Owner | Current status | Evidence file or source | Closeout action | Pass signal |
| --- | --- | --- | --- | --- | --- |
| owner decisions | Product / legal / design / hardware / community owners | Open evidence | `docs/owner-decision-record.md`, `docs/launch-evidence/owner-decisions.md` | Fill all OQ-001 through OQ-009 rows with owner, valid non-future `YYYY-MM-DD` date, final decision, concrete traceable `Evidence / link`, and `Closed` status. Missing, duplicate, or unexpected OQ IDs fail the gate; generic approval text or `command output was reviewed` is not enough. | All OQ-001 through OQ-009 owner decisions are closed and `docs/launch-evidence/owner-decisions.md` has `Status: Passed` with complete owner/date/environment/evidence/result/follow-up fields. |
| final license | Product / legal owner | Open evidence | `LICENSE`, temporary license placeholder file, `docs/license-decision-guide.md`, `docs/launch-evidence/final-license.md` | Choose final license strategy, record the SPDX license identifier, root `LICENSE` path, affected subrepo license impact, hardware / structure file license scope, third-party dependency compatibility note, add final license files, and remove temporary license placeholder references from launch-facing docs. | Final license exists, temporary license placeholder is absent, and `docs/launch-evidence/final-license.md` has `Status: Passed` with complete owner/date/environment/evidence/result/follow-up fields plus SPDX/license-path/subrepo/hardware-scope/compatibility evidence. |
| community entrance | Product / community owner | Open evidence | `README.md`, `docs/community-launch-plan.md`, `docs/owner-decision-record.md`, `docs/launch-evidence/community-entrance.md` | Choose GitHub Discussions or another official public route, record official community URL, access status, moderation owner, response window, fallback contact, and README community link, then update README and docs index. | README includes the concrete official community route and `docs/launch-evidence/community-entrance.md` has `Status: Passed` with complete owner/date/environment/evidence/result/follow-up fields plus URL/access/moderation/fallback evidence. |
| approved demo asset | Product / design owner | Open evidence | `README.md`, `docs/demo-asset-checklist.md`, `docs/assets/README.md`, `docs/launch-evidence/demo-asset.md` | Approve a real product image, GIF, or video with approved media URL or repository path, asset type, public usage rights, source owner, README Demo section replacement, `docs/assets/README.md` placement/reference, and caption approval. | README Demo section contains approved media, no placeholder media text remains, and `docs/launch-evidence/demo-asset.md` has `Status: Passed` with complete owner/date/environment/evidence/result/follow-up fields plus media path/type/rights/source/caption evidence. |
| github admin state | Repository admin | Open evidence | `docs/launch-evidence/github-admin.md`, `docs/github-settings-checklist.md` | Push local GitHub templates/workflow, sync labels, create good first issues, verify Discussions or equivalent entrance, enable branch protection, and confirm branch protection required checks. Run `scripts/audit-github-readiness.ps1` with `GH_TOKEN` or `GITHUB_TOKEN` when available. | GitHub audit or admin evidence confirms issue template URLs, PR template URL, synced label list, good first issue URLs, Discussions or official community route URL, open-source readiness workflow visibility, main branch protection, branch protection required checks, and `docs/launch-evidence/github-admin.md` has `Status: Passed` with complete owner/date/environment/evidence/result/follow-up fields. |
| release manifest | Release owner | Open evidence | `docs/launch-evidence/release-artifacts.md`, `docs/release-manifest.example.json` | Replace placeholder artifact names, artifact `required` values, artifact `path_or_url` values, checksums, release date, release URL, workspace/App/desktop/server/ESP32/STM32 component commit hashes or semantic version tags, and readiness / hardware smoke / clean-machine check results with release-owner-approved values, then run `scripts/validate-release-manifest.ps1` without placeholder allowance on the final manifest. | Release manifest validation passes with no pending token anywhere in the manifest, a valid non-future `release_date`, an http(s) `release_url`, unique artifact names, JSON boolean artifact `required` values, artifact `path_or_url` values as http(s) URLs or traceable repository/build file paths, all six required component refs as commit hashes or semantic version tags, required `desktop-windows-installer` and `esp32-firmware-package` artifacts, required readiness / hardware smoke / clean-machine check results set to `passed`, complete optional STM32 artifact if published, and `docs/launch-evidence/release-artifacts.md` has `Status: Passed` with complete owner/date/environment/evidence/result/follow-up fields. |
| java and app gradle | App owner | Open evidence | `docs/launch-evidence/app-gradle.md` | Configure Java and Android tooling, run App Gradle or equivalent build validation from `WatcheRobot_app/android`, and record `java -version`, `JAVA_HOME`, Android SDK path/version, Gradle task and build variant, Gradle command exit code, Gradle output log path, Metro / React Native command if used, signing-secret exclusion, and the OQ-009 legacy identifier decision. | App Gradle or equivalent App build evidence file has `Status: Passed` with complete owner/date/environment/evidence/result/follow-up fields, traceable command/log evidence, `Gradle command exit code`, confirmation that signing secrets are not included, and the OQ-009 legacy identifier decision. |
| clean-machine validation | QA owner | Open evidence | `docs/launch-evidence/clean-machine.md`, `docs/public-launch-validation.md` | Use a fresh machine with no local cache reuse to clone, initialize submodules, follow Quick Start, run readiness and example dry-run commands, and record OS/tool versions plus command output. | Clean-machine evidence file has `Status: Passed` with complete owner/date/environment/evidence/result/follow-up fields, fresh clone directory, root commit hash, `git submodule status --recursive`, completed `docs/quick-start.md` path, `scripts/check-open-source-readiness.ps1 -SkipGradle` output, and `scripts/test-open-source-examples.ps1` output. |
| hardware smoke validation | Firmware / QA owner | Open evidence | `docs/launch-evidence/hardware-smoke.md`, `examples/`, `docs/public-launch-validation.md` | Run BLE ping, servo, expression, provisioning, and AI reminder smoke tests on a safe powered device with logs. | Hardware smoke evidence file has `Status: Passed` with complete owner/date/environment/evidence/result/follow-up fields, device ID / hardware revision, firmware versions, power supply and safety setup, serial/app logs, and expected ACK / observed result for BLE ping, servo action, expression switch, Wi-Fi provisioning ready state, and AI reminder flow. |

## Closure Order

1. Close owner decisions first, because license, community, demo, hardware scope, maintainers, GitHub admin, and App rename choices depend on owner approval.
2. Publish root and App readiness changes using [Remote Publication Runbook](remote-publication-runbook.md).
3. Complete GitHub admin, release artifact, App Gradle, clean-machine, and hardware smoke evidence.
4. Run the launch gate audit in strict mode:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-launch-gates.ps1 -RequirePassed
```

5. Re-run the evidence collector and update [Open Source Readiness Final](open-source-readiness-final.md) only after every gate is passed.
