# WO-06: Owner Decision Closeout

| Field | Instruction |
| --- | --- |
| Primary agent | Main Agent |
| Start condition | Product, legal, design, hardware, community, release, QA, or repository owners provide decisions or evidence. |
| Scope | Convert owner replies into WatcheRobot docs, owner decision records, placeholder cleanup, and launch evidence routing. |
| Inputs | `docs/owner-decision-record.md`, `docs/owner-decision-brief.md`, `docs/open-questions.md`, `docs/placeholder-register.md`, and `docs/launch-evidence-request-pack.md`. |
| Allowed actions | Close OQ rows with owner/date/final decision/traceable evidence, update affected public docs, remove or reclassify placeholders, and keep final reports consistent. |
| Do not | Do not infer approvals from silence, merge partial owner answers into final commitments, or remove TODO/TBD/PLACEHOLDER markers without evidence. |
| Required verification | `scripts/test-owner-decision-record.ps1`, `scripts/test-owner-decision-quality-fixtures.ps1`, `scripts/test-owner-decision-brief.ps1`, `scripts/audit-open-source-placeholders.ps1`, and `scripts/test-uncertainty-governance-contract.ps1`. |
| Stop and escalate | Stop if the owner identity, date, final decision, traceable evidence link/source, or affected file list is missing. |
| Deliverable | Updated owner decision record, affected docs, placeholder register, final report notes, and exact remaining open decisions. |
| Self-score note | Owner decisions can raise confidence but cannot close runtime/admin gates unless the matching evidence also passes. |

Preserve WatcheRobot naming and never replace uncertainty with marketing copy.
