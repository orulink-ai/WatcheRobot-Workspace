# Release Policy

Draft status: public release policy needs owner confirmation.

## Current Evidence

- ESP32 firmware contains release notes and packaged release folders.
- Desktop release assets are documented in the desktop repository.
- App and ESP32 have changelog files.
- Root workspace, desktop, server, and STM32 need unified release / changelog policy.

## Proposed Versioning

Use semantic prerelease naming unless a product owner decides otherwise:

- `v0.1.0-alpha`: first public open-source preview
- `v0.2.0-beta`: broader developer preview
- `v1.0.0`: production-ready public baseline

TODO(owner/date): Confirm version naming and whether App/Desktop/Firmware releases are synchronized or independent.

## Release Checklist

- [ ] Version compatibility matrix updated.
- [ ] Changelog updated.
- [ ] Firmware package and desktop package links verified.
- [ ] Checksums added where binaries are published.
- [ ] Open questions reviewed for public-blocking items.
- [ ] Security scan completed.

## Release Manifest

Use `docs/release-manifest.example.json` as the release artifact manifest template.

Draft validation with placeholders:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-release-manifest.ps1 -AllowPlaceholders
```

Regression tests for manifest validation:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-release-manifest-validation.ps1
```

Final release validation:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-release-manifest.ps1 -Manifest path\to\release-manifest.json
```

Final manifests must not contain pending tokens anywhere in the JSON. `version` must be a semantic version tag such as `v0.1.0-alpha`, `release_date` must be a valid non-future `YYYY-MM-DD` date, `release_url` must be an http(s) URL, component refs must include `workspace`, `app`, `desktop`, `server`, `esp32`, and `stm32`, and every component ref must be a 7-40 character commit hash or semantic version tag such as `v0.1.0-alpha`. Checks must include `readiness_script`, `hardware_smoke`, and `clean_machine` with the exact value `passed`. Artifact names must be unique, and artifact `required` fields must be JSON booleans. Each artifact `path_or_url` must be an http(s) URL or traceable repository/build file path, not a descriptive label, and each artifact must include a 64-character SHA-256 digest. The final manifest must include `desktop-windows-installer` as `desktop-installer` and `esp32-firmware-package` as `firmware`, both with `required: true`; `stm32-firmware-package` stays optional until the release owner confirms it is part of the public package, but must be complete if included.
