param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$Failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([string]$Message)
  $script:Failures.Add($Message)
}

function Get-FieldValue {
  param(
    [string]$Content,
    [string]$FieldName
  )

  $Pattern = "(?im)^\s*$([regex]::Escape($FieldName))\s*:\s*(.*?)\s*$"
  $Match = [regex]::Match($Content, $Pattern)
  if ($Match.Success) {
    return $Match.Groups[1].Value.Trim()
  }

  return $null
}

$TemplateSpecs = @(
  @{
    path = "docs/launch-evidence/templates/app-gradle.md"
    target = "docs/launch-evidence/app-gradle.md"
    checks = @("Java command and version", "JAVA_HOME", "Android SDK path and version", "WatcheRobot_app/android Gradle command", "Gradle task and build variant", "Gradle command exit code", "Gradle output log path", "Metro / React Native command", "OQ-009 legacy identifier decision", "Signing secret exclusion")
  },
  @{
    path = "docs/launch-evidence/templates/owner-decisions.md"
    target = "docs/launch-evidence/owner-decisions.md"
    checks = @("Open owner questions", "Final decision values", "Evidence links", "Closed status rule")
  },
  @{
    path = "docs/launch-evidence/templates/final-license.md"
    target = "docs/launch-evidence/final-license.md"
    checks = @("SPDX license identifier", "Root LICENSE path", "Subrepo license impact", "Hardware / structure file license scope", "Third-party dependency compatibility", "Temporary license placeholder removed")
  },
  @{
    path = "docs/launch-evidence/templates/community-entrance.md"
    target = "docs/launch-evidence/community-entrance.md"
    checks = @("Official community URL", "Access status", "GitHub Discussions setting or equivalent route", "README community link", "Moderation owner", "Response window", "Fallback contact")
  },
  @{
    path = "docs/launch-evidence/templates/demo-asset.md"
    target = "docs/launch-evidence/demo-asset.md"
    checks = @("Approved media URL or repository path", "Asset type", "Public usage rights", "Source owner", "README Demo section replacement", "docs/assets/README.md placement", "Caption approval")
  },
  @{
    path = "docs/launch-evidence/templates/clean-machine.md"
    target = "docs/launch-evidence/clean-machine.md"
    checks = @("Fresh clone directory", "Root commit hash", "git submodule status --recursive", "OS and tool versions", "docs/quick-start.md completed", "scripts/check-open-source-readiness.ps1 -SkipGradle output", "scripts/test-open-source-examples.ps1 output", "No local cache reuse")
  },
  @{
    path = "docs/launch-evidence/templates/github-admin.md"
    target = "docs/launch-evidence/github-admin.md"
    checks = @("Issue template URLs", "PR template URL", "Synced label list", "Good first issue URLs", "Discussions or official community route URL", "Open-source readiness workflow visibility", "Main branch protection", "Branch protection required checks", "scripts/audit-github-readiness.ps1 output")
  },
  @{
    path = "docs/launch-evidence/templates/hardware-smoke.md"
    target = "docs/launch-evidence/hardware-smoke.md"
    checks = @("Device ID / hardware revision", "Firmware versions", "Power supply and safety setup", "BLE ping expected ACK / observed result", "Servo action expected ACK / observed result", "Expression switch expected ACK / observed result", "Wi-Fi provisioning ready state expected ACK / observed result", "AI reminder flow expected ACK / observed result", "Serial/app logs")
  },
  @{
    path = "docs/launch-evidence/templates/release-artifacts.md"
    target = "docs/launch-evidence/release-artifacts.md"
    checks = @("Desktop installer URL", "ESP32 firmware package URL", "STM32 firmware package URL, if published", "Artifact names", "Artifact required flags", "Artifact paths or URLs", "Checksums", "Release version", "Release URL", "Component refs", "Required checks", "Release manifest validation command", "Release notes")
  }
)

