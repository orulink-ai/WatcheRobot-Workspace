# Branch Policy

This workspace uses multiple repositories. Each repository keeps its own default branch, but cross-repository work must be coordinated.

| Repository | Current branch evidence | Policy |
| --- | --- | --- |
| Root workspace | `main` in current checkout | Workspace docs, scripts, submodule references |
| App | `dev` from `.gitmodules` | App work and BLE mobile flows |
| Desktop | `main` from `.gitmodules` | Desktop client work |
| Server | `main` from `.gitmodules` | Server / AI runtime work |
| ESP32 | `main` from `.gitmodules` | ESP32 firmware work |
| STM32 | `dev` from `.gitmodules` | STM32 firmware work |

## Cross-Repository Work

- Commit in each affected repository separately.
- Mention paired commits in the commit body.
- Do not commit subrepository source changes into the root repository.
- Do not change gitlink pointers unintentionally.

## Release Branches

TODO(owner/date): Confirm official release branch naming before public launch.
