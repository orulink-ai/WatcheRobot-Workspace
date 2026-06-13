# App Gradle Evidence

Status: Draft
Owner: App / QA owner
Date: 2026-06-11
Environment: Current local Windows workspace shell in `D:\CodeProjects\WatcheRobot-Workspace`.
Evidence: `Get-Command java -ErrorAction SilentlyContinue` returned no command; `JAVA_HOME` was not set; common `C:\Program Files` Java / Android / Eclipse Adoptium paths did not contain `java.exe`; no Gradle command exit code, Gradle output log path, signing-secret exclusion evidence, or OQ-009 legacy identifier decision has been provided yet.
Result: Blocked because java is not available in PATH. Gradle dry-run was not executed.
Follow-up: Install or expose a supported JDK, then run `powershell -ExecutionPolicy Bypass -File .\scripts\check-open-source-readiness.ps1` without `-SkipGradle` or run `.\gradlew.bat :app:tasks --dry-run` from `WatcheRobot_app\android`. Record the exact command from `WatcheRobot_app/android`, Gradle task and build variant, Gradle command exit code, Gradle output log path, Metro / React Native command if used, confirmation that signing secrets are not included in shared evidence, and the OQ-009 legacy identifier decision.

## Required Checks

- Java command and version: Not available in PATH in the current shell; `java -version` was not executed successfully.
- JAVA_HOME: Not set in the current shell.
- Android SDK path and version: Not verified because Java is missing.
- WatcheRobot_app/android Gradle command: Pending; expected command must be run from `WatcheRobot_app/android` or provide the exact equivalent repository path.
- Gradle task and build variant: Pending until the App owner selects the validation task and variant.
- Gradle command exit code: Pending because Gradle dry-run was not executed.
- Gradle output log path: Pending because no Gradle log was produced.
- Metro / React Native command: Pending if a first-run or React Native validation command is used.
- OQ-009 legacy identifier decision: Pending App owner decision for legacy internal identifiers in build output.
- Signing secret exclusion: Pending confirmation that signing secrets are not included in shared evidence.
