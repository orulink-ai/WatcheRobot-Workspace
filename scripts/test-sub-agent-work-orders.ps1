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

$Index = Get-RepoText "docs/sub-agent-work-orders/README.md"
$Handoff = Get-RepoText "docs/sub-agent-handoff.md"
$Plan = Get-RepoText "docs/open-source-delivery-plan.md"
$FinalReport = Get-RepoText "docs/open-source-readiness-final.md"
$ChineseFinalReport = Get-RepoText "docs/open-source-readiness-final.zh-CN.md"

$WorkOrders = @(
  @{ Id = "WO-01"; File = "docs/sub-agent-work-orders/WO-01-local-readiness-refresh.md"; Command = "scripts/check-open-source-readiness.ps1" },
  @{ Id = "WO-02"; File = "docs/sub-agent-work-orders/WO-02-root-publication.md"; Command = "scripts/audit-publication-hygiene.ps1" },
  @{ Id = "WO-03"; File = "docs/sub-agent-work-orders/WO-03-app-cleanup-publication.md"; Command = "git -C WatcheRobot_app diff --check" },
  @{ Id = "WO-04"; File = "docs/sub-agent-work-orders/WO-04-github-admin-setup.md"; Command = "scripts/audit-github-readiness.ps1" },
  @{ Id = "WO-05"; File = "docs/sub-agent-work-orders/WO-05-hardware-smoke-validation.md"; Command = "docs/launch-evidence/hardware-smoke.md" },
  @{ Id = "WO-06"; File = "docs/sub-agent-work-orders/WO-06-owner-decision-closeout.md"; Command = "scripts/test-owner-decision-record.ps1" },
  @{ Id = "WO-07"; File = "docs/sub-agent-work-orders/WO-07-full-launch-review.md"; Command = "scripts/audit-open-source-launch-gates.ps1 -RequirePassed" }
)

foreach ($Needle in @(
  "# WatcheRobot Sub-Agent Work Orders",
  "docs/sub-agent-handoff.md",
  "docs/open-source-delivery-plan.md",
  "Do not invent",
  "free of pending tokens",
  "Self-score"
)) {
  Assert-Contains -Content $Index -Needle $Needle -Context "docs/sub-agent-work-orders/README.md"
}

foreach ($WorkOrder in $WorkOrders) {
  Assert-Contains -Content $Index -Needle $WorkOrder.Id -Context "docs/sub-agent-work-orders/README.md"
  Assert-Contains -Content $Handoff -Needle $WorkOrder.File -Context "docs/sub-agent-handoff.md"

  $Content = Get-RepoText $WorkOrder.File
  foreach ($Needle in @(
    "# $($WorkOrder.Id)",
    "Primary agent",
    "Start condition",
    "Scope",
    "Inputs",
    "Allowed actions",
    "Do not",
    "Required verification",
    "Stop and escalate",
    "Deliverable",
    "Self-score note",
    "WatcheRobot",
    "TODO/TBD/PLACEHOLDER",
    $WorkOrder.Command
  )) {
    Assert-Contains -Content $Content -Needle $Needle -Context $WorkOrder.File
  }
}

$FieldLevelWorkOrderChecks = @(
  @{
    File = "docs/sub-agent-work-orders/WO-04-github-admin-setup.md"
    Needles = @(
      "issue template URLs",
      "PR template URL",
      "synced label list",
      "good first issue URLs",
      "Discussions or official community route URL",
      "open-source readiness workflow visibility",
      "main branch protection",
      "branch protection required checks",
      "scripts/audit-github-readiness.ps1 output"
    )
  },
  @{
    File = "docs/sub-agent-work-orders/WO-05-hardware-smoke-validation.md"
    Needles = @(
      "power supply and safety setup",
      "Wi-Fi provisioning ready state",
      "serial/app logs",
      "expected ACK / observed result",
      "BLE ping expected ACK / observed result",
      "Servo action expected ACK / observed result",
      "Expression switch expected ACK / observed result",
      "AI reminder flow expected ACK / observed result"
    )
  },
  @{
    File = "docs/sub-agent-work-orders/WO-07-full-launch-review.md"
    Needles = @(
      "owner decisions",
      "final license",
      "community entrance",
      "approved demo asset",
      "github admin state",
      "release manifest",
      "java and app gradle",
      "clean-machine validation",
      "hardware smoke validation",
      "Status: Passed",
      "no pending tokens",
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
      "git -C WatcheRobot_app diff --check"
    )
  }
)

foreach ($Spec in $FieldLevelWorkOrderChecks) {
  $Content = Get-RepoText $Spec.File
  foreach ($Needle in $Spec.Needles) {
    Assert-Contains -Content $Content -Needle $Needle -Context $Spec.File
  }
}

foreach ($Needle in @(
  "docs/sub-agent-work-orders/README.md",
  "scripts/test-sub-agent-work-orders.ps1"
)) {
  Assert-Contains -Content $Plan -Needle $Needle -Context "docs/open-source-delivery-plan.md"
  Assert-Contains -Content $FinalReport -Needle $Needle -Context "docs/open-source-readiness-final.md"
  Assert-Contains -Content $ChineseFinalReport -Needle $Needle -Context "docs/open-source-readiness-final.zh-CN.md"
}

if ($Failures.Count -gt 0) {
  Write-Host "Sub-agent work order tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Sub-agent work order tests passed."
