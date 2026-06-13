# WatcheRobot Codex / Sub-Agent Handoff

This handoff is for future Codex runs and sub-agents that continue the open-source readiness work. It summarizes the current state, required reading order, allowed actions, and stop conditions without relying on chat history.

## Current State

| Area | State |
| --- | --- |
| Local readiness | `scripts/check-open-source-readiness.ps1` passes locally. |
| Evidence collector | `scripts/collect-open-source-evidence.ps1 -SkipGradle` currently reports Passed 42, Failed 0, Unavailable 7. |
| Score | 99/100 in `docs/open-source-readiness-final.md`. |
| Self-reflection log | Latest round is recorded in `docs/self-reflection-log.md`. |
| Product name | Public name is `WatcheRobot`. Preserve this spelling in new public docs. |
| Root scope | Root repository is a meta workspace for docs, scripts, templates, and submodule references. |
| App scope | App changes must be committed inside `WatcheRobot_app`. |

## Required Reading Order

1. `docs/open-source-delivery-plan.md`
2. `docs/open-source-readiness-final.md`
3. `docs/open-source-readiness-final.zh-CN.md`
4. `docs/goal-completion-audit.md`
5. `docs/owner-decision-record.md`
6. `docs/owner-decision-brief.md`
7. `docs/launch-evidence-request-pack.md`
8. `docs/launch-evidence-owner-requests.md`
9. `docs/placeholder-register.md`
10. `docs/remote-publication-runbook.md`
11. `docs/sub-agent-work-orders/README.md`
12. `docs/public-launch-validation.md`
13. `docs/open-source-launch-gates.md`

## Universal Rules

