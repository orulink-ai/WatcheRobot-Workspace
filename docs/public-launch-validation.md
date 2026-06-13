# Public Launch Validation Runbook

Use this runbook before claiming the open-source launch is complete. It converts the remaining external checks into evidence that can be attached to a release, PR, or launch review.

## 1. Clean-Machine Developer Check

Environment: a machine that has not previously run the workspace.

| Step | Command / action | Pass evidence |
| --- | --- | --- |
| Clone workspace | `git clone <repo-url>` then `git submodule update --init --recursive` | All subrepos present. |
| Root status | `yarn status` | Shows expected subrepo branches without missing gitlinks. |
| Docs readiness | `powershell -ExecutionPolicy Bypass -File .\scripts\check-open-source-readiness.ps1 -SkipGradle` | Prints `Open-source readiness checks passed.` |
| Placeholder audit | `powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-placeholders.ps1` | Every public TODO / TBD / PLACEHOLDER marker is registered in `docs/placeholder-register.md`. |
| Launch gate audit | `powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-launch-gates.ps1` | Reports which final public-launch gates are passed, unavailable, or failed. |
| Launch gate regression tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-open-source-launch-gates.ps1` | Confirms temporary community text, missing README media, draft evidence, and incomplete passed evidence cannot close gates. |
| Text quality audit | `powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-text-quality.ps1` | Confirms public docs do not contain high-confidence mojibake markers and Chinese entry files contain expected anchors. |
| Publication hygiene audit | `powershell -ExecutionPolicy Bypass -File .\scripts\audit-publication-hygiene.ps1` | Confirms local exports, temporary pull worktrees, output folders, subrepo paths, unrelated root `.docx` files, and helper files are ignored or not staged for publication. |
| Publication hygiene regression tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-publication-hygiene.ps1` | Confirms the hygiene audit catches missing ignore rules, staged helper files, staged subrepo paths, and unrelated root `.docx` files. |
| Delivery plan structure contract tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-delivery-plan-structure-contract.ps1` | Confirms the self-contained plan keeps Check points, Target Table, Todo List, sub-agent strategy, TDD rules, and self-reflection. |
| Owner decision record tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-record.ps1` | Confirms OQ-001 through OQ-009 are mirrored between open questions and owner decisions, and that Open / Closed rows are internally consistent with concrete traceable `Evidence / link` values. |
| Owner decision quality fixture tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-quality-fixtures.ps1` | Confirms invalid calendar dates, future dates, and weak non-traceable evidence cannot close owner-decision rows. |
| Owner decision brief tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-brief.ps1` | Confirms each owner question maps to blocking gates, evidence types, and files to update after approval. |
| Launch evidence template tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-templates.ps1` | Confirms external evidence templates keep Draft status, include required fields, and preserve valid non-future date rules. |
| Uncertainty governance contract tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-uncertainty-governance-contract.ps1` | Confirms unresolved product, legal, release, maintainer, hardware, and GitHub admin facts stay as owner questions or placeholders instead of guessed public promises. |
| GitHub web snapshot contract tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-github-web-snapshot-contract.ps1` | Confirms GitHub remote web snapshots are recorded as fallback evidence and cannot close the GitHub admin gate. |
| Open-source CI workflow tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-open-source-ci-workflow.ps1` | Confirms the GitHub Actions readiness workflow keeps PR/push triggers, recursive submodules, Python setup, pwsh, and the `-SkipGradle` readiness command. |
| Markdown link audit | `powershell -ExecutionPolicy Bypass -File .\scripts\audit-markdown-links.ps1` | Confirms local Markdown links and heading anchors resolve before public launch. |
| Markdown link audit tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-markdown-link-audit.ps1` | Confirms the audit catches missing local files and missing heading anchors. |
| Evidence collector coverage tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-evidence-collector-coverage.ps1` | Confirms local readiness checks are represented in the evidence collector and final reports. |
| Product name policy tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-product-name-policy.ps1` | Confirms public copy uses `WatcheRobot` and legacy names stay limited to allowed technical exceptions. |
| Readiness score contract tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-readiness-score-contract.ps1` | Confirms final reports and handoff do not claim 100/100 while launch gates remain unavailable. |
| Launch gate closeout plan tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-gate-closeout-plan.ps1` | Confirms every launch gate has an owner, evidence target, closeout action, and pass signal. |
| Launch evidence request pack tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-request-pack.ps1` | Confirms the owner/admin/QA request pack covers all launch gates and OQ-001 through OQ-009 without closing gates by itself. |
| Plan docx contract tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-plan-docx-contract.ps1` | Confirms the root Word reference plan stays aligned with the current Markdown execution plan. |
| DOCX render prerequisite audit | `powershell -ExecutionPolicy Bypass -File .\scripts\audit-docx-render-prerequisites.ps1` | Records whether the Word plan can be visually rendered with available local prerequisites. |
| DOCX render prerequisite audit tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-docx-render-prerequisites-audit.ps1` | Confirms the DOCX render prerequisite audit keeps JSON output, required checks, and evidence collector routing. |
| Goal completion audit tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-goal-completion-audit.ps1` | Confirms the active goal is not marked complete while launch gates or final evidence remain unresolved. |
| Public README contract tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-public-readme-contract.ps1` | Confirms English and Chinese README files keep product positioning, Demo placeholder, resource hub, governance links, and contribution boundaries. |
| Docs index contract tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-docs-index-contract.ps1` | Confirms English and Chinese docs indexes keep key docs, script gates, and subrepo README entrances. |
| Developer onboarding contract tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-developer-onboarding-contract.ps1` | Confirms Quick Start, toolchain matrix, and examples README keep the clone, startup, tool, subrepo, and smoke-test paths needed by outside developers. |
| Workspace submodule contract tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-workspace-submodule-contract.ps1` | Confirms `.gitmodules`, root gitlinks, README repository maps, and Quick Start submodule paths stay aligned. |
| Open-source runbook tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-open-source-runbooks.ps1` | Confirms publication and sub-agent runbooks keep safe staging rules, required reading order, work orders, and minimum validation commands. |
| WOS coverage tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-wos-coverage.ps1` | Confirms the delivery plan and final reports still cover WOS-01 through WOS-45 without missing or unexpected IDs. |
| WOS evidence trace tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-wos-evidence-trace.ps1` | Confirms every final-report WOS row has status, traceable evidence, and remaining-blocker text. |
| Sub-agent work order tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-sub-agent-work-orders.ps1` | Confirms WO-01 through WO-07 stay copy-ready, bounded, evidence-driven, and self-score aware. |
| Release manifest regression tests | `powershell -ExecutionPolicy Bypass -File .\scripts\test-release-manifest-validation.ps1` | Confirms placeholders require `-AllowPlaceholders`, final manifests reject pending tokens in any field, final `version` is a semantic version tag, final `release_date` is a valid non-future date, `release_url` is an http(s) URL, workspace/App/desktop/server/ESP32/STM32 component refs exist and are commit hashes or semantic version tags, artifact names are unique, artifact `required` fields are JSON booleans, artifact `path_or_url` values are http(s) URLs or traceable file paths, required desktop and ESP32 artifacts exist, required readiness / hardware smoke / clean-machine check results are `passed`, and SHA-256 values are validated. |
| Example dry run | `powershell -ExecutionPolicy Bypass -File .\scripts\test-open-source-examples.ps1` | BLE ping, servo, AI status, and server reminder examples generate expected local payloads. |
| Desktop quick start | Follow `docs/quick-start.md` desktop path | Desktop starts or failure is documented with exact missing dependency. |
| App quick start | Follow `WatcheRobot_app/README.md` | Metro/Android/iOS path starts or failure is documented. |
| Server quick start | Follow `WatcheRobot_server/README.md` | `GET /api/admin/health` responds. |

Clean-machine evidence must record these fields before the clean-machine gate can pass:

- fresh clone directory:
- root commit hash:
- git submodule status --recursive:
- OS and tool versions:
- completed `docs/quick-start.md` path:
- `scripts/check-open-source-readiness.ps1 -SkipGradle` output:
- scripts/test-open-source-examples.ps1 output:
- no local cache reuse:

## 2. Hardware Smoke Check

Run only on a safe powered test device.

| WOS | Check | Command / action | Pass evidence |
| --- | --- | --- | --- |
| WOS-14 | BLE route | `python examples\ble-control-minimal\ble_control_minimal.py --name ESP_ROBOT --command ping` | ACK/pong or documented equivalent response. |
| WOS-18 | Motion | `python examples\ble-control-minimal\ble_control_minimal.py --name ESP_ROBOT --command servo-x --angle 90 --duration-ms 300` | Safe X-axis movement or expected ACK. |
| WOS-19 | Expression | `python examples\ble-control-minimal\ble_control_minimal.py --name ESP_ROBOT --command ai-status --status happy --image-name happy` | Display/status changes or expected ACK. |
| WOS-15 | Wi-Fi provisioning | Follow `docs/provisioning.md` | Device reaches ready/online state or failure recovery is documented. |
| WOS-20 | AI / reminder path | `python examples\ai-reminder-minimal\ai_reminder_minimal.py` after server start | Server creates/clarifies/rejects intent with explicit JSON response. |

Hardware smoke evidence must record these fields before the hardware smoke gate can pass:

- Device ID / hardware revision:
- Firmware versions:
- power supply and safety setup:
- BLE ping expected ACK / observed result:
- Servo action expected ACK / observed result:
- Expression switch expected ACK / observed result:
- Wi-Fi provisioning ready state expected ACK / observed result:
- AI reminder flow expected ACK / observed result:
- serial/app logs:

## 3. GitHub Admin Check

Requires repository admin permissions.

| WOS | Check | Command / action | Pass evidence |
| --- | --- | --- | --- |
| WOS-30 | Issue templates | Open new issue page | Bug, Feature, Documentation, Hardware, and Connection templates appear. |
| WOS-31 | PR template | Open a test PR | PR body includes scope, tests, impact, and related subrepo commits. |
| WOS-32 | Labels | `powershell -ExecutionPolicy Bypass -File .\scripts\sync-github-labels.ps1 -DryRun`, then without `-DryRun` | Labels exist in repository settings. |
| WOS-33 | Good first issues | `powershell -ExecutionPolicy Bypass -File .\scripts\create-good-first-issues.ps1 -DryRun`, then without `-DryRun` | 3-5 beginner issues exist on GitHub. |
| WOS-34 | Discussions | Enable GitHub Discussions or publish final community link | README community section points to the chosen official entrance. |
| WOS-43 | Branch protection | Apply `docs/github-settings-checklist.md` | Main/default branch requires PR review and required checks. |

GitHub admin evidence must record these fields before the GitHub admin gate can pass:

- issue template URLs:
- PR template URL:
- synced label list:
- good first issue URLs:
- Discussions or official community route URL:
- open-source readiness workflow visibility:
- main branch protection:
- branch protection required checks:
- scripts/audit-github-readiness.ps1 output:

Read-only remote audit:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\audit-github-readiness.ps1
```

