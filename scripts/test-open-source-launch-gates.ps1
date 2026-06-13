param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$AuditScript = Join-Path $Root "scripts/audit-open-source-launch-gates.ps1"
$TempBase = [System.IO.Path]::GetTempPath()
$FixtureRoot = Join-Path $TempBase ("watche-launch-gate-test-" + [guid]::NewGuid().ToString("N"))

function Set-FixtureFile {
  param(
    [string]$RelativePath,
    [string]$Content
  )

  $Path = Join-Path $FixtureRoot $RelativePath
  $Parent = Split-Path -Parent $Path
  if (-not (Test-Path -LiteralPath $Parent)) {
    New-Item -ItemType Directory -Path $Parent | Out-Null
  }
  Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
}

function Get-BaseReadme {
  param(
    [string]$DemoSection,
    [string]$CommunitySection
  )

  @"
# WatcheRobot

WatcheRobot is an open-source desktop embodied AI robot.

## Demo

$DemoSection

## Open Source and Community

$CommunitySection

## Contribution Boundaries

Root workspace boundaries are documented elsewhere.
"@
}

function Get-PassingEvidence {
  param([string]$Name)

  @"
# $Name Evidence

Status: Passed
Owner: QA Agent
Date: 2026-06-11
Environment: Test fixture environment.
Evidence: powershell -ExecutionPolicy Bypass -File .\scripts\fixture-check.ps1 produced passing command output.
Result: $Name gate passed in the fixture.
Follow-up: None.
"@
}

function Get-CompleteOwnerDecisionRecord {
  $Rows = @(
    "# Owner Decision Record",
    "",
    "| Open question | Decision needed | Owner | Final decision | Evidence / link | Date | Status |",
    "| --- | --- | --- | --- | --- | --- | --- |"
  )

  foreach ($Index in 1..9) {
    $Id = "OQ-{0:D3}" -f $Index
    $Rows += "| $Id Fixture | Fixture decision needed | QA Agent | Approved for fixture | ``docs/launch-evidence/fixture.md`` | 2026-06-11 | Closed |"
  }

  return ($Rows -join [Environment]::NewLine)
}

function Initialize-Fixture {
  param([string]$ReadmeContent)

  if (-not (Test-Path -LiteralPath $FixtureRoot)) {
    New-Item -ItemType Directory -Path $FixtureRoot | Out-Null
  }

  Set-FixtureFile "README.md" $ReadmeContent
  Set-FixtureFile "LICENSE" "Apache-2.0 test fixture"
  Set-FixtureFile "docs/owner-decision-record.md" @"
# Owner Decision Record

| ID | Question | Owner | Final decision | Evidence | Date | Status |
| --- | --- | --- | --- | --- | --- | --- |
| OQ-001 | Test fixture decision | QA Agent | Approved for fixture | `docs/launch-evidence/fixture.md` | 2026-06-11 | Closed |
"@
  Set-FixtureFile "docs/launch-evidence/app-gradle.md" (Get-PassingEvidence "App Gradle")
  Set-FixtureFile "docs/launch-evidence/clean-machine.md" (Get-PassingEvidence "Clean machine")
  Set-FixtureFile "docs/launch-evidence/hardware-smoke.md" (Get-PassingEvidence "Hardware smoke")
}

function Invoke-LaunchGateAudit {
  $Output = & powershell -ExecutionPolicy Bypass -File $AuditScript -RootPath $FixtureRoot -SkipExternal -Json 2>&1
  $Text = ($Output | Out-String).Trim()
  if ([string]::IsNullOrWhiteSpace($Text)) {
    throw "Launch gate audit returned no output."
  }

  try {
    return $Text | ConvertFrom-Json
  } catch {
    throw "Launch gate audit returned invalid JSON: $Text"
  }
}

function Get-Gate {
  param(
    [object]$Report,
    [string]$Name
  )

  $Gate = @($Report.gates | Where-Object { $_.name -eq $Name })[0]
  if (-not $Gate) {
    throw "Missing gate in audit report: $Name"
  }
  return $Gate
}

