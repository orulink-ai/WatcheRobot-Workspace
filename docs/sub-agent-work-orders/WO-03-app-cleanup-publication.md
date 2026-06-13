# WO-03: App Cleanup Publication

| Field | Instruction |
| --- | --- |
| Primary agent | App Agent |
| Start condition | The user asks to publish App public naming or signing cleanup in `WatcheRobot_app`. |
| Scope | Work only inside the App subrepo boundary and keep root meta repo staging separate. |
| Inputs | `WatcheRobot_app/README.md`, `WatcheRobot_app/README_zh.md`, `WatcheRobot_app/android/gradle.release.example.properties`, and `docs/app-internal-rename-plan.md`. |
| Allowed actions | Verify public App copy, signing example cleanup, App diff hygiene, and Gradle evidence when Java/Android tooling is available. |
| Do not | Do not rename native targets such as legacy internal identifiers without a dedicated App rename task and build evidence. |
| Required verification | `git -C WatcheRobot_app diff --check`, App README review, and App Gradle validation after Java is available. |
| Stop and escalate | Stop if native target rename is requested, Java/Android tooling is missing, or a change crosses into unrelated App features. |
| Deliverable | App subrepo diff summary, verification output, and remaining TODO/TBD/PLACEHOLDER items for App owner review. |
| Self-score note | App cleanup supports WatcheRobot public consistency but cannot close Java/App Gradle gate without actual tooling evidence. |

Do not claim App launch readiness until the App evidence file is complete.
