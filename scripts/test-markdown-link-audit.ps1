$ErrorActionPreference = "Stop"

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$AuditScript = Join-Path $ScriptRoot "audit-markdown-links.ps1"
$Failures = New-Object System.Collections.Generic.List[string]
$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("watche-mdlink-" + [guid]::NewGuid().ToString("N"))

function Add-Failure {
  param([string]$Message)
  $script:Failures.Add($Message)
}

function Assert-ExitCode {
  param(
    [int]$Actual,
    [int]$Expected,
    [string]$Context
  )

  if ($Actual -ne $Expected) {
    Add-Failure "$Context expected exit code $Expected but got $Actual."
  }
}

function Assert-Contains {
  param(
    [string]$Content,
    [string]$Needle,
    [string]$Context
  )

  if ($Content -notlike "*$Needle*") {
    Add-Failure "$Context is missing expected text: $Needle"
  }
}

function Invoke-LinkAudit {
  $Output = & powershell -ExecutionPolicy Bypass -File $AuditScript -WorkspaceRoot $TempRoot -Include @("README.md", "docs") 2>&1 | Out-String
  $ExitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }

  [pscustomobject]@{
    exit_code = $ExitCode
    output = $Output.Trim()
  }
}

try {
  if (-not (Test-Path -LiteralPath $AuditScript)) {
    Add-Failure "Missing audit script: scripts/audit-markdown-links.ps1"
  }

  New-Item -ItemType Directory -Force -Path (Join-Path $TempRoot "docs/assets") | Out-Null
  Set-Content -LiteralPath (Join-Path $TempRoot "docs/assets/logo.png") -Value "placeholder" -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $TempRoot "docs/guide.md") -Value @"
# Guide

## Quick Start

Use WatcheRobot.
"@ -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $TempRoot "README.md") -Value @"
# Overview

[Guide](docs/guide.md)
[Guide section](docs/guide.md#quick-start)
[Same file section](#overview)
![Logo](docs/assets/logo.png)
[External](https://example.com/watche)
"@ -Encoding UTF8

  $ValidResult = Invoke-LinkAudit
  Assert-ExitCode -Actual $ValidResult.exit_code -Expected 0 -Context "valid markdown links"
  Assert-Contains -Content $ValidResult.output -Needle "Markdown link audit passed." -Context "valid markdown links"

  Set-Content -LiteralPath (Join-Path $TempRoot "README.md") -Value @"
# Overview

[Missing file](docs/missing.md)
"@ -Encoding UTF8

  $MissingFileResult = Invoke-LinkAudit
  Assert-ExitCode -Actual $MissingFileResult.exit_code -Expected 1 -Context "missing file link"
  Assert-Contains -Content $MissingFileResult.output -Needle "Broken Markdown link" -Context "missing file link"
  Assert-Contains -Content $MissingFileResult.output -Needle "README.md -> docs/missing.md" -Context "missing file link"

  Set-Content -LiteralPath (Join-Path $TempRoot "README.md") -Value @"
# Overview

[Missing anchor](docs/guide.md#missing-section)
"@ -Encoding UTF8

  $MissingAnchorResult = Invoke-LinkAudit
  Assert-ExitCode -Actual $MissingAnchorResult.exit_code -Expected 1 -Context "missing heading anchor"
  Assert-Contains -Content $MissingAnchorResult.output -Needle "Broken Markdown anchor" -Context "missing heading anchor"
  Assert-Contains -Content $MissingAnchorResult.output -Needle "README.md -> docs/guide.md#missing-section" -Context "missing heading anchor"
} finally {
  if (Test-Path -LiteralPath $TempRoot) {
    Remove-Item -LiteralPath $TempRoot -Recurse -Force
  }
}

if ($Failures.Count -gt 0) {
  Write-Host "Markdown link audit tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Markdown link audit tests passed."
