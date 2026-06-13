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

$ScriptPath = Join-Path $Root "scripts/audit-docx-render-prerequisites.ps1"
if (-not (Test-Path -LiteralPath $ScriptPath)) {
  Add-Failure "Missing script: scripts/audit-docx-render-prerequisites.ps1"
} else {
  $ScriptContent = Get-Content -LiteralPath $ScriptPath -Raw -Encoding UTF8
  foreach ($RequiredText in @(
    "DOCX render prerequisite summary",
    "TemporaryDirectory nested write",
    "soffice availability",
    "pdftoppm availability",
    "alternative Word/PDF render path",
    "RequireAvailable",
    "ConvertTo-Json"
  )) {
    Assert-Contains -Content $ScriptContent -Needle $RequiredText -Context "scripts/audit-docx-render-prerequisites.ps1"
  }

  $Output = & powershell -ExecutionPolicy Bypass -File $ScriptPath -Json
  if ($LASTEXITCODE -ne 0) {
    Add-Failure "audit-docx-render-prerequisites.ps1 -Json failed with exit code $LASTEXITCODE"
  } else {
    try {
      $Parsed = (($Output -join [Environment]::NewLine) | ConvertFrom-Json)
      if ($Parsed.status -notin @("passed", "unavailable")) {
        Add-Failure "Unexpected DOCX render prerequisite status: $($Parsed.status)"
      }
      if (-not $Parsed.docx_path) {
        Add-Failure "DOCX render prerequisite audit did not report docx_path."
      }
      $CheckNames = @($Parsed.checks | ForEach-Object { $_.name })
      foreach ($ExpectedCheck in @(
        "TemporaryDirectory nested write",
        "soffice availability",
        "pdftoppm availability",
        "alternative Word/PDF render path"
      )) {
        if ($CheckNames -notcontains $ExpectedCheck) {
          Add-Failure "DOCX render prerequisite audit is missing check: $ExpectedCheck"
        }
      }
    } catch {
      Add-Failure "DOCX render prerequisite JSON could not be parsed: $($_.Exception.Message)"
    }
  }
}

$CollectorPath = Join-Path $Root "scripts/collect-open-source-evidence.ps1"
if (Test-Path -LiteralPath $CollectorPath) {
  $Collector = Get-Content -LiteralPath $CollectorPath -Raw -Encoding UTF8
  Assert-Contains -Content $Collector -Needle "docx render prerequisites" -Context "scripts/collect-open-source-evidence.ps1"
  Assert-Contains -Content $Collector -Needle "audit-docx-render-prerequisites.ps1" -Context "scripts/collect-open-source-evidence.ps1"
}

if ($Failures.Count -gt 0) {
  Write-Host "DOCX render prerequisite audit tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "DOCX render prerequisite audit tests passed."
