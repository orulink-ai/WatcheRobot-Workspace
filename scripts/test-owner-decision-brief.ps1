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
    [string]$Path
  )

  if (-not $Content.Contains($Needle)) {
    Add-Failure "$Path is missing required text: $Needle"
  }
}

function Get-DecisionRows {
  param(
    [string]$Content
  )

  $Rows = @{}
  foreach ($Line in ($Content -split "`r?`n")) {
    if ($Line -notmatch "^\|\s*(OQ-\d{3})\b") {
      continue
    }

    $Id = $Matches[1]
    if ($Rows.ContainsKey($Id)) {
      Add-Failure "docs/owner-decision-brief.md contains duplicate row for $Id"
      continue
    }

    $Rows[$Id] = @($Line.Trim("|") -split "\|" | ForEach-Object { $_.Trim() })
  }

  return $Rows
}

$BriefPath = Join-Path $Root "docs/owner-decision-brief.md"
if (-not (Test-Path -LiteralPath $BriefPath)) {
  Add-Failure "Missing file: docs/owner-decision-brief.md"
} else {
  $Content = Get-Content -LiteralPath $BriefPath -Raw -Encoding UTF8

  foreach ($RequiredText in @(
    "# Owner Decision Brief",
    "Codex and sub-agents must not close any launch gate from this brief alone.",
    "If no owner reply arrives, keep the current public docs unchanged and leave the launch gate unavailable.",
    "docs/owner-decision-record.md",
    "docs/open-source-launch-gates.md",
    "scripts/audit-open-source-launch-gates.ps1",
    "traceable source marker",
    "| Decision | Blocks | Owner role | Exact answer needed | Acceptable evidence | Files to update after approval |",
    "Final license",
    "Official community entrance",
    "Approved demo asset",
    "GitHub admin state",
    "Java / Android validation",
    "Clean-machine validation",
    "Hardware smoke validation"
  )) {
    Assert-Contains -Content $Content -Needle $RequiredText -Path "docs/owner-decision-brief.md"
  }

  $Rows = Get-DecisionRows -Content $Content
  $ExpectedIds = 1..9 | ForEach-Object { "OQ-{0:D3}" -f $_ }
  foreach ($ExpectedId in $ExpectedIds) {
    if (-not $Rows.ContainsKey($ExpectedId)) {
      Add-Failure "docs/owner-decision-brief.md is missing $ExpectedId"
      continue
    }

    $Cells = @($Rows[$ExpectedId])
    if ($Cells.Count -ne 6) {
      Add-Failure "docs/owner-decision-brief.md row $ExpectedId has $($Cells.Count) cells; expected 6"
    }
  }

  foreach ($FoundId in $Rows.Keys) {
    if ($ExpectedIds -notcontains $FoundId) {
      Add-Failure "docs/owner-decision-brief.md contains unexpected decision id: $FoundId"
    }
  }
}

if ($Failures.Count -gt 0) {
  Write-Host "Owner decision brief tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Owner decision brief tests passed."