- Do not invent license, maintainer, demo, community, roadmap, release, or hardware public-scope decisions.
- Do not use broad `git add .` in this workspace.
- Do not stage unrelated dirty subrepos or local helper files.
- Do not rename high-risk App native targets unless a dedicated App rename task has build evidence.
- Keep public-facing product spelling as `WatcheRobot`.
- Product naming must follow `docs/product-name-policy.md`; run `scripts/test-product-name-policy.ps1` after editing public naming, README copy, or legacy technical-name exceptions.
- Readiness score must stay evidence-bound; run `scripts/test-readiness-score-contract.ps1` after editing final reports, launch gates, evidence collection, or self-score language.
- Self-reflection log must stay evidence-bound; run `scripts/test-self-reflection-log.ps1` after editing self-score language, final reports, completion audit, or evidence collector counts.
- Launch gate closeout must stay actionable; run `scripts/test-launch-gate-closeout-plan.ps1` after editing launch gates, launch evidence, public validation, or closeout ownership.
- The root Word reference plan must stay aligned with `docs/open-source-delivery-plan.md`; run `scripts/test-plan-docx-contract.ps1` after editing the plan or regenerating the `.docx`.
- DOCX render fallback must be recorded: if `render_docx.py` cannot render the root Word reference plan, run `scripts/audit-docx-render-prerequisites.ps1`, keep `scripts/test-plan-docx-contract.ps1` as structural evidence, and record the visual QA gap in `docs/self-reflection-log.md`.
- Goal completion must stay evidence-bound; `docs/goal-completion-audit.md` must retain field-level launch-gate evidence requirements for owner decisions, final license, community entrance, approved demo asset, GitHub admin state, release manifest, App Gradle, clean-machine validation, and hardware smoke validation, plus the Strict Final Review Command Set. Run `scripts/test-goal-completion-audit.ps1` after editing launch gates, final reports, completion language, or handoff rules.
- Final review evidence must be fresh: stale screenshots, stale logs, stale owner replies, old web snapshots, old command output, and old release notes cannot close a launch gate unless they are revalidated with date, owner, environment, and command/output link in the same final review round.
- Final reports, README sections, WOS tables, handoff docs, and work orders are derived summaries. Launch evidence files override final reports; if there is a source-of-truth conflict or contradictory evidence, keep the related gate unavailable or failed until authoritative evidence is reconciled.
- Every new public uncertainty marker must be registered in `docs/placeholder-register.md`.
- Every new local readiness affordance must be added to `scripts/check-open-source-readiness.ps1`.
- Delivery plan structure must keep Check points, Target Table, Todo List, sub-agent strategy, TDD rules, and self-reflection; run `scripts/test-delivery-plan-structure-contract.ps1` after editing the plan or final reports.
- OQ-001 through OQ-009 must remain mirrored between `docs/open-questions.md` and `docs/owner-decision-record.md`; run `scripts/test-owner-decision-record.ps1` and `scripts/test-owner-decision-quality-fixtures.ps1` after any owner-decision edit.
- Closed owner decision rows must include concrete traceable `Evidence / link`; weak text such as plain owner approval or `command output was reviewed` is not enough to close an owner gate.
- Owner decision handoff must keep each OQ row mapped to blocking gates, evidence types, and files to update after approval; run `scripts/test-owner-decision-brief.ps1` after editing owner-decision guidance.
- Launch evidence requests must cover all 9 launch gates and OQ-001 through OQ-009 without claiming to close gates; final-license, community, demo, release, GitHub admin, App Gradle, clean-machine, and hardware smoke requests must ask for field-level evidence; run `scripts/test-launch-evidence-request-pack.ps1` after editing owner/admin/QA request guidance.
- Launch evidence owner request drafts must stay copy-ready and evidence-bound, including final-license SPDX/license-path/scope evidence, community URL/access/fallback evidence, demo media/rights/caption evidence, and field-level App Gradle evidence for `java -version`, `JAVA_HOME`, Android SDK, `WatcheRobot_app/android`, Gradle command exit code, signing-secret exclusion, and OQ-009; run `scripts/test-launch-evidence-owner-requests.ps1` after editing `docs/launch-evidence-owner-requests.md` or request routing.
- Launch evidence templates must keep `Status: Draft`, required audit fields, valid non-future date rules, license/community/demo field-level evidence fields, GitHub admin workflow/branch/check fields, clean-machine no-cache/example fields, hardware smoke expected ACK/log fields, and App Gradle command/log/secret/OQ-009 fields; run `scripts/test-launch-evidence-templates.ps1` after template edits.
- Launch evidence coverage must keep all 9 launch gates connected to evidence files, templates, launch gates docs, closeout plan, request pack, final reports, and this handoff; run `scripts/test-launch-evidence-coverage.ps1` after editing launch evidence routes.
- Uncertainty governance rules must keep "ask the user, otherwise use TODO/TBD/PLACEHOLDER" semantics; run `scripts/test-uncertainty-governance-contract.ps1` after editing plan, open questions, owner decisions, placeholder register, handoff, or final reports.
- GitHub remote web snapshots are fallback evidence only; run `scripts/test-github-web-snapshot-contract.ps1` after editing snapshot templates, snapshot files, or GitHub admin fallback docs.
- GitHub Actions readiness workflow must keep PR/push triggers, recursive submodules, Python setup, pwsh, and `-SkipGradle`; run `scripts/test-open-source-ci-workflow.ps1` after workflow edits.
- Markdown local links and heading anchors must stay valid; run `scripts/audit-markdown-links.ps1` and `scripts/test-markdown-link-audit.ps1` after README, docs, examples, or GitHub template link edits.
- Evidence collector coverage must stay aligned with local readiness; run `scripts/test-evidence-collector-coverage.ps1` after editing readiness checks, evidence collection, final reports, or handoff summaries.
- Public README files must keep product positioning, Demo placeholder, resource hub, governance links, and contribution boundaries; run `scripts/test-public-readme-contract.ps1` after README edits.
- Docs indexes must keep key docs, script gates, and subrepo README entrances; run `scripts/test-docs-index-contract.ps1` after docs index edits.
- Developer onboarding docs must keep clone, startup, toolchain, example, and subrepo paths; run `scripts/test-developer-onboarding-contract.ps1` after Quick Start, toolchain, or examples README edits.
- Workspace submodule metadata must keep `.gitmodules`, gitlink entries, README repository maps, and Quick Start submodule paths aligned; run `scripts/test-workspace-submodule-contract.ps1` after submodule, README, or Quick Start edits.
- Publication, public-launch validation, and sub-agent runbooks must keep safe staging rules, reading order, work orders, minimum validation commands, and field-level clean-machine / GitHub admin / hardware smoke evidence requirements; run `scripts/test-open-source-runbooks.ps1` after runbook edits.
- Publication hygiene must pass before staging or committing root readiness work; run `scripts/audit-publication-hygiene.ps1` and `scripts/test-publication-hygiene.ps1` after editing `.gitignore`, runbooks, local export rules, subrepo staging rules, root `.docx` staging rules, or helper scripts.
- Sub-agent work orders must stay copy-ready and evidence-bound, including field-level checklists for GitHub admin settings, hardware smoke expected ACK/logs, and final launch gate completion; run `scripts/test-sub-agent-work-orders.ps1` after editing `docs/sub-agent-work-orders/`, work orders, handoff rules, final reports, or sub-agent strategy.
- WOS-01 through WOS-45 must remain covered by `docs/open-source-delivery-plan.md`, `docs/open-source-readiness-final.md`, and `docs/open-source-readiness-final.zh-CN.md`; run `scripts/test-wos-coverage.ps1` after any plan or final-report edit.
- WOS evidence trace must remain current; run `scripts/test-wos-evidence-trace.ps1` after editing final reports, WOS evidence cells, completion language, or launch gate evidence references.
- Do not create launch evidence files with `Status: Passed` unless the result was directly observed and the owner, date, environment, evidence, result, and follow-up fields are complete.
- Passed launch evidence must include a concrete traceable source marker in `Evidence`, such as a URL, repository path, exact command, screenshot/log path, checksum value, issue/PR number, release artifact URL, transcript/recording path, or commit hash. A generic `command output was reviewed` sentence is not enough.
- Passed launch evidence must not contain pending tokens anywhere in the file: `TODO`, `TBD`, `PLACEHOLDER`, `REPLACE_ME`, or `UNKNOWN`.
- Do not treat README, license, owner-decision, release manifest, or remote GitHub state changes as a closed launch gate unless the matching `docs/launch-evidence/*.md` file also has `Status: Passed` and complete owner/date/environment/evidence/result/follow-up fields.

