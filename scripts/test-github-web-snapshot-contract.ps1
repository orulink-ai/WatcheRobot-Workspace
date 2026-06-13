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

$Template = Get-RepoText "docs/launch-evidence/templates/github-remote-web-snapshot.md"
$LatestIndex = Get-RepoText "docs/launch-evidence/web-snapshots/latest-github-remote.md"
$EvidenceReadme = Get-RepoText "docs/launch-evidence/README.md"
$LaunchGates = Get-RepoText "docs/open-source-launch-gates.md"
$PublicValidation = Get-RepoText "docs/public-launch-validation.md"

$SnapshotDir = Join-Path $Root "docs/launch-evidence/web-snapshots"
$DatedSnapshots = @()
if (Test-Path -LiteralPath $SnapshotDir) {
  $DatedSnapshots = Get-ChildItem -LiteralPath $SnapshotDir -File |
    Where-Object { $_.Name -match '^github-remote-\d{4}-\d{2}-\d{2}\.md$' } |
    Sort-Object Name
}

if ($DatedSnapshots.Count -eq 0) {
  Add-Failure "No dated GitHub remote web snapshots found under docs/launch-evidence/web-snapshots/."
  $LatestSnapshotName = ""
  $LatestSnapshotDate = ""
  $Snapshot = ""
} else {
  $LatestSnapshotName = $DatedSnapshots[-1].Name
  $LatestSnapshotDate = [regex]::Match($LatestSnapshotName, '\d{4}-\d{2}-\d{2}').Value
  $Snapshot = Get-RepoText "docs/launch-evidence/web-snapshots/$LatestSnapshotName"
}

foreach ($Needle in @(
  "# GitHub Remote Web Snapshot",
  "Status: Draft",
  "Observation date:",
  "Observed URL:",
  "Source links:",
  "Public findings:",
  "Readiness conclusion:",
  "does not close the GitHub admin gate"
)) {
  Assert-Contains -Content $Template -Needle $Needle -Context "docs/launch-evidence/templates/github-remote-web-snapshot.md"
}

foreach ($Needle in @(
  "# Latest GitHub Remote Web Snapshot",
  "Latest dated snapshot:",
  $LatestSnapshotName,
  "docs/launch-evidence/web-snapshots/",
  "does not close the GitHub admin gate"
)) {
  Assert-Contains -Content $LatestIndex -Needle $Needle -Context "docs/launch-evidence/web-snapshots/latest-github-remote.md"
}

foreach ($Needle in @(
  "# GitHub Remote Web Snapshot - $LatestSnapshotDate",
  "Status: Observed",
  "Observation date: $LatestSnapshotDate",
  "Observed URL: https://github.com/orulink-ai/WatcheRobot-Workspace",
  "WatcheRobot-Workspace",
  "No Releases were visible",
  "No Discussions tab was visible",
  'No `.github` directory was visible',
  "older workspace/meta repo introduction",
  "not launch-ready",
  "does not close the GitHub admin gate"
)) {
  Assert-Contains -Content $Snapshot -Needle $Needle -Context "docs/launch-evidence/web-snapshots/$LatestSnapshotName"
}

foreach ($Needle in @(
  "web-snapshots/",
  "GitHub remote web snapshots",
  "cannot close a launch gate"
)) {
  Assert-Contains -Content $EvidenceReadme -Needle $Needle -Context "docs/launch-evidence/README.md"
}

foreach ($Needle in @(
  "GitHub remote web snapshot",
  "fallback evidence",
  "cannot close the GitHub admin state gate"
)) {
  Assert-Contains -Content $LaunchGates -Needle $Needle -Context "docs/open-source-launch-gates.md"
}

foreach ($Needle in @(
  "GitHub remote web snapshot",
  "docs/launch-evidence/web-snapshots/",
  'does not replace `scripts/audit-github-readiness.ps1`'
)) {
  Assert-Contains -Content $PublicValidation -Needle $Needle -Context "docs/public-launch-validation.md"
}

if ($Failures.Count -gt 0) {
  Write-Host "GitHub web snapshot contract tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "GitHub web snapshot contract tests passed."
