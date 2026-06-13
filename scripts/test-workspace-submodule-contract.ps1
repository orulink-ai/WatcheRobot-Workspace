param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$GitSafeDirectory = ([string]$Root) -replace "\\", "/"
$Failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([string]$Message)
  $script:Failures.Add($Message)
}

function Get-RepoText {
  param([string]$RelativePath)

  $Path = Join-Path $Root $RelativePath
  if (-not (Test-Path -LiteralPath $Path)) {
    Add-Failure "Missing required file: $RelativePath"
    return ""
  }

  return Get-Content -LiteralPath $Path -Raw -Encoding UTF8
}

function Assert-Contains {
  param(
    [string]$Content,
    [string]$Needle,
    [string]$Context
  )

  $NormalizedContent = $Content -replace "\\", "/"
  $NormalizedNeedle = $Needle -replace "\\", "/"
  if ($Content -notmatch [regex]::Escape($Needle) -and $NormalizedContent -notmatch [regex]::Escape($NormalizedNeedle)) {
    Add-Failure "$Context is missing required text: $Needle"
  }
}

function Get-GitModulesValue {
  param(
    [string]$Content,
    [string]$Path,
    [string]$Key
  )

  $SectionPattern = "(?ms)^\[submodule\s+""(?<name>[^""]+)""\]\s*(?<body>.*?)(?=^\[submodule\s+""|\z)"
  foreach ($Match in [regex]::Matches($Content, $SectionPattern)) {
    $Body = $Match.Groups["body"].Value
    $PathMatch = [regex]::Match($Body, "(?im)^\s*path\s*=\s*(.+?)\s*$")
    if (-not $PathMatch.Success) {
      continue
    }
    if ($PathMatch.Groups[1].Value.Trim() -ne $Path) {
      continue
    }

    $KeyMatch = [regex]::Match($Body, "(?im)^\s*$([regex]::Escape($Key))\s*=\s*(.+?)\s*$")
    if ($KeyMatch.Success) {
      return $KeyMatch.Groups[1].Value.Trim()
    }
    return ""
  }

  return $null
}

$GitModules = Get-RepoText ".gitmodules"
$Readme = Get-RepoText "README.md"
$ChineseReadme = Get-RepoText "README.zh-CN.md"
$QuickStart = Get-RepoText "docs/quick-start.md"
$FinalReport = Get-RepoText "docs/open-source-readiness-final.md"
$ChineseFinalReport = Get-RepoText "docs/open-source-readiness-final.zh-CN.md"

$ExpectedSubmodules = @(
  @{ path = "WatcheRobot_app"; branch = "dev"; url = "https://github.com/Ro-In-AI/WatcheRobotAPP.git"; label = "Mobile App" },
  @{ path = "WatcheRobot_client"; branch = "main"; url = "https://github.com/ERRORIGHT-AI/watcher-desktop-app.git"; label = "Desktop App" },
  @{ path = "WatcheRobot_server"; branch = "main"; url = "https://github.com/Ro-In-AI/watcher-server.git"; label = "Server" },
  @{ path = "WatcheRobot_esp32"; branch = "main"; url = "https://github.com/Ro-In-AI/WatcheRobot-Firmware.git"; label = "ESP32 Firmware" },
  @{ path = "WatcheRobot_stm32"; branch = "dev"; url = "https://github.com/Ro-In-AI/watcherobot_stm32.git"; label = "STM32 Firmware" }
)

$GitLinkOutput = git -c "safe.directory=$GitSafeDirectory" ls-files -s WatcheRobot_app WatcheRobot_client WatcheRobot_server WatcheRobot_esp32 WatcheRobot_stm32 2>&1
if ($LASTEXITCODE -ne 0) {
  Add-Failure "Unable to read gitlink entries: $($GitLinkOutput -join ' ')"
}

$GitLinkByPath = @{}
foreach ($Line in $GitLinkOutput) {
  if ($Line -match "^(?<mode>\d+)\s+(?<sha>[0-9a-f]{40})\s+\d+\s+(?<path>\S+)$") {
    $GitLinkByPath[$Matches.path] = @{
      mode = $Matches.mode
      sha = $Matches.sha
    }
  }
}

foreach ($Spec in $ExpectedSubmodules) {
  $Path = [string]$Spec.path
  $ExpectedBranch = [string]$Spec.branch
  $ExpectedUrl = [string]$Spec.url
  $Label = [string]$Spec.label

  $ActualUrl = Get-GitModulesValue -Content $GitModules -Path $Path -Key "url"
  $ActualBranch = Get-GitModulesValue -Content $GitModules -Path $Path -Key "branch"

  if ($null -eq $ActualUrl) {
    Add-Failure ".gitmodules is missing submodule path: $Path"
  } elseif ($ActualUrl -ne $ExpectedUrl) {
    Add-Failure ".gitmodules url mismatch for ${Path}: expected $ExpectedUrl, got $ActualUrl"
  }

  if ($null -eq $ActualBranch) {
    Add-Failure ".gitmodules is missing branch for: $Path"
  } elseif ($ActualBranch -ne $ExpectedBranch) {
    Add-Failure ".gitmodules branch mismatch for ${Path}: expected $ExpectedBranch, got $ActualBranch"
  }

  if (-not $GitLinkByPath.ContainsKey($Path)) {
    Add-Failure "Root index is missing gitlink entry for: $Path"
  } elseif ($GitLinkByPath[$Path].mode -ne "160000") {
    Add-Failure "Root index mode for $Path must be 160000, got $($GitLinkByPath[$Path].mode)"
  }

  foreach ($Doc in @(
    @{ name = "README.md"; content = $Readme },
    @{ name = "README.zh-CN.md"; content = $ChineseReadme }
  )) {
    Assert-Contains -Content ([string]$Doc.content) -Needle $Path -Context ([string]$Doc.name)
    Assert-Contains -Content ([string]$Doc.content) -Needle $ExpectedBranch -Context ([string]$Doc.name)
    Assert-Contains -Content ([string]$Doc.content) -Needle $Label -Context ([string]$Doc.name)
  }

  Assert-Contains -Content $QuickStart -Needle $Path -Context "docs/quick-start.md"
}

foreach ($Needle in @(
  "git submodule update --init --recursive",
  "yarn status",
  "submodules / gitlinks",
  "Contribution Boundaries"
)) {
  Assert-Contains -Content $Readme -Needle $Needle -Context "README.md"
}

foreach ($Needle in @(
  "scripts/test-workspace-submodule-contract.ps1",
  "workspace submodule contract tests",
  "WOS-06",
  "WOS-08",
  "WOS-45"
)) {
  Assert-Contains -Content $FinalReport -Needle $Needle -Context "docs/open-source-readiness-final.md"
}

foreach ($Needle in @(
  "scripts/test-workspace-submodule-contract.ps1",
  "workspace submodule contract tests",
  "WOS-06",
  "WOS-08",
  "WOS-45"
)) {
  Assert-Contains -Content $ChineseFinalReport -Needle $Needle -Context "docs/open-source-readiness-final.zh-CN.md"
}

if ($Failures.Count -gt 0) {
  Write-Host "Workspace submodule contract tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Workspace submodule contract tests passed."
