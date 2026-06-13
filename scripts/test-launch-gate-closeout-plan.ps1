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
    [string]$Context
  )

  if (-not $Content.Contains($Needle)) {
    Add-Failure "$Context is missing required text: $Needle"
  }
}

function Invoke-LaunchGateAuditJson {
  $Output = & powershell -ExecutionPolicy Bypass -File (Join-Path $Root "scripts/audit-open-source-launch-gates.ps1") -Json -SkipExternal
  if ($LASTEXITCODE -ne 0) {
    Add-Failure "Launch gate audit JSON command failed with exit code $LASTEXITCODE"
    return $null
  }

  try {
    return (($Output -join [Environment]::NewLine) | ConvertFrom-Json)
  } catch {
    Add-Failure "Launch gate audit JSON output could not be parsed: $($_.Exception.Message)"
    return $null
  }
}

$PlanPath = Join-Path $Root "docs/launch-gate-closeout-plan.md"
if (-not (Test-Path -LiteralPath $PlanPath)) {
  Add-Failure "Missing file: docs/launch-gate-closeout-plan.md"
} else {
  $Content = Get-Content -LiteralPath $PlanPath -Raw -Encoding UTF8

  foreach ($RequiredText in @(
    "# Launch Gate Closeout Plan",
    "This plan does not close gates by itself.",
    "Do not create passed evidence without observed results.",
    "scripts/audit-open-source-launch-gates.ps1",
    "scripts/collect-open-source-evidence.ps1 -SkipGradle",
    "docs/launch-evidence/templates/",
    "docs/launch-evidence-request-pack.md",
    'Every passed launch gate must have its corresponding evidence file with `Status: Passed`',
    "README, license, release manifest, or remote GitHub state changes are necessary inputs, but they do not close a gate without the matching launch evidence file.",
    "| Gate | Owner | Current status | Evidence file or source | Closeout action | Pass signal |",
    "docs/owner-decision-record.md",
    "docs/launch-evidence/owner-decisions.md",
    "docs/launch-evidence/final-license.md",
    "docs/launch-evidence/community-entrance.md",
    "docs/launch-evidence/demo-asset.md",
    "valid non-future",
    "LICENSE",
    "README.md",
    "docs/launch-evidence/github-admin.md",
    "docs/launch-evidence/release-artifacts.md",
    "docs/launch-evidence/app-gradle.md",
    "docs/launch-evidence/clean-machine.md",
    "docs/launch-evidence/hardware-smoke.md",
    "scripts/audit-github-readiness.ps1",
    "scripts/validate-release-manifest.ps1",
    "all six required component refs as commit hashes or semantic version tags",
    'complete owner/date/environment/evidence/result/follow-up fields',
    'no pending tokens',
    'docs/launch-evidence/owner-decisions.md` has `Status: Passed` with complete owner/date/environment/evidence/result/follow-up fields',
    'docs/launch-evidence/final-license.md` has `Status: Passed` with complete owner/date/environment/evidence/result/follow-up fields',
    'docs/launch-evidence/community-entrance.md` has `Status: Passed` with complete owner/date/environment/evidence/result/follow-up fields',
    'docs/launch-evidence/demo-asset.md` has `Status: Passed` with complete owner/date/environment/evidence/result/follow-up fields',
    'docs/launch-evidence/github-admin.md` has `Status: Passed` with complete owner/date/environment/evidence/result/follow-up fields',
    'docs/launch-evidence/release-artifacts.md` has `Status: Passed` with complete owner/date/environment/evidence/result/follow-up fields'
  )) {
    Assert-Contains -Content $Content -Needle $RequiredText -Context "docs/launch-gate-closeout-plan.md"
  }

  $Audit = Invoke-LaunchGateAuditJson
  if ($null -ne $Audit) {
    foreach ($Gate in $Audit.gates) {
      $Needle = "| $($Gate.name) |"
      Assert-Contains -Content $Content -Needle $Needle -Context "docs/launch-gate-closeout-plan.md"
    }
  }
}

if ($Failures.Count -gt 0) {
  Write-Host "Launch gate closeout plan tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Launch gate closeout plan tests passed."
