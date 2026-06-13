# Open Source Launch Gates

This file defines the remaining gates that must be closed before WatcheRobot can be called fully public-launch ready. It converts the last external conditions into auditable evidence instead of relying on memory or chat context.

Run the audit:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-launch-gates.ps1
```

Use strict mode only for an actual launch review:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-launch-gates.ps1 -RequirePassed
```

## Gate Table

| Gate | Required evidence | Current route |
| --- | --- | --- |
| Owner decisions | All OQ-001 through OQ-009 rows in `docs/owner-decision-record.md` exist and are closed with owner, valid non-future `YYYY-MM-DD` date, final decision, and traceable `Evidence / link`. Missing, duplicate, or unexpected owner-decision IDs fail the gate. | Product / legal / design / hardware / community owners |
| Final license | Final root license exists and affected docs no longer point to the temporary license placeholder. | Product / legal owner |
| Official community entrance | README points to the chosen official community path or GitHub Discussions is enabled and verified. | Product / community owner |
| Approved demo asset | README hero media is a real approved product image, GIF, or video. | Product / design owner |
| GitHub admin state | Issue templates, PR template, labels, good first issues, Discussions or equivalent entrance, and branch protection are verified remotely. | Repository admin |
| Release manifest | Release manifest uses real artifact URLs and checksums. | Release owner |
| Java / Android validation | App Gradle dry-run or equivalent App build validation has evidence. | App owner |
| Clean-machine validation | A fresh machine can clone, initialize submodules, and follow Quick Start. | QA owner |
| Hardware smoke validation | BLE ping, servo, expression, provisioning, and AI reminder flow have safe test-device evidence. | Firmware / QA owner |

## Evidence Directory

Store external proof under `docs/launch-evidence/`:

| File | Purpose |
| --- | --- |
| `docs/launch-evidence/owner-decisions.md` | Owner decision closeout evidence for OQ-001 through OQ-009 |
| `docs/launch-evidence/final-license.md` | Final license approval, root license file, and temporary placeholder removal evidence |
| `docs/launch-evidence/community-entrance.md` | Official public community route and README community link evidence |
| `docs/launch-evidence/demo-asset.md` | Approved README product photo, GIF, or video evidence |
| `docs/launch-evidence/github-admin.md` | GitHub settings screenshots, audit output, or admin notes |
| `docs/launch-evidence/hardware-smoke.md` | Device, firmware version, commands, responses, and safety notes |
| `docs/launch-evidence/clean-machine.md` | Machine OS, clone steps, commands, and results |
| `docs/launch-evidence/app-gradle.md` | Java / Android tooling versions and Gradle validation output |
| `docs/launch-evidence/release-artifacts.md` | Release URLs, checksums, manifest validation, and notes |

Templates live under `docs/launch-evidence/templates/`. Do not move a template to the root of `docs/launch-evidence/` until the check has actually been performed. The audit script treats an evidence file as passing only when it contains `Status: Passed`, complete `Owner`, `Date`, `Environment`, `Evidence`, `Result`, and `Follow-up` fields, a valid non-future `YYYY-MM-DD` date, a concrete traceable evidence marker, and no pending tokens.

The README gates are content-level checks too: the community gate requires a concrete official route or GitHub Discussions route, and the demo gate requires actual README media. Removing temporary text is not enough.

All passed gates are evidence-bound. Even if README, license, release manifest, owner decision, or remote GitHub state checks look ready, the audit must keep the gate unavailable or failed until the matching `docs/launch-evidence/*.md` file has `Status: Passed` with complete owner/date/environment/evidence/result/follow-up fields. The `Evidence` field must include a concrete traceable source marker such as a URL, repository path, exact command, screenshot/log path, checksum value, issue/PR number, release artifact URL, transcript/recording path, or commit hash; a generic sentence like `command output was reviewed` is not enough. The file must not contain pending tokens such as `TODO`, `TBD`, `PLACEHOLDER`, `REPLACE_ME`, or `UNKNOWN`.

GitHub remote web snapshot fallback evidence can be stored under `docs/launch-evidence/web-snapshots/` when API or `gh` evidence is unavailable. A snapshot may record visible tabs, README state, Releases state, About metadata, and Discussions visibility, but it cannot close the GitHub admin state gate. The GitHub admin gate still requires repository admin verification or `scripts/audit-github-readiness.ps1` evidence.

Use [Launch Gate Closeout Plan](launch-gate-closeout-plan.md) to assign each gate to an owner, evidence target, closeout action, and pass signal before the final launch review. Use [Launch Evidence Request Pack](launch-evidence-request-pack.md) to ask each owner, admin, release owner, QA, or firmware tester for the exact reply fields needed to close a gate.

## Score Rule

The local documentation and automation can remain at 99/100. Move to 100/100 only after this gate audit is fully passed and `docs/open-source-readiness-final.md` has current evidence for every WOS row.
