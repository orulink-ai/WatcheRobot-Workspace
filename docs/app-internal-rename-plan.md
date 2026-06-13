# App Internal Rename Plan

Public docs and display names now use `WatcheRobot`. Some internal React Native / native project identifiers still use `WatcherRobotAPP`; this is intentionally left as a dedicated rename task because native target renames are higher risk than documentation changes.

## Current Evidence

| Identifier | Current state | Risk |
| --- | --- | --- |
| Public App display name | `WatcheRobot` | Low; already updated. |
| React Native `app.json` `name` | `WatcherRobotAPP` | High; changing can affect native registration. |
| iOS project path / target | `ios/WatcherRobotAPP/` | High; changing touches Xcode project, Pod targets, bundle settings, and CI. |
| Android package / app internals | Needs separate audit | Medium/high depending on package identifiers. |

## Rename Strategy

1. Create a dedicated App subrepo branch.
2. Add tests or smoke checks that prove Android and iOS app startup before the rename.
3. Rename one layer at a time: JS app registration, Android native identifiers, iOS target/project identifiers, docs.
4. Run Android Gradle tasks, Metro startup, and iOS project validation after each layer.
5. Update root docs only after the App subrepo rename is merged.

## Do Not Do In This Root Pass

- Do not rename iOS folders or Xcode project files casually.
- Do not change React Native registration names without running platform builds.
- Do not rewrite remote repository URLs unless the GitHub repository has actually been renamed.

This plan closes the naming audit gap without introducing avoidable native build risk.
