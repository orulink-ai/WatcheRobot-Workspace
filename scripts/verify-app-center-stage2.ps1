<#
.SYNOPSIS
Prints or runs the WatcheRobot App.Center Stage 2 verification plan.

.DESCRIPTION
By default this script is a dry-run checklist. It prints the automated evidence
commands and the manual device/signing evidence template without running tests,
builds, flashing, or hardware actions.

Use -RunAutomated to run the non-hardware automated checks. The automated path
can include the ESP32 build. Use -SkipEsp32Build only when the current machine
does not have ESP-IDF ready; that shortcut is useful for desktop/server/catalog
confidence but is not sufficient for 100/100 acceptance.

For PR or issue evidence, paste the command you ran, the final pass/fail line,
and the filled manual evidence template. Do not paste private signing keys,
Wi-Fi credentials, tokens, or local-only absolute paths that are not useful to
reviewers.

.PARAMETER RunAutomated
Runs the non-hardware automated verification steps instead of printing only the
plan.

.PARAMETER SkipEsp32Build
Skips the ESP32 build step. This is intended for PC-side confidence checks only
and does not produce complete acceptance evidence.

.EXAMPLE
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify-app-center-stage2.ps1

Print the full dry-run verification plan and manual evidence template.

.EXAMPLE
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify-app-center-stage2.ps1 -RunAutomated

Run the automated desktop, server, catalog, and ESP32 build checks.

.EXAMPLE
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify-app-center-stage2.ps1 -RunAutomated -SkipEsp32Build

Run only the PC-side automated checks when ESP-IDF is not available.
#>

param(
    [switch]$RunAutomated,
    [switch]$SkipEsp32Build
)

$ErrorActionPreference = "Stop"

$workspaceRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$desktopRoot = Join-Path $workspaceRoot "WatcheRobot_client\Watcher Desktop App"
$serverRoot = Join-Path $workspaceRoot "WatcheRobot_server"
$esp32Root = Join-Path $workspaceRoot "WatcheRobot_esp32\firmware\s3"
$localCatalogScript = Join-Path $PSScriptRoot "check-app-center-local.ps1"
$esp32BuildScript = Join-Path $PSScriptRoot "build-esp32.ps1"
$signingFixtureDir = Join-Path ([System.IO.Path]::GetTempPath()) "watcher-appcenter-signing-fixtures-verify"
$acceptanceTemplate = Join-Path $workspaceRoot "docs\app-center-stage2-acceptance-template.md"

function Write-Step {
    param(
        [string]$Title,
        [string]$Command,
        [string]$Evidence
    )

    Write-Host ""
    Write-Host "== $Title ==" -ForegroundColor Cyan
    Write-Host "Command : $Command"
    Write-Host "Evidence: $Evidence"
}

