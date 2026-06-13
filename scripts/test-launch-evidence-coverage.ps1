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

  if ($Content -notmatch [regex]::Escape($Needle)) {
    Add-Failure "$Context is missing required text: $Needle"
  }
}

$LaunchEvidenceReadme = Get-RepoText "docs/launch-evidence/README.md"
$LaunchGates = Get-RepoText "docs/open-source-launch-gates.md"
$CloseoutPlan = Get-RepoText "docs/launch-gate-closeout-plan.md"
$RequestPack = Get-RepoText "docs/launch-evidence-request-pack.md"
$FinalReport = Get-RepoText "docs/open-source-readiness-final.md"
$ChineseFinalReport = Get-RepoText "docs/open-source-readiness-final.zh-CN.md"
$Handoff = Get-RepoText "docs/sub-agent-handoff.md"

$GateEvidence = @(
  @{ gate = "owner decisions"; evidence = "docs/launch-evidence/owner-decisions.md"; template = "docs/launch-evidence/templates/owner-decisions.md" },
  @{ gate = "final license"; evidence = "docs/launch-evidence/final-license.md"; template = "docs/launch-evidence/templates/final-license.md" },
  @{ gate = "community entrance"; evidence = "docs/launch-evidence/community-entrance.md"; template = "docs/launch-evidence/templates/community-entrance.md" },
  @{ gate = "approved demo asset"; evidence = "docs/launch-evidence/demo-asset.md"; template = "docs/launch-evidence/templates/demo-asset.md" },
  @{ gate = "github admin state"; evidence = "docs/launch-evidence/github-admin.md"; template = "docs/launch-evidence/templates/github-admin.md" },
  @{ gate = "release manifest"; evidence = "docs/launch-evidence/release-artifacts.md"; template = "docs/launch-evidence/templates/release-artifacts.md" },
  @{ gate = "java and app gradle"; evidence = "docs/launch-evidence/app-gradle.md"; template = "docs/launch-evidence/templates/app-gradle.md" },
  @{ gate = "clean-machine validation"; evidence = "docs/launch-evidence/clean-machine.md"; template = "docs/launch-evidence/templates/clean-machine.md" },
  @{ gate = "hardware smoke validation"; evidence = "docs/launch-evidence/hardware-smoke.md"; template = "docs/launch-evidence/templates/hardware-smoke.md" }
)

foreach ($Spec in $GateEvidence) {
  foreach ($RelativePath in @($Spec.evidence, $Spec.template)) {
    if (-not (Test-Path -LiteralPath (Join-Path $Root $RelativePath))) {
      Add-Failure "Missing launch evidence coverage path for $($Spec.gate): $RelativePath"
    }
  }

  $FileName = Split-Path -Leaf $Spec.evidence
  Assert-Contains -Content $LaunchEvidenceReadme -Needle $FileName -Context "docs/launch-evidence/README.md"
  Assert-Contains -Content $LaunchGates -Needle $Spec.evidence -Context "docs/open-source-launch-gates.md"
  Assert-Contains -Content $CloseoutPlan -Needle $Spec.evidence -Context "docs/launch-gate-closeout-plan.md"
  Assert-Contains -Content $RequestPack -Needle $Spec.evidence -Context "docs/launch-evidence-request-pack.md"
  Assert-Contains -Content $FinalReport -Needle $Spec.evidence -Context "docs/open-source-readiness-final.md"
  Assert-Contains -Content $ChineseFinalReport -Needle $Spec.evidence -Context "docs/open-source-readiness-final.zh-CN.md"
  Assert-Contains -Content $Handoff -Needle $Spec.evidence -Context "docs/sub-agent-handoff.md"
}

foreach ($Needle in @(
  "9 launch gates",
  "Status: Passed",
  "Draft",
  "must not be in the future",
  "README, license, owner-decision, release manifest, or remote GitHub state changes are necessary inputs, but they do not close a gate without the matching evidence file."
)) {
  Assert-Contains -Content $LaunchEvidenceReadme -Needle $Needle -Context "docs/launch-evidence/README.md"
}

if ($Failures.Count -gt 0) {
  Write-Host "Launch evidence coverage tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Launch evidence coverage tests passed."
