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
    Add-Failure "Missing README file: $RelativePath"
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

function Assert-DoesNotContain {
  param(
    [string]$Content,
    [string]$Needle,
    [string]$Context
  )

  if ($Content -cmatch [regex]::Escape($Needle)) {
    Add-Failure "$Context contains forbidden text: $Needle"
  }
}

$EnglishReadme = Get-RepoText "README.md"
$ChineseReadme = Get-RepoText "README.zh-CN.md"

if ($EnglishReadme -and $EnglishReadme -notmatch '(?m)^# WatcheRobot\s*$') {
  Add-Failure "README.md must keep '# WatcheRobot' as the first public title."
}
if ($ChineseReadme -and $ChineseReadme -notmatch '(?m)^# WatcheRobot\s*$') {
  Add-Failure "README.zh-CN.md must keep '# WatcheRobot' as the first public title."
}

foreach ($Needle in @(
  "open-source desktop embodied AI robot",
  "EVT / open-source preparation",
  "Public scope, license, community entrance, and final demo assets are being confirmed",
  "## Demo",
  "PLACEHOLDER(product/design owner)",
  "## What You Can Build",
  "## Main Capabilities",
  "## Start Here",
  "## Repository Map",
  "## Quick Clone",
  "git submodule update --init --recursive",
  "## Common Commands",
  "## Core Development Paths",
  "## Open Source and Community",
  "Community entrance is not confirmed yet",
  "## Contribution Boundaries"
)) {
  Assert-Contains -Content $EnglishReadme -Needle $Needle -Context "README.md"
}

foreach ($Needle in @(
  "WatcheRobot",
  "EVT",
  "License",
  "## Demo",
  "PLACEHOLDER",
  "Open Questions",
  "git submodule update --init --recursive",
  "yarn status",
  "CONTRIBUTING.md",
  "CODE_OF_CONDUCT.md",
  "SECURITY.md"
)) {
  Assert-Contains -Content $ChineseReadme -Needle $Needle -Context "README.zh-CN.md"
}

$RequiredPaths = @(
  "README.zh-CN.md",
  "docs/README.md",
  "docs/quick-start.md",
  "docs/architecture.md",
  "docs/toolchain-matrix.md",
  "docs/open-source-scope.md",
  "docs/hardware-structure-map.md",
  "docs/open-questions.md",
  "docs/open-source-readiness-baseline.md",
  "docs/open-source-readiness-final.md",
  "docs/open-source-readiness-final.zh-CN.md",
  "docs/public-launch-validation.md",
  "WatcheRobot_app/README.md",
  "WatcheRobot_client/README.md",
  "WatcheRobot_server/README.md",
  "WatcheRobot_esp32/README.md",
  "WatcheRobot_stm32/README.md",
  "docs/provisioning.md",
  "docs/motion-guide.md",
  "docs/expression-guide.md",
  "docs/ai-integration.md",
  "docs/demo-asset-checklist.md",
  "examples/README.md",
  "LICENSE-TBD.md",
  "CONTRIBUTING.md",
  "CODE_OF_CONDUCT.md",
  "SECURITY.md",
  "docs/maintainers.md",
  "docs/branch-policy.md",
  "docs/release-policy.md",
  "docs/github-labels.md",
  "docs/github-settings-checklist.md",
  "docs/community-launch-plan.md",
  "docs/good-first-issues.md",
  "docs/showcase.md"
)

foreach ($Path in $RequiredPaths) {
  Assert-Contains -Content $EnglishReadme -Needle $Path -Context "README.md"
}

foreach ($Path in @(
  "docs/README.md",
  "docs/README.zh-CN.md",
  "docs/quick-start.md",
  "docs/architecture.md",
  "docs/toolchain-matrix.md",
  "docs/open-source-scope.md",
  "docs/hardware-structure-map.md",
  "docs/open-questions.md",
  "docs/open-source-readiness-final.md",
  "docs/open-source-readiness-final.zh-CN.md",
  "docs/public-launch-validation.md",
  "WatcheRobot_app/README.md",
  "WatcheRobot_client/README.md",
  "WatcheRobot_server/README.md",
  "WatcheRobot_esp32/README.md",
  "WatcheRobot_stm32/README.md",
  "docs/provisioning.md",
  "docs/motion-guide.md",
  "docs/expression-guide.md",
  "docs/ai-integration.md",
  "docs/demo-asset-checklist.md",
  "examples/README.md",
  "LICENSE-TBD.md",
  "CONTRIBUTING.md",
  "CODE_OF_CONDUCT.md",
  "SECURITY.md",
  "docs/github-labels.md",
  "docs/github-settings-checklist.md",
  "docs/community-launch-plan.md",
  "docs/good-first-issues.md",
  "docs/showcase.md"
)) {
  Assert-Contains -Content $ChineseReadme -Needle $Path -Context "README.zh-CN.md"
}

foreach ($ContentSpec in @(
  @{ name = "README.md"; content = $EnglishReadme },
  @{ name = "README.zh-CN.md"; content = $ChineseReadme }
)) {
  $Content = [string]$ContentSpec.content
  $Name = [string]$ContentSpec.name
  foreach ($Subrepo in @("WatcheRobot_app", "WatcheRobot_client", "WatcheRobot_server", "WatcheRobot_esp32", "WatcheRobot_stm32")) {
    Assert-Contains -Content $Content -Needle $Subrepo -Context $Name
  }
  foreach ($Forbidden in @("Watcherobot", "watcherobot", "Watcher Robot", "watcher-robot")) {
    Assert-DoesNotContain -Content $Content -Needle $Forbidden -Context $Name
  }
}

if ($Failures.Count -gt 0) {
  Write-Host "Public README contract tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Public README contract tests passed."
