# WO-04: GitHub Admin Setup

| Field | Instruction |
| --- | --- |
| Primary agent | Governance Agent |
| Start condition | `gh`, `GH_TOKEN`, `GITHUB_TOKEN`, or repository admin access is available. |
| Scope | Verify or apply GitHub remote settings for the WatcheRobot root repository. |
| Inputs | `.github/labels.json`, `.github/ISSUE_TEMPLATE/`, `.github/PULL_REQUEST_TEMPLATE.md`, `docs/github-settings-checklist.md`, and `docs/good-first-issues.md`. |
| Allowed actions | Run remote audits, sync labels, create approved good first issues, verify templates, and collect admin evidence. |
| Do not | Do not enable an unapproved community route, create duplicate issues, claim branch protection without proof, or treat web snapshots as admin proof. |
| Required verification | `scripts/audit-github-readiness.ps1`, `scripts/test-github-community-assets.ps1`, `scripts/test-github-templates.ps1`, and `docs/launch-evidence/github-admin.md`. |
| Stop and escalate | Stop if permissions are missing, token scope is insufficient, Discussions/community choice is undecided, or admin evidence is unavailable. |
| Deliverable | GitHub admin evidence file, remote audit output, created issue links, and remaining TODO/TBD/PLACEHOLDER items. |
| Self-score note | Only verified remote settings can close the GitHub admin gate and move WatcheRobot closer to 100/100. |

## Evidence Checklist

- issue template URLs:
- PR template URL:
- synced label list:
- good first issue URLs:
- Discussions or official community route URL:
- open-source readiness workflow visibility:
- main branch protection:
- branch protection required checks:
- scripts/audit-github-readiness.ps1 output:

Keep the GitHub admin gate unavailable until direct admin or authenticated audit evidence exists.
