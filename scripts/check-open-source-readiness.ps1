param(
  [switch]$SkipGradle
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$GitSafeDirectory = ([string]$Root) -replace "\\", "/"
$AppSafeDirectory = ((Join-Path $Root "WatcheRobot_app") -replace "\\", "/")
$Failures = New-Object System.Collections.Generic.List[string]
$Warnings = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([string]$Message)
  $script:Failures.Add($Message)
}

function Add-Warning {
  param([string]$Message)
  $script:Warnings.Add($Message)
}

function Format-NativeOutput {
  param([object[]]$Output)

  if (-not $Output) {
    return ""
  }

  $Lines = $Output | ForEach-Object { [string]$_ }
  $FilteredLines = $Lines | Where-Object {
    $_ -notmatch "^warning: in the working copy of '.+', LF will be replaced by CRLF the next time Git touches it$"
  }

  return (($FilteredLines -join [Environment]::NewLine).Trim())
}

function Test-RequiredPath {
  param([string]$RelativePath)
  $Path = Join-Path $Root $RelativePath
  if (-not (Test-Path -LiteralPath $Path)) {
    Add-Failure "Missing required path: $RelativePath"
  }
}

function Get-TextFiles {
  param([string[]]$RelativePaths)

  $Files = @()
  foreach ($RelativePath in $RelativePaths) {
    $Path = Join-Path $Root $RelativePath
    if (-not (Test-Path -LiteralPath $Path)) {
      continue
    }

    $Item = Get-Item -LiteralPath $Path
    if ($Item.PSIsContainer) {
      $Files += Get-ChildItem -LiteralPath $Path -Recurse -File |
        Where-Object { $_.Extension -in @(".md", ".yml", ".yaml", ".json", ".ps1", ".properties", ".gradle", ".xml") }
    } else {
      $Files += $Item
    }
  }

  return $Files
}

function Test-MarkdownLinks {
  $MarkdownRoots = @(
    "README.md",
    "README.zh-CN.md",
    "CONTRIBUTING.md",
    "CODE_OF_CONDUCT.md",
    "SECURITY.md",
    "CHANGELOG.md",
    "LICENSE-TBD.md",
    "docs",
    "examples",
    ".github"
  )

  $MarkdownFiles = Get-TextFiles $MarkdownRoots | Where-Object { $_.Extension -eq ".md" }
  $Pattern = '(!?\[[^\]]*\]\(([^)]+)\))'

  foreach ($File in $MarkdownFiles) {
    $Content = Get-Content -LiteralPath $File.FullName -Raw
    foreach ($Match in [regex]::Matches($Content, $Pattern)) {
      $Target = $Match.Groups[2].Value.Trim()
      if ([string]::IsNullOrWhiteSpace($Target)) {
        continue
      }
      if ($Target -match '^(https?|mailto):') {
        continue
      }
      if ($Target.StartsWith("#")) {
        continue
      }
      if ($Target.StartsWith("<") -and $Target.EndsWith(">")) {
        $Target = $Target.Substring(1, $Target.Length - 2)
      }

      $Target = ($Target -split "#")[0]
      if ([string]::IsNullOrWhiteSpace($Target)) {
        continue
      }
      if ($Target -match '^[A-Za-z][A-Za-z0-9+.-]*:') {
        continue
      }

      $DecodedTarget = [uri]::UnescapeDataString($Target)
      $BasePath = Split-Path -Parent $File.FullName
      $Candidate = Join-Path $BasePath $DecodedTarget
      if (-not (Test-Path -LiteralPath $Candidate)) {
        $RelativeFile = Resolve-Path -LiteralPath $File.FullName -Relative
        Add-Failure "Broken Markdown link in $RelativeFile -> $Target"
      }
    }
  }
}

