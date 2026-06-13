param(
  [switch]$SkipGradle,
  [switch]$Json
)

$ErrorActionPreference = "Continue"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$GitSafeDirectory = ([string]$Root) -replace "\\", "/"

function New-CheckResult {
  param(
    [string]$Name,
    [string]$Status,
    [string]$Detail = "",
    [int]$ExitCode = 0
  )

  [pscustomobject]@{
    name = $Name
    status = $Status
    detail = $Detail
    exit_code = $ExitCode
  }
}

function Invoke-CapturedCheck {
  param(
    [string]$Name,
    [scriptblock]$Command
  )

  Push-Location $Root
  try {
    $Output = & $Command 2>&1 | Out-String
    $ExitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
    if ($ExitCode -eq 0) {
      return New-CheckResult -Name $Name -Status "passed" -Detail $Output.Trim() -ExitCode $ExitCode
    }
    return New-CheckResult -Name $Name -Status "failed" -Detail $Output.Trim() -ExitCode $ExitCode
  } catch {
    return New-CheckResult -Name $Name -Status "failed" -Detail $_.Exception.Message -ExitCode 1
  } finally {
    Pop-Location
  }
}

function Test-CommandAvailable {
  param([string]$Name)
  $Command = Get-Command $Name -ErrorAction SilentlyContinue
  if ($Command) {
    return New-CheckResult -Name "$Name availability" -Status "passed" -Detail $Command.Source
  }
  New-CheckResult -Name "$Name availability" -Status "unavailable" -Detail "$Name is not available in PATH."
}

function Test-EnvAvailable {
  param([string]$Name)
  $Value = [Environment]::GetEnvironmentVariable($Name)
  if ($Value) {
    return New-CheckResult -Name "$Name environment" -Status "passed" -Detail "set"
  }
  New-CheckResult -Name "$Name environment" -Status "unavailable" -Detail "$Name is not set."
}

function Invoke-NativeProcessCapture {
  param(
    [string]$FileName,
    [string]$Arguments
  )

  $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
  $ProcessInfo.FileName = $FileName
  $ProcessInfo.Arguments = $Arguments
  $ProcessInfo.RedirectStandardOutput = $true
  $ProcessInfo.RedirectStandardError = $true
  $ProcessInfo.UseShellExecute = $false

  $Process = [System.Diagnostics.Process]::Start($ProcessInfo)
  $StandardOutput = $Process.StandardOutput.ReadToEnd()
  $StandardError = $Process.StandardError.ReadToEnd()
  $Process.WaitForExit()

  [pscustomobject]@{
    exit_code = [int]$Process.ExitCode
    output = (($StandardOutput, $StandardError | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -join [Environment]::NewLine).Trim()
  }
}

function Invoke-GitHubAuditEvidence {
  Push-Location $Root
  try {
    $Output = powershell -ExecutionPolicy Bypass -File .\scripts\audit-github-readiness.ps1 -Json 2>&1 | Out-String
    $ExitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
    if ($ExitCode -ne 0) {
      return New-CheckResult -Name "github remote audit" -Status "failed" -Detail $Output.Trim() -ExitCode $ExitCode
    }

    try {
      $Parsed = $Output | ConvertFrom-Json
      if ($Parsed.api_status -and $Parsed.api_status -ne "ok") {
        return New-CheckResult -Name "github remote audit" -Status "unavailable" -Detail $Output.Trim()
      }
      return New-CheckResult -Name "github remote audit" -Status "passed" -Detail $Output.Trim()
    } catch {
      return New-CheckResult -Name "github remote audit" -Status "failed" -Detail "Unable to parse audit JSON: $($_.Exception.Message)"
    }
  } catch {
    return New-CheckResult -Name "github remote audit" -Status "failed" -Detail $_.Exception.Message -ExitCode 1
  } finally {
    Pop-Location
  }
}

function Invoke-GitRemoteHeadsEvidence {
  Push-Location $Root
  try {
    $Result = Invoke-NativeProcessCapture -FileName "git" -Arguments ('-c "safe.directory=' + $GitSafeDirectory + '" ls-remote --heads origin')
    $ExitCode = $Result.exit_code
    $Detail = $Result.output
    if ($ExitCode -eq 0) {
      return New-CheckResult -Name "git remote heads" -Status "passed" -Detail $Detail
    }

    if ($Detail -match "unable to access|SSL/TLS|Could not resolve|Failed to connect|timed out|Connection reset|schannel") {
      return New-CheckResult -Name "git remote heads" -Status "unavailable" -Detail $Detail -ExitCode $ExitCode
    }

    return New-CheckResult -Name "git remote heads" -Status "failed" -Detail $Detail -ExitCode $ExitCode
  } catch {
    return New-CheckResult -Name "git remote heads" -Status "failed" -Detail $_.Exception.Message -ExitCode 1
  } finally {
    Pop-Location
  }
}

$Checks = New-Object System.Collections.Generic.List[object]

$Checks.Add((Invoke-CapturedCheck -Name "readiness script" -Command {
  if ($SkipGradle) {
    powershell -ExecutionPolicy Bypass -File .\scripts\check-open-source-readiness.ps1 -SkipGradle
  } else {
    powershell -ExecutionPolicy Bypass -File .\scripts\check-open-source-readiness.ps1
  }
}))

$Checks.Add((Invoke-CapturedCheck -Name "release manifest placeholder validation" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\validate-release-manifest.ps1 -AllowPlaceholders
}))

