param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$Failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([string]$Message)
  $script:Failures.Add($Message)
}

function Read-IssueDraft {
  param([string]$Path)

  $Text = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
  if ($Text -notmatch "(?s)^---\s*(?<front>.*?)\s*---\s*(?<body>.*)$") {
    Add-Failure "Issue draft is missing frontmatter: $Path"
    return $null
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

  [pscustomobject]@{
    path = $Path
    title = $Title
    labels = $Labels
    body = $Body
  }
}

function Invoke-LocalCommand {
  param(
    [string]$Name,
    [scriptblock]$Command
  )

  Push-Location $Root
  try {
    $Output = & $Command 2>&1
    $ExitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
    if ($ExitCode -ne 0) {
      Add-Failure "$Name failed with exit code $ExitCode. Output: $(($Output | Out-String).Trim())"
    }
  } catch {
    Add-Failure "$Name failed: $($_.Exception.Message)"
  } finally {
    Pop-Location
  }
}

$LabelPath = Join-Path $Root ".github/labels.json"
$IssueDir = Join-Path $Root ".github/good-first-issues"
$LabelNames = New-Object "System.Collections.Generic.HashSet[string]"

if (-not (Test-Path -LiteralPath $LabelPath)) {
  Add-Failure "Missing label config: .github/labels.json"
} else {
  $Labels = Get-Content -LiteralPath $LabelPath -Raw -Encoding UTF8 | ConvertFrom-Json
  foreach ($Label in @($Labels)) {
    $Name = [string]$Label.name
    $Color = [string]$Label.color
    $Description = [string]$Label.description
    if ([string]::IsNullOrWhiteSpace($Name)) {
      Add-Failure "Label entry is missing name."
      continue
    }
    if (-not $LabelNames.Add($Name)) {
      Add-Failure "Duplicate label name: $Name"
    }
    if ($Color -notmatch "^[0-9a-fA-F]{6}$") {
      Add-Failure "Label '$Name' has invalid color: $Color"
    }
    if ([string]::IsNullOrWhiteSpace($Description)) {
      Add-Failure "Label '$Name' is missing description."
    }
  }

  $RequiredLabels = @(
    "bug",
    "feature",
    "docs",
    "app",
    "desktop",
    "server",
    "firmware",
    "hardware",
    "good first issue",
    "examples",
    "release"
  )
  foreach ($Required in $RequiredLabels) {
    if (-not $LabelNames.Contains($Required)) {
      Add-Failure "Required label is missing from .github/labels.json: $Required"
    }
  }
}

if (-not (Test-Path -LiteralPath $IssueDir)) {
  Add-Failure "Missing good first issue draft directory: .github/good-first-issues"
} else {
  $DraftFiles = @(Get-ChildItem -LiteralPath $IssueDir -Filter "*.md" | Sort-Object Name)
  if ($DraftFiles.Count -lt 5) {
    Add-Failure "Expected at least 5 good first issue drafts, got $($DraftFiles.Count)."
  }

  foreach ($File in $DraftFiles) {
    $Draft = Read-IssueDraft -Path $File.FullName
    if (-not $Draft) {
      continue
    }
    if ([string]::IsNullOrWhiteSpace($Draft.title)) {
      Add-Failure "Issue draft is missing title: $($File.Name)"
    }
    if (-not $Draft.labels -or $Draft.labels.Count -eq 0) {
      Add-Failure "Issue draft is missing labels: $($File.Name)"
    }
    if ($Draft.labels -notcontains "good first issue") {
      Add-Failure "Issue draft must include 'good first issue' label: $($File.Name)"
    }
    foreach ($Label in $Draft.labels) {
      if (-not $LabelNames.Contains($Label)) {
        Add-Failure "Issue draft references unknown label '$Label': $($File.Name)"
      }
    }
    foreach ($Section in @("Background", "Suggested Files", "Expected Result", "Acceptance")) {
      $SectionPattern = "(?im)^#+\s*$([regex]::Escape($Section))\s*$"
      if ($Draft.body -notmatch $SectionPattern) {
        Add-Failure "Issue draft is missing section '$Section': $($File.Name)"
      }
    }
  }
}

Invoke-LocalCommand "label sync dry run" {
  powershell -ExecutionPolicy Bypass -File .\scripts\sync-github-labels.ps1 -DryRun | Out-Null
}

Invoke-LocalCommand "good first issue dry run" {
  powershell -ExecutionPolicy Bypass -File .\scripts\create-good-first-issues.ps1 -DryRun | Out-Null
}

if ($Failures.Count -gt 0) {
  Write-Host "GitHub community asset tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "GitHub community asset tests passed."
