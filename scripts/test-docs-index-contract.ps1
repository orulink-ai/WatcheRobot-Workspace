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
    Add-Failure "Missing docs index file: $RelativePath"
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

function Assert-DoesNotContain {
  param(
    [string]$Content,
    [string]$Needle,
    [string]$Context
  )

  if ($Content -cmatch [regex]::Escape($Needle)) {
    Add-Failure "$Context contains forbidden text: $Needle"
  }
}

$EnglishIndex = Get-RepoText "docs/README.md"
$ChineseIndex = Get-RepoText "docs/README.zh-CN.md"

foreach ($Spec in @(
  @{ name = "docs/README.md"; content = $EnglishIndex },
  @{ name = "docs/README.zh-CN.md"; content = $ChineseIndex }
)) {
  $Name = [string]$Spec.name
  $Content = [string]$Spec.content

  Assert-Contains -Content $Content -Needle "# WatcheRobot" -Context $Name
  Assert-Contains -Content $Content -Needle "WatcheRobot" -Context $Name

  foreach ($Forbidden in @("Watcherobot", "watcherobot", "Watcher Robot", "watcher-robot")) {
    Assert-DoesNotContain -Content $Content -Needle $Forbidden -Context $Name
  }

  foreach ($RequiredDoc in @(
    "quick-start.md",
    "architecture.md",
    "toolchain-matrix.md",
    "open-source-scope.md",
    "product-name-policy.md",
    "hardware-structure-map.md",
    "license-decision-guide.md",
    "demo-asset-checklist.md",
    "roadmap.md",
    "open-source-delivery-plan.md",
    "sub-agent-handoff.md",
    "sub-agent-work-orders/README.md",
    "open-source-readiness-baseline.md",
    "open-source-readiness-final.md",
    "open-source-readiness-final.zh-CN.md",
    "goal-completion-audit.md",
    "public-launch-validation.md",
    "remote-publication-runbook.md",
    "open-source-launch-gates.md",
    "launch-gate-closeout-plan.md",
    "launch-evidence-request-pack.md",
    "launch-evidence/README.md",
    "placeholder-register.md",
    "provisioning.md",
    "motion-guide.md",
    "expression-guide.md",
    "ai-integration.md",
    "extension-boundaries.md",
    "resource-pack-spec.md",
    "community-submissions.md",
    "maintainers.md",
    "community-launch-plan.md",
    "branch-policy.md",
    "release-policy.md",
    "release-manifest.example.json",
    "github-labels.md",
    "github-settings-checklist.md",
    "good-first-issues.md",
    "showcase.md",
    "open-questions.md",
    "owner-decision-record.md",
    "owner-decision-brief.md",
    "decision-log.md",
    "app-internal-rename-plan.md",
    "sd-card-assets.md"
  )) {
    Assert-Contains -Content $Content -Needle $RequiredDoc -Context $Name
  }

  foreach ($RequiredScript in @(
    "../scripts/collect-open-source-evidence.ps1",
    "../scripts/test-github-community-assets.ps1",
    "../scripts/test-github-templates.ps1",
    "../scripts/test-delivery-plan-structure-contract.ps1",
    "../scripts/test-sub-agent-work-orders.ps1",
    "../scripts/test-owner-decision-record.ps1",
    "../scripts/test-owner-decision-quality-fixtures.ps1",
    "../scripts/test-owner-decision-brief.ps1",
    "../scripts/test-launch-evidence-templates.ps1",
    "../scripts/test-uncertainty-governance-contract.ps1",
    "../scripts/test-open-source-ci-workflow.ps1",
    "../scripts/test-product-name-policy.ps1",
    "../scripts/test-readiness-score-contract.ps1",
    "../scripts/test-launch-gate-closeout-plan.ps1",
    "../scripts/test-launch-evidence-request-pack.ps1",
    "../scripts/test-plan-docx-contract.ps1",
    "../scripts/audit-docx-render-prerequisites.ps1",
    "../scripts/test-docx-render-prerequisites-audit.ps1",
    "../scripts/test-goal-completion-audit.ps1",
    "../scripts/test-public-readme-contract.ps1",
    "../scripts/test-docs-index-contract.ps1",
    "../scripts/test-developer-onboarding-contract.ps1",
    "../scripts/test-workspace-submodule-contract.ps1",
    "../scripts/test-github-web-snapshot-contract.ps1",
    "../scripts/test-open-source-runbooks.ps1",
    "../scripts/test-evidence-collector-coverage.ps1",
    "../scripts/test-wos-coverage.ps1",
    "../scripts/test-wos-evidence-trace.ps1",
    "../scripts/audit-open-source-launch-gates.ps1",
    "../scripts/test-open-source-launch-gates.ps1",
    "../scripts/audit-open-source-placeholders.ps1",
    "../scripts/audit-open-source-text-quality.ps1",
    "../scripts/audit-publication-hygiene.ps1",
    "../scripts/test-publication-hygiene.ps1",
    "../scripts/test-release-manifest-validation.ps1",
    "../scripts/test-open-source-examples.ps1"
  )) {
    Assert-Contains -Content $Content -Needle $RequiredScript -Context $Name
  }

  foreach ($SubrepoDoc in @(
    "../WatcheRobot_app/README.md",
    "../WatcheRobot_client/README.md",
    "../WatcheRobot_server/README.md",
    "../WatcheRobot_esp32/README.md",
    "../WatcheRobot_stm32/README.md"
  )) {
    Assert-Contains -Content $Content -Needle $SubrepoDoc -Context $Name
  }
}

Assert-Contains -Content $EnglishIndex -Needle "## Acceptance Principles" -Context "docs/README.md"
Assert-Contains -Content $EnglishIndex -Needle "DOCX render prerequisites" -Context "docs/README.md"
Assert-Contains -Content $EnglishIndex -Needle "scripts/audit-docx-render-prerequisites.ps1" -Context "docs/README.md"
$ChineseDocxRenderPrerequisites = "DOCX " + (-join @([char]0x6E32, [char]0x67D3, [char]0x524D, [char]0x7F6E, [char]0x6761, [char]0x4EF6))
Assert-Contains -Content $ChineseIndex -Needle $ChineseDocxRenderPrerequisites -Context "docs/README.zh-CN.md"
Assert-Contains -Content $ChineseIndex -Needle "scripts/audit-docx-render-prerequisites.ps1" -Context "docs/README.zh-CN.md"

if ($Failures.Count -gt 0) {
  Write-Host "Docs index contract tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Docs index contract tests passed."
