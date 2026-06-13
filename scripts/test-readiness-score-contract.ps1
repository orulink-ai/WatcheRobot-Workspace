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

function Read-Text {
  param([string]$RelativePath)

  $Path = Join-Path $Root $RelativePath
  if (-not (Test-Path -LiteralPath $Path)) {
    Add-Failure "Missing file: $RelativePath"
    return ""
  }

  return Get-Content -LiteralPath $Path -Raw -Encoding UTF8
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

$Final = Read-Text "docs/open-source-readiness-final.md"
$FinalZh = Read-Text "docs/open-source-readiness-final.zh-CN.md"
$Handoff = Read-Text "docs/sub-agent-handoff.md"
$LaunchGates = Read-Text "docs/open-source-launch-gates.md"
$Plan = Read-Text "docs/open-source-delivery-plan.md"

foreach ($Required in @(
  "Current score: 99/100.",
  "Why not higher:",
  "Launch gate audit still reports 9 unavailable final gates",
  "Do not claim 100/100 until every launch gate is passed."
)) {
  Assert-Contains -Content $Final -Needle $Required -Context "docs/open-source-readiness-final.md"
}

foreach ($Required in @(
  "99/100",
  "100/100",
  "Launch gate audit",
  "unavailable",
  "clean-machine",
  "smoke"
)) {
  Assert-Contains -Content $FinalZh -Needle $Required -Context "docs/open-source-readiness-final.zh-CN.md"
}

foreach ($Required in @(
  "Score | 99/100",
  "External Evidence Needed Before 100/100",
  "Any WOS row lacks current evidence"
)) {
  Assert-Contains -Content $Handoff -Needle $Required -Context "docs/sub-agent-handoff.md"
}

foreach ($Required in @(
  "Move to 100/100 only after this gate audit is fully passed",
  "score_rule = `"Do not claim 100/100 until every launch gate is passed.`""
)) {
  if ($Required -like "score_rule*") {
    continue
  }
  Assert-Contains -Content $LaunchGates -Needle $Required -Context "docs/open-source-launch-gates.md"
}

Assert-Contains -Content $Plan -Needle "Final evidence refresh and self-score" -Context "docs/open-source-delivery-plan.md"

$Audit = Invoke-LaunchGateAuditJson
if ($null -ne $Audit) {
  if ($Audit.score_rule -ne "Do not claim 100/100 until every launch gate is passed.") {
    Add-Failure "Launch gate audit score_rule changed unexpectedly: $($Audit.score_rule)"
  }

  if ($Audit.summary.failed -ne 0) {
    Add-Failure "Launch gate audit has failed gates: $($Audit.summary.failed)"
  }

  if ($Audit.summary.unavailable -gt 0) {
    foreach ($Context in @(
      @{ name = "docs/open-source-readiness-final.md"; content = $Final },
      @{ name = "docs/open-source-readiness-final.zh-CN.md"; content = $FinalZh },
      @{ name = "docs/sub-agent-handoff.md"; content = $Handoff }
    )) {
      if ($Context.content -match "(?m)^\s*(Current score:\s*)?100/100\b") {
        Add-Failure "$($Context.name) claims 100/100 while launch gates are still unavailable."
      }
    }
  }

  $ExpectedGateNames = @(
    "owner decisions",
    "final license",
    "community entrance",
    "approved demo asset",
    "github admin state",
    "release manifest",
    "java and app gradle",
    "clean-machine validation",
    "hardware smoke validation"
  )

  $FoundGateNames = @($Audit.gates | ForEach-Object { $_.name })
  foreach ($ExpectedGateName in $ExpectedGateNames) {
    if ($FoundGateNames -notcontains $ExpectedGateName) {
      Add-Failure "Launch gate audit is missing expected gate: $ExpectedGateName"
    }
  }
}

if ($Failures.Count -gt 0) {
  Write-Host "Readiness score contract tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Readiness score contract tests passed."