function Invoke-Step {
    param(
        [string]$Title,
        [scriptblock]$Body
    )

    Write-Host ""
    Write-Host "== Running: $Title ==" -ForegroundColor Cyan
    & $Body
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

function Write-ManualEvidenceTemplate {
    Write-Host ""
    Write-Host "== Manual evidence template ==" -ForegroundColor Cyan
    Write-Host "Device:"
    Write-Host "  ESP32 port / firmware commit:"
    Write-Host "  Watcher device id / MAC:"
    Write-Host "  Desktop app commit:"
    Write-Host "  Server commit:"
    Write-Host ""
    Write-Host "Device flow:"
    Write-Host "  [ ] App.Center opens with one selected online Watcher"
    Write-Host "  [ ] ESP-NOW Remote package imports or downloads successfully"
    Write-Host "  [ ] Transfer/install reaches installed state on the selected device"
    Write-Host "  [ ] Open on device starts the installed ESP-NOW Remote app"
    Write-Host "  [ ] Uninstall from device removes only the device-side app"
    Write-Host "  [ ] Refresh device apps no longer shows the uninstalled app"
    Write-Host "  [ ] Disconnect/reconnect restores device app state without stale global fallback"
    Write-Host ""
    Write-Host "Signing:"
    Write-Host "  Fixture directory: $signingFixtureDir"
    Write-Host "  [ ] Valid ecdsa-p256-sha256 package installs"
    Write-Host "  [ ] Tampered digest returns install_failed"
    Write-Host "  [ ] Untrusted public key returns install_failed"
    Write-Host "  [ ] Wrong issuer returns install_failed when issuer allowlist is configured"
    Write-Host ""
    Write-Host "Customer UI review:"
    Write-Host "  [ ] App.Center first screen explains the flow as Get package -> Pick Watcher -> Install or manage"
    Write-Host "  [ ] Primary actions are obvious: import/download, select package, transfer/install, open, uninstall"
    Write-Host "  [ ] Empty states tell the user the next step instead of showing a generic blank panel"
    Write-Host "  [ ] Remove local clearly says it only deletes the desktop cache"
    Write-Host "  [ ] Uninstall clearly says it removes only the device-side App.Center app"
    Write-Host "  [ ] Technical protocol details stay secondary and do not dominate the customer path"
}

function Write-EvidenceRecordingTip {
    Write-Host ""
    Write-Host "== Evidence recording tip ==" -ForegroundColor Cyan
    Write-Host "For an issue or PR, record:"
    Write-Host "  - The exact command used, for example npm run appcenter:verify:run"
    Write-Host "  - The final pass/fail line from this script"
    Write-Host "  - The filled manual device/signing/UI evidence template"
    Write-Host "  - Prefer filling docs/app-center-stage2-acceptance-template.md for complete release evidence"
    Write-Host "Do not paste private signing keys, Wi-Fi credentials, tokens, or unrelated local-only paths."
}

Write-Host "App.Center Stage 2 verification plan" -ForegroundColor Yellow
Write-Host "Workspace: $workspaceRoot"
Write-Host ""
Write-Host "Default mode is dry-run. Pass -RunAutomated to run non-hardware automated checks."
Write-Host "Use -SkipEsp32Build with -RunAutomated when you only want desktop/server/catalog evidence."
if ($SkipEsp32Build) {
    Write-Host "WARNING: ESP32 build is skipped. This run is not sufficient for 100/100 acceptance." -ForegroundColor Yellow
}
Write-Host "Hardware checks, flashing, and device-side production signing acceptance remain manual evidence."
Write-Host "Acceptance template: $acceptanceTemplate"

Write-Step `
    -Title "Desktop App.Center static guard tests" `
    -Command "cd `"$desktopRoot`"; npm run test:server-scripts" `
    -Evidence "server root priority, app-package protocol constants, signature canonicalization, real P-256 signing/tamper check, UI copy, and device status categories pass."

Write-Step `
    -Title "App.Center signing fixture generation" `
    -Command "cd `"$desktopRoot`"; npm run appcenter:signing-fixtures -- --out `"$signingFixtureDir`"" `
    -Evidence "valid trusted, tampered digest, untrusted key, and wrong issuer packages can be generated for device-side signing acceptance."

Write-Step `
    -Title "Desktop typecheck" `
    -Command "cd `"$desktopRoot`"; npm run typecheck" `
    -Evidence "App.Center workspace, shared policy/state, and Tauri command typings compile."

Write-Step `
    -Title "Desktop renderer build" `
    -Command "cd `"$desktopRoot`"; npm run build:renderer" `
    -Evidence "The App.Center customer install flow renders through the production Vite build without TypeScript or bundling regressions."

Write-Step `
    -Title "Server protocol tests" `
    -Command "cd `"$serverRoot`"; python -m pytest tests/test_protocol_dispatcher.py" `
    -Evidence "app.package transfer/open/uninstall/list routing and disconnect abort behavior pass."

Write-Step `
    -Title "App.Center sample catalog checks" `
    -Command "powershell -NoProfile -ExecutionPolicy Bypass -File `"$localCatalogScript`"" `
    -Evidence "apps.json, packageUrl, sample package metadata, and local HTTP fetch path are valid."

if (-not $SkipEsp32Build) {
    Write-Step `
        -Title "ESP32 build" `
        -Command "powershell -NoProfile -ExecutionPolicy Bypass -File `"$esp32BuildScript`"" `
        -Evidence "ESP32 App.Center install manager, mbedTLS signature verification, and WebSocket handlers compile."
} else {
    Write-Step `
        -Title "ESP32 build" `
        -Command "Skipped by -SkipEsp32Build" `
        -Evidence "Missing until the ESP32 build is run; this shortcut cannot be used as full 100/100 evidence."
}

Write-Step `
    -Title "Manual device flow" `
    -Command "Run desktop App.Center with one online Watcher, import/download espnow-remote package, transfer/install, open, uninstall, disconnect/reconnect, refresh device apps." `
    -Evidence "Real device completes install/open/uninstall/reconnect recovery without stale Device apps state."

Write-Step `
    -Title "Manual signing acceptance" `
    -Command "Use the generated signing fixtures, configure ESP32 trusted public key hash/issuer from signing-fixtures-summary.json, then test valid and invalid packages on device." `
    -Evidence "Device-side policy accepts a trusted signed package and rejects tampered digest, untrusted public key, and wrong issuer with install_failed."

Write-Step `
    -Title "Manual customer UI review" `
    -Command "Open the desktop App.Center page and review the first-run, staged-package, installed, empty, and dangerous-action states." `
    -Evidence "A customer can understand the three-step install/manage flow without reading protocol details, and destructive actions are clearly scoped."

if (-not $RunAutomated) {
    Write-ManualEvidenceTemplate
    Write-EvidenceRecordingTip
    Write-Host ""
    if ($SkipEsp32Build) {
        Write-Host "Dry-run note: ESP32 build is marked as skipped in this plan." -ForegroundColor Yellow
    }
    Write-Host "Dry-run complete. No commands were executed." -ForegroundColor Green
    exit 0
}

foreach ($path in @($desktopRoot, $serverRoot, $localCatalogScript, $acceptanceTemplate)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Required verification path not found: $path"
    }
}
$acceptanceTemplateText = Get-Content -LiteralPath $acceptanceTemplate -Raw
foreach ($requiredText in @(
        "App.Center Stage 2",
        "npm run appcenter:verify:run",
        "Desktop App.Center static guard tests",
        "ESP-NOW Remote",
        "trustedPublicKeySha256",
        "trustedIssuer",
        "Get package -> Pick Watcher -> Install or manage",
        "role=`"status`"",
        "aria-live=`"polite`"",
        "01-valid-trusted.pkg",
        "02-tampered-digest.pkg",
        "03-untrusted-key.pkg",
        "04-wrong-issuer.pkg",
        "Remove local",
        "Uninstall from device"
    )) {
    if ($acceptanceTemplateText -notlike "*$requiredText*") {
        throw "Acceptance template is missing required evidence item: $requiredText"
    }
}
if (-not $SkipEsp32Build) {
    foreach ($path in @($esp32Root, $esp32BuildScript)) {
        if (-not (Test-Path -LiteralPath $path)) {
            throw "Required ESP32 verification path not found: $path"
        }
    }
}

Invoke-Step "Desktop App.Center static guard tests" {
    Push-Location $desktopRoot
    try {
        npm run test:server-scripts
    } finally {
        Pop-Location
    }
}

Invoke-Step "App.Center signing fixture generation" {
    Push-Location $desktopRoot
    try {
        npm run appcenter:signing-fixtures -- --out $signingFixtureDir
    } finally {
        Pop-Location
    }
}

Invoke-Step "Desktop typecheck" {
    Push-Location $desktopRoot
    try {
        npm run typecheck
    } finally {
        Pop-Location
    }
}

Invoke-Step "Desktop renderer build" {
    Push-Location $desktopRoot
    try {
        npm run build:renderer
    } finally {
        Pop-Location
    }
}

Invoke-Step "Server protocol tests" {
    Push-Location $serverRoot
    try {
        python -m pytest tests/test_protocol_dispatcher.py
    } finally {
        Pop-Location
    }
}

Invoke-Step "App.Center sample catalog checks" {
    powershell -NoProfile -ExecutionPolicy Bypass -File $localCatalogScript
}

if (-not $SkipEsp32Build) {
    Invoke-Step "ESP32 build" {
        powershell -NoProfile -ExecutionPolicy Bypass -File $esp32BuildScript
    }
} else {
    Write-Host ""
    Write-Host "== Skipping: ESP32 build ==" -ForegroundColor Yellow
    Write-Host "This run is useful for desktop/server confidence, but it is not enough for 100/100 acceptance."
}

Write-Host ""
Write-Host "Automated checks completed. Manual device flow, device-side signing acceptance, and customer UI review evidence are still required for 100/100." -ForegroundColor Green
Write-ManualEvidenceTemplate
Write-EvidenceRecordingTip