function Test-ForbiddenPublicNames {
  $ScanRoots = @(
    "README.md",
    "README.zh-CN.md",
    "CONTRIBUTING.md",
    "CODE_OF_CONDUCT.md",
    "SECURITY.md",
    "CHANGELOG.md",
    "LICENSE-TBD.md",
    "docs",
    "examples",
    ".github",
    "WatcheRobot_app/README.md",
    "WatcheRobot_app/README_zh.md",
    "WatcheRobot_app/CONTRIBUTING.md"
  )
  $Files = Get-TextFiles $ScanRoots
  $Forbidden = @("Watcherobot", "watcherobot", "Watcher Robot", "watcher-robot")

  foreach ($Hit in Select-String -LiteralPath $Files.FullName -Pattern $Forbidden -SimpleMatch -CaseSensitive -ErrorAction SilentlyContinue) {
    $RelativePath = (Resolve-Path -LiteralPath $Hit.Path -Relative) -replace "^\.[\\/]", ""
    $RelativePath = $RelativePath -replace "\\", "/"
    if ($RelativePath -eq "docs/product-name-policy.md") {
      continue
    }

    $Line = $Hit.Line.Trim()
    if ($Line -match 'resources/robot/models/watcherobot-') {
      continue
    }
    Add-Failure "Public naming drift: $($Hit.Path):$($Hit.LineNumber): $($Hit.Line.Trim())"
  }
}

function Test-SensitiveValues {
  $ScanRoots = @(
    "README.md",
    "README.zh-CN.md",
    "CONTRIBUTING.md",
    "CODE_OF_CONDUCT.md",
    "CHANGELOG.md",
    "LICENSE-TBD.md",
    "docs",
    "examples",
    ".github",
    "WatcheRobot_app/android",
    "WatcheRobot_app/README.md",
    "WatcheRobot_app/README_zh.md",
    "WatcheRobot_app/CONTRIBUTING.md"
  )
  $Files = Get-TextFiles $ScanRoots
  $Pattern = 'MYAPP_RELEASE_STORE_PASSWORD\s*=\s*orulink|MYAPP_RELEASE_KEY_PASSWORD\s*=\s*orulink|-----BEGIN (RSA |DSA |EC |OPENSSH )?PRIVATE KEY-----'

  foreach ($Hit in Select-String -LiteralPath $Files.FullName -Pattern $Pattern -ErrorAction SilentlyContinue) {
    Add-Failure "Sensitive value risk: $($Hit.Path):$($Hit.LineNumber): $($Hit.Line.Trim())"
  }
}

function Invoke-NativeCheck {
  param(
    [string]$Name,
    [scriptblock]$Command
  )

  Push-Location $Root
  try {
    $PreviousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
      $Output = & $Command 2>&1
      $ExitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
      $FormattedOutput = Format-NativeOutput $Output
      if (-not [string]::IsNullOrWhiteSpace($FormattedOutput)) {
        Write-Host $FormattedOutput
      }
    } finally {
      $ErrorActionPreference = $PreviousErrorActionPreference
    }
    if ($ExitCode -ne 0) {
      Add-Failure "$Name failed with exit code $ExitCode"
      if (-not [string]::IsNullOrWhiteSpace($FormattedOutput)) {
        Add-Failure "$Name output: $FormattedOutput"
      }
    }
  } finally {
    Pop-Location
  }
}

