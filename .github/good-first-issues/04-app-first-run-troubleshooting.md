---
title: "Expand App first-run troubleshooting"
labels: "good first issue, app, docs"
---

## Background

The App README has run commands, but first-time contributors need clearer troubleshooting around Android/iOS tooling, Metro, BLE permission prompts, and release signing.

## Suggested Files

- `WatcheRobot_app/README.md`
- `WatcheRobot_app/README_zh.md`
- `WatcheRobot_app/android/gradle.release.example.properties`

## Expected Result

- Add a short troubleshooting section for local development.
- Clarify that release signing values must come from local files or CI secrets.
- Keep public display name as `WatcheRobot`.

## Acceptance

- No signing password or token is committed.
- App docs still pass the root readiness script naming and sensitive-value checks.
