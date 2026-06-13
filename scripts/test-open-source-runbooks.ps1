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
    Add-Failure "Missing runbook file: $RelativePath"
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

  $NormalizedContent = $Content -replace "\\", "/"
  $NormalizedNeedle = $Needle -replace "\\", "/"
  if ($Content -notmatch [regex]::Escape($Needle) -and $NormalizedContent -notmatch [regex]::Escape($NormalizedNeedle)) {
    Add-Failure "$Context is missing required text: $Needle"
  }
}

$Handoff = Get-RepoText "docs/sub-agent-handoff.md"
$RemoteRunbook = Get-RepoText "docs/remote-publication-runbook.md"
$PublicValidation = Get-RepoText "docs/public-launch-validation.md"
$LaunchGates = Get-RepoText "docs/open-source-launch-gates.md"

$BannedGitPatterns = @(
  '(?im)^\s*git\s+add\s+(\.|-A|--all|\*)\s*$',
  '(?im)^\s*git\s+reset\s+--hard\b',
  '(?im)^\s*git\s+checkout\s+--\b',
  '(?im)^\s*git\s+clean\s+-[^\r\n]*[fd]\b'
)

foreach ($Pattern in $BannedGitPatterns) {
  foreach ($Match in [regex]::Matches($RemoteRunbook, $Pattern)) {
    Add-Failure "docs/remote-publication-runbook.md contains unsafe git command: $($Match.Value.Trim())"
  }
  foreach ($Match in [regex]::Matches($Handoff, $Pattern)) {
    Add-Failure "docs/sub-agent-handoff.md contains unsafe git command: $($Match.Value.Trim())"
  }
}

foreach ($Needle in @(
  'Do not use broad `git add .`',
  "Do not stage these unless they are intentionally reviewed",
  "git diff --cached --check",
  "WatcheRobot_app",
  "WatcheRobot_client",
  "WatcheRobot_esp32",
  "scripts/desktop-server.ps1"
)) {
  Assert-Contains -Content $RemoteRunbook -Needle $Needle -Context "docs/remote-publication-runbook.md"
}

foreach ($ScriptPath in @(
  "scripts/check-open-source-readiness.ps1",
  "scripts/audit-github-readiness.ps1",
  "scripts/audit-docx-render-prerequisites.ps1",
  "scripts/audit-open-source-launch-gates.ps1",
  "scripts/audit-open-source-placeholders.ps1",
  "scripts/audit-open-source-text-quality.ps1",
  "scripts/audit-publication-hygiene.ps1",
  "scripts/collect-open-source-evidence.ps1",
  "scripts/create-good-first-issues.ps1",
  "scripts/sync-github-labels.ps1",
  "scripts/test-delivery-plan-structure-contract.ps1",
  "scripts/test-github-community-assets.ps1",
  "scripts/test-github-templates.ps1",
  "scripts/test-owner-decision-record.ps1",
  "scripts/test-owner-decision-quality-fixtures.ps1",
  "scripts/test-owner-decision-brief.ps1",
  "scripts/test-launch-evidence-templates.ps1",
  "scripts/test-uncertainty-governance-contract.ps1",
  "scripts/test-open-source-ci-workflow.ps1",
  "scripts/test-product-name-policy.ps1",
  "scripts/test-readiness-score-contract.ps1",
  "scripts/test-launch-gate-closeout-plan.ps1",
  "scripts/test-launch-evidence-request-pack.ps1",
  "scripts/test-plan-docx-contract.ps1",
  "scripts/test-docx-render-prerequisites-audit.ps1",
  "scripts/test-goal-completion-audit.ps1",
  "scripts/test-public-readme-contract.ps1",
  "scripts/test-docs-index-contract.ps1",
  "scripts/test-developer-onboarding-contract.ps1",
  "scripts/test-workspace-submodule-contract.ps1",
  "scripts/test-github-web-snapshot-contract.ps1",
  "scripts/test-open-source-runbooks.ps1",
  "scripts/test-evidence-collector-coverage.ps1",
  "scripts/test-wos-coverage.ps1",
  "scripts/test-wos-evidence-trace.ps1",
  "scripts/test-open-source-examples.ps1",
  "scripts/test-open-source-launch-gates.ps1",
  "scripts/test-publication-hygiene.ps1",
  "scripts/test-release-manifest-validation.ps1",
  "scripts/test-sub-agent-work-orders.ps1",
  "scripts/validate-release-manifest.ps1"
)) {
  Assert-Contains -Content $RemoteRunbook -Needle "git add $ScriptPath" -Context "docs/remote-publication-runbook.md"
}
Assert-Contains -Content $RemoteRunbook -Needle 'git add -- "*Codex*Sub-Agent*.docx"' -Context "docs/remote-publication-runbook.md"
Assert-Contains -Content $RemoteRunbook -Needle 'Only the root Word reference plan matching `*Codex*Sub-Agent*.docx` may be staged as a `.docx` file.' -Context "docs/remote-publication-runbook.md"
Assert-Contains -Content $RemoteRunbook -Needle "git add .gitignore" -Context "docs/remote-publication-runbook.md"
Assert-Contains -Content $RemoteRunbook -Needle "scripts/audit-publication-hygiene.ps1" -Context "docs/remote-publication-runbook.md"

