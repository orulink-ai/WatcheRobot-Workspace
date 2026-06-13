param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$Failures = New-Object System.Collections.Generic.List[string]
$ExpectedIds = 1..45 | ForEach-Object { "WOS-{0:D2}" -f $_ }

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

function Get-MarkdownCells {
  param([string]$Line)

  $Trimmed = $Line.Trim()
  if ($Trimmed.StartsWith("|")) {
    $Trimmed = $Trimmed.Substring(1)
  }
  if ($Trimmed.EndsWith("|")) {
    $Trimmed = $Trimmed.Substring(0, $Trimmed.Length - 1)
  }

  return @($Trimmed -split "\|" | ForEach-Object { $_.Trim() })
}

function Test-WosRows {
  param(
    [string]$RelativePath,
    [string]$StatusHeader,
    [string]$EvidenceHeader,
    [string]$RemainingHeader
  )

  $Content = Get-RepoText $RelativePath
  $Lines = @($Content -split "`r?`n")
  $Rows = @($Lines | Where-Object { $_ -match '^\|\s*WOS-\d{2}\s*\|' })
  $SeenIds = New-Object System.Collections.Generic.HashSet[string]

  if ($Rows.Count -ne 45) {
    Add-Failure "$RelativePath has $($Rows.Count) WOS table rows; expected 45"
  }

  foreach ($Row in $Rows) {
    $Cells = Get-MarkdownCells $Row
    if ($Cells.Count -lt 4) {
      Add-Failure "$RelativePath WOS row has fewer than 4 cells: $Row"
      continue
    }

    $Id = $Cells[0]
    if ($ExpectedIds -notcontains $Id) {
      Add-Failure "$RelativePath has unexpected WOS row id: $Id"
      continue
    }
    [void]$SeenIds.Add($Id)

    $Status = $Cells[1]
    $Evidence = $Cells[2]
    $Remaining = $Cells[3]

    if ([string]::IsNullOrWhiteSpace($Status) -or $Status -match '^(TBD|TODO|PLACEHOLDER)$') {
      Add-Failure "$RelativePath $Id has empty or placeholder-only $StatusHeader"
    }
    if ([string]::IsNullOrWhiteSpace($Evidence) -or $Evidence -match '^(TBD|TODO|PLACEHOLDER)$') {
      Add-Failure "$RelativePath $Id has empty or placeholder-only $EvidenceHeader"
    }
    if ([string]::IsNullOrWhiteSpace($Remaining) -or $Remaining -match '^(TBD|TODO|PLACEHOLDER)$') {
      Add-Failure "$RelativePath $Id has empty or placeholder-only $RemainingHeader"
    }
    if ($Evidence -notmatch '(`[^`]+`|\[[^\]]+\]\([^)]+\)|README|GitHub|WOS|Target Table|Todo List)') {
      Add-Failure "$RelativePath $Id evidence is too weak; include a file path, link, README/GitHub reference, or explicit table reference"
    }
  }

  foreach ($ExpectedId in $ExpectedIds) {
    if (-not $SeenIds.Contains($ExpectedId)) {
      Add-Failure "$RelativePath is missing WOS table row $ExpectedId"
    }
  }
}

$Plan = Get-RepoText "docs/open-source-delivery-plan.md"
$GoalAudit = Get-RepoText "docs/goal-completion-audit.md"
$FinalReport = Get-RepoText "docs/open-source-readiness-final.md"
$ChineseFinalReport = Get-RepoText "docs/open-source-readiness-final.zh-CN.md"

foreach ($Needle in @(
  "WOS evidence trace",
  "scripts/test-wos-evidence-trace.ps1"
)) {
  Assert-Contains -Content $Plan -Needle $Needle -Context "docs/open-source-delivery-plan.md"
  Assert-Contains -Content $GoalAudit -Needle $Needle -Context "docs/goal-completion-audit.md"
  Assert-Contains -Content $FinalReport -Needle $Needle -Context "docs/open-source-readiness-final.md"
  Assert-Contains -Content $ChineseFinalReport -Needle $Needle -Context "docs/open-source-readiness-final.zh-CN.md"
}

Test-WosRows -RelativePath "docs/open-source-readiness-final.md" -StatusHeader "Status after this round" -EvidenceHeader "Evidence" -RemainingHeader "Remaining blocker / TODO"
Test-WosRows -RelativePath "docs/open-source-readiness-final.zh-CN.md" -StatusHeader "Chinese status" -EvidenceHeader "Current evidence" -RemainingHeader "Remaining blocker"

if ($Failures.Count -gt 0) {
  Write-Host "WOS evidence trace tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "WOS evidence trace tests passed."
