# Release Artifact Evidence

Status: Draft
Owner: Release owner
Date: 2026-06-11
Environment: Current local Windows workspace shell in `D:\CodeProjects\WatcheRobot-Workspace`.
Evidence: `powershell -ExecutionPolicy Bypass -File .\scripts\validate-release-manifest.ps1` was run against the current placeholder manifest data.
Result: Blocked because final release artifacts and release metadata are not confirmed. Final validation currently rejects pending tokens in release version, release date, release URL, workspace/App/desktop/server/ESP32/STM32 component refs, component refs that are not commit hashes or semantic version tags, artifact names are duplicated, artifact required flags are not JSON booleans, artifact locations that are not http(s) URLs or traceable file paths, artifact checksums, and readiness / hardware smoke / clean-machine check results that are missing, pending, or not `passed`.
Follow-up: Replace placeholder desktop and ESP32 artifact `path_or_url` values with release-owner-approved http(s) URLs or traceable repository/build file paths, add SHA-256 checksums, fill semantic release version, release date, http(s) release URL, workspace/App/desktop/server/ESP32/STM32 component commit hashes or semantic version tags, and `passed` readiness / hardware smoke / clean-machine check results, include STM32 with complete URL/path and checksum evidence if it is published in this release, then run `powershell -ExecutionPolicy Bypass -File .\scripts\validate-release-manifest.ps1 -Manifest <final-manifest>`.

## Required Checks

- Desktop installer URL: TBD placeholder remains; not release-owner approved.
- ESP32 firmware package URL: Required package placeholder remains; not release-owner approved.
- STM32 firmware package URL, if published: Optional package placeholder remains in the example manifest and needs release-owner confirmation before public release.
- Artifact names: Final manifest artifact names must be unique.
- Artifact required flags: Final manifest artifact required flags must be JSON booleans, not strings.
- Artifact paths or URLs: Final artifact locations must be http(s) URLs or traceable repository/build file paths, not descriptive labels.
- Release URL: Final public release URL is not available.
- Checksums and metadata: Final SHA-256 checksums, semantic release version, release date, workspace/App/desktop/server/ESP32/STM32 component commit hashes or semantic version tags, and `passed` readiness / hardware smoke / clean-machine check results are not available.
- Release manifest validation command: `powershell -ExecutionPolicy Bypass -File .\scripts\validate-release-manifest.ps1 -Manifest <final-manifest>`
- Release notes: Release notes and artifact links must be updated after final artifact approval.
