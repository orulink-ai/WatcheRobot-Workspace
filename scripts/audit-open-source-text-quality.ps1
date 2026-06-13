param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$Failures = New-Object System.Collections.Generic.List[string]

function New-UnicodeString {
  param([int[]]$CodePoints)

  return -join ($CodePoints | ForEach-Object { [char]$_ })
}

function Convert-ToRelativePath {
  param([string]$Path)

  $Relative = Resolve-Path -LiteralPath $Path -Relative
  return ($Relative -replace "^\.[\\/]", "") -replace "\\", "/"
}

function Get-PublicTextFiles {
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
    ".github"
  )
  $Extensions = @(".md", ".json", ".yml", ".yaml", ".ps1")
  $Files = New-Object System.Collections.Generic.List[object]

  foreach ($RelativeRoot in $ScanRoots) {
    $Path = Join-Path $Root $RelativeRoot
    if (-not (Test-Path -LiteralPath $Path)) {
      continue
    }

    $Item = Get-Item -LiteralPath $Path
    if ($Item.PSIsContainer) {
      Get-ChildItem -LiteralPath $Path -Recurse -File |
        Where-Object { $_.Extension -in $Extensions } |
        ForEach-Object { $Files.Add($_) }
    } elseif ($Item.Extension -in $Extensions) {
      $Files.Add($Item)
    }
  }

  return $Files
}

function Add-Failure {
  param([string]$Message)
  $script:Failures.Add($Message)
}

function Assert-FileContains {
  param(
    [string]$RelativePath,
    [string[]]$RequiredPatterns
  )

  $Path = Join-Path $Root $RelativePath
  if (-not (Test-Path -LiteralPath $Path)) {
    Add-Failure "Missing required text quality target: $RelativePath"
    return
  }

  $Content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
  foreach ($Pattern in $RequiredPatterns) {
    if ($Content -notmatch [regex]::Escape($Pattern)) {
      Add-Failure "$RelativePath does not contain expected phrase: $Pattern"
    }
  }
}

$MojibakeMarkers = @(
  [char]0xFFFD,
  [char]0x951F,
  [char]0x951B,
  [char]0x9286,
  [char]0x9225,
  [char]0x00C3,
  [char]0x00C2,
  [char]0x00E2
)

foreach ($File in Get-PublicTextFiles) {
  $Content = Get-Content -LiteralPath $File.FullName -Raw -Encoding UTF8
  foreach ($Marker in $MojibakeMarkers) {
    $Index = $Content.IndexOf([string]$Marker, [System.StringComparison]::Ordinal)
    if ($Index -lt 0) {
      continue
    }

    $Before = $Content.Substring(0, $Index)
    $LineNumber = ($Before -split "`n").Count
    $Relative = Convert-ToRelativePath $File.FullName
    Add-Failure "Possible mojibake marker U+$(([int][char]$Marker).ToString('X4')) in ${Relative}:$LineNumber"
  }
}

$OpenSource = New-UnicodeString @(0x5F00, 0x6E90)
$Community = New-UnicodeString @(0x793E, 0x533A)
$DeveloperDocs = "WatcheRobot " + (New-UnicodeString @(0x5F00, 0x53D1, 0x8005, 0x6587, 0x6863))
$QuickEntry = New-UnicodeString @(0x5FEB, 0x901F, 0x5165, 0x53E3)
$AcceptanceRules = New-UnicodeString @(0x9A8C, 0x6536, 0x539F, 0x5219)
$CurrentConclusion = New-UnicodeString @(0x5F53, 0x524D, 0x7ED3, 0x8BBA)
$WhyNotFullScore = (New-UnicodeString @(0x4E3A, 0x4EC0, 0x4E48, 0x4E0D, 0x662F)) + " 100/100"
$WosChineseStatus = "WOS " + (New-UnicodeString @(0x4E2D, 0x6587, 0x72B6, 0x6001, 0x8868))

Assert-FileContains "README.zh-CN.md" @("WatcheRobot", $OpenSource, $Community)
Assert-FileContains "docs/README.zh-CN.md" @($DeveloperDocs, $QuickEntry, $AcceptanceRules)
Assert-FileContains "docs/open-source-readiness-final.zh-CN.md" @($CurrentConclusion, $WhyNotFullScore, $WosChineseStatus)

if ($Failures.Count -gt 0) {
  Write-Host "Open-source text quality audit failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Open-source text quality audit passed."
