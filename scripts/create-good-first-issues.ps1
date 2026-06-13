param(
  [string]$IssueDir = ".github/good-first-issues",
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$FullIssueDir = Join-Path $Root $IssueDir

if (-not (Test-Path -LiteralPath $FullIssueDir)) {
  throw "Issue directory not found: $IssueDir"
}

$Gh = Get-Command gh -ErrorAction SilentlyContinue
if (-not $Gh -and -not $DryRun) {
  throw "GitHub CLI 'gh' is required for creating issues. Re-run with -DryRun to preview commands."
}

function Read-IssueDraft {
  param([string]$Path)

  $Text = Get-Content -LiteralPath $Path -Raw
  if ($Text -notmatch "(?s)^---\s*(?<front>.*?)\s*---\s*(?<body>.*)$") {
    throw "Issue draft is missing frontmatter: $Path"
  }

  $Front = $Matches.front
  $Body = $Matches.body.Trim()
  $Title = ""
  $Labels = @()

  foreach ($Line in ($Front -split "`r?`n")) {
    if ($Line -match "^title:\s*`"?(?<value>.*?)`"?\s*$") {
      $Title = $Matches.value.Trim()
    } elseif ($Line -match "^labels:\s*`"?(?<value>.*?)`"?\s*$") {
      $Labels = $Matches.value.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    }
  }

  if (-not $Title) {
    throw "Issue draft is missing title: $Path"
  }
  if (-not $Body) {
    throw "Issue draft is missing body: $Path"
  }

  [pscustomobject]@{
    Path = $Path
    Title = $Title
    Labels = $Labels
    Body = $Body
  }
}

foreach ($File in Get-ChildItem -LiteralPath $FullIssueDir -Filter "*.md" | Sort-Object Name) {
  $Draft = Read-IssueDraft -Path $File.FullName
  $Args = @("issue", "create", "--title", $Draft.Title, "--body-file", $Draft.Path)
  foreach ($Label in $Draft.Labels) {
    $Args += @("--label", $Label)
  }

  if ($DryRun) {
    Write-Host "gh $($Args -join ' ')"
  } else {
    & gh @Args
    if ($LASTEXITCODE -ne 0) {
      throw "gh issue create failed for: $($Draft.Title)"
    }
  }
}

Write-Host "Good first issue creation completed."
