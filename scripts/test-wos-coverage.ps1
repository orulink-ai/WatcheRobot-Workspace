param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$Failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([string]$Message)
  $script:Failures.Add($Message)
}

$ExpectedIds = 1..45 | ForEach-Object { "WOS-{0:D2}" -f $_ }
$TargetDocs = @(
  "docs/open-source-delivery-plan.md",
  "docs/open-source-readiness-final.md",
  "docs/open-source-readiness-final.zh-CN.md"
)

foreach ($RelativePath in $TargetDocs) {
  $Path = Join-Path $Root $RelativePath
  if (-not (Test-Path -LiteralPath $Path)) {
    Add-Failure "Missing WOS coverage document: $RelativePath"
    continue
  }

  $Content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
  $FoundIds = @([regex]::Matches($Content, "WOS-\d{2}") | ForEach-Object { $_.Value } | Sort-Object -Unique)

  foreach ($ExpectedId in $ExpectedIds) {
    if ($FoundIds -notcontains $ExpectedId) {
      Add-Failure "$RelativePath is missing $ExpectedId"
    }
  }

  foreach ($FoundId in $FoundIds) {
    if ($ExpectedIds -notcontains $FoundId) {
      Add-Failure "$RelativePath contains unexpected WOS id: $FoundId"
    }
  }

  if ($FoundIds.Count -ne $ExpectedIds.Count) {
    Add-Failure "$RelativePath has $($FoundIds.Count) unique WOS ids; expected $($ExpectedIds.Count)"
  }
}

if ($Failures.Count -gt 0) {
  Write-Host "WOS coverage test failures:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "WOS coverage tests passed."