If the anonymous GitHub API is rate-limited, set `GH_TOKEN` or `GITHUB_TOKEN` and rerun the audit.

GitHub remote web snapshot fallback:

```text
docs/launch-evidence/templates/github-remote-web-snapshot.md
docs/launch-evidence/web-snapshots/
```

Use this route only to record public webpage observations when API, `gh`, or token evidence is unavailable. It does not replace `scripts/audit-github-readiness.ps1` and does not close the GitHub admin gate.

Local consistency test before remote admin action:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-github-community-assets.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-github-templates.ps1
```

## 4. Release Artifact Check

| WOS | Check | Pass evidence |
| --- | --- | --- |
| WOS-35 | Release policy | Release notes follow `docs/release-policy.md`. |
| WOS-36 | Changelog | `CHANGELOG.md` includes the launch version. |
| WOS-38 | Downloadable artifacts | Desktop installer, firmware package, checksum, and version notes are linked from the release. |
| WOS-40 | Assets | README hero image/GIF/video comes from an approved source and is listed in `docs/demo-asset-checklist.md`. |

Validate release artifact metadata:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-release-manifest.ps1 -AllowPlaceholders
```

Validate the final release manifest after the semantic `version`, release URL, real desktop installer and ESP32 firmware package `path_or_url` values, SHA-256 checksums, release date, workspace/App/desktop/server/ESP32/STM32 component commit hashes or semantic version tags, and `passed` readiness / hardware smoke / clean-machine check results are available. Artifact names must be unique, artifact `required` fields must be JSON booleans, and artifact `path_or_url` values must be http(s) URLs or traceable repository/build file paths, not descriptive labels. If STM32 is published in the release, include it with the same URL/path and checksum evidence:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-release-manifest.ps1 -Manifest path\to\release-manifest.json
```

## 5. Sign-Off Record

Collect current local and remote evidence:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\collect-open-source-evidence.ps1 -SkipGradle
```

