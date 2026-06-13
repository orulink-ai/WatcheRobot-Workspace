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
    [string]$Context
  )

  if (-not $Content.Contains($Needle)) {
    Add-Failure "$Context is missing required text: $Needle"
  }
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

$Audit = Read-Text "docs/goal-completion-audit.md"

foreach ($RequiredText in @(
  "# Goal Completion Audit",
  "WatcheRobot",
  "root Word reference plan",
  "docs/open-source-delivery-plan.md",
  "docs/launch-evidence-request-pack.md",
  "scripts/test-plan-docx-contract.ps1",
  "scripts/audit-docx-render-prerequisites.ps1",
  "scripts/test-docx-render-prerequisites-audit.ps1",
  "DOCX render prerequisites",
  "WOS-01",
  "WOS-45",
  "self-reflection score",
  "99/100",
  "Do not mark the goal complete",
  "owner decisions",
  "final license",
  "community entrance",
  "approved demo asset",
  "github admin state",
  "release manifest",
  "java and app gradle",
  "clean-machine validation",
  "hardware smoke validation",
  "scripts/check-open-source-readiness.ps1 -SkipGradle",
  "scripts/collect-open-source-evidence.ps1 -SkipGradle",
  "scripts/audit-docx-render-prerequisites.ps1",
  "scripts/audit-open-source-launch-gates.ps1 -RequirePassed",
  "scripts/test-goal-completion-audit.ps1",
  "Strict Final Review Command Set",
  "Evidence Freshness Rule",
  "Authoritative Evidence Hierarchy",
  "derived summaries",
  "launch evidence files override final reports",
  "contradictory evidence",
  "source-of-truth conflict",
  "keep the related gate unavailable or failed",
  "same final review round",
  "stale screenshots",
  "stale logs",
  "stale owner replies",
  "revalidated with date, owner, environment, and command/output link",
  "scripts/check-open-source-readiness.ps1",
  "full Gradle-inclusive readiness check",
  "scripts/test-readiness-score-contract.ps1",
  "scripts/test-wos-coverage.ps1",
  "scripts/test-wos-evidence-trace.ps1",
  "scripts/test-open-source-launch-gates.ps1",
  "scripts/test-release-manifest-validation.ps1",
  "scripts/validate-release-manifest.ps1 -Manifest <final-manifest>",
  "scripts/audit-github-readiness.ps1",
  "git diff --check",
  "git -C WatcheRobot_app diff --check",
  "no pending tokens",
  "Field-Level Launch Gate Evidence Required Before Completion",
  "OQ-001 through OQ-009 exactly once",
  "SPDX license identifier",
  "root LICENSE path",
  "subrepo license impact",
  "hardware / structure file license scope",
  "third-party dependency compatibility",
  "temporary license placeholder removal",
  "official community URL",
  "access status",
  "moderation owner",
  "response window",
  "fallback contact",
  "README community link",
  "GitHub Discussions setting or equivalent route",
  "approved media URL or repository path",
  "asset type",
  "public usage rights",
  "source owner",
  "README Demo section replacement",
  "docs/assets/README.md placement/reference",
  "caption approval",
  "issue template URLs",
  "PR template URL",
  "synced label list",
  "good first issue URLs",
  "workflow visibility",
  "branch protection required checks",
  "scripts/audit-github-readiness.ps1 output",
  "unique artifact names",
  "JSON boolean artifact required values",
  "artifact path_or_url values",
  "workspace/App/desktop/server/ESP32/STM32 component refs",
  "java -version",
  "JAVA_HOME",
  "Android SDK path/version",
  "Gradle command exit code",
  "Gradle output log path",
  "signing secrets are not included",
  "fresh clone directory",
  "root commit hash",
  "git submodule status --recursive",
  "no local cache reuse",
  "device ID / hardware revision",
  "power supply and safety setup",
  "serial/app logs",
  "expected ACK / observed result"
)) {
  Assert-Contains -Content $Audit -Needle $RequiredText -Context "docs/goal-completion-audit.md"
}

if ($Audit -match "(?m)^\|\s*Launch gates all passed\s*\|[^|]*\|\s*Complete\s*\|") {
  Add-Failure "docs/goal-completion-audit.md must not mark launch gates all passed as Complete while current gates are unavailable."
}

if ($Failures.Count -gt 0) {
  Write-Host "Goal completion audit tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Goal completion audit tests passed."
