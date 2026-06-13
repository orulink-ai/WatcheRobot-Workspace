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

$DeliveryPlan = Get-RepoText "docs/open-source-delivery-plan.md"
$SubAgentHandoff = Get-RepoText "docs/sub-agent-handoff.md"
$OpenQuestions = Get-RepoText "docs/open-questions.md"
$OwnerDecisionRecord = Get-RepoText "docs/owner-decision-record.md"
$PlaceholderRegister = Get-RepoText "docs/placeholder-register.md"
$FinalReport = Get-RepoText "docs/open-source-readiness-final.md"
$ChineseFinalReport = Get-RepoText "docs/open-source-readiness-final.zh-CN.md"

$UncertaintyRulesTitle = "## 2. " + (New-UnicodeString @(0x4E0D, 0x786E, 0x5B9A, 0x6027, 0x89C4, 0x5219))
$StrictNoInvent = New-UnicodeString @(0x4E25, 0x7981, 0x865A, 0x6784)
$MustAskNoReply = (New-UnicodeString @(0x5FC5, 0x987B, 0x8BE2, 0x95EE, 0x7528, 0x6237)) + [char]0xFF1B + (New-UnicodeString @(0x65E0, 0x4EBA, 0x56DE, 0x590D, 0x65F6, 0x4F7F, 0x7528)) + " TODO/TBD"
$SubAgentUncertain = (New-UnicodeString @(0x5B50)) + " agent " + (New-UnicodeString @(0x53D1, 0x73B0, 0x4E0D, 0x786E, 0x5B9A, 0x70B9))

foreach ($Needle in @(
  $UncertaintyRulesTitle,
  $StrictNoInvent,
  $MustAskNoReply,
  $SubAgentUncertain,
  "TODO(owner/date)",
  "TBD: ",
  "PLACEHOLDER(owner/date)",
  "docs/open-questions.md"
)) {
  Assert-Contains -Content $DeliveryPlan -Needle $Needle -Context "docs/open-source-delivery-plan.md"
}

foreach ($Needle in @(
  "Do not invent license, maintainer, demo, community, roadmap, release, or hardware public-scope decisions.",
  'Every new public uncertainty marker must be registered in `docs/placeholder-register.md`.',
  'Do not create launch evidence files with `Status: Passed` unless the result was directly observed',
  "Passed launch evidence must not contain pending tokens anywhere in the file",
  "Owner decision closeout",
  "Decision evidence is missing"
)) {
  Assert-Contains -Content $SubAgentHandoff -Needle $Needle -Context "docs/sub-agent-handoff.md"
}

foreach ($Needle in @(
  "must not be guessed by Codex or sub-agents",
  "Rule: if a fact is not confirmed here or in repository evidence",
  "TODO",
  "TBD",
  "PLACEHOLDER"
)) {
  Assert-Contains -Content $OpenQuestions -Needle $Needle -Context "docs/open-questions.md"
}

foreach ($Needle in @(
  "Codex and sub-agents must not fill these decisions with guesses",
  "If a decision remains open, keep the corresponding public docs as TODO/TBD/PLACEHOLDER",
  "OQ-001",
  "OQ-009"
)) {
  Assert-Contains -Content $OwnerDecisionRecord -Needle $Needle -Context "docs/owner-decision-record.md"
}

foreach ($Needle in @(
  "prevent Codex or sub-agents from hiding uncertainty in random files",
  "Do not convert any item below into a public promise",
  "docs/open-questions.md",
  "docs/owner-decision-record.md"
)) {
  Assert-Contains -Content $PlaceholderRegister -Needle $Needle -Context "docs/placeholder-register.md"
}

foreach ($Needle in @(
  "scripts/test-uncertainty-governance-contract.ps1",
  "uncertainty governance contract tests",
  "WOS-26",
  "WOS-34",
  "WOS-41",
  "WOS-45"
)) {
  Assert-Contains -Content $FinalReport -Needle $Needle -Context "docs/open-source-readiness-final.md"
}

foreach ($Needle in @(
  "scripts/test-uncertainty-governance-contract.ps1",
  "uncertainty governance contract tests",
  "WOS-26",
  "WOS-34",
  "WOS-41",
  "WOS-45"
)) {
  Assert-Contains -Content $ChineseFinalReport -Needle $Needle -Context "docs/open-source-readiness-final.zh-CN.md"
}

if ($Failures.Count -gt 0) {
  Write-Host "Uncertainty governance contract tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Uncertainty governance contract tests passed."
