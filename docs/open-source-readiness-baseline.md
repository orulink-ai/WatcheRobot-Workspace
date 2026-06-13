# Open Source Readiness Baseline

Generated from the current workspace state and the WOS table. Product name is normalized to `WatcheRobot`.

Legend:

- Done: evidence exists and root entry is sufficient.
- Aggregate: evidence exists in subrepositories but root entry must connect it.
- Gap: missing or not sufficient.
- TBD: needs product, legal, maintainer, or GitHub-admin confirmation.

| ID | Priority | Status | Target | Current evidence / action |
| --- | --- | --- | --- | --- |
| WOS-01 | P0 | In progress | Public naming consistency | New root docs use `WatcheRobot`; App public display names updated; internal legacy target/module names remain by decision log. |
| WOS-02 | P0 | Gap | One-line intro | Root README now needs open-source embodied AI robot positioning. |
| WOS-03 | P0 | Gap | Project audience | Add external-facing audience and capability summary. |
| WOS-04 | P0 | TBD | Demo | Real approved demo asset is missing; README uses placeholder. |
| WOS-05 | P0 | Aggregate | Resource hub | Root README must link App/Desktop/Server/Firmware/Hardware/Docs/Examples. |
| WOS-06 | P0 | Aggregate | Subrepo relationship | Existing README and `.gitmodules` have core mapping; add use-together notes. |
| WOS-07 | P0 | Gap | Architecture diagram | Add `docs/architecture.md`. |
| WOS-08 | P0 | Gap | Quick Start | Add `docs/quick-start.md`. |
| WOS-09 | P0 | Aggregate | Toolchain versions | Add `docs/toolchain-matrix.md`; some versions remain TBD. |
| WOS-10 | P0 | Aggregate | App development | App README exists; root needs entry and FAQ path. |
| WOS-11 | P0 | Aggregate | Desktop development | Desktop README exists; root needs first-run summary. |
| WOS-12 | P1 | Aggregate | Server development | Server README/docs exist; root needs link and summary. |
| WOS-13 | P1 | Aggregate | Firmware development | ESP32/STM32 docs exist; root needs state-aware aggregation. |
| WOS-14 | P1 | Aggregate | BLE protocol | ESP32/App docs exist; root needs protocol entry. |
| WOS-15 | P0 | Aggregate | Wi-Fi provisioning | Add `docs/provisioning.md` to close ready/failure path. |
| WOS-16 | P1 | Aggregate | Hardware entry | ESP32 hardware docs exist; root needs links. |
| WOS-17 | P1 | TBD | Structure entry | STL/URDF files exist locally; public scope needs confirmation. |
| WOS-18 | P0 | Gap | Motion guide | Add `docs/motion-guide.md` and example. |
| WOS-19 | P1 | Aggregate | Expression guide | AnimPack docs exist; add creator-facing summary. |
| WOS-20 | P1 | Aggregate | AI integration | Server docs exist; add productized entry. |
| WOS-21 | P0 | Gap | Minimal examples | Add root `examples/` skeleton and smoke checks. |
| WOS-22 | P1 | Gap | Docs directory hub | `docs/` exists but lacks index. |
| WOS-23 | P0 | Aggregate | Config templates | Existing examples need root security summary. |
| WOS-24 | P0 | In progress | Sensitive info cleanup | Default Android signing password values removed; release signing now requires local/CI properties; keep scanning before final. |
| WOS-25 | P1 | Aggregate | `.gitignore` | Needs final scan after changes. |
| WOS-26 | P0 | TBD | License | Root and some subrepos lack license; legal decision needed. |
| WOS-27 | P0 | Gap | Contributing guide | Add root `CONTRIBUTING.md`. |
| WOS-28 | P0 | Gap | Code of Conduct | Add root `CODE_OF_CONDUCT.md`. |
| WOS-29 | P0 | Gap | Security | Add root `SECURITY.md`; private contact TBD. |
| WOS-30 | P1 | Gap | Issue templates | Add `.github/ISSUE_TEMPLATE`. |
| WOS-31 | P1 | Gap | PR template | Add `.github/PULL_REQUEST_TEMPLATE.md`. |
| WOS-32 | P1 | TBD | Labels | Add label checklist; GitHub admin action required. |
| WOS-33 | P1 | Gap | Good first issues | Add 5 candidates in `docs/github-labels.md`. |
| WOS-34 | P1 | TBD | Community entrance | GitHub Discussions/email/etc. needs confirmation. |
| WOS-35 | P1 | Aggregate | Release policy | Existing releases exist in subrepos; add root policy. |
| WOS-36 | P1 | Gap | Changelog | Add root `CHANGELOG.md`. |
| WOS-37 | P1 | Aggregate | CI checks | Existing partial workflows; add GitHub settings checklist. |
| WOS-38 | P1 | Aggregate | Download artifacts | Existing release assets need root aggregation. |
| WOS-39 | P1 | Aggregate | Multilingual | Existing bilingual docs; root public pages need English/Chinese consistency. |
| WOS-40 | P1 | Aggregate | Brand assets | Assets exist but public approval and structure need confirmation. |
| WOS-41 | P1 | TBD | Maintainers | Add role placeholders; names need confirmation. |
| WOS-42 | P1 | Aggregate | Branch policy | Add `docs/branch-policy.md`. |
| WOS-43 | P1 | TBD | Branch protection | Add admin checklist. |
| WOS-44 | P1 | Gap | Showcase | Add `docs/showcase.md`. |
| WOS-45 | P0 | Gap | External developer loop | Final report must verify full loop. |

## First-Round Self Score

Target score after this pass: 70/100.

Known gaps that keep the score below 100:

- License, community entrance, demo assets, public hardware scope, and maintainers require user / owner confirmation.
- Real hardware smoke tests are not run in this documentation pass.
- GitHub admin settings cannot be proven from local files.