## Work Orders

Copy-ready packets live in `docs/sub-agent-work-orders/`:

- `docs/sub-agent-work-orders/WO-01-local-readiness-refresh.md`
- `docs/sub-agent-work-orders/WO-02-root-publication.md`
- `docs/sub-agent-work-orders/WO-03-app-cleanup-publication.md`
- `docs/sub-agent-work-orders/WO-04-github-admin-setup.md`
- `docs/sub-agent-work-orders/WO-05-hardware-smoke-validation.md`
- `docs/sub-agent-work-orders/WO-06-owner-decision-closeout.md`
- `docs/sub-agent-work-orders/WO-07-full-launch-review.md`

| Work order | Primary agent | Start condition | Actions | Verification | Stop condition |
| --- | --- | --- | --- | --- | --- |
| WO-01 Local readiness refresh | QA Agent | Any new docs, scripts, or examples are edited | Run local checks, update score only with evidence | `scripts/check-open-source-readiness.ps1`, `git diff --check` | Any check fails twice with the same cause |
| WO-02 Root publication | Release Agent | User asks to commit or publish root readiness work | Follow `docs/remote-publication-runbook.md` exactly | `scripts/audit-publication-hygiene.ps1`, `scripts/test-publication-hygiene.ps1`, `git diff --cached --check`, remote audit after merge | Unrelated files appear in staged diff |
| WO-03 App cleanup publication | App Agent | User asks to commit App changes | Commit only App public naming and signing cleanup inside `WatcheRobot_app` | `git -C WatcheRobot_app diff --check`, Gradle check after Java is available | Build tools are missing or native rename is requested |
| WO-04 GitHub admin setup | Governance Agent | `gh` or `GH_TOKEN` / `GITHUB_TOKEN` is available | Sync labels, create good first issues, verify templates, verify open-source readiness workflow visibility, enable Discussions or final community link, verify branch protection and required checks | `scripts/audit-github-readiness.ps1`, GitHub UI evidence | Missing admin permission or owner decision |
| WO-05 Hardware smoke validation | Firmware / QA Agent | Safe powered test device and ports are available | Run BLE ping, servo, expression, provisioning, and AI reminder checks with device ID / hardware revision, firmware versions, power setup, serial/app logs, and expected ACK / observed result | `docs/public-launch-validation.md` evidence table | Device behavior is unsafe or firmware contract differs |
| WO-06 Owner decision closeout | Main Agent | Product / legal / design / hardware / community owners provide decisions | Use `docs/owner-decision-brief.md` and `docs/launch-evidence-request-pack.md`, update `docs/owner-decision-record.md`, affected docs, and placeholder register | Placeholder audit, owner decision record tests, owner decision quality fixture tests, owner decision brief tests, launch evidence request pack tests, readiness script, final report | Decision evidence is missing or not traceable |
| WO-07 Full launch review | Main Agent + QA Agent | Root/App changes are merged and admin/hardware evidence exists | Use `docs/launch-gate-closeout-plan.md` and `docs/goal-completion-audit.md`, re-run all validation, attach evidence, update final score | Evidence collector, remote audit, release manifest validation, launch gate closeout plan tests, goal completion audit tests, and the Strict Final Review Command Set | Any WOS row lacks current evidence |

## External Evidence Needed Before 100/100

