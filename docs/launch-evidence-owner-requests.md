# Launch Evidence Owner Requests

Use these copy-ready requests to collect the external evidence needed before WatcheRobot can be called fully public-launch ready.

Do not mark Status: Passed from a reply alone. Copy the observed result into the target evidence file, update affected docs, and rerun validation before closing a gate.

Every owner reply must include a valid non-future YYYY-MM-DD date, environment/context, traceable evidence source, result, remaining risk, and follow-up required before launch.

`Traceable evidence source` must point to a URL, repository path, exact command, screenshot/log path, checksum value, issue/PR number, release artifact URL, transcript/recording path, or commit hash. A plain approval sentence or generic `command output was reviewed` sentence is not enough to close a gate.

Required verification after applying any reply:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-launch-gates.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\check-open-source-readiness.ps1 -SkipGradle
```

Search anchors: `scripts/audit-open-source-launch-gates.ps1`, `scripts/check-open-source-readiness.ps1 -SkipGradle`.

## owner decisions

Target evidence file: `docs/launch-evidence/owner-decisions.md`
Recipient: Product / legal / design / hardware / community owners

```text
Request ID: owner decisions
Owner:
Date: valid non-future YYYY-MM-DD
Environment / context:
Decision or observed result:
Please provide final decisions for OQ-001 through OQ-009, with approval evidence for each row in docs/owner-decision-record.md.
Evidence link or command output:
Traceable evidence source:
Affected files approved:
Follow-up required before launch:
Remaining risk:
Can this close the gate? Yes / No
```

## final license

Target evidence file: `docs/launch-evidence/final-license.md`
Recipient: Product / legal owner

```text
Request ID: final license
Owner:
Date: valid non-future YYYY-MM-DD
Environment / context:
Decision or observed result:
Please approve the final license strategy for WatcheRobot with the SPDX license identifier, root LICENSE path (`LICENSE`), affected subrepo license impact, hardware / structure file license scope, third-party dependency compatibility note, and temporary license placeholder removal plan.
Evidence link or command output:
Traceable evidence source:
Affected files approved:
Follow-up required before launch:
Remaining risk:
Can this close the gate? Yes / No
```

## community entrance

Target evidence file: `docs/launch-evidence/community-entrance.md`
Recipient: Product / community owner

```text
Request ID: community entrance
Owner:
Date: valid non-future YYYY-MM-DD
Environment / context:
Decision or observed result:
Please confirm the official community URL, access status, moderation owner, response window, fallback contact, README community link, and GitHub Discussions setting or equivalent route for WatcheRobot.
Evidence link or command output:
Traceable evidence source:
Affected files approved:
Follow-up required before launch:
Remaining risk:
Can this close the gate? Yes / No
```

## approved demo asset

Target evidence file: `docs/launch-evidence/demo-asset.md`
Recipient: Product / design owner

```text
Request ID: approved demo asset
Owner:
Date: valid non-future YYYY-MM-DD
Environment / context:
Decision or observed result:
Please approve the README first-screen demo asset with approved media URL or repository path, asset type, public usage rights, source owner, README Demo section replacement plan, `docs/assets/README.md` placement or reference, and caption approval.
Evidence link or command output:
Traceable evidence source:
Affected files approved:
Follow-up required before launch:
Remaining risk:
Can this close the gate? Yes / No
```

## github admin state

Target evidence file: `docs/launch-evidence/github-admin.md`
Recipient: Repository admin

```text
Request ID: github admin state
Owner:
Date: valid non-future YYYY-MM-DD
Environment / context:
Decision or observed result:
Please confirm the remote GitHub admin state for WatcheRobot: issue template URLs, PR template URL, synced label list, good first issue URLs, Discussions or official community route URL, open-source readiness workflow visibility, main branch protection, and branch protection required checks. Attach `scripts/audit-github-readiness.ps1` output or equivalent GitHub settings screenshots/URLs.
Evidence link or command output:
Traceable evidence source:
Affected files approved:
Follow-up required before launch:
Remaining risk:
Can this close the gate? Yes / No
```

## release manifest

Target evidence file: `docs/launch-evidence/release-artifacts.md`
Recipient: Release owner

```text
Request ID: release manifest
Owner:
Date: valid non-future YYYY-MM-DD
Environment / context:
Decision or observed result:
Please provide the final release manifest values: unique artifact names, JSON boolean `required` values, artifact `path_or_url` values as http(s) URLs or traceable repository/build file paths, SHA-256 checksums, semantic release version, `release_url`, workspace/App/desktop/server/ESP32/STM32 component refs as commit hashes or semantic version tags, and `passed` readiness / hardware smoke / clean-machine check results. Include STM32 only if it is published in this release, with complete URL/path and checksum evidence.
Evidence link or command output:
Traceable evidence source:
Affected files approved:
Follow-up required before launch:
Remaining risk:
Can this close the gate? Yes / No
```

## java and app gradle

Target evidence file: `docs/launch-evidence/app-gradle.md`
Recipient: App owner

```text
Request ID: java and app gradle
Owner:
Date: valid non-future YYYY-MM-DD
Environment / context:
Decision or observed result:
Please provide Java / Android tooling evidence for WatcheRobot_app: `java -version`, `JAVA_HOME`, Android SDK path/version, the exact Gradle command run from `WatcheRobot_app/android`, Gradle task and build variant, Gradle command exit code, Gradle output log path, Metro / React Native command if used, confirmation that signing secrets are not included in shared evidence, and the OQ-009 legacy identifier decision if build output still references legacy internal identifiers.
Evidence link or command output:
Traceable evidence source:
Affected files approved:
Follow-up required before launch:
Remaining risk:
Can this close the gate? Yes / No
```

## clean-machine validation

Target evidence file: `docs/launch-evidence/clean-machine.md`
Recipient: QA owner

```text
Request ID: clean-machine validation
Owner:
Date: valid non-future YYYY-MM-DD
Environment / context:
Decision or observed result:
Please run a clean-machine validation with no local cache reuse: record the fresh clone directory, root commit hash, `git submodule status --recursive`, OS and tool versions, the completed `docs/quick-start.md` path, `scripts/check-open-source-readiness.ps1 -SkipGradle` output, and `scripts/test-open-source-examples.ps1` output.
Evidence link or command output:
Traceable evidence source:
Affected files approved:
Follow-up required before launch:
Remaining risk:
Can this close the gate? Yes / No
```

## hardware smoke validation

Target evidence file: `docs/launch-evidence/hardware-smoke.md`
Recipient: Firmware / QA owner

```text
Request ID: hardware smoke validation
Owner:
Date: valid non-future YYYY-MM-DD
Environment / context:
Decision or observed result:
Please run hardware smoke validation on a safe powered WatcheRobot device and record device ID / hardware revision, firmware versions, power supply and safety setup, BLE ping, servo action, expression switch, Wi-Fi provisioning ready state, AI reminder flow, serial/app logs, and expected ACK / observed result for each step.
Evidence link or command output:
Traceable evidence source:
Affected files approved:
Follow-up required before launch:
Remaining risk:
Can this close the gate? Yes / No
```
