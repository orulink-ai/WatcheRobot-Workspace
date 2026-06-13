param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$Failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([string]$Message)
  $script:Failures.Add($Message)
}

function Assert-Match {
  param(
    [string]$Content,
    [string]$Pattern,
    [string]$Message
  )

  if ($Content -notmatch $Pattern) {
    Add-Failure $Message
  }
}

$WorkflowPath = Join-Path $Root ".github/workflows/open-source-readiness.yml"
if (-not (Test-Path -LiteralPath $WorkflowPath)) {
  Add-Failure "Missing workflow: .github/workflows/open-source-readiness.yml"
} else {
  $Content = Get-Content -LiteralPath $WorkflowPath -Raw -Encoding UTF8

  Assert-Match -Content $Content -Pattern '(?m)^name:\s*Open Source Readiness\s*$' -Message "Workflow name must remain Open Source Readiness."
  Assert-Match -Content $Content -Pattern '(?m)^\s*pull_request:\s*$' -Message "Workflow must run on pull_request."
  Assert-Match -Content $Content -Pattern '(?m)^\s*push:\s*$' -Message "Workflow must run on push."
  Assert-Match -Content $Content -Pattern '(?s)branches:\s*\r?\n\s*-\s*main\s*\r?\n\s*-\s*dev' -Message "Workflow push branches must include main and dev."
  Assert-Match -Content $Content -Pattern '(?m)^\s*runs-on:\s*windows-latest\s*$' -Message "Workflow must use windows-latest because readiness scripts are PowerShell/Windows oriented."
  Assert-Match -Content $Content -Pattern '(?m)^\s*uses:\s*actions/checkout@v4\s*$' -Message "Workflow must use actions/checkout@v4."
  Assert-Match -Content $Content -Pattern '(?m)^\s*submodules:\s*recursive\s*$' -Message "Workflow must checkout submodules recursively."
  Assert-Match -Content $Content -Pattern '(?m)^\s*uses:\s*actions/setup-python@v5\s*$' -Message "Workflow must set up Python for example syntax checks."
  Assert-Match -Content $Content -Pattern '(?m)^\s*python-version:\s*["'']?3\.12["'']?\s*$' -Message "Workflow must use Python 3.12."
  Assert-Match -Content $Content -Pattern '(?m)^\s*shell:\s*pwsh\s*$' -Message "Workflow must run readiness checks with pwsh."
  Assert-Match -Content $Content -Pattern '(?m)^\s*run:\s*\.\\scripts\\check-open-source-readiness\.ps1\s+-SkipGradle\s*$' -Message "Workflow must run check-open-source-readiness.ps1 -SkipGradle."

  if ($Content -match '(?m)^\s*pull_request_target:\s*$') {
    Add-Failure "Workflow must not use pull_request_target for untrusted PR readiness checks."
  }
  if ($Content -match '(?i)secrets\.') {
    Add-Failure "Workflow must not require secrets for local readiness checks."
  }
  if ($Content -match '(?im)(^\s*\.?\\?gradlew\b|^\s*gradle\s|npm\s+install|yarn\s+install)') {
    Add-Failure "Workflow should stay lightweight and delegate local checks to check-open-source-readiness.ps1 -SkipGradle."
  }
}

if ($Failures.Count -gt 0) {
  Write-Host "Open-source CI workflow tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Open-source CI workflow tests passed."
