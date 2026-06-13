# Final License Evidence

Status: Draft
Owner: Product / legal owner
Date: 2026-06-11
Environment: Current local Windows workspace shell in `D:\CodeProjects\WatcheRobot-Workspace`.
Evidence: `LICENSE-TBD.md` exists and `docs/license-decision-guide.md` lists license options without final approval; SPDX license identifier, root LICENSE path, hardware / structure file license scope, and third-party dependency compatibility evidence are not confirmed.
Result: Blocked because Final LICENSE is not confirmed. LICENSE-TBD.md is still present or LICENSE is missing. The approved license has not been selected.
Follow-up: Product / legal owner must approve the root and subrepo license strategy, provide SPDX license identifier, root LICENSE path, hardware / structure file license scope, and third-party dependency compatibility evidence, add final license files where needed, remove the temporary license placeholder from launch-facing docs, and rerun `scripts/audit-open-source-launch-gates.ps1`.

## Required Checks

- SPDX license identifier: Not selected.
- Root LICENSE path: Not present as the final root license.
- Subrepo license impact: Root, desktop, server, STM32, hardware, and structure scope still need owner confirmation.
- Hardware / structure file license scope: Not confirmed.
- Third-party dependency compatibility: Not confirmed.
- Temporary license placeholder removed: `LICENSE-TBD.md` remains present.