foreach ($Section in @(
  "## Required Reading Order",
  "## Universal Rules",
  "## Work Orders",
  "## External Evidence Needed Before 100/100",
  "## Minimum Commands For A Fresh Continuation",
  "## Completion Rule"
)) {
  Assert-Contains -Content $Handoff -Needle $Section -Context "docs/sub-agent-handoff.md"
}

foreach ($RequiredDoc in @(
  "docs/open-source-delivery-plan.md",
  "docs/open-source-readiness-final.md",
  "docs/open-source-readiness-final.zh-CN.md",
  "docs/goal-completion-audit.md",
  "docs/owner-decision-record.md",
  "docs/owner-decision-brief.md",
  "docs/launch-evidence-request-pack.md",
  "docs/placeholder-register.md",
  "docs/remote-publication-runbook.md",
  "docs/public-launch-validation.md",
  "docs/open-source-launch-gates.md",
  "docs/launch-gate-closeout-plan.md"
)) {
  Assert-Contains -Content $Handoff -Needle $RequiredDoc -Context "docs/sub-agent-handoff.md"
}

foreach ($WorkOrder in @("WO-01", "WO-02", "WO-03", "WO-04", "WO-05", "WO-06", "WO-07")) {
  Assert-Contains -Content $Handoff -Needle $WorkOrder -Context "docs/sub-agent-handoff.md"
}

Assert-Contains -Content $Handoff -Needle "DOCX render fallback must be recorded" -Context "docs/sub-agent-handoff.md"

foreach ($Command in @(
  "scripts/check-open-source-readiness.ps1",
  "scripts/collect-open-source-evidence.ps1",
  "scripts/test-delivery-plan-structure-contract.ps1",
  "scripts/test-owner-decision-record.ps1",
  "scripts/test-owner-decision-quality-fixtures.ps1",
  "scripts/test-owner-decision-brief.ps1",
  "scripts/test-launch-evidence-templates.ps1",
  "scripts/test-uncertainty-governance-contract.ps1",
  "scripts/test-open-source-ci-workflow.ps1",
  "scripts/test-product-name-policy.ps1",
  "scripts/test-readiness-score-contract.ps1",
  "scripts/test-launch-gate-closeout-plan.ps1",
  "scripts/test-launch-evidence-request-pack.ps1",
  "scripts/test-plan-docx-contract.ps1",
  "scripts/test-docx-render-prerequisites-audit.ps1",
  "scripts/test-goal-completion-audit.ps1",
  "scripts/test-public-readme-contract.ps1",
  "scripts/test-docs-index-contract.ps1",
  "scripts/test-developer-onboarding-contract.ps1",
  "scripts/test-workspace-submodule-contract.ps1",
  "scripts/test-github-web-snapshot-contract.ps1",
  "scripts/test-open-source-runbooks.ps1",
  "scripts/test-evidence-collector-coverage.ps1",
  "scripts/test-wos-coverage.ps1",
  "scripts/audit-open-source-launch-gates.ps1",
  "scripts/test-open-source-launch-gates.ps1",
  "scripts/audit-open-source-placeholders.ps1",
  "scripts/audit-open-source-text-quality.ps1",
  "scripts/audit-publication-hygiene.ps1",
  "scripts/test-publication-hygiene.ps1",
  "scripts/test-release-manifest-validation.ps1",
  "scripts/test-sub-agent-work-orders.ps1",
  "scripts/test-wos-evidence-trace.ps1"
)) {
  Assert-Contains -Content $Handoff -Needle $Command -Context "docs/sub-agent-handoff.md"
}

