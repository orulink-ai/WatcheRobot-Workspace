# GitHub Labels

This file is a configuration checklist. It does not prove labels already exist on GitHub.

Machine-readable config:

- `.github/labels.json`

Sync command after GitHub CLI is authenticated:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync-github-labels.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File .\scripts\sync-github-labels.ps1
```

The dry run is local-only and does not require GitHub CLI. It prints the commands that would be created.

Validate label and good-first-issue consistency:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-github-community-assets.ps1
```

GitHub CLI is not required for a read-only remote audit:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\audit-github-readiness.ps1
```

If the anonymous GitHub API is rate-limited, set `GH_TOKEN` or `GITHUB_TOKEN` and rerun the audit.

| Label | Purpose |
| --- | --- |
| `bug` | Something broken |
| `feature` | New capability request |
| `docs` | Documentation work |
| `app` | Mobile app scope |
| `desktop` | Desktop client scope |
| `server` | Server / AI runtime scope |
| `firmware` | ESP32 or STM32 firmware scope |
| `esp32` | ESP32-specific scope |
| `stm32` | STM32-specific scope |
| `hardware` | Hardware / structure / assembly scope |
| `examples` | Example code and smoke-test assets |
| `release` | Release notes, packages, checksums, and publication |
| `connection` | BLE, Wi-Fi, provisioning, discovery |
| `security` | Security or privacy-sensitive item |
| `good first issue` | Suitable for first-time contributors |
| `help wanted` | Maintainers would welcome outside contribution |
| `blocked: decision` | Waiting for product / legal / maintainer decision |
| `blocked: hardware` | Waiting for physical-device verification |

Good first issue candidates:

1. Improve `docs/toolchain-matrix.md` with exact desktop and STM32 versions.
2. Add screenshots to README after product assets are approved.
3. Run and document `examples/ble-control-minimal` on Windows.
4. Expand `docs/expression-guide.md` with current animation state names.
5. Add a troubleshooting entry for BLE provisioning timeout.
