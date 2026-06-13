# Release Artifact Evidence

Status: Draft
Owner:
Date:
Environment:
Evidence:
Result:
Follow-up:

## Required Checks

- Desktop installer URL:
- ESP32 firmware package URL:
- STM32 firmware package URL, if published:
- Artifact names: must be unique across the final manifest.
- Artifact required flags: must be JSON booleans, not strings.
- Artifact paths or URLs: must be http(s) URLs or traceable repository/build file paths, not descriptive labels.
- Checksums:
- Release version:
- Release URL:
- Component refs: workspace/App/desktop/server/ESP32/STM32 commit hashes or semantic version tags
- Required checks: readiness_script, hardware_smoke, clean_machine
- Release manifest validation command: `powershell -ExecutionPolicy Bypass -File .\scripts\validate-release-manifest.ps1 -Manifest <final-manifest>`
- Release notes:

## Notes

Copy this file to `docs/launch-evidence/release-artifacts.md` only after the release assets are published and verified.
