# WatcheRobot Sub-Agent Work Orders

These work orders are the copy-ready execution packets for Codex sub-agents. They expand the strategy in `docs/sub-agent-handoff.md` and the goals in `docs/open-source-delivery-plan.md` into bounded assignments.

Do not invent license, community, demo, release, GitHub admin, hardware, maintainer, or roadmap facts. If a fact is uncertain, keep it as TODO/TBD/PLACEHOLDER and register it through the existing open-question and placeholder controls.

## Index

| Work order | File | Purpose |
| --- | --- | --- |
| WO-01 | [Local readiness refresh](WO-01-local-readiness-refresh.md) | Refresh local checks and final reports after edits. |
| WO-02 | [Root publication](WO-02-root-publication.md) | Stage and publish root readiness work safely when asked. |
| WO-03 | [App cleanup publication](WO-03-app-cleanup-publication.md) | Handle App public-name and signing cleanup inside the App subrepo. |
| WO-04 | [GitHub admin setup](WO-04-github-admin-setup.md) | Verify and apply remote GitHub labels, templates, discussions, and protections. |
| WO-05 | [Hardware smoke validation](WO-05-hardware-smoke-validation.md) | Capture real device evidence for BLE, motion, expression, provisioning, and AI reminder paths. |
| WO-06 | [Owner decision closeout](WO-06-owner-decision-closeout.md) | Convert owner decisions into docs, evidence, and placeholder cleanup. |
| WO-07 | [Full launch review](WO-07-full-launch-review.md) | Perform the final strict launch audit only after external evidence exists. |

## Shared Rules

- Preserve public product spelling as `WatcheRobot`.
- Read `docs/sub-agent-handoff.md` before taking a work order.
- Read `docs/open-source-delivery-plan.md` before changing acceptance language.
- Use TDD: add or run the relevant contract test before claiming a new guarantee.
- Self-score must stay evidence-bound; do not claim 100/100 while launch gates are unavailable.
- Do not use broad `git add .`, `git add -A`, or destructive Git commands.
- Do not mark launch evidence as `Status: Passed` unless the work was actually performed and the owner, date, environment, evidence, result, and follow-up fields are complete, traceable, and free of pending tokens.

## Handoff Back To Main Agent

Return a short report with:

| Field | Required content |
| --- | --- |
| Scope | Work order ID, files touched, and areas intentionally untouched. |
| Evidence | Commands run and exact pass/fail/unavailable summary. |
| Uncertainty | TODO/TBD/PLACEHOLDER items, owner needed, and next file to update. |
| Self-score | Local score impact and why the goal is or is not closer to 100/100. |