function Assert-GateStatus {
  param(
    [object]$Report,
    [string]$Name,
    [string]$ExpectedStatus
  )

  $Gate = Get-Gate -Report $Report -Name $Name
  if ($Gate.status -ne $ExpectedStatus) {
    throw "Expected gate '$Name' to be '$ExpectedStatus', got '$($Gate.status)': $($Gate.detail)"
  }
}

try {
  $NoRouteReadme = Get-BaseReadme `
    -DemoSection "A written launch note without media." `
    -CommunitySection "Issues are available, but no official route is set here."
  Initialize-Fixture -ReadmeContent $NoRouteReadme
  $Report = Invoke-LaunchGateAudit
  Assert-GateStatus -Report $Report -Name "community entrance" -ExpectedStatus "unavailable"
  Assert-GateStatus -Report $Report -Name "approved demo asset" -ExpectedStatus "unavailable"

  Set-FixtureFile "docs/launch-evidence/owner-decisions.md" (Get-PassingEvidence "Owner decisions")
  $Report = Invoke-LaunchGateAudit
  Assert-GateStatus -Report $Report -Name "owner decisions" -ExpectedStatus "failed"
  Set-FixtureFile "docs/launch-evidence/owner-decisions.md" @"
# Owner Decisions Evidence

Status: Draft
Owner:
Date:
Environment:
Evidence:
Result:
Follow-up:
"@
  Set-FixtureFile "docs/owner-decision-record.md" (Get-CompleteOwnerDecisionRecord)

  $PassingReadme = Get-BaseReadme `
    -DemoSection "![WatcheRobot demo](docs/assets/watche-robot-demo.gif)" `
    -CommunitySection "Use GitHub Discussions for durable public Q&A."
  Set-FixtureFile "README.md" $PassingReadme
  $Report = Invoke-LaunchGateAudit
  Assert-GateStatus -Report $Report -Name "final license" -ExpectedStatus "unavailable"
  Assert-GateStatus -Report $Report -Name "community entrance" -ExpectedStatus "unavailable"
  Assert-GateStatus -Report $Report -Name "approved demo asset" -ExpectedStatus "unavailable"

  Set-FixtureFile "docs/launch-evidence/final-license.md" (Get-PassingEvidence "Final license")
  Set-FixtureFile "docs/launch-evidence/community-entrance.md" (Get-PassingEvidence "Community entrance")
  Set-FixtureFile "docs/launch-evidence/demo-asset.md" (Get-PassingEvidence "Demo asset")
  $Report = Invoke-LaunchGateAudit
  Assert-GateStatus -Report $Report -Name "final license" -ExpectedStatus "passed"
  Assert-GateStatus -Report $Report -Name "community entrance" -ExpectedStatus "passed"
  Assert-GateStatus -Report $Report -Name "approved demo asset" -ExpectedStatus "passed"

  Set-FixtureFile "docs/launch-evidence/community-entrance.md" @"
# Community Entrance Evidence

Status: Draft
Owner: QA Agent
Date:
Evidence:
Result:
"@
  $Report = Invoke-LaunchGateAudit
  Assert-GateStatus -Report $Report -Name "community entrance" -ExpectedStatus "unavailable"

  Set-FixtureFile "docs/launch-evidence/community-entrance.md" (Get-PassingEvidence "Community entrance")

  Set-FixtureFile "docs/launch-evidence/clean-machine.md" @"
# Clean Machine Evidence

Status: Draft
Owner: QA Agent
Date:
Evidence:
Result:
"@
  $Report = Invoke-LaunchGateAudit
  Assert-GateStatus -Report $Report -Name "clean-machine validation" -ExpectedStatus "unavailable"

  Set-FixtureFile "docs/launch-evidence/clean-machine.md" @"
# Clean Machine Evidence

Status: Passed
Owner: QA Agent
Date: 2026-06-11
Evidence: Fixture command output was reviewed.
Result:
"@
  $Report = Invoke-LaunchGateAudit
  Assert-GateStatus -Report $Report -Name "clean-machine validation" -ExpectedStatus "failed"

  Set-FixtureFile "docs/launch-evidence/clean-machine.md" (Get-PassingEvidence "Clean machine")
  $Report = Invoke-LaunchGateAudit
  Assert-GateStatus -Report $Report -Name "clean-machine validation" -ExpectedStatus "passed"

  Set-FixtureFile "docs/launch-evidence/clean-machine.md" @"
# Clean Machine Evidence

Status: Passed
Owner: QA Agent
Date: 2026-06-11
Evidence: Fixture command output was reviewed.
Result: Clean machine gate passed in the fixture.
Follow-up: None.
"@
  $Report = Invoke-LaunchGateAudit
  Assert-GateStatus -Report $Report -Name "clean-machine validation" -ExpectedStatus "failed"

  Set-FixtureFile "docs/launch-evidence/clean-machine.md" @"
# Clean Machine Evidence

Status: Passed
Owner: QA Agent
Date: 2026-06-11
Environment: Test fixture environment.
Evidence: Fixture command output was reviewed.
Result: Clean machine gate passed in the fixture.
Follow-up: None.
Notes: UNKNOWN
"@
  $Report = Invoke-LaunchGateAudit
  Assert-GateStatus -Report $Report -Name "clean-machine validation" -ExpectedStatus "failed"

  Set-FixtureFile "docs/launch-evidence/clean-machine.md" @"
# Clean Machine Evidence

Status: Passed
Owner: QA Agent
Date: 2026-06-11
Environment: Test fixture environment.
Evidence: Fixture command output was reviewed.
Result: Clean machine gate passed in the fixture.
"@
  $Report = Invoke-LaunchGateAudit
  Assert-GateStatus -Report $Report -Name "clean-machine validation" -ExpectedStatus "failed"

  Set-FixtureFile "docs/launch-evidence/clean-machine.md" @"
# Clean Machine Evidence

Status: Passed
Owner: QA Agent
Date: 2026-06-11
Environment: Test fixture environment.
Evidence: Approved by QA.
Result: Clean machine gate passed in the fixture.
Follow-up: None.
"@
  $Report = Invoke-LaunchGateAudit
  Assert-GateStatus -Report $Report -Name "clean-machine validation" -ExpectedStatus "failed"

  Set-FixtureFile "docs/launch-evidence/clean-machine.md" @"
# Clean Machine Evidence

Status: Passed
Owner: QA Agent
Date: 2026-06-11
Environment: Test fixture environment.
Evidence: Command output was reviewed.
Result: Clean machine gate passed in the fixture.
Follow-up: None.
"@
  $Report = Invoke-LaunchGateAudit
  Assert-GateStatus -Report $Report -Name "clean-machine validation" -ExpectedStatus "failed"

  Set-FixtureFile "docs/launch-evidence/clean-machine.md" @"
# Clean Machine Evidence

Status: Passed
Owner: QA Agent
Date: 2026-99-99
Environment: Test fixture environment.
Evidence: Fixture command output was reviewed.
Result: Clean machine gate passed in the fixture.
Follow-up: None.
"@
  $Report = Invoke-LaunchGateAudit
  Assert-GateStatus -Report $Report -Name "clean-machine validation" -ExpectedStatus "failed"

  Set-FixtureFile "docs/launch-evidence/clean-machine.md" @"
# Clean Machine Evidence

Status: Passed
Owner: QA Agent
Date: 2099-01-01
Environment: Test fixture environment.
Evidence: Fixture command output was reviewed.
Result: Clean machine gate passed in the fixture.
Follow-up: None.
"@
  $Report = Invoke-LaunchGateAudit
  Assert-GateStatus -Report $Report -Name "clean-machine validation" -ExpectedStatus "failed"

  Write-Host "Open-source launch gate regression tests passed."
} finally {
  if (Test-Path -LiteralPath $FixtureRoot) {
    $ResolvedFixture = [System.IO.Path]::GetFullPath($FixtureRoot)
    $ResolvedTemp = [System.IO.Path]::GetFullPath($TempBase)
    if ($ResolvedFixture.StartsWith($ResolvedTemp, [System.StringComparison]::OrdinalIgnoreCase)) {
      Remove-Item -LiteralPath $FixtureRoot -Recurse -Force
    }
  }
}