$RequiredFields = @("Status", "Owner", "Date", "Environment", "Evidence", "Result", "Follow-up")
$DraftEvidenceSpecs = @(
  @{
    path = "docs/launch-evidence/app-gradle.md"
    status = "Draft"
    needles = @(
      "java is not available in PATH",
      "Gradle dry-run was not executed",
      "Gradle command exit code",
      "signing secrets are not included",
      "OQ-009 legacy identifier decision"
    )
  },
  @{
    path = "docs/launch-evidence/owner-decisions.md"
    status = "Draft"
    needles = @(
      "0/9 owner decisions are closed",
      "OQ-001",
      "owner decisions are not closed"
    )
  },
  @{
    path = "docs/launch-evidence/final-license.md"
    status = "Draft"
    needles = @(
      "Final LICENSE is not confirmed",
      "LICENSE-TBD.md is still present or LICENSE is missing",
      "approved license has not been selected",
      "SPDX license identifier",
      "hardware / structure file license scope",
      "third-party dependency compatibility"
    )
  },
  @{
    path = "docs/launch-evidence/community-entrance.md"
    status = "Draft"
    needles = @(
      "README still uses a temporary community route",
      "official community entrance is not confirmed",
      "GitHub Issues until confirmed",
      "official community URL",
      "access status",
      "fallback contact"
    )
  },
  @{
    path = "docs/launch-evidence/demo-asset.md"
    status = "Draft"
    needles = @(
      "README still contains the demo asset placeholder",
      "approved demo asset is not confirmed",
      "Add the verified product photo",
      "approved media URL or repository path",
      "asset type",
      "caption approval"
    )
  },
  @{
    path = "docs/launch-evidence/release-artifacts.md"
    status = "Draft"
    needles = @(
      "final release artifacts and release metadata are not confirmed",
      "release version",
      "artifact names are duplicated",
      "artifact required flags are not JSON booleans",
      "workspace/App/desktop/server/ESP32/STM32 component refs",
      "component refs that are not commit hashes or semantic version tags",
      "artifact locations that are not http(s) URLs or traceable file paths",
      "readiness / hardware smoke / clean-machine check results that are missing, pending, or not"
    )
  },
  @{
    path = "docs/launch-evidence/github-admin.md"
    status = "Draft"
    needles = @(
      "GitHub admin validation was not completed",
      "GitHub API audit was unavailable",
      "GitHub Discussions are not confirmed",
      "open-source readiness workflow visibility",
      "branch protection required checks",
      "good first issue URLs"
    )
  },
  @{
    path = "docs/launch-evidence/clean-machine.md"
    status = "Draft"
    needles = @(
      "Clean-machine validation was not executed",
      "Fresh clone was not run",
      "Quick Start was not completed",
      "root commit hash",
      "git submodule status --recursive",
      "no local cache reuse"
    )
  },
  @{
    path = "docs/launch-evidence/hardware-smoke.md"
    status = "Draft"
    needles = @(
      "Hardware smoke validation was not executed",
      "No safe powered device was connected",
      "BLE ping was not run",
      "power supply and safety setup",
      "serial/app logs",
      "expected ACK / observed result"
    )
  }
)
$LaunchEvidenceReadmePath = Join-Path $Root "docs/launch-evidence/README.md"
if (-not (Test-Path -LiteralPath $LaunchEvidenceReadmePath)) {
  Add-Failure "Missing launch evidence README: docs/launch-evidence/README.md"
} else {
  $LaunchEvidenceReadme = Get-Content -LiteralPath $LaunchEvidenceReadmePath -Raw -Encoding UTF8
  foreach ($Needle in @(
    "valid `YYYY-MM-DD` calendar date",
    "must not be in the future",
    "traceable source marker"
  )) {
    if ($LaunchEvidenceReadme -notmatch [regex]::Escape($Needle)) {
      Add-Failure "docs/launch-evidence/README.md is missing required date rule: $Needle"
    }
  }
}

foreach ($Spec in $TemplateSpecs) {
  $RelativePath = [string]$Spec.path
  $Path = Join-Path $Root $RelativePath
  if (-not (Test-Path -LiteralPath $Path)) {
    Add-Failure "Missing launch evidence template: $RelativePath"
    continue
  }

  $Content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
  foreach ($Field in $RequiredFields) {
    $Value = Get-FieldValue -Content $Content -FieldName $Field
    if ($null -eq $Value) {
      Add-Failure "$RelativePath is missing field '$Field'"
      continue
    }

    if ($Field -eq "Status" -and $Value -ne "Draft") {
      Add-Failure "$RelativePath must keep Status: Draft until real evidence is copied to $($Spec.target)"
    }
  }

  if ($Content -match "(?im)^\s*Status\s*:\s*Passed\s*$") {
    Add-Failure "$RelativePath must not claim Status: Passed"
  }

  if ($Content -notmatch "(?im)^##\s+Required Checks\s*$") {
    Add-Failure "$RelativePath is missing the Required Checks section"
  }

  foreach ($Check in @($Spec.checks)) {
    $Pattern = "(?im)^\s*-\s*$([regex]::Escape($Check))\s*:"
    if ($Content -notmatch $Pattern) {
      Add-Failure "$RelativePath is missing required check bullet: $Check"
    }
  }

  if ($RelativePath -eq "docs/launch-evidence/templates/release-artifacts.md") {
    $ReleaseManifestCommand = 'powershell -ExecutionPolicy Bypass -File .\scripts\validate-release-manifest.ps1 -Manifest <final-manifest>'
    if (-not $Content.Contains($ReleaseManifestCommand)) {
      Add-Failure "$RelativePath is missing the release manifest validation command: $ReleaseManifestCommand"
    }
  }

  $ExpectedNote = "Copy this file to ``$($Spec.target)`` only after"
  if ($Content -notmatch [regex]::Escape($ExpectedNote)) {
    Add-Failure "$RelativePath must tell the operator to copy it to $($Spec.target) only after real validation"
  }
}

foreach ($Spec in $DraftEvidenceSpecs) {
  $RelativePath = [string]$Spec.path
  $Path = Join-Path $Root $RelativePath
  if (-not (Test-Path -LiteralPath $Path)) {
    Add-Failure "Missing launch evidence draft: $RelativePath"
    continue
  }

  $Content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
  $Status = Get-FieldValue -Content $Content -FieldName "Status"
  if ($Status -ne $Spec.status) {
    Add-Failure "$RelativePath must keep Status: $($Spec.status) until the gate is really passed"
  }
  if ($Content -match "(?im)^\s*Status\s*:\s*Passed\s*$") {
    Add-Failure "$RelativePath must not claim Status: Passed before real validation"
  }
  foreach ($Needle in @($Spec.needles)) {
    if ($Content -notmatch [regex]::Escape($Needle)) {
      Add-Failure "$RelativePath is missing required blocker evidence: $Needle"
    }
  }
}

if ($Failures.Count -gt 0) {
  Write-Host "Launch evidence template tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Launch evidence template tests passed."