$RequiredPaths = @(
  "README.md",
  "README.zh-CN.md",
  ".gitignore",
  "CONTRIBUTING.md",
  "CODE_OF_CONDUCT.md",
  "SECURITY.md",
  "CHANGELOG.md",
  "LICENSE-TBD.md",
  "docs/README.md",
  "docs/README.zh-CN.md",
  "docs/open-source-delivery-plan.md",
  "docs/open-source-launch-gates.md",
  "docs/launch-gate-closeout-plan.md",
  "docs/launch-evidence-request-pack.md",
  "docs/launch-evidence-owner-requests.md",
  "docs/product-name-policy.md",
  "docs/open-source-readiness-final.md",
  "docs/open-source-readiness-final.zh-CN.md",
  "docs/goal-completion-audit.md",
  "docs/self-reflection-log.md",
  "docs/launch-evidence/README.md",
  "docs/launch-evidence/owner-decisions.md",
  "docs/launch-evidence/final-license.md",
  "docs/launch-evidence/community-entrance.md",
  "docs/launch-evidence/demo-asset.md",
  "docs/launch-evidence/github-admin.md",
  "docs/launch-evidence/release-artifacts.md",
  "docs/launch-evidence/app-gradle.md",
  "docs/launch-evidence/clean-machine.md",
  "docs/launch-evidence/hardware-smoke.md",
  "docs/launch-evidence/templates/owner-decisions.md",
  "docs/launch-evidence/templates/final-license.md",
  "docs/launch-evidence/templates/community-entrance.md",
  "docs/launch-evidence/templates/demo-asset.md",
  "docs/launch-evidence/templates/app-gradle.md",
  "docs/launch-evidence/templates/clean-machine.md",
  "docs/launch-evidence/templates/github-admin.md",
  "docs/launch-evidence/templates/github-remote-web-snapshot.md",
  "docs/launch-evidence/templates/hardware-smoke.md",
  "docs/launch-evidence/templates/release-artifacts.md",
  "docs/launch-evidence/web-snapshots/latest-github-remote.md",
  "docs/launch-evidence/web-snapshots/github-remote-2026-06-12.md",
  "docs/placeholder-register.md",
  "docs/public-launch-validation.md",
  "docs/remote-publication-runbook.md",
  "docs/sub-agent-handoff.md",
  "docs/sub-agent-work-orders/README.md",
  "docs/sub-agent-work-orders/WO-01-local-readiness-refresh.md",
  "docs/sub-agent-work-orders/WO-02-root-publication.md",
  "docs/sub-agent-work-orders/WO-03-app-cleanup-publication.md",
  "docs/sub-agent-work-orders/WO-04-github-admin-setup.md",
  "docs/sub-agent-work-orders/WO-05-hardware-smoke-validation.md",
  "docs/sub-agent-work-orders/WO-06-owner-decision-closeout.md",
  "docs/sub-agent-work-orders/WO-07-full-launch-review.md",
  "docs/open-questions.md",
  "docs/owner-decision-record.md",
  "docs/owner-decision-brief.md",
  "docs/architecture.md",
  "docs/quick-start.md",
  "docs/toolchain-matrix.md",
  "docs/provisioning.md",
  "docs/motion-guide.md",
  "docs/expression-guide.md",
  "docs/ai-integration.md",
  "docs/open-source-scope.md",
  "docs/hardware-structure-map.md",
  "docs/license-decision-guide.md",
  "docs/community-launch-plan.md",
  "docs/demo-asset-checklist.md",
  "docs/app-internal-rename-plan.md",
  "docs/privacy-and-data-flow.md",
  "docs/extension-boundaries.md",
  "docs/resource-pack-spec.md",
  "docs/release-manifest.example.json",
  "docs/community-submissions.md",
  "docs/good-first-issues.md",
  "docs/assets/README.md",
  "examples/README.md",
  "examples/ble-control-minimal/README.md",
  "examples/ble-control-minimal/ble_control_minimal.py",
  "examples/send-motion-minimal/README.md",
  "examples/switch-expression-minimal/README.md",
  "examples/ai-reminder-minimal/README.md",
  "examples/ai-reminder-minimal/ai_reminder_minimal.py",
  "examples/creator-template-minimal/README.md",
  "examples/creator-template-minimal/manifest.example.json",
  ".github/labels.json",
  ".github/good-first-issues/01-quick-start-error-notes.md",
  ".github/good-first-issues/02-expression-switching-smoke-script.md",
  ".github/good-first-issues/03-hardware-resource-entry-points.md",
  ".github/good-first-issues/04-app-first-run-troubleshooting.md",
  ".github/good-first-issues/05-release-asset-checksum-notes.md",
  ".github/PULL_REQUEST_TEMPLATE.md",
  ".github/ISSUE_TEMPLATE/bug_report.md",
  ".github/ISSUE_TEMPLATE/feature_request.md",
  ".github/ISSUE_TEMPLATE/documentation_feedback.md",
  ".github/ISSUE_TEMPLATE/hardware_issue.md",
  ".github/ISSUE_TEMPLATE/connection_issue.md",
  ".github/workflows/open-source-readiness.yml",
  "scripts/sync-github-labels.ps1",
  "scripts/audit-markdown-links.ps1",
  "scripts/audit-github-readiness.ps1",
  "scripts/audit-docx-render-prerequisites.ps1",
  "scripts/audit-open-source-launch-gates.ps1",
  "scripts/audit-open-source-placeholders.ps1",
  "scripts/audit-open-source-text-quality.ps1",
  "scripts/audit-publication-hygiene.ps1",
  "scripts/collect-open-source-evidence.ps1",
  "scripts/create-good-first-issues.ps1",
  "scripts/test-open-source-ci-workflow.ps1",
  "scripts/test-evidence-collector-coverage.ps1",
  "scripts/test-markdown-link-audit.ps1",
  "scripts/test-product-name-policy.ps1",
  "scripts/test-readiness-score-contract.ps1",
  "scripts/test-self-reflection-log.ps1",
  "scripts/test-launch-gate-closeout-plan.ps1",
  "scripts/test-launch-evidence-request-pack.ps1",
  "scripts/test-launch-evidence-owner-requests.ps1",
  "scripts/test-plan-docx-contract.ps1",
  "scripts/test-docx-render-prerequisites-audit.ps1",
  "scripts/test-goal-completion-audit.ps1",
  "scripts/test-delivery-plan-structure-contract.ps1",
  "scripts/test-sub-agent-work-orders.ps1",
  "scripts/test-launch-evidence-templates.ps1",
  "scripts/test-launch-evidence-coverage.ps1",
  "scripts/test-uncertainty-governance-contract.ps1",
  "scripts/test-public-readme-contract.ps1",
  "scripts/test-docs-index-contract.ps1",
  "scripts/test-developer-onboarding-contract.ps1",
  "scripts/test-workspace-submodule-contract.ps1",
  "scripts/test-github-web-snapshot-contract.ps1",
  "scripts/test-github-community-assets.ps1",
  "scripts/test-github-templates.ps1",
  "scripts/test-owner-decision-record.ps1",
  "scripts/test-owner-decision-quality-fixtures.ps1",
  "scripts/test-owner-decision-brief.ps1",
  "scripts/test-open-source-runbooks.ps1",
  "scripts/test-wos-coverage.ps1",
  "scripts/test-wos-evidence-trace.ps1",
  "scripts/test-open-source-launch-gates.ps1",
  "scripts/test-publication-hygiene.ps1",
  "scripts/test-open-source-examples.ps1",
  "scripts/test-release-manifest-validation.ps1",
  "scripts/validate-release-manifest.ps1"
)

