param(
  [string]$Repo = "",
  [string]$RemoteName = "origin",
  [switch]$Json,
  [switch]$FailOnMissing
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$GitSafeDirectory = ([string]$Root) -replace "\\", "/"

function Get-RepositorySlug {
  param([string]$ExplicitRepo, [string]$Remote)

  if ($ExplicitRepo) {
    return $ExplicitRepo.Trim().TrimEnd("/")
  }

  $RemoteUrl = (& git -c "safe.directory=$GitSafeDirectory" -C $Root remote get-url $Remote 2>$null)
  if (-not $RemoteUrl) {
    throw "Unable to read git remote '$Remote'. Pass -Repo owner/name explicitly."
  }

  if ($RemoteUrl -match "github\.com[:/](?<owner>[^/]+)/(?<repo>[^/.]+)(\.git)?$") {
    return "$($Matches.owner)/$($Matches.repo)"
  }

  throw "Remote is not a GitHub URL that can be parsed: $RemoteUrl"
}

function Invoke-GitHubGet {
  param([string]$Path)

  $Headers = @{
    "User-Agent" = "WatcheRobot-readiness-audit"
    "Accept" = "application/vnd.github+json"
  }
  $Token = $env:GH_TOKEN
  if (-not $Token) {
    $Token = $env:GITHUB_TOKEN
  }
  if ($Token) {
    $Headers.Authorization = "Bearer $Token"
  }

  Invoke-RestMethod -Uri "https://api.github.com/$Path" -Headers $Headers
}

function Get-AllGitHubPages {
  param([string]$Path)

  $Items = @()
  $Page = 1
  while ($true) {
    $Batch = Invoke-GitHubGet "$Path`?per_page=100&page=$Page"
    if (-not $Batch -or $Batch.Count -eq 0) {
      break
    }
    $Items += $Batch
    if ($Batch.Count -lt 100) {
      break
    }
    $Page += 1
  }
  return $Items
}

$Slug = Get-RepositorySlug -ExplicitRepo $Repo -Remote $RemoteName
try {
  $RepoInfo = Invoke-GitHubGet "repos/$Slug"
} catch {
  $Result = [ordered]@{
    repo = $Slug
    api_status = "unavailable"
    api_error = $_.Exception.Message
    note = "Set GH_TOKEN or GITHUB_TOKEN to avoid anonymous GitHub API rate limits."
  }
  if ($Json) {
    $Result | ConvertTo-Json -Depth 4
  } else {
    Write-Host "GitHub readiness audit for $Slug"
    Write-Host "API status: unavailable"
    Write-Host "API error: $($Result.api_error)"
    Write-Host $Result.note
  }
  if ($FailOnMissing) {
    exit 1
  }
  exit 0
}
$DefaultBranch = [string]$RepoInfo.default_branch

$ExpectedLabelPath = Join-Path $Root ".github/labels.json"
$ExpectedLabels = @()
if (Test-Path -LiteralPath $ExpectedLabelPath) {
  $ExpectedLabels = Get-Content -LiteralPath $ExpectedLabelPath -Raw | ConvertFrom-Json
}

$RemoteLabels = @{}
$LabelError = ""
try {
  foreach ($Label in Get-AllGitHubPages "repos/$Slug/labels") {
    $RemoteLabels[[string]$Label.name] = $true
  }
} catch {
  $LabelError = $_.Exception.Message
}

$MissingLabels = @()
foreach ($Label in $ExpectedLabels) {
  if (-not $RemoteLabels.ContainsKey([string]$Label.name)) {
    $MissingLabels += [string]$Label.name
  }
}

$Protection = $null
$ProtectionStatus = "unknown"
try {
  $Protection = Invoke-GitHubGet "repos/$Slug/branches/$DefaultBranch/protection"
  $ProtectionStatus = "enabled"
} catch {
  $ProtectionStatus = "not_enabled_or_no_permission"
}

$Contents = @{}
foreach ($Path in @(
  ".github/ISSUE_TEMPLATE",
  ".github/PULL_REQUEST_TEMPLATE.md",
  ".github/workflows/open-source-readiness.yml"
)) {
  try {
    $null = Invoke-GitHubGet "repos/$Slug/contents/$Path"
    $Contents[$Path] = "present"
  } catch {
    $Contents[$Path] = "missing_or_not_pushed"
  }
}

$Result = [ordered]@{
  repo = $Slug
  api_status = "ok"
  default_branch = $DefaultBranch
  private = [bool]$RepoInfo.private
  archived = [bool]$RepoInfo.archived
  has_discussions = [bool]$RepoInfo.has_discussions
  license = if ($RepoInfo.license) { [string]$RepoInfo.license.spdx_id } else { "" }
  expected_label_count = @($ExpectedLabels).Count
  missing_labels = $MissingLabels
  label_error = $LabelError
  branch_protection = $ProtectionStatus
  required_status_checks = if ($Protection -and $Protection.required_status_checks) { "configured" } else { "unknown_or_unconfigured" }
  required_pull_request_reviews = if ($Protection -and $Protection.required_pull_request_reviews) { "configured" } else { "unknown_or_unconfigured" }
  remote_contents = $Contents
}

if ($Json) {
  $Result | ConvertTo-Json -Depth 6
} else {
  Write-Host "GitHub readiness audit for $Slug"
  Write-Host "Default branch: $DefaultBranch"
  Write-Host "Discussions enabled: $($Result.has_discussions)"
  Write-Host "Remote license: $($Result.license)"
  Write-Host "Missing labels: $($MissingLabels -join ', ')"
  Write-Host "Branch protection: $ProtectionStatus"
  foreach ($Key in $Contents.Keys) {
    Write-Host "${Key}: $($Contents[$Key])"
  }
}

if ($FailOnMissing -and ($MissingLabels.Count -gt 0 -or -not $Result.has_discussions -or $ProtectionStatus -ne "enabled")) {
  exit 1
}