foreach ($Evidence in @(
  "Final license decision",
  "Official community entrance",
  "Approved README demo asset",
  "GitHub admin state",
  "Hardware smoke test",
  "Java / Android tooling",
  "Clean-machine run"
)) {
  Assert-Contains -Content $Handoff -Needle $Evidence -Context "docs/sub-agent-handoff.md"
}

foreach ($ValidationCommand in @(
  "scripts/check-open-source-readiness.ps1",
  "scripts/audit-open-source-placeholders.ps1",
  "scripts/audit-open-source-launch-gates.ps1",
  "scripts/test-open-source-launch-gates.ps1",
  "scripts/audit-open-source-text-quality.ps1",
  "scripts/audit-publication-hygiene.ps1",
  "scripts/test-publication-hygiene.ps1",
  "scripts/test-delivery-plan-structure-contract.ps1",
  "scripts/test-owner-decision-record.ps1",
  "scripts/test-owner-decision-quality-fixtures.ps1",
  "scripts/test-owner-decision-brief.ps1",
  "scripts/test-launch-evidence-templates.ps1",
  "scripts/test-uncertainty-governance-contract.ps1",
  "scripts/test-open-source-ci-workflow.ps1",
  "scripts/test-product-name-policy.ps1",
  "scripts/test-readiness-score-contract.ps1",
  "scripts/test-launch-gate-closeout-plan.ps1",
  "scripts/test-plan-docx-contract.ps1",
  "scripts/test-docx-render-prerequisites-audit.ps1",
  "scripts/test-goal-completion-audit.ps1",
  "scripts/test-public-readme-contract.ps1",
  "scripts/test-docs-index-contract.ps1",
  "scripts/test-developer-onboarding-contract.ps1",
  "scripts/test-workspace-submodule-contract.ps1",
  "scripts/test-github-web-snapshot-contract.ps1",
  "scripts/test-open-source-runbooks.ps1",
  "scripts/test-evidence-collector-coverage.ps1",
  "scripts/test-wos-coverage.ps1",
  "scripts/test-release-manifest-validation.ps1",
  "scripts/test-open-source-examples.ps1",
  "scripts/test-sub-agent-work-orders.ps1",
  "scripts/test-wos-evidence-trace.ps1",
  "scripts/collect-open-source-evidence.ps1"
)) {
  Assert-Contains -Content $PublicValidation -Needle $ValidationCommand -Context "docs/public-launch-validation.md"
}

foreach ($Needle in @(
  "fresh clone directory",
  "root commit hash",
  "git submodule status --recursive",
  "no local cache reuse",
  "scripts/test-open-source-examples.ps1 output",
  "issue template URLs",
  "PR template URL",
  "synced label list",
  "good first issue URLs",
  "open-source readiness workflow visibility",
  "branch protection required checks",
  "scripts/audit-github-readiness.ps1 output",
  "power supply and safety setup",
  "Wi-Fi provisioning ready state",
  "serial/app logs",
  "expected ACK / observed result"
)) {
  Assert-Contains -Content $PublicValidation -Needle $Needle -Context "docs/public-launch-validation.md field-level evidence"
}

foreach ($Gate in @(
  "Owner decisions",
  "Final license",
  "Official community entrance",
  "Approved demo asset",
  "GitHub admin state",
  "Release manifest",
  "Java / Android validation",
  "Clean-machine validation",
  "Hardware smoke validation"
)) {
  Assert-Contains -Content $LaunchGates -Needle $Gate -Context "docs/open-source-launch-gates.md"
}

if ($Failures.Count -gt 0) {
  Write-Host "Open-source runbook tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Open-source runbook tests passed."
