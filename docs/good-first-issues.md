# Good First Issue Drafts

These are issue drafts for maintainers to create after labels and GitHub settings are ready. Do not claim they already exist on GitHub until they are created in the repository.

Machine-readable drafts:

- `.github/good-first-issues/`

Preview or create them with:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\create-good-first-issues.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File .\scripts\create-good-first-issues.ps1
```

Validate that every draft references existing local labels:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-github-community-assets.ps1
```

## Draft 1: Improve Quick Start Error Notes

Labels: `good first issue`, `docs`

Background: `docs/quick-start.md` gives the happy path, but new developers also need common failure notes for missing Node, Yarn, Python, Java, Android SDK, Rust, and ESP-IDF.

Suggested files:

- `docs/quick-start.md`
- `docs/toolchain-matrix.md`

Expected result:

- Add a "Common failures" section.
- Keep each failure note short and actionable.
- Use TODO/TBD only for unverified environment-specific details.

Acceptance:

- Markdown links still pass `powershell -ExecutionPolicy Bypass -File .\scripts\check-open-source-readiness.ps1 -SkipGradle`.
- No personal path, port, token, or machine-specific value is added.

## Draft 2: Add an Expression Switching Smoke Script

Labels: `good first issue`, `examples`, `firmware`

Background: `examples/switch-expression-minimal/README.md` currently documents the intended payload but keeps the executable sender as TODO until the firmware command contract is confirmed.

Suggested files:

- `examples/switch-expression-minimal/README.md`
- `examples/switch-expression-minimal/`
- `docs/expression-guide.md`

Expected result:

- Add a minimal script only after confirming the BLE command format from firmware docs or code.
- Document expected ACK / status behavior.
- If the contract remains unclear, keep the TODO and update `docs/open-questions.md`.

Acceptance:

- The script can be syntax-checked locally.
- The README includes dependencies, command, expected result, and manual smoke-test steps.

## Draft 3: Map Hardware Resource Entry Points

Labels: `good first issue`, `hardware`, `docs`

Background: ESP32 hardware docs and some structure/model assets exist, but the public root docs need a clearer map of what is confirmed public, what is TBD, and what must not be published yet.

Suggested files:

- `docs/open-source-scope.md`
- `docs/extension-boundaries.md`
- `docs/assets/README.md`
- `docs/open-questions.md`

Expected result:

- Add a concise table for BOM, GPIO / Pin Map, wiring, STL, STEP, CAD, URDF, and assembly instructions.
- Mark each item as confirmed, existing-but-unconfirmed, or unavailable.
- Do not copy or expose unapproved assets.

Acceptance:

- Every uncertain hardware or structure item is represented as TODO/TBD.
- No private manufacturing file is added to the root repository.

## Draft 4: Expand App First-Run Troubleshooting

Labels: `good first issue`, `app`, `docs`

Background: The App README has run commands, but first-time contributors need clearer troubleshooting around Android/iOS tooling, Metro, BLE permission prompts, and release signing.

Suggested files:

- `WatcheRobot_app/README.md`
- `WatcheRobot_app/README_zh.md`
- `WatcheRobot_app/android/gradle.release.example.properties`

Expected result:

- Add a short troubleshooting section for local development.
- Clarify that release signing values must come from local files or CI secrets.
- Keep public display name as `WatcheRobot`.

Acceptance:

- No signing password or token is committed.
- App docs still pass the root readiness script naming and sensitive-value checks.

## Draft 5: Add Release Asset Checksum Notes

Labels: `good first issue`, `release`, `docs`

Background: Release packages and firmware artifacts need a public checklist for checksums, version notes, and cross-repository compatibility.

Suggested files:

- `docs/release-policy.md`
- `CHANGELOG.md`
- `docs/github-settings-checklist.md`

Expected result:

- Add a small release asset checklist for desktop installers, firmware packages, checksum files, and version notes.
- Explain how App, desktop, server, ESP32, and STM32 versions should be referenced when they are released together.

Acceptance:

- The release checklist does not invent version numbers.
- Unknown release cadence or owner names remain TODO/TBD.
