# Clean Machine Validation Evidence

Status: Draft
Owner: QA owner
Date: 2026-06-11
Environment: Current local Windows workspace shell in `D:\CodeProjects\WatcheRobot-Workspace`; this is not a fresh external developer machine.
Evidence: The launch gate audit previously reported `docs/launch-evidence/clean-machine.md` as missing. This draft records the blocker and the required validation route. Fresh clone directory, root commit hash, `git submodule status --recursive`, OS and tool versions, completed `docs/quick-start.md`, readiness output, example dry-run output, and no local cache reuse evidence are not available yet.
Result: Blocked because Clean-machine validation was not executed. Fresh clone was not run. Quick Start was not completed.
Follow-up: Run the public repository flow on a fresh machine with no local cache reuse, record the fresh clone directory, root commit hash, `git submodule status --recursive`, OS and tool versions, completed `docs/quick-start.md` path, `scripts/check-open-source-readiness.ps1 -SkipGradle` output, and `scripts/test-open-source-examples.ps1` output, then change Status to Passed only if all fields are complete.

## Required Checks

- Fresh clone directory: Fresh clone was not run.
- Root commit hash: root commit hash was not captured.
- git submodule status --recursive: Not captured from a clean validation machine.
- OS and tool versions: Not captured from a clean validation machine.
- docs/quick-start.md completed: Quick Start was not completed.
- scripts/check-open-source-readiness.ps1 -SkipGradle output: Not captured from a clean validation machine.
- scripts/test-open-source-examples.ps1 output: Not captured from a clean validation machine.
- No local cache reuse: no local cache reuse evidence is not available.
