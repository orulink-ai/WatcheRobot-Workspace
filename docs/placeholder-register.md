# Placeholder Register

This register controls where public-facing TODO / TBD / PLACEHOLDER markers are allowed before launch. It exists to prevent Codex or sub-agents from hiding uncertainty in random files.

Rules:

- If a file contains TODO / TBD / PLACEHOLDER, it must be listed here unless it is this register itself.
- If the marker is tied to product, legal, security, maintainer, GitHub admin, release, or hardware scope, the decision must also appear in [Open Questions](open-questions.md) or [Owner Decision Record](owner-decision-record.md).
- Do not convert any item below into a public promise until the listed owner or evidence source confirms it.

| File | Reason | Owner / evidence route |
| --- | --- | --- |
| `SECURITY.md` | Private security contact is not confirmed. | Product / security owner |
| `CODE_OF_CONDUCT.md` | Conduct reporting contact is not confirmed. | Community owner |
| `README.md` | README hero demo asset is not approved. | Product / design owner |
| `README.zh-CN.md` | README hero demo asset is not approved. | Product / design owner |
| `CONTRIBUTING.md` | Contributor checklist reminds authors not to guess unresolved decisions. | Governance docs |
| `.github/PULL_REQUEST_TEMPLATE.md` | PR checklist reminds authors not to guess unresolved decisions. | Governance docs |
| `.github/good-first-issues/01-quick-start-error-notes.md` | Good first issue instructions may preserve environment-specific uncertainty. | Maintainer |
| `.github/good-first-issues/02-expression-switching-smoke-script.md` | Expression route behavior needs firmware / hardware evidence. | Firmware owner |
| `.github/good-first-issues/03-hardware-resource-entry-points.md` | Hardware public scope is not confirmed. | Hardware owner |
| `.github/good-first-issues/05-release-asset-checksum-notes.md` | Release cadence and owner names are not confirmed. | Release owner |
| `docs/ai-integration.md` | Public default AI provider recommendation is not confirmed. | Product / AI owner |
| `docs/assets/README.md` | Demo asset placeholders are allowed until assets are approved. | Product / design owner |
| `docs/branch-policy.md` | Official release branch naming is not confirmed. | Maintainer |
| `docs/community-launch-plan.md` | Official real-time community channel is not confirmed. | Product / community owner |
| `docs/community-submissions.md` | Community asset license policy is not confirmed. | Product / legal owner |
| `docs/demo-asset-checklist.md` | External video link and approved demo assets are not confirmed. | Product / design owner |
| `docs/extension-boundaries.md` | Hardware / structure extension boundary depends on public scope decision. | Hardware owner |
| `docs/good-first-issues.md` | Maintainer-facing issue drafts intentionally preserve uncertainty. | Maintainer |
| `docs/hardware-structure-map.md` | Hardware, STL, expression, and screenshot public status is not confirmed. | Hardware / product owner |
| `docs/license-decision-guide.md` | Final license strategy is not confirmed. | Product / legal owner |
| `docs/launch-evidence-request-pack.md` | Owner/admin/QA request pack intentionally repeats TODO/TBD/PLACEHOLDER handling rules for missing replies. | QA agent |
| `docs/launch-evidence/README.md` | Launch evidence rules intentionally name pending tokens that cannot appear in Passed evidence. | QA agent |
| `docs/launch-evidence/templates/final-license.md` | Final license evidence template references the temporary license placeholder until legal approval exists. | Product / legal owner |
| `docs/launch-evidence/final-license.md` | Draft blocker evidence records unresolved final license approval and the temporary license placeholder. | Product / legal owner |
| `docs/launch-evidence/release-artifacts.md` | Draft blocker evidence records unresolved release artifact URLs and checksums until the release owner approves final values. | Release owner |
| `docs/maintainers.md` | Named maintainers and response windows are not confirmed. | Project owner |
| `docs/open-questions.md` | Canonical uncertainty list. | Product / legal / maintainer owners |
| `docs/open-source-delivery-plan.md` | Execution plan defines placeholder rules and original WOS matrix. | Codex / QA agent |
| `docs/open-source-launch-gates.md` | Launch gate rules intentionally name pending tokens that cannot appear in Passed evidence. | QA agent |
| `docs/open-source-readiness-baseline.md` | Baseline audit preserves pre-fix gaps. | QA agent |
| `docs/open-source-readiness-final.md` | Final report records remaining blockers and unresolved decisions. | QA agent |
| `docs/open-source-readiness-final.zh-CN.md` | Chinese final summary records remaining blockers and unresolved decisions. | QA agent |
| `docs/open-source-scope.md` | Public scope still has unknowns. | Product / legal owner |
| `docs/owner-decision-record.md` | Canonical owner sign-off table. | Product / legal / maintainer owners |
| `docs/privacy-and-data-flow.md` | Final public privacy wording is not confirmed. | Product / legal owner |
| `docs/provisioning.md` | Final ready / recovery public copy needs hardware validation. | Desktop / firmware owner |
| `docs/public-launch-validation.md` | Launch checklist records remaining TODO / TBD items. | QA agent |
| `docs/README.zh-CN.md` | Chinese docs index explains placeholder handling. | Docs agent |
| `docs/release-manifest.example.json` | Example manifest intentionally uses placeholder values. | Release owner |
| `docs/release-policy.md` | Versioning and sync cadence are not confirmed. | Release owner |
| `docs/remote-publication-runbook.md` | Publication instructions reference `LICENSE-TBD.md`. | Release / repo owner |
| `docs/resource-pack-spec.md` | Creator pack format and license are not confirmed. | Product / firmware owner |
| `docs/roadmap.md` | Public roadmap dates are not confirmed. | Product owner |
| `docs/self-reflection-log.md` | Self-reflection log records the current round's pending-token audit hardening. | QA agent |
| `docs/showcase.md` | Public showcase approval and license policy are not confirmed. | Product / legal owner |
| `docs/sub-agent-handoff.md` | Sub-agent rules explicitly mention TODO/TBD/PLACEHOLDER handling to prevent guessed public promises. | QA agent |
| `docs/sub-agent-work-orders/README.md` | Work order index explicitly mentions TODO/TBD/PLACEHOLDER handling to prevent guessed public promises. | QA agent |
| `docs/sub-agent-work-orders/WO-01-local-readiness-refresh.md` | Local readiness work order explicitly mentions TODO/TBD/PLACEHOLDER handling to prevent unregistered uncertainty. | QA agent |
| `docs/sub-agent-work-orders/WO-02-root-publication.md` | Root publication work order explicitly preserves TODO/TBD/PLACEHOLDER markers unless evidence closes them. | Release / repo owner |
| `docs/sub-agent-work-orders/WO-03-app-cleanup-publication.md` | App cleanup work order explicitly records TODO/TBD/PLACEHOLDER items for App owner review. | App owner |
| `docs/sub-agent-work-orders/WO-04-github-admin-setup.md` | GitHub admin work order explicitly records TODO/TBD/PLACEHOLDER items until admin evidence exists. | Repository admin |
| `docs/sub-agent-work-orders/WO-05-hardware-smoke-validation.md` | Hardware smoke work order explicitly records TODO/TBD/PLACEHOLDER items requiring firmware owner review. | Firmware / QA owner |
| `docs/sub-agent-work-orders/WO-06-owner-decision-closeout.md` | Owner decision work order explicitly prevents removing TODO/TBD/PLACEHOLDER markers without evidence. | Product / legal / maintainer owners |
| `docs/sub-agent-work-orders/WO-07-full-launch-review.md` | Full launch review work order explicitly prevents 100/100 while TODO/TBD/PLACEHOLDER blocks remain. | Main agent / QA agent |
| `docs/toolchain-matrix.md` | Some toolchain baselines need final verification. | Engineering owner |
| `examples/creator-template-minimal/manifest.example.json` | Template intentionally contains author/license/version placeholders. | Example author |
| `examples/switch-expression-minimal/README.md` | Firmware route support needs confirmation. | Firmware owner |
| `scripts/audit-open-source-launch-gates.ps1` | Launch gate audit intentionally detects unresolved public placeholders and external evidence gaps. | QA agent |
