param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$Failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([string]$Message)
  $script:Failures.Add($Message)
}

function Assert-Contains {
  param(
    [string]$Content,
    [string]$Needle,
    [string]$Path
  )

  if (-not $Content.Contains($Needle)) {
    Add-Failure "$Path is missing required text: $Needle"
  }
}

function Get-TableRowsById {
  param(
    [string]$Content,
    [string]$Pattern,
    [string]$Path
  )

  $Rows = @{}
  foreach ($Line in ($Content -split "`r?`n")) {
    if ($Line -notmatch $Pattern) {
      continue
    }

    $Id = $Matches[1]
    if ($Rows.ContainsKey($Id)) {
      Add-Failure "$Path contains duplicate row for $Id"
      continue
    }

    $Rows[$Id] = $Line
  }

  return $Rows
}

$RelativePath = "docs/launch-evidence-request-pack.md"
$Path = Join-Path $Root $RelativePath
if (-not (Test-Path -LiteralPath $Path)) {
  Add-Failure "Missing file: $RelativePath"
} else {
  $Content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8

  foreach ($RequiredText in @(
    '# Launch Evidence Request Pack',
    'WatcheRobot',
    'This pack does not close any launch gate by itself.',
    'Do not mark `Status: Passed` from this pack alone.',
    'If no reply arrives, keep the gate unavailable and keep TODO/TBD/PLACEHOLDER markers in the public docs.',
    'docs/owner-decision-record.md',
    'docs/open-source-launch-gates.md',
    'docs/launch-gate-closeout-plan.md',
    'docs/launch-evidence/README.md',
    'scripts/audit-open-source-launch-gates.ps1',
    'traceable source marker',
    'workspace/App/desktop/server/ESP32/STM32 component refs are commit hashes or semantic version tags',
    'powershell -ExecutionPolicy Bypass -File .\scripts\validate-release-manifest.ps1 -Manifest <final-manifest>',
    'powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-request-pack.ps1',
    'powershell -ExecutionPolicy Bypass -File .\scripts\check-open-source-readiness.ps1 -SkipGradle',
    'Reply Template',
    'Can this close the gate? Yes / No'
  )) {
    Assert-Contains -Content $Content -Needle $RequiredText -Path $RelativePath
  }

  $DecisionRows = Get-TableRowsById -Content $Content -Pattern "^\|\s*(OQ-\d{3})\s*\|" -Path $RelativePath
  $ExpectedDecisions = 1..9 | ForEach-Object { "OQ-{0:D3}" -f $_ }
  foreach ($Decision in $ExpectedDecisions) {
    if (-not $DecisionRows.ContainsKey($Decision)) {
      Add-Failure "$RelativePath is missing owner decision request row: $Decision"
    }
  }

  foreach ($FoundDecision in $DecisionRows.Keys) {
    if ($ExpectedDecisions -notcontains $FoundDecision) {
      Add-Failure "$RelativePath contains unexpected owner decision request row: $FoundDecision"
    }
  }

  foreach ($Gate in @(
    "owner decisions",
    "final license",
    "community entrance",
    "approved demo asset",
    "github admin state",
    "release manifest",
    "java and app gradle",
    "clean-machine validation",
    "hardware smoke validation"
  )) {
    if ($Content -notmatch "(?m)^\|\s*$([regex]::Escape($Gate))\s*\|") {
      Add-Failure "$RelativePath is missing launch evidence request row: $Gate"
    }
  }

  foreach ($EvidenceFile in @(
    "docs/launch-evidence/owner-decisions.md",
    "docs/launch-evidence/final-license.md",
    "docs/launch-evidence/community-entrance.md",
    "docs/launch-evidence/demo-asset.md",
    "docs/launch-evidence/github-admin.md",
    "docs/launch-evidence/release-artifacts.md",
    "docs/launch-evidence/app-gradle.md",
    "docs/launch-evidence/clean-machine.md",
    "docs/launch-evidence/hardware-smoke.md"
  )) {
    Assert-Contains -Content $Content -Needle $EvidenceFile -Path $RelativePath
  }
}

if ($Failures.Count -gt 0) {
  Write-Host "Launch evidence request pack tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Launch evidence request pack tests passed."
