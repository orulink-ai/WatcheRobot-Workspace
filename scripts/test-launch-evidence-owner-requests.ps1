param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$Failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([string]$Message)
  $script:Failures.Add($Message)
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

$RelativePath = "docs/launch-evidence-owner-requests.md"
$Content = Read-Text $RelativePath
$RequestPack = Read-Text "docs/launch-evidence-request-pack.md"
$CloseoutPlan = Read-Text "docs/launch-gate-closeout-plan.md"
$Handoff = Read-Text "docs/sub-agent-handoff.md"
$FinalReport = Read-Text "docs/open-source-readiness-final.md"

foreach ($Needle in @(
  "# Launch Evidence Owner Requests",
  "WatcheRobot",
  "Do not mark `Status: Passed` from a reply alone.",
  "valid non-future YYYY-MM-DD",
  "Can this close the gate? Yes / No",
  "scripts/audit-open-source-launch-gates.ps1",
  "scripts/check-open-source-readiness.ps1 -SkipGradle"
)) {
  Assert-Contains -Content $Content -Needle $Needle -Context $RelativePath
}

$GateEvidence = @(
  @{ gate = "owner decisions"; evidence = "docs/launch-evidence/owner-decisions.md"; owner = "Product / legal / design / hardware / community owners" },
  @{ gate = "final license"; evidence = "docs/launch-evidence/final-license.md"; owner = "Product / legal owner" },
  @{ gate = "community entrance"; evidence = "docs/launch-evidence/community-entrance.md"; owner = "Product / community owner" },
  @{ gate = "approved demo asset"; evidence = "docs/launch-evidence/demo-asset.md"; owner = "Product / design owner" },
  @{ gate = "github admin state"; evidence = "docs/launch-evidence/github-admin.md"; owner = "Repository admin" },
  @{ gate = "release manifest"; evidence = "docs/launch-evidence/release-artifacts.md"; owner = "Release owner" },
  @{ gate = "java and app gradle"; evidence = "docs/launch-evidence/app-gradle.md"; owner = "App owner" },
  @{ gate = "clean-machine validation"; evidence = "docs/launch-evidence/clean-machine.md"; owner = "QA owner" },
  @{ gate = "hardware smoke validation"; evidence = "docs/launch-evidence/hardware-smoke.md"; owner = "Firmware / QA owner" }
)

foreach ($Spec in $GateEvidence) {
  Assert-Contains -Content $Content -Needle "## $($Spec.gate)" -Context $RelativePath
  Assert-Contains -Content $Content -Needle $Spec.evidence -Context $RelativePath
  Assert-Contains -Content $Content -Needle $Spec.owner -Context $RelativePath
  Assert-Contains -Content $Content -Needle "Request ID:" -Context "$RelativePath $($Spec.gate)"
  Assert-Contains -Content $Content -Needle "Owner:" -Context "$RelativePath $($Spec.gate)"
  Assert-Contains -Content $Content -Needle "Date:" -Context "$RelativePath $($Spec.gate)"
  Assert-Contains -Content $Content -Needle "Environment / context:" -Context "$RelativePath $($Spec.gate)"
  Assert-Contains -Content $Content -Needle "Evidence link or command output:" -Context "$RelativePath $($Spec.gate)"
  Assert-Contains -Content $Content -Needle "Traceable evidence source:" -Context "$RelativePath $($Spec.gate)"
  Assert-Contains -Content $Content -Needle "Follow-up required before launch:" -Context "$RelativePath $($Spec.gate)"
  Assert-Contains -Content $Content -Needle "Remaining risk:" -Context "$RelativePath $($Spec.gate)"
}

foreach ($Needle in @(
  "SPDX license identifier",
  "root `LICENSE` path",
  "subrepo license impact",
  "hardware / structure file license scope",
  "third-party dependency compatibility",
  "temporary license placeholder removal"
)) {
  Assert-Contains -Content $Content -Needle $Needle -Context "$RelativePath final license"
}

foreach ($Needle in @(
  "official community URL",
  "access status",
  "moderation owner",
  "response window",
  "fallback contact",
  "README community link",
  "GitHub Discussions setting or equivalent route"
)) {
  Assert-Contains -Content $Content -Needle $Needle -Context "$RelativePath community entrance"
}

foreach ($Needle in @(
  "approved media URL or repository path",
  "asset type",
  "public usage rights",
  "source owner",
  "README Demo section replacement",
  "docs/assets/README.md",
  "caption approval"
)) {
  Assert-Contains -Content $Content -Needle $Needle -Context "$RelativePath approved demo asset"
}

foreach ($Needle in @(
  "unique artifact names",
  'JSON boolean `required` values',
  'artifact `path_or_url` values',
  "http(s) URLs or traceable repository/build file paths",
  "semantic release version",
  "release_url",
  "workspace/App/desktop/server/ESP32/STM32 component refs",
  '`passed` readiness / hardware smoke / clean-machine check results'
)) {
  Assert-Contains -Content $Content -Needle $Needle -Context "$RelativePath release manifest"
}

foreach ($Needle in @(
  "open-source readiness workflow",
  "branch protection required checks",
  "good first issue URLs",
  "issue template URLs",
  "PR template URL",
  "label list",
  "Discussions or official community route URL",
  "scripts/audit-github-readiness.ps1"
)) {
  Assert-Contains -Content $Content -Needle $Needle -Context "$RelativePath github admin state"
}

foreach ($Needle in @(
  "java -version",
  "JAVA_HOME",
  "Android SDK",
  "WatcheRobot_app/android",
  "Gradle task and build variant",
  "Gradle command exit code",
  "Gradle output log path",
  "signing secrets are not included",
  "Metro / React Native command",
  "OQ-009 legacy identifier decision"
)) {
  Assert-Contains -Content $Content -Needle $Needle -Context "$RelativePath java and app gradle"
}

foreach ($Needle in @(
  "fresh clone directory",
  "root commit hash",
  "git submodule status --recursive",
  "docs/quick-start.md",
  "scripts/check-open-source-readiness.ps1 -SkipGradle",
  "scripts/test-open-source-examples.ps1",
  "OS and tool versions",
  "no local cache reuse"
)) {
  Assert-Contains -Content $Content -Needle $Needle -Context "$RelativePath clean-machine validation"
}

foreach ($Needle in @(
  "device ID / hardware revision",
  "firmware versions",
  "power supply and safety setup",
  "BLE ping",
  "servo action",
  "expression switch",
  "Wi-Fi provisioning ready state",
  "AI reminder flow",
  "serial/app logs",
  "expected ACK / observed result"
)) {
  Assert-Contains -Content $Content -Needle $Needle -Context "$RelativePath hardware smoke validation"
}

foreach ($Context in @(
  @{ name = "docs/launch-evidence-request-pack.md"; content = $RequestPack },
  @{ name = "docs/launch-gate-closeout-plan.md"; content = $CloseoutPlan },
  @{ name = "docs/sub-agent-handoff.md"; content = $Handoff },
  @{ name = "docs/open-source-readiness-final.md"; content = $FinalReport }
)) {
  Assert-Contains -Content $Context.content -Needle $RelativePath -Context $Context.name
}

if ($Failures.Count -gt 0) {
  Write-Host "Launch evidence owner request tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Launch evidence owner request tests passed."
