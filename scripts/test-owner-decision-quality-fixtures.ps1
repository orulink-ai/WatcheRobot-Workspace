param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$TargetScript = Join-Path $Root "scripts/test-owner-decision-record.ps1"
$Failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([string]$Message)
  $script:Failures.Add($Message)
}

function New-OpenQuestionsContent {
  $Lines = @(
    "# Open Questions",
    "",
    "| ID | Question |",
    "| --- | --- |"
  )

  foreach ($Index in 1..9) {
    $Id = "OQ-{0:D3}" -f $Index
    $Lines += "| $Id Question | Fixture question $Index |"
  }

  return ($Lines -join [Environment]::NewLine) + [Environment]::NewLine
}

function New-OwnerDecisionContent {
  param(
    [string]$ClosedDate,
    [string]$ClosedEvidence = '`docs/launch-evidence/fixture.md`'
  )

  $Lines = @(
    "# Owner Decision Record",
    "",
    "| Open question | Decision needed | Owner | Final decision | Evidence / link | Date | Status |",
    "| --- | --- | --- | --- | --- | --- | --- |"
  )

  foreach ($Index in 1..9) {
    $Id = "OQ-{0:D3}" -f $Index
    if ($Index -eq 1) {
      $Lines += "| $Id Fixture | Fixture decision needed | Product owner | Approved fixture decision | $ClosedEvidence | $ClosedDate | Closed |"
    } else {
      $Lines += "| $Id Fixture | Fixture decision needed | Product owner | TBD | `docs/launch-evidence/fixture.md` | TBD | Open |"
    }
  }

  return ($Lines -join [Environment]::NewLine) + [Environment]::NewLine
}

function Write-Fixture {
  param(
    [string]$FixtureRoot,
    [string]$ClosedDate,
    [string]$ClosedEvidence = '`docs/launch-evidence/fixture.md`'
  )

  $Docs = Join-Path $FixtureRoot "docs"
  New-Item -ItemType Directory -Force -Path $Docs | Out-Null
  Set-Content -LiteralPath (Join-Path $Docs "open-questions.md") -Value (New-OpenQuestionsContent) -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $Docs "owner-decision-record.md") -Value (New-OwnerDecisionContent -ClosedDate $ClosedDate -ClosedEvidence $ClosedEvidence) -Encoding UTF8
}

function Invoke-OwnerDecisionRecordTest {
  param([string]$FixtureRoot)

  $Output = & powershell -NoProfile -ExecutionPolicy Bypass -File $TargetScript -RootPath $FixtureRoot 2>&1 | Out-String
  [pscustomobject]@{
    ExitCode = $LASTEXITCODE
    Output = $Output.Trim()
  }
}

function Assert-Fails {
  param(
    [string]$Name,
    [string]$ClosedDate,
    [string]$FixtureRoot,
    [string]$ClosedEvidence = '`docs/launch-evidence/fixture.md`'
  )

  Write-Fixture -FixtureRoot $FixtureRoot -ClosedDate $ClosedDate -ClosedEvidence $ClosedEvidence
  $Result = Invoke-OwnerDecisionRecordTest -FixtureRoot $FixtureRoot
  if ($Result.ExitCode -eq 0) {
    Add-Failure "$Name should fail, but test-owner-decision-record.ps1 passed."
  }
}

function Assert-Passes {
  param(
    [string]$Name,
    [string]$ClosedDate,
    [string]$FixtureRoot,
    [string]$ClosedEvidence = '`docs/launch-evidence/fixture.md`'
  )

  Write-Fixture -FixtureRoot $FixtureRoot -ClosedDate $ClosedDate -ClosedEvidence $ClosedEvidence
  $Result = Invoke-OwnerDecisionRecordTest -FixtureRoot $FixtureRoot
  if ($Result.ExitCode -ne 0) {
    Add-Failure "$Name should pass, but test-owner-decision-record.ps1 failed: $($Result.Output)"
  }
}

$TempRoot = [System.IO.Path]::GetTempPath()
$FixtureRoot = Join-Path $TempRoot ("watche-owner-decision-fixture-" + [guid]::NewGuid().ToString("N"))

try {
  New-Item -ItemType Directory -Path $FixtureRoot | Out-Null

  Assert-Fails -Name "Invalid calendar date" -ClosedDate "2026-99-99" -FixtureRoot $FixtureRoot
  Assert-Fails -Name "Future date" -ClosedDate "2099-01-01" -FixtureRoot $FixtureRoot
  Assert-Fails -Name "Weak evidence" -ClosedDate (Get-Date).ToString("yyyy-MM-dd") -ClosedEvidence "Approved by owner" -FixtureRoot $FixtureRoot
  Assert-Fails -Name "Generic command output evidence" -ClosedDate (Get-Date).ToString("yyyy-MM-dd") -ClosedEvidence "Command output was reviewed" -FixtureRoot $FixtureRoot
  Assert-Passes -Name "Valid non-future date" -ClosedDate (Get-Date).ToString("yyyy-MM-dd") -FixtureRoot $FixtureRoot
} finally {
  if (Test-Path -LiteralPath $FixtureRoot) {
    $ResolvedFixture = (Resolve-Path $FixtureRoot).Path
    $ResolvedTemp = (Resolve-Path $TempRoot).Path
    if ($ResolvedFixture.StartsWith($ResolvedTemp, [System.StringComparison]::OrdinalIgnoreCase)) {
      Remove-Item -LiteralPath $ResolvedFixture -Recurse -Force
    }
  }
}

if ($Failures.Count -gt 0) {
  Write-Host "Owner decision quality fixture tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Owner decision quality fixture tests passed."
