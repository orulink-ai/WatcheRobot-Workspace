param(
  [switch]$Json,
  [switch]$RequireAvailable,
  [string]$RootPath = ""
)

$ErrorActionPreference = "Continue"
if ($RootPath) {
  $Root = Resolve-Path $RootPath
} else {
  $Root = Resolve-Path (Join-Path $PSScriptRoot "..")
}

$ExpectedCheckLabels = @(
  "TemporaryDirectory nested write",
  "soffice availability",
  "pdftoppm availability",
  "alternative Word/PDF render path"
)

function New-CheckResult {
  param(
    [string]$Name,
    [string]$Status,
    [string]$Detail
  )

  [pscustomobject]@{
    name = $Name
    status = $Status
    detail = $Detail
  }
}

function Test-CommandAvailability {
  param(
    [string]$Name,
    [string[]]$FallbackPaths = @()
  )

  $Command = Get-Command $Name -ErrorAction SilentlyContinue
  if ($Command) {
    return New-CheckResult "$Name availability" "passed" $Command.Source
  }

  foreach ($Path in $FallbackPaths) {
    if (Test-Path -LiteralPath $Path) {
      return New-CheckResult "$Name availability" "passed" $Path
    }
  }

  return New-CheckResult "$Name availability" "unavailable" "$Name is not available in PATH or known fallback paths."
}

function Test-PythonModule {
  param([string]$ModuleName)

  $Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
  if (-not (Test-Path -LiteralPath $Python)) {
    return New-CheckResult "$ModuleName python module" "unavailable" "Bundled Python is missing at $Python."
  }

  $Code = "import importlib.util, sys; sys.exit(0 if importlib.util.find_spec('$ModuleName') else 3)"
  $Output = & $Python -c $Code 2>&1 | Out-String
  $ExitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
  if ($ExitCode -eq 0) {
    return New-CheckResult "$ModuleName python module" "passed" "$ModuleName is importable from bundled Python."
  }

  return New-CheckResult "$ModuleName python module" "unavailable" (($Output.Trim(), "$ModuleName is not importable from bundled Python.") -join " ").Trim()
}

function Test-TemporaryDirectoryNestedWrite {
  $Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
  if (-not (Test-Path -LiteralPath $Python)) {
    return New-CheckResult "TemporaryDirectory nested write" "unavailable" "Bundled Python is missing at $Python."
  }

  $TempRoot = Join-Path $Root ".codex-temp\docx-render-prereq-temp"
  New-Item -ItemType Directory -Force -Path $TempRoot | Out-Null
$Code = @"
import os
import pathlib
import sys
import tempfile
tempfile.tempdir = r'$TempRoot'
pathlib.Path(tempfile.tempdir).mkdir(parents=True, exist_ok=True)
td = None
try:
    td = tempfile.TemporaryDirectory(prefix='soffice_profile_')
    profile = td.name
    os.makedirs(os.path.join(profile, 'xdg_config'), exist_ok=True)
    os.makedirs(os.path.join(profile, 'xdg_cache'), exist_ok=True)
    print('TemporaryDirectory nested write passed')
except Exception as exc:
    print(type(exc).__name__ + ': nested xdg directory write failed under Python TemporaryDirectory')
    sys.exit(3)
finally:
    if td is not None:
        try:
            td.cleanup()
        except Exception:
            pass
"@

  $Output = & $Python -c $Code 2>&1 | Out-String
  $ExitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
  if ($ExitCode -eq 0) {
    return New-CheckResult "TemporaryDirectory nested write" "passed" $Output.Trim()
  }

  return New-CheckResult "TemporaryDirectory nested write" "unavailable" $Output.Trim()
}

function Test-AlternativeWordPdfRenderPath {
  $WinwordPaths = @(
    "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE",
    "C:\Program Files\Microsoft Office\Office16\WINWORD.EXE",
    "C:\Program Files (x86)\Microsoft Office\root\Office16\WINWORD.EXE",
    "C:\Program Files (x86)\Microsoft Office\Office16\WINWORD.EXE"
  )
  $HasWord = $false
  foreach ($Path in $WinwordPaths) {
    if (Test-Path -LiteralPath $Path) {
      $HasWord = $true
      break
    }
  }

  $Fitz = Test-PythonModule "fitz"
  $Pdf2Image = Test-PythonModule "pdf2image"
  $Pdftoppm = Test-CommandAvailability "pdftoppm"

  if ($HasWord -and ($Fitz.status -eq "passed" -or ($Pdf2Image.status -eq "passed" -and $Pdftoppm.status -eq "passed"))) {
    return New-CheckResult "alternative Word/PDF render path" "passed" "WINWORD.EXE and a PDF-to-image route are available."
  }

  $Detail = "WINWORD.EXE available=$HasWord; fitz=$($Fitz.status); pdf2image=$($Pdf2Image.status); pdftoppm=$($Pdftoppm.status)."
  return New-CheckResult "alternative Word/PDF render path" "unavailable" $Detail
}

$DocxItem = Get-ChildItem -LiteralPath $Root -Filter "*.docx" -File |
  Where-Object { $_.Name -like "*Codex*" -and $_.Name -like "*Sub-Agent*" } |
  Select-Object -First 1

$Checks = New-Object System.Collections.Generic.List[object]
if ($DocxItem) {
  $Checks.Add((New-CheckResult "reference plan docx" "passed" $DocxItem.FullName))
} else {
  $Checks.Add((New-CheckResult "reference plan docx" "failed" "Missing root DOCX matching *Codex*Sub-Agent*.docx."))
}

$Checks.Add((Test-TemporaryDirectoryNestedWrite))
$Checks.Add((Test-CommandAvailability "soffice" @(
  "C:\Program Files\LibreOffice\program\soffice.exe",
  "C:\Program Files (x86)\LibreOffice\program\soffice.exe"
)))
$Checks.Add((Test-CommandAvailability "pdftoppm"))
$Checks.Add((Test-AlternativeWordPdfRenderPath))

$Failed = @($Checks | Where-Object { $_.status -eq "failed" })
$Unavailable = @($Checks | Where-Object { $_.status -eq "unavailable" })
$Passed = @($Checks | Where-Object { $_.status -eq "passed" })

if ($Failed.Count -gt 0) {
  $Status = "failed"
} elseif ($Unavailable.Count -gt 0) {
  $Status = "unavailable"
} else {
  $Status = "passed"
}

$Report = [pscustomobject]@{
  generated_at = (Get-Date).ToString("o")
  status = $Status
  docx_path = if ($DocxItem) { $DocxItem.FullName } else { "" }
  summary = [pscustomobject]@{
    passed = $Passed.Count
    unavailable = $Unavailable.Count
    failed = $Failed.Count
  }
  checks = $Checks
}

if ($Json) {
  $Report | ConvertTo-Json -Depth 6
} else {
  Write-Host "DOCX render prerequisite summary"
  Write-Host "Status: $Status"
  Write-Host "Passed: $($Report.summary.passed)"
  Write-Host "Unavailable: $($Report.summary.unavailable)"
  Write-Host "Failed: $($Report.summary.failed)"
  foreach ($Check in $Checks) {
    Write-Host "- [$($Check.status)] $($Check.name): $($Check.detail)"
  }
}

if ($Failed.Count -gt 0) {
  exit 1
}

if ($RequireAvailable -and $Status -ne "passed") {
  exit 2
}