| Evidence | Why it matters | Where to record |
| --- | --- | --- |
| Owner decisions | All OQ-001 through OQ-009 rows must close before dependent public promises can change. | `docs/owner-decision-record.md`, `docs/launch-evidence/owner-decisions.md` |
| Final license decision | WOS-26 cannot complete without owner evidence for SPDX license identifier, root `LICENSE` path, subrepo license impact, hardware / structure file license scope, third-party dependency compatibility, and temporary license placeholder removal. | `docs/owner-decision-record.md`, `docs/launch-evidence/final-license.md`, `docs/launch-evidence-owner-requests.md`, root license file |
| Official community entrance | WOS-34 needs a real public support path with official community URL, access status, moderation owner, response window, fallback contact, README community link, and GitHub Discussions setting or equivalent route. | README, `docs/community-launch-plan.md`, `docs/launch-evidence/community-entrance.md`, `docs/launch-evidence-owner-requests.md` |
| Approved README demo asset | WOS-04 and WOS-40 need approved media URL or repository path, asset type, public usage rights, source owner, README Demo section replacement, assets README placement/reference, and caption approval. | README, `docs/demo-asset-checklist.md`, `docs/assets/README.md`, `docs/launch-evidence/demo-asset.md`, `docs/launch-evidence-owner-requests.md` |
| GitHub admin state | WOS-30 to WOS-33, WOS-37, and WOS-43 require remote proof for templates, labels, good first issues, community route, workflow visibility, branch protection, and required checks. | `docs/github-settings-checklist.md`, `docs/launch-evidence/github-admin.md`, `docs/launch-evidence-owner-requests.md`, remote audit |
| Release artifacts | WOS-38 needs unique artifact names, JSON boolean artifact `required` values, real desktop installer and ESP32 firmware artifacts with http(s) URL or traceable file-path `path_or_url` values and SHA-256 checksums, plus complete STM32 artifact data if STM32 is published in the release. | `docs/launch-evidence/release-artifacts.md`, `docs/launch-evidence-owner-requests.md`, final release manifest |
| Hardware smoke test | WOS-15, WOS-18, WOS-19, WOS-21 need safe powered-device evidence with device ID / hardware revision, firmware versions, power setup, serial/app logs, and expected ACK / observed result. | `docs/public-launch-validation.md`, `docs/launch-evidence/hardware-smoke.md`, `docs/launch-evidence-owner-requests.md` |
| Java / Android tooling | WOS-10 needs Gradle-level App validation with `java -version`, `JAVA_HOME`, Android SDK path/version, exact command from `WatcheRobot_app/android`, Gradle task and build variant, Gradle command exit code, Gradle output log path, Metro / React Native command if used, signing-secret exclusion, and OQ-009 legacy identifier decision. | `docs/launch-evidence/app-gradle.md`, `docs/launch-evidence-owner-requests.md`, final readiness report |
| Clean-machine run | WOS-08 and WOS-45 need external developer proof with fresh clone directory, root commit, recursive submodule status, Quick Start, readiness, examples dry-run, OS/tool versions, and no local cache reuse. | `docs/public-launch-validation.md`, `docs/launch-evidence/clean-machine.md`, `docs/launch-evidence-owner-requests.md` |

## Launch Evidence Files

- `docs/launch-evidence/owner-decisions.md`
- `docs/launch-evidence/final-license.md`
- `docs/launch-evidence/community-entrance.md`
- `docs/launch-evidence/demo-asset.md`
- `docs/launch-evidence/github-admin.md`
- `docs/launch-evidence/release-artifacts.md`
- `docs/launch-evidence/app-gradle.md`
- `docs/launch-evidence/clean-machine.md`
- `docs/launch-evidence/hardware-smoke.md`

## Minimum Commands For A Fresh Continuation

```powershell
git status --short
powershell -ExecutionPolicy Bypass -File .\scripts\check-open-source-readiness.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\collect-open-source-evidence.ps1 -SkipGradle
powershell -ExecutionPolicy Bypass -File .\scripts\test-github-community-assets.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-github-templates.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-delivery-plan-structure-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-record.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-quality-fixtures.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-brief.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-templates.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-coverage.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-uncertainty-governance-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-github-web-snapshot-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-open-source-ci-workflow.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\audit-markdown-links.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-markdown-link-audit.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-evidence-collector-coverage.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-product-name-policy.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-readiness-score-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-self-reflection-log.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-gate-closeout-plan.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-request-pack.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-owner-requests.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-plan-docx-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\audit-docx-render-prerequisites.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-docx-render-prerequisites-audit.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-goal-completion-audit.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-public-readme-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-docs-index-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-developer-onboarding-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-workspace-submodule-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-open-source-runbooks.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-wos-coverage.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-wos-evidence-trace.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-sub-agent-work-orders.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-launch-gates.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-open-source-launch-gates.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-placeholders.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-text-quality.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\audit-publication-hygiene.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-publication-hygiene.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-release-manifest-validation.ps1
git diff --check
git -C WatcheRobot_app diff --check
```

## Completion Rule

Do not mark the goal complete until every WOS row in `docs/open-source-readiness-final.md` has current evidence and the external evidence table above is closed. A near-complete local documentation state is not the same as a public launch.
