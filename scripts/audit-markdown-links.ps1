param(
  [string]$WorkspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")),
  [string[]]$Include = @(
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
  ),
  [switch]$Json
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path -LiteralPath $WorkspaceRoot
$Failures = New-Object System.Collections.Generic.List[object]
$AnchorCache = @{}
$QuoteClassPattern = "[" + [char]34 + [char]39 + "]"

function Add-Failure {
  param(
    [string]$Type,
    [string]$File,
    [string]$Target,
    [string]$Detail
  )

  $script:Failures.Add([pscustomobject]@{
    type = $Type
    file = $File
    target = $Target
    detail = $Detail
  })
}

function Get-NormalizedRelativePath {
  param([string]$Path)

  $RootPath = [string]$Root
  if (-not $RootPath.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
    $RootPath += [System.IO.Path]::DirectorySeparatorChar
  }

  $RootUri = New-Object System.Uri($RootPath)
  $PathUri = New-Object System.Uri($Path)
  $RelativeUri = $RootUri.MakeRelativeUri($PathUri)
  return [uri]::UnescapeDataString($RelativeUri.ToString())
}

function Get-MarkdownFiles {
  $Files = @()
  foreach ($RelativePath in $Include) {
    $Path = Join-Path $Root $RelativePath
    if (-not (Test-Path -LiteralPath $Path)) {
      continue
    }

    $Item = Get-Item -LiteralPath $Path
    if ($Item.PSIsContainer) {
      $Files += Get-ChildItem -LiteralPath $Path -Recurse -File -Filter "*.md"
    } elseif ($Item.Extension -eq ".md") {
      $Files += $Item
    }
  }

  return $Files | Sort-Object FullName -Unique
}

function Get-MarkdownTarget {
  param([string]$RawTarget)

  $Target = $RawTarget.Trim()
  if ([string]::IsNullOrWhiteSpace($Target)) {
    return ""
  }

  if ($Target.StartsWith("<") -and $Target.Contains(">")) {
    $CloseIndex = $Target.IndexOf(">")
    return $Target.Substring(1, $CloseIndex - 1).Trim()
  }

  if ($Target -match ("^(?<target>\S+)\s+" + $QuoteClassPattern)) {
    return $Matches.target.Trim()
  }

  return $Target
}

function ConvertTo-GitHubAnchor {
  param([string]$Heading)

  $Anchor = $Heading.Trim().ToLowerInvariant()
  $Anchor = [regex]::Replace($Anchor, "<[^>]+>", "")
  $Anchor = [regex]::Replace($Anchor, "[^\p{L}\p{Nd}\s_-]", "")
  $Anchor = [regex]::Replace($Anchor, "\s+", "-")
  $Anchor = [regex]::Replace($Anchor, "-+", "-")
  return $Anchor.Trim("-")
}

function Get-MarkdownAnchors {
  param([string]$MarkdownPath)

  $CacheKey = (Resolve-Path -LiteralPath $MarkdownPath).Path
  if ($AnchorCache.ContainsKey($CacheKey)) {
    return $AnchorCache[$CacheKey]
  }

  $Anchors = New-Object System.Collections.Generic.HashSet[string]
  $AnchorCounts = @{}
  $InFence = $false
  $Lines = Get-Content -LiteralPath $MarkdownPath

  foreach ($Line in $Lines) {
    if ($Line -match '^\s*```') {
      $InFence = -not $InFence
      continue
    }

    if ($InFence) {
      continue
    }

    if ($Line -match '^\s{0,3}(#{1,6})\s+(?<heading>.+?)\s*#*\s*$') {
      $BaseAnchor = ConvertTo-GitHubAnchor -Heading $Matches.heading
      if ([string]::IsNullOrWhiteSpace($BaseAnchor)) {
        continue
      }

      if (-not $AnchorCounts.ContainsKey($BaseAnchor)) {
        $AnchorCounts[$BaseAnchor] = 0
        [void]$Anchors.Add($BaseAnchor)
      } else {
        $AnchorCounts[$BaseAnchor] += 1
        [void]$Anchors.Add("$BaseAnchor-$($AnchorCounts[$BaseAnchor])")
      }
    }
  }

  $AnchorCache[$CacheKey] = $Anchors
  return $Anchors
}

function Test-MarkdownLink {
  param(
    [System.IO.FileInfo]$File,
    [string]$RawTarget
  )

  $Target = Get-MarkdownTarget -RawTarget $RawTarget
  if ([string]::IsNullOrWhiteSpace($Target)) {
    return
  }

  if ($Target -match "^(https?|mailto):") {
    return
  }

  if ($Target -match "^[A-Za-z][A-Za-z0-9+.-]*:") {
    return
  }

  $TargetWithoutQuery = ($Target -split "\?")[0]
  $PathPart = ($TargetWithoutQuery -split "#", 2)[0]
  $Fragment = ""
  if ($TargetWithoutQuery.Contains("#")) {
    $Fragment = ($TargetWithoutQuery -split "#", 2)[1]
  }

  $DecodedPathPart = [uri]::UnescapeDataString($PathPart)
  $BasePath = Split-Path -Parent $File.FullName
  $Candidate = if ([string]::IsNullOrWhiteSpace($DecodedPathPart)) {
    $File.FullName
  } else {
    Join-Path $BasePath $DecodedPathPart
  }

  $RelativeFile = Get-NormalizedRelativePath -Path $File.FullName
  if (-not (Test-Path -LiteralPath $Candidate)) {
    Add-Failure -Type "link" -File $RelativeFile -Target $Target -Detail "Broken Markdown link in $RelativeFile -> $Target"
    return
  }

  if ([string]::IsNullOrWhiteSpace($Fragment)) {
    return
  }

  $Item = Get-Item -LiteralPath $Candidate
  if ($Item.PSIsContainer -or $Item.Extension -ne ".md") {
    return
  }

  $DecodedFragment = [uri]::UnescapeDataString($Fragment).Trim()
  if ([string]::IsNullOrWhiteSpace($DecodedFragment)) {
    return
  }

  $ExpectedAnchor = $DecodedFragment.TrimStart("#").ToLowerInvariant()
  $Anchors = Get-MarkdownAnchors -MarkdownPath $Item.FullName
  if (-not $Anchors.Contains($ExpectedAnchor)) {
    Add-Failure -Type "anchor" -File $RelativeFile -Target $Target -Detail "Broken Markdown anchor in $RelativeFile -> $Target"
  }
}

$MarkdownFiles = Get-MarkdownFiles
$Pattern = '(!?\[[^\]]*\]\(([^)]+)\))'

foreach ($File in $MarkdownFiles) {
  $Content = Get-Content -LiteralPath $File.FullName -Raw
  foreach ($Match in [regex]::Matches($Content, $Pattern)) {
    Test-MarkdownLink -File $File -RawTarget $Match.Groups[2].Value
  }
}

$Report = [pscustomobject]@{
  workspace = [string]$Root
  scanned_files = $MarkdownFiles.Count
  failed = $Failures.Count
  failures = $Failures
}

if ($Json) {
  $Report | ConvertTo-Json -Depth 5
} elseif ($Failures.Count -gt 0) {
  Write-Host "Markdown link audit failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $($Failure.detail)"
  }
} else {
  Write-Host "Markdown link audit passed."
}

if ($Failures.Count -gt 0) {
  exit 1
}