$Checks.Add((Invoke-CapturedCheck -Name "release manifest regression tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-release-manifest-validation.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "delivery plan structure contract tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-delivery-plan-structure-contract.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "sub-agent work order tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-sub-agent-work-orders.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "good first issue dry run" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\create-good-first-issues.ps1 -DryRun
}))

$Checks.Add((Invoke-CapturedCheck -Name "github community asset tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-github-community-assets.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "github template tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-github-templates.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "owner decision record tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-record.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "owner decision quality fixture tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-quality-fixtures.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "owner decision brief tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-brief.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "launch evidence template tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-templates.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "launch evidence coverage tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-coverage.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "uncertainty governance contract tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-uncertainty-governance-contract.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "github web snapshot contract tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-github-web-snapshot-contract.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "open-source ci workflow tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-open-source-ci-workflow.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "markdown link audit" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\audit-markdown-links.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "markdown link audit tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-markdown-link-audit.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "evidence collector coverage tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-evidence-collector-coverage.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "product name policy tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-product-name-policy.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "readiness score contract tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-readiness-score-contract.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "self-reflection log tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-self-reflection-log.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "launch gate closeout plan tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-gate-closeout-plan.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "launch evidence request pack tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-request-pack.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "launch evidence owner request tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-owner-requests.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "plan docx contract tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-plan-docx-contract.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "docx render prerequisite audit tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-docx-render-prerequisites-audit.ps1
}))

$DocxPrereqOutput = powershell -ExecutionPolicy Bypass -File .\scripts\audit-docx-render-prerequisites.ps1 -Json 2>&1 | Out-String
try {
  $DocxPrereq = $DocxPrereqOutput | ConvertFrom-Json
  if ($DocxPrereq.status -eq "passed") {
    $Checks.Add((New-CheckResult -Name "docx render prerequisites" -Status "passed" -Detail $DocxPrereqOutput.Trim()))
  } elseif ($DocxPrereq.status -eq "unavailable") {
    $Checks.Add((New-CheckResult -Name "docx render prerequisites" -Status "unavailable" -Detail $DocxPrereqOutput.Trim()))
  } else {
    $Checks.Add((New-CheckResult -Name "docx render prerequisites" -Status "failed" -Detail $DocxPrereqOutput.Trim() -ExitCode 1))
  }
} catch {
  $Checks.Add((New-CheckResult -Name "docx render prerequisites" -Status "failed" -Detail "Unable to parse audit-docx-render-prerequisites.ps1 JSON: $($_.Exception.Message)" -ExitCode 1))
}

$Checks.Add((Invoke-CapturedCheck -Name "goal completion audit tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-goal-completion-audit.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "public readme contract tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-public-readme-contract.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "docs index contract tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-docs-index-contract.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "developer onboarding contract tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-developer-onboarding-contract.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "workspace submodule contract tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-workspace-submodule-contract.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "open-source runbook tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-open-source-runbooks.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "wos coverage tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-wos-coverage.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "wos evidence trace tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-wos-evidence-trace.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "example dry-run smoke tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-open-source-examples.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "launch gate regression tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-open-source-launch-gates.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "placeholder audit" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-placeholders.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "text quality audit" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-text-quality.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "publication hygiene audit" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\audit-publication-hygiene.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "publication hygiene regression tests" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\test-publication-hygiene.ps1
}))

$Checks.Add((Invoke-CapturedCheck -Name "launch gate audit" -Command {
  powershell -ExecutionPolicy Bypass -File .\scripts\audit-open-source-launch-gates.ps1
}))

$Checks.Add((Invoke-GitHubAuditEvidence))

$Checks.Add((Invoke-GitRemoteHeadsEvidence))

$Checks.Add((Test-CommandAvailable -Name "java"))
$Checks.Add((Test-CommandAvailable -Name "gh"))
$Checks.Add((Test-EnvAvailable -Name "GH_TOKEN"))
$Checks.Add((Test-EnvAvailable -Name "GITHUB_TOKEN"))

$Failed = @($Checks | Where-Object { $_.status -eq "failed" })
$Unavailable = @($Checks | Where-Object { $_.status -eq "unavailable" })

$Report = [pscustomobject]@{
  generated_at = (Get-Date).ToString("o")
  workspace = [string]$Root
  score_context = "Evidence collector does not prove public launch complete; it records local and remote readiness evidence."
  checks = $Checks
  summary = [pscustomobject]@{
    passed = @($Checks | Where-Object { $_.status -eq "passed" }).Count
    failed = $Failed.Count
    unavailable = $Unavailable.Count
  }
}

if ($Json) {
  $Report | ConvertTo-Json -Depth 6
} else {
  Write-Host "Open-source evidence summary"
  Write-Host "Passed: $($Report.summary.passed)"
  Write-Host "Failed: $($Report.summary.failed)"
  Write-Host "Unavailable: $($Report.summary.unavailable)"
  foreach ($Check in $Checks) {
    $Detail = [string]$Check.detail
    $OneLineDetail = $Detail -replace "`r?`n", " "
    Write-Host "- [$($Check.status)] $($Check.name): $OneLineDetail"
  }
}

if ($Failed.Count -gt 0) {
  exit 1
}