Use JSON output when attaching evidence to a review:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\collect-open-source-evidence.ps1 -SkipGradle -Json
```

Publish local readiness files to GitHub using [Remote Publication Runbook](remote-publication-runbook.md).

Use [Open Source Launch Gates](open-source-launch-gates.md) for the final all-gates review.

Use [Launch Gate Closeout Plan](launch-gate-closeout-plan.md) to assign owners and collect the remaining evidence for every unavailable gate.

Use [Launch Evidence Request Pack](launch-evidence-request-pack.md) when asking owners, admins, release owners, QA, or firmware testers for the exact reply fields needed to close a gate.

Use [Goal Completion Audit](goal-completion-audit.md) before marking the active goal complete.

Use `docs/launch-evidence/templates/` when recording external proof. The final audit will not pass a launch evidence file unless it is marked `Status: Passed`, includes complete owner, date, environment, evidence, result, and follow-up fields, includes traceable evidence, and contains no pending tokens.

Record the result in `docs/open-source-readiness-final.md`:

- validation date
- commit SHA / release tag
- machine OS and key tool versions
- hardware device / firmware version
- GitHub repository URL
- completed `docs/owner-decision-record.md`
- remaining TODO/TBD items, if any

Do not mark WOS-45 complete until clean-machine, hardware, GitHub admin, and release artifact checks all have evidence.
