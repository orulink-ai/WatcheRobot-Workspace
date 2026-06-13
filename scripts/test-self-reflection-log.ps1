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

function Invoke-LaunchGateAuditJson {
  $Output = & powershell -ExecutionPolicy Bypass -File (Join-Path $Root "scripts/audit-open-source-launch-gates.ps1") -Json -SkipExternal
  if ($LASTEXITCODE -ne 0) {
    Add-Failure "Launch gate audit JSON command failed with exit code $LASTEXITCODE"
    return $null
  }

  try {
    return (($Output -join [Environment]::NewLine) | ConvertFrom-Json)
  } catch {
    Add-Failure "Launch gate audit JSON output could not be parsed: $($_.Exception.Message)"
    return $null
  }
}

$Log = Read-Text "docs/self-reflection-log.md"
$GoalAudit = Read-Text "docs/goal-completion-audit.md"
$Final = Read-Text "docs/open-source-readiness-final.md"
$FinalZh = Read-Text "docs/open-source-readiness-final.zh-CN.md"
$Handoff = Read-Text "docs/sub-agent-handoff.md"
$Plan = Read-Text "docs/open-source-delivery-plan.md"

foreach ($Required in @(
  "# Self-Reflection Log",
  "Current round self-score: 99.99/100.",
  "Canonical public readiness score: 99/100.",
  "Do not mark the goal complete",
  "Passed 42",
  "Failed 0",
  "Unavailable 7",
  "Passed: 0",
  "Unavailable: 9",
  "Failed: 0",
  "scripts/check-open-source-readiness.ps1 -SkipGradle",
  "scripts/collect-open-source-evidence.ps1 -SkipGradle",
  "scripts/audit-open-source-launch-gates.ps1",
  "DOCX render fallback recorded",
  "Docs index contract",
  "scripts/test-docs-index-contract.ps1",
  "Release manifest contract",
  "scripts/test-release-manifest-validation.ps1",
  "non-semantic versions are rejected",
  'semantic `version`',
  "Release owner request contract",
  "scripts/test-launch-evidence-owner-requests.ps1",
  "final release manifest values",
  "GitHub admin owner request contract",
  "open-source readiness workflow",
  "branch protection required checks",
  "License/community/demo owner request contract",
  "License/community/demo evidence template contract",
  "GitHub/QA/hardware evidence template contract",
  "Sub-agent work order field-level contract",
  "Public launch validation runbook field-level contract",
  "Goal completion audit field-level contract",
  "Strict final review command contract",
  "Evidence freshness contract",
  "Authoritative evidence hierarchy contract",
  "SPDX license identifier",
  "official community URL",
  "approved media URL or repository path",
  "branch protection required checks",
  "no local cache reuse",
  "expected ACK / observed result",
  "scripts/test-sub-agent-work-orders.ps1",
  "scripts/test-open-source-runbooks.ps1",
  "scripts/test-goal-completion-audit.ps1",
  "Field-Level Launch Gate Evidence Required Before Completion",
  "Strict Final Review Command Set",
  "Evidence Freshness Rule",
  "Authoritative Evidence Hierarchy",
  "source-of-truth conflict",
  "launch evidence files override final reports",
  "stale screenshots",
  "stale owner replies",
  "full Gradle-inclusive readiness check",
  "scripts/validate-release-manifest.ps1 -Manifest <final-manifest>",
  "caption approval",
  "QA owner request contract",
  "fresh clone directory",
  "Firmware smoke owner request contract",
  "device ID / hardware revision",
  "App Gradle owner request contract",
  "App Gradle evidence template contract",
  "java -version",
  "Gradle command exit code",
  "signing secrets are not included",
  "OQ-009 legacy identifier decision",
  "Launch evidence contract",
  "scripts/test-open-source-launch-gates.ps1",
  'generic `command output was reviewed` evidence cannot close a launch gate',
  "concrete URL, repository path, exact command",
  "Owner decision contract",
  "scripts/test-owner-decision-quality-fixtures.ps1",
  'generic `Command output was reviewed` cannot close an owner decision',
  'concrete traceable `Evidence / link` values',
  "launch gate cannot pass when",
  "missing OQ-001 through OQ-009 rows",
  "required desktop / ESP32 artifacts",
  "duplicate artifact names are rejected",
  'artifact `required` fields are JSON booleans',
  'artifact `path_or_url` values',
  "http(s) URLs or traceable file paths",
  "public release URL",
  "future release dates are rejected",
  "non-http(s) release URLs are rejected",
  "readiness / hardware smoke / clean-machine checks cannot be omitted",
  "required checks cannot be",
  "required component refs cannot be omitted",
  "arbitrary component ref strings are rejected",
  "workspace/app/desktop/server/esp32/stm32 component refs as commit hashes or semantic version tags",
  "all release checks to be",
  "desktop-windows-installer",
  "esp32-firmware-package",
  "scripts/audit-docx-render-prerequisites.ps1"
)) {
  Assert-Contains -Content $Log -Needle $Required -Context "docs/self-reflection-log.md"
}

foreach ($Context in @(
  @{ name = "docs/goal-completion-audit.md"; content = $GoalAudit },
  @{ name = "docs/open-source-readiness-final.md"; content = $Final },
  @{ name = "docs/open-source-readiness-final.zh-CN.md"; content = $FinalZh },
  @{ name = "docs/sub-agent-handoff.md"; content = $Handoff },
  @{ name = "docs/open-source-delivery-plan.md"; content = $Plan }
)) {
  Assert-Contains -Content $Context.content -Needle "docs/self-reflection-log.md" -Context $Context.name
}

if ($Log -match "Current round self-score:\s*([0-9]+(?:\.[0-9]+)?)/100") {
  $Score = [double]$Matches[1]
  $Audit = Invoke-LaunchGateAuditJson
  if ($null -ne $Audit -and $Audit.summary.unavailable -gt 0 -and $Score -ge 100) {
    Add-Failure "Self-reflection score must stay below 100 while launch gates are unavailable."
  }
} else {
  Add-Failure "docs/self-reflection-log.md does not expose a parseable current round self-score."
}

if ($Log -match "(?m)^\s*Current round self-score:\s*100/100\b") {
  Add-Failure "docs/self-reflection-log.md must not claim a 100/100 current round score while launch gates are unavailable."
}

if ($Failures.Count -gt 0) {
  Write-Host "Self-reflection log tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Self-reflection log tests passed."
