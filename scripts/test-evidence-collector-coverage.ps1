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
    Add-Failure "Missing required file: $RelativePath"
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

$Readiness = Get-RepoText "scripts/check-open-source-readiness.ps1"
$Collector = Get-RepoText "scripts/collect-open-source-evidence.ps1"
$Plan = Get-RepoText "docs/open-source-delivery-plan.md"
$FinalReport = Get-RepoText "docs/open-source-readiness-final.md"
$ChineseFinalReport = Get-RepoText "docs/open-source-readiness-final.zh-CN.md"
$Handoff = Get-RepoText "docs/sub-agent-handoff.md"

$ReadinessScriptRefs = @(
  [regex]::Matches($Readiness, 'scripts[\\/][A-Za-z0-9_.-]+\.ps1') |
    ForEach-Object { ($_.Value -replace "\\", "/") } |
    Sort-Object -Unique
)

$AllowCollectorOmissions = @(
  "scripts/check-open-source-readiness.ps1",
  "scripts/collect-open-source-evidence.ps1",
  "scripts/sync-github-labels.ps1"
)

foreach ($ScriptRef in $ReadinessScriptRefs) {
  if ($AllowCollectorOmissions -contains $ScriptRef) {
    continue
  }
  Assert-Contains -Content $Collector -Needle $ScriptRef -Context "scripts/collect-open-source-evidence.ps1"
}

foreach ($Needle in @(
  "readiness script",
  "launch gate audit",
  "github remote audit",
  "git remote heads",
  'Test-CommandAvailable -Name "java"',
  'Test-CommandAvailable -Name "gh"',
  'Test-EnvAvailable -Name "GH_TOKEN"',
  'Test-EnvAvailable -Name "GITHUB_TOKEN"',
  "Evidence collector does not prove public launch complete"
)) {
  Assert-Contains -Content $Collector -Needle $Needle -Context "scripts/collect-open-source-evidence.ps1"
}

foreach ($Needle in @(
  "Evidence collector coverage",
  "scripts/test-evidence-collector-coverage.ps1"
)) {
  Assert-Contains -Content $Plan -Needle $Needle -Context "docs/open-source-delivery-plan.md"
  Assert-Contains -Content $FinalReport -Needle $Needle -Context "docs/open-source-readiness-final.md"
  Assert-Contains -Content $ChineseFinalReport -Needle $Needle -Context "docs/open-source-readiness-final.zh-CN.md"
  Assert-Contains -Content $Handoff -Needle $Needle -Context "docs/sub-agent-handoff.md"
}

if ($Failures.Count -gt 0) {
  Write-Host "Evidence collector coverage tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Evidence collector coverage tests passed."
