param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$SourceAudit = Join-Path $Root "scripts/audit-publication-hygiene.ps1"
$TempBase = [System.IO.Path]::GetTempPath()
$FixtureRoots = New-Object System.Collections.Generic.List[string]
$LastFixtureRoot = $null

function New-FixtureRepo {
  param(
    [string]$Name,
    [string]$GitignoreContent = $null
  )

  $FixtureRoot = Join-Path $TempBase ("watche-publication-hygiene-" + $Name + "-" + [guid]::NewGuid().ToString("N"))
  $FixtureRoots.Add($FixtureRoot)
  $script:LastFixtureRoot = $FixtureRoot
  New-Item -ItemType Directory -Path $FixtureRoot | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $FixtureRoot "scripts") | Out-Null

  if ([string]::IsNullOrEmpty($GitignoreContent)) {
    $GitignoreContent = (@(
      ".codex-temp/",
      "downloads/",
      "output/",
      "outputs/",
      "_tmp_pull*/",
      "feishu_watcherobot_tables*.tsv.md"
    ) -join [Environment]::NewLine)
  }

  Set-Content -LiteralPath (Join-Path $FixtureRoot ".gitignore") -Value $GitignoreContent -Encoding UTF8

  Push-Location $FixtureRoot
  try {
    git init | Out-Null
    git config user.email "codex@example.invalid" | Out-Null
    git config user.name "Codex Test" | Out-Null
  } finally {
    Pop-Location
  }

  return
}

function Invoke-FixtureAudit {
  param([string]$FixtureRoot)

  Push-Location $FixtureRoot
  try {
    $Output = powershell -ExecutionPolicy Bypass -File $SourceAudit -WorkspaceRoot $FixtureRoot 2>&1 | Out-String
    $ExitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
    $GitignorePath = Join-Path $FixtureRoot ".gitignore"
    $GitignoreContent = if (Test-Path -LiteralPath $GitignorePath) {
      Get-Content -LiteralPath $GitignorePath -Raw -Encoding UTF8
    } else {
      "<missing>"
    }
    return [pscustomobject]@{
      exit_code = $ExitCode
      output = $Output.Trim()
      workspace = $FixtureRoot
      gitignore = $GitignoreContent
    }
  } finally {
    Pop-Location
  }
}

function Assert-ExitCode {
  param(
    [object]$Result,
    [int]$Expected,
    [string]$CaseName
  )

  if ($Result.exit_code -ne $Expected) {
    throw "$CaseName expected exit code $Expected, got $($Result.exit_code). Workspace: $($Result.workspace). Gitignore: $($Result.gitignore). Output: $($Result.output)"
  }
}

try {
  New-FixtureRepo "clean"
  $CleanRepo = $LastFixtureRoot
  Assert-ExitCode -Result (Invoke-FixtureAudit $CleanRepo) -Expected 0 -CaseName "clean fixture"

  New-FixtureRepo "allowed"
  $AllowedRepo = $LastFixtureRoot
  Set-Content -LiteralPath (Join-Path $AllowedRepo "README.md") -Value "# WatcheRobot" -Encoding UTF8
  Push-Location $AllowedRepo
  try { git add README.md | Out-Null } finally { Pop-Location }
  Assert-ExitCode -Result (Invoke-FixtureAudit $AllowedRepo) -Expected 0 -CaseName "allowed README staging"

  New-FixtureRepo "allowed-docx"
  $AllowedDocxRepo = $LastFixtureRoot
  Set-Content -LiteralPath (Join-Path $AllowedDocxRepo "Watcherobot open-source plan Codex Sub-Agent self-contained.docx") -Value "placeholder docx bytes" -Encoding UTF8
  Push-Location $AllowedDocxRepo
  try { git add "Watcherobot open-source plan Codex Sub-Agent self-contained.docx" | Out-Null } finally { Pop-Location }
  Assert-ExitCode -Result (Invoke-FixtureAudit $AllowedDocxRepo) -Expected 0 -CaseName "allowed root reference docx staging"

  New-FixtureRepo "unrelated-docx"
  $UnrelatedDocxRepo = $LastFixtureRoot
  Set-Content -LiteralPath (Join-Path $UnrelatedDocxRepo "private-notes.docx") -Value "placeholder docx bytes" -Encoding UTF8
  Push-Location $UnrelatedDocxRepo
  try { git add "private-notes.docx" | Out-Null } finally { Pop-Location }
  Assert-ExitCode -Result (Invoke-FixtureAudit $UnrelatedDocxRepo) -Expected 1 -CaseName "unrelated root docx staging"

  New-FixtureRepo "helper"
  $HelperRepo = $LastFixtureRoot
  Set-Content -LiteralPath (Join-Path $HelperRepo "scripts/desktop-server.ps1") -Value "Write-Host local" -Encoding UTF8
  Push-Location $HelperRepo
  try { git add scripts/desktop-server.ps1 | Out-Null } finally { Pop-Location }
  Assert-ExitCode -Result (Invoke-FixtureAudit $HelperRepo) -Expected 1 -CaseName "staged local helper"

  New-FixtureRepo "subrepo"
  $SubrepoRepo = $LastFixtureRoot
  New-Item -ItemType Directory -Path (Join-Path $SubrepoRepo "WatcheRobot_app") | Out-Null
  Set-Content -LiteralPath (Join-Path $SubrepoRepo "WatcheRobot_app/README.md") -Value "# App" -Encoding UTF8
  Push-Location $SubrepoRepo
  try { git add WatcheRobot_app/README.md | Out-Null } finally { Pop-Location }
  Assert-ExitCode -Result (Invoke-FixtureAudit $SubrepoRepo) -Expected 1 -CaseName "staged subrepo path"

  New-FixtureRepo "missing-ignore" ((@(
    ".codex-temp/",
    "downloads/",
    "output/",
    "outputs/",
    "_tmp_pull*/"
  ) -join [Environment]::NewLine))
  $MissingIgnoreRepo = $LastFixtureRoot
  Assert-ExitCode -Result (Invoke-FixtureAudit $MissingIgnoreRepo) -Expected 1 -CaseName "missing Feishu export ignore"

  Write-Host "Publication hygiene regression tests passed."
} finally {
  foreach ($FixtureRoot in $FixtureRoots) {
    if (-not (Test-Path -LiteralPath $FixtureRoot)) {
      continue
    }

    $ResolvedFixture = [System.IO.Path]::GetFullPath($FixtureRoot)
    $ResolvedTemp = [System.IO.Path]::GetFullPath($TempBase)
    if ($ResolvedFixture.StartsWith($ResolvedTemp, [System.StringComparison]::OrdinalIgnoreCase)) {
      Remove-Item -LiteralPath $FixtureRoot -Recurse -Force
    }
  }
}
