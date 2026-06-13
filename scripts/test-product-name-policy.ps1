param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$Failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([string]$Message)
  $script:Failures.Add($Message)
}

function Convert-ToRelativePath {
  param([string]$Path)

  $Relative = Resolve-Path -LiteralPath $Path -Relative
  return ($Relative -replace "^\.[\\/]", "") -replace "\\", "/"
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
        Where-Object { $_.Extension -in @(".md", ".json", ".yml", ".yaml", ".ps1") }
    } else {
      $Files += $Item
    }
  }

  return $Files
}

function Test-AllowedNamingException {
  param(
    [string]$RelativePath,
    [string]$Line
  )

  if ($RelativePath -eq "docs/product-name-policy.md") {
    return $true
  }
  if ($Line -match "WatcherRobotAPP") {
    return $true
  }
  if ($Line -match "resources/robot/models/watcherobot-") {
    return $true
  }
  if ($Line -match "watcherobot-(base-link|link-1|link-2|preview)\.stl") {
    return $true
  }

  return $false
}

$PolicyPath = Join-Path $Root "docs/product-name-policy.md"
if (-not (Test-Path -LiteralPath $PolicyPath)) {
  Add-Failure "Missing file: docs/product-name-policy.md"
} else {
  $Policy = Get-Content -LiteralPath $PolicyPath -Raw -Encoding UTF8
  foreach ($RequiredText in @(
    '# Product Name Policy',
    'Public product name: `WatcheRobot`',
    'Forbidden public spellings',
    '`Watcherobot`',
    '`watcherobot`',
    '`Watcher Robot`',
    '`watcher-robot`',
    '`WatcherRobot`',
    'Allowed technical exceptions',
    '`WatcherRobotAPP`',
    '`resources/robot/models/watcherobot-*.stl`',
    'source plan document',
    'Do not rename high-risk native targets without owner approval and build evidence.'
  )) {
    Assert-Contains -Content $Policy -Needle $RequiredText -Context "docs/product-name-policy.md"
  }
}

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

$Forbidden = @("Watcherobot", "watcherobot", "Watcher Robot", "watcher-robot", "WatcherRobot")
$Files = Get-TextFiles -RelativePaths $ScanRoots
foreach ($Hit in Select-String -LiteralPath $Files.FullName -Pattern $Forbidden -SimpleMatch -CaseSensitive -ErrorAction SilentlyContinue) {
  $Relative = Convert-ToRelativePath $Hit.Path
  $Line = $Hit.Line.Trim()
  if (Test-AllowedNamingException -RelativePath $Relative -Line $Line) {
    continue
  }

  Add-Failure "Unexpected public product-name drift in ${Relative}:$($Hit.LineNumber): $Line"
}

foreach ($RequiredPublicFile in @(
  "README.md",
  "README.zh-CN.md",
  "docs/README.md",
  "docs/README.zh-CN.md",
  "docs/open-source-readiness-final.md",
  "docs/open-source-readiness-final.zh-CN.md"
)) {
  $Path = Join-Path $Root $RequiredPublicFile
  if (-not (Test-Path -LiteralPath $Path)) {
    Add-Failure "Missing public naming surface: $RequiredPublicFile"
    continue
  }

  $Content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
  Assert-Contains -Content $Content -Needle "WatcheRobot" -Context $RequiredPublicFile
}

if ($Failures.Count -gt 0) {
  Write-Host "Product name policy tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Product name policy tests passed."
