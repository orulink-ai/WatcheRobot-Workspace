param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$Failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([string]$Message)
  $script:Failures.Add($Message)
}

function New-UnicodeString {
  param([int[]]$CodePoints)
  return -join ($CodePoints | ForEach-Object { [char]$_ })
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

$Plan = Get-RepoText "docs/open-source-delivery-plan.md"
$FinalReport = Get-RepoText "docs/open-source-readiness-final.md"
$ChineseFinalReport = Get-RepoText "docs/open-source-readiness-final.zh-CN.md"

$GoalTable = New-UnicodeString @(0x76EE, 0x6807, 0x8868)
$TodoList = New-UnicodeString @(0x5F85, 0x529E, 0x4E8B, 0x9879)
$CheckPoint = "Check " + (New-UnicodeString @(0x70B9))
$SubAgentStrategy = (New-UnicodeString @(0x5B50)) + " Agent " + (New-UnicodeString @(0x8C03, 0x7528, 0x7B56, 0x7565))
$SelfReflection = New-UnicodeString @(0x81EA, 0x6211, 0x53CD, 0x601D, 0x8BC4, 0x5206)

foreach ($Needle in @(
  "# WatcheRobot",
  "## 1. ",
  "## 2. ",
  "## 3. " + $CheckPoint,
  "## 3.1 Target Table / " + $GoalTable,
  "## 3.2 Todo List / " + $TodoList,
  "## 4. ",
  "## 6. " + $SubAgentStrategy,
  "## 7. TDD",
  "## 8. " + $SelfReflection
)) {
  Assert-Contains -Content $Plan -Needle $Needle -Context "docs/open-source-delivery-plan.md"
}

foreach ($Needle in @(
  "| Goal | Priority | Metric | Acceptance Standard | Time Window |",
  "G-01",
  "G-02",
  "G-03",
  "G-04",
  "G-05",
  "| Task | Owner / Agent | Due Window | Deliverable | Verification |",
  "T-01",
  "T-02",
  "T-03",
  "T-04",
  "T-05",
  "T-06",
  "T-07",
  "T-08",
  "T-09",
  "T-10",
  "WOS-01",
  "WOS-45",
  "Repo Audit Agent",
  "Docs Agent",
  "QA Agent",
  "scripts/check-open-source-readiness.ps1",
  "scripts/collect-open-source-evidence.ps1"
)) {
  Assert-Contains -Content $Plan -Needle $Needle -Context "docs/open-source-delivery-plan.md"
}

foreach ($Needle in @(
  "scripts/test-delivery-plan-structure-contract.ps1",
  "delivery plan structure contract tests",
  "Target Table",
  "Todo List",
  "WOS-45"
)) {
  Assert-Contains -Content $FinalReport -Needle $Needle -Context "docs/open-source-readiness-final.md"
}

foreach ($Needle in @(
  "scripts/test-delivery-plan-structure-contract.ps1",
  "delivery plan structure contract tests",
  "Target Table",
  "Todo List",
  "WOS-45"
)) {
  Assert-Contains -Content $ChineseFinalReport -Needle $Needle -Context "docs/open-source-readiness-final.zh-CN.md"
}

if ($Failures.Count -gt 0) {
  Write-Host "Delivery plan structure contract tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Delivery plan structure contract tests passed."
