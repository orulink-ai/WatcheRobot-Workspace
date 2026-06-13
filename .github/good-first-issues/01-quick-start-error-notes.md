---
title: "Improve Quick Start error notes"
labels: "good first issue, docs"
---

## Background

`docs/quick-start.md` gives the happy path, but new developers also need common failure notes for missing Node, Yarn, Python, Java, Android SDK, Rust, and ESP-IDF.

## Suggested Files

- `docs/quick-start.md`
- `docs/toolchain-matrix.md`

## Expected Result

- Add a "Common failures" section.
- Keep each failure note short and actionable.
- Use TODO/TBD only for unverified environment-specific details.

## Acceptance

- Markdown links still pass `powershell -ExecutionPolicy Bypass -File .\scripts\check-open-source-readiness.ps1 -SkipGradle`.
- No personal path, port, token, or machine-specific value is added.
