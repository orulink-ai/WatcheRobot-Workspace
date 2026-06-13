param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$RegisterRelativePath = "docs/placeholder-register.md"
$RegisterPath = Join-Path $Root $RegisterRelativePath

if (-not (Test-Path -LiteralPath $RegisterPath)) {
  throw "Missing placeholder register: $RegisterRelativePath"
}

function Convert-ToRelativePath {
  param([string]$Path)

  $Relative = Resolve-Path -LiteralPath $Path -Relative
  return ($Relative -replace "^\.[\\/]", "") -replace "\\", "/"
}

$AllowedFiles = New-Object "System.Collections.Generic.HashSet[string]"
$RegisterLines = Get-Content -LiteralPath $RegisterPath -Encoding UTF8
foreach ($Line in $RegisterLines) {
  if ($Line -match '^\|\s*`([^`]+)`\s*\|') {
    [void]$AllowedFiles.Add(($Matches[1] -replace "\\", "/"))
  }
}

if ($AllowedFiles.Count -eq 0) {
  throw "Placeholder register has no file entries."
}

foreach ($AllowedFile in $AllowedFiles) {
  $AllowedPath = Join-Path $Root $AllowedFile
  if (-not (Test-Path -LiteralPath $AllowedPath)) {
    throw "Placeholder register references a missing file: $AllowedFile"
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
  ".github"
)

$TextExtensions = @(".md", ".json", ".yml", ".yaml", ".ps1")
$Files = New-Object System.Collections.Generic.List[object]
foreach ($RelativeRoot in $ScanRoots) {
  $Path = Join-Path $Root $RelativeRoot
  if (-not (Test-Path -LiteralPath $Path)) {
    continue
  }

  $Item = Get-Item -LiteralPath $Path
  if ($Item.PSIsContainer) {
    Get-ChildItem -LiteralPath $Path -Recurse -File |
      Where-Object { $_.Extension -in $TextExtensions } |
      ForEach-Object { $Files.Add($_) }
  } elseif ($Item.Extension -in $TextExtensions) {
    $Files.Add($Item)
  }
}

$Pattern = "TODO|TBD|PLACEHOLDER"
$Failures = New-Object System.Collections.Generic.List[string]
$HitFiles = New-Object "System.Collections.Generic.HashSet[string]"
$HitCount = 0

foreach ($File in $Files) {
  $Relative = Convert-ToRelativePath $File.FullName
  if ($Relative -eq $RegisterRelativePath) {
    continue
  }

  $Hits = Select-String -LiteralPath $File.FullName -Pattern $Pattern -CaseSensitive -ErrorAction SilentlyContinue
  if (-not $Hits) {
    continue
  }

  [void]$HitFiles.Add($Relative)
  foreach ($Hit in $Hits) {
    $HitCount += 1
    if (-not $AllowedFiles.Contains($Relative)) {
      $Failures.Add("Unregistered placeholder marker in ${Relative}:$($Hit.LineNumber): $($Hit.Line.Trim())")
    }
  }
}

if ($Failures.Count -gt 0) {
  Write-Host "Placeholder audit failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Placeholder audit passed. Registered files with markers: $($HitFiles.Count); marker count: $HitCount."
