param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$Failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([string]$Message)
  $script:Failures.Add($Message)
}

function Get-RepoText {
  param([string]$RelativePath)

  $Path = Join-Path $Root $RelativePath
  if (-not (Test-Path -LiteralPath $Path)) {
    Add-Failure "Missing developer onboarding file: $RelativePath"
    return ""
  }

  return Get-Content -LiteralPath $Path -Raw -Encoding UTF8
}

function Assert-Contains {
  param(
    [string]$Content,
    [string]$Needle,
    [string]$Context
  )

  $NormalizedContent = $Content -replace "\\", "/"
  $NormalizedNeedle = $Needle -replace "\\", "/"
  if ($Content -notmatch [regex]::Escape($Needle) -and $NormalizedContent -notmatch [regex]::Escape($NormalizedNeedle)) {
    Add-Failure "$Context is missing required text: $Needle"
  }
}

$QuickStart = Get-RepoText "docs/quick-start.md"
$Toolchain = Get-RepoText "docs/toolchain-matrix.md"
$Examples = Get-RepoText "examples/README.md"

foreach ($Needle in @(
  "# Quick Start",
  "external developers",
  "git clone <repo-url>",
  "cd WatcheRobot-Workspace",
  "git submodule update --init --recursive",
  "yarn status",
  "Expected result",
  "WatcheRobot_app",
  "WatcheRobot_client",
  "WatcheRobot_server",
  "WatcheRobot_esp32",
  "WatcheRobot_stm32",
  "## 2. Desktop Client",
  "yarn desktop:dev",
  "WatcheRobot_client/README.md",
  "## 3. Server",
  "yarn server:start:checked",
  "WatcheRobot_server/README.md",
  "## 4. Mobile App",
  "yarn app:start",
  "yarn app:android",
  "WatcheRobot_app/README.md",
  "## 5. ESP32-S3 Firmware",
  "yarn esp32:build",
  "WatcheRobot_esp32/README.md",
  "## 6. STM32 Firmware",
  "yarn stm32",
  "WatcheRobot_stm32/README.md",
  "## 7. Minimal Examples",
  "examples/ble-control-minimal",
  "examples/send-motion-minimal",
  "examples/switch-expression-minimal",
  "examples/creator-template-minimal",
  ".codex/local/device-map.toml",
  "docs/open-questions.md"
)) {
  Assert-Contains -Content $QuickStart -Needle $Needle -Context "docs/quick-start.md"
}

foreach ($Needle in @(
  "# Toolchain Matrix",
  "If a version is not confirmed, it is marked as TBD",
  "| Area | Tool | Version / Requirement | Evidence |",
  "Root workspace",
  "Yarn / npm",
  "Node.js",
  "React Native",
  "Android Studio / Xcode",
  "Desktop",
  "Tauri",
  "Rust",
  "Server",
  "Python",
  "ESP32",
  "ESP-IDF",
  "STM32",
  "STM32 toolchain",
  "WatcheRobot_app/README.md",
  "WatcheRobot_client/README.md",
  "WatcheRobot_server/README.md",
  "WatcheRobot_esp32/README.md",
  "WatcheRobot_stm32/README.md",
  "TODO(owner/date)"
)) {
  Assert-Contains -Content $Toolchain -Needle $Needle -Context "docs/toolchain-matrix.md"
}

foreach ($Needle in @(
  "# WatcheRobot Examples",
  "ble-control-minimal",
  "send-motion-minimal",
  "switch-expression-minimal",
  "ai-reminder-minimal",
  "creator-template-minimal",
  "Local dry-run passes",
  "requires hardware smoke test",
  "## Test Rule",
  "dependencies",
  "command line",
  "expected output",
  "failure handling",
  "manual smoke test",
  "..\scripts\test-open-source-examples.ps1",
  "Do not claim an example is fully verified until it has been tested on hardware"
)) {
  Assert-Contains -Content $Examples -Needle $Needle -Context "examples/README.md"
}

if ($Failures.Count -gt 0) {
  Write-Host "Developer onboarding contract tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Developer onboarding contract tests passed."