foreach ($Path in $RequiredPaths) {
  Test-RequiredPath $Path
}

Test-MarkdownLinks
Test-ForbiddenPublicNames
Test-SensitiveValues

Invoke-NativeCheck "Markdown link audit" {
  powershell -ExecutionPolicy Bypass -File .\scripts\audit-markdown-links.ps1
}
Invoke-NativeCheck "Markdown link audit tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-markdown-link-audit.ps1
}
Invoke-NativeCheck "root git diff --check" { git -c "safe.directory=$GitSafeDirectory" diff --check }
Invoke-NativeCheck "app git diff --check" { git -c "safe.directory=$AppSafeDirectory" -C WatcheRobot_app diff --check }
Invoke-NativeCheck "BLE example syntax parse" {
  python -c "import ast, pathlib; ast.parse(pathlib.Path(r'examples\ble-control-minimal\ble_control_minimal.py').read_text(encoding='utf-8'))"
}
Invoke-NativeCheck "AI reminder example syntax parse" {
  python -c "import ast, pathlib; ast.parse(pathlib.Path(r'examples\ai-reminder-minimal\ai_reminder_minimal.py').read_text(encoding='utf-8'))"
}
Invoke-NativeCheck "Release manifest validation" {
  powershell -ExecutionPolicy Bypass -File .\scripts\validate-release-manifest.ps1 -AllowPlaceholders
}
Invoke-NativeCheck "Release manifest regression tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-release-manifest-validation.ps1
}
Invoke-NativeCheck "Delivery plan structure contract tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-delivery-plan-structure-contract.ps1
}
Invoke-NativeCheck "Sub-agent work order tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-sub-agent-work-orders.ps1
}
Invoke-NativeCheck "Good first issue draft dry run" {
  powershell -ExecutionPolicy Bypass -File .\scripts\create-good-first-issues.ps1 -DryRun | Out-Null
}
Invoke-NativeCheck "GitHub community asset tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-github-community-assets.ps1
}
Invoke-NativeCheck "GitHub template tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-github-templates.ps1
}
Invoke-NativeCheck "Owner decision record tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-record.ps1
}
Invoke-NativeCheck "Owner decision quality fixture tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-quality-fixtures.ps1
}
Invoke-NativeCheck "Owner decision brief tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-brief.ps1
}
Invoke-NativeCheck "Launch evidence template tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-templates.ps1
}
Invoke-NativeCheck "Launch evidence coverage tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-coverage.ps1
}
Invoke-NativeCheck "Uncertainty governance contract tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-uncertainty-governance-contract.ps1
}
Invoke-NativeCheck "GitHub web snapshot contract tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-github-web-snapshot-contract.ps1
}
Invoke-NativeCheck "Open-source CI workflow tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-open-source-ci-workflow.ps1
}
Invoke-NativeCheck "Evidence collector coverage tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-evidence-collector-coverage.ps1
}
Invoke-NativeCheck "Product name policy tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-product-name-policy.ps1
}
Invoke-NativeCheck "Readiness score contract tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-readiness-score-contract.ps1
}
Invoke-NativeCheck "Self-reflection log tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-self-reflection-log.ps1
}
Invoke-NativeCheck "Launch gate closeout plan tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-gate-closeout-plan.ps1
}
Invoke-NativeCheck "Launch evidence request pack tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-request-pack.ps1
}
Invoke-NativeCheck "Launch evidence owner request tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-owner-requests.ps1
}
Invoke-NativeCheck "Plan docx contract tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-plan-docx-contract.ps1
}
Invoke-NativeCheck "DOCX render prerequisite audit" {
  powershell -ExecutionPolicy Bypass -File .\scripts\audit-docx-render-prerequisites.ps1
}
Invoke-NativeCheck "DOCX render prerequisite audit tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-docx-render-prerequisites-audit.ps1
}
Invoke-NativeCheck "Goal completion audit tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-goal-completion-audit.ps1
}
Invoke-NativeCheck "Public README contract tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-public-readme-contract.ps1
}
Invoke-NativeCheck "Docs index contract tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-docs-index-contract.ps1
}
Invoke-NativeCheck "Developer onboarding contract tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-developer-onboarding-contract.ps1
}
Invoke-NativeCheck "Workspace submodule contract tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-workspace-submodule-contract.ps1
}
Invoke-NativeCheck "Open-source runbook tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-open-source-runbooks.ps1
}
Invoke-NativeCheck "WOS coverage tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-wos-coverage.ps1
}
Invoke-NativeCheck "WOS evidence trace tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-wos-evidence-trace.ps1
}
Invoke-NativeCheck "Open-source example dry run" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-open-source-examples.ps1
}
Invoke-NativeCheck "Open-source launch gate regression tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-open-source-launch-gates.ps1
}
Invoke-NativeCheck "Placeholder audit" {
  powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-placeholders.ps1
}
Invoke-NativeCheck "Text quality audit" {
  powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-text-quality.ps1
}
Invoke-NativeCheck "Publication hygiene audit" {
  powershell -ExecutionPolicy Bypass -File .\scripts\audit-publication-hygiene.ps1
}
Invoke-NativeCheck "Publication hygiene regression tests" {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-publication-hygiene.ps1
}
Invoke-NativeCheck "Launch gate audit" {
  powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-launch-gates.ps1
}

if (-not $SkipGradle) {
  $Java = Get-Command java -ErrorAction SilentlyContinue
  if ($Java) {
    Invoke-NativeCheck "App Gradle dry run" {
      Push-Location (Join-Path $Root "WatcheRobot_app/android")
      try {
        .\gradlew.bat :app:tasks --dry-run
      } finally {
        Pop-Location
      }
    }
  } else {
    Add-Warning "Java is not available; skipped App Gradle dry run. Re-run without -SkipGradle after setting JAVA_HOME."
  }
}

if ($Warnings.Count -gt 0) {
  Write-Host "Warnings:"
  foreach ($Warning in $Warnings) {
    Write-Host "  - $Warning"
  }
}

if ($Failures.Count -gt 0) {
  Write-Host "Failures:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Open-source readiness checks passed."
