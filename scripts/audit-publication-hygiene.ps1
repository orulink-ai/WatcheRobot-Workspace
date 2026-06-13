param(
  [string]$WorkspaceRoot
)

$ErrorActionPreference = "Stop"
if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
  $Root = Resolve-Path (Join-Path $PSScriptRoot "..")
} else {
  $Root = Resolve-Path $WorkspaceRoot
}
$GitSafeDirectory = ([string]$Root) -replace "\\", "/"
$Failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([string]$Message)
  $script:Failures.Add($Message)
}

function Normalize-StatusPath {
  param([string]$RawPath)

  $Path = $RawPath.Trim()
  if ($Path.StartsWith('"') -and $Path.EndsWith('"')) {
    $Path = $Path.Substring(1, $Path.Length - 2)
  }

  return ($Path -replace "\\", "/")
}

$GitignorePath = Join-Path $Root ".gitignore"
if (-not (Test-Path -LiteralPath $GitignorePath)) {
  Add-Failure "Missing .gitignore"
} else {
  $Gitignore = Get-Content -LiteralPath $GitignorePath -Raw -Encoding UTF8
  foreach ($RequiredPattern in @(
    ".codex-temp/",
    "downloads/",
    "output/",
    "outputs/",
    "_tmp_pull*/",
    "feishu_watcherobot_tables*.tsv.md"
  )) {
    if (-not $Gitignore.Contains($RequiredPattern)) {
      Add-Failure ".gitignore is missing local-only pattern: $RequiredPattern"
    }
  }
}

$RiskyStagedPatterns = @(
  "^\.codex-temp/",
  "^downloads/",
  "^output/",
  "^outputs/",
  "^_tmp_pull",
  "^feishu_watcherobot_tables.*\.tsv\.md$",
  "^WatcheRobot_app(/|$)",
  "^WatcheRobot_client(/|$)",
  "^WatcheRobot_server(/|$)",
  "^WatcheRobot_esp32(/|$)",
  "^WatcheRobot_stm32(/|$)",
  "^scripts/desktop-server\.ps1$"
)

Push-Location $Root
try {
  $StatusLines = git -c "safe.directory=$GitSafeDirectory" status --porcelain=v1 --untracked-files=all
  foreach ($Line in $StatusLines) {
    if ([string]::IsNullOrWhiteSpace($Line) -or $Line.Length -lt 4) {
      continue
    }

    $IndexStatus = $Line.Substring(0, 1)
    if ($IndexStatus -eq " " -or $IndexStatus -eq "?" -or $IndexStatus -eq "!") {
      continue
    }

    $Path = Normalize-StatusPath ($Line.Substring(3))
    if ($Path -match "^[^/]+\.docx$" -and ($Path -notmatch "Codex" -or $Path -notmatch "Sub-Agent")) {
      Add-Failure "Unexpected root .docx is staged; only the Codex / Sub-Agent reference plan should be published: $Path"
      continue
    }

    foreach ($Pattern in $RiskyStagedPatterns) {
      if ($Path -match $Pattern) {
        Add-Failure "Local-only, subrepo, or helper path is staged and must be reviewed before publication: $Path"
      }
    }
  }
} finally {
  Pop-Location
}

if ($Failures.Count -gt 0) {
  Write-Host "Publication hygiene audit failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Publication hygiene audit passed."
