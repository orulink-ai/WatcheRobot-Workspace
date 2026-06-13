---
title: "Add release asset checksum notes"
labels: "good first issue, release, docs"
---

## Background

Release packages and firmware artifacts need a public checklist for checksums, version notes, and cross-repository compatibility.

## Suggested Files

- `docs/release-policy.md`
- `CHANGELOG.md`
- `docs/release-manifest.example.json`
- `docs/github-settings-checklist.md`

## Expected Result

- Add or maintain release asset checklist entries for desktop installers, firmware packages, checksum files, and version notes.
- Explain how App, desktop, server, ESP32, and STM32 versions should be referenced when they are released together.

## Acceptance

- The release checklist does not invent version numbers.
- Unknown release cadence or owner names remain TODO/TBD.
