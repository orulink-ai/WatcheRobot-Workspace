# Product Name Policy

Public product name: `WatcheRobot`

This policy exists because older notes, source file names, package identifiers, and imported planning artifacts may still contain legacy spellings. New public-facing documentation, release text, community material, and README copy must use `WatcheRobot`.

## Forbidden Public Spellings

Forbidden public spellings:

- `Watcherobot`
- `watcherobot`
- `Watcher Robot`
- `watcher-robot`
- `WatcherRobot`

Do not introduce these spellings in new public copy unless the line is explicitly documenting a legacy technical identifier or a migration decision.

## Allowed Technical Exceptions

Allowed technical exceptions are narrow:

- `WatcherRobotAPP` may remain as a legacy React Native / iOS target identifier until OQ-009 is closed.
- `resources/robot/models/watcherobot-*.stl` may remain as existing model file paths until the hardware owner approves a rename or release packaging change.
- Existing package names, upstream repository names, and source plan document names may be preserved when changing them would break tooling, history, or imported evidence.

Do not rename high-risk native targets without owner approval and build evidence.

## Update Rule

When editing public material:

1. Use `WatcheRobot` for the product name.
2. Keep legacy names only where they are technical identifiers, file paths, or source evidence.
3. If a legacy name becomes user-visible, either rename it with verification or record the reason in [Owner Decision Record](owner-decision-record.md).
4. Run `powershell -ExecutionPolicy Bypass -File .\scripts\test-product-name-policy.ps1`.
