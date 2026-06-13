param(
  [string]$LabelFile = ".github/labels.json",
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$LabelPath = Join-Path $Root $LabelFile

if (-not (Test-Path -LiteralPath $LabelPath)) {
  throw "Label file not found: $LabelFile"
}

$Gh = Get-Command gh -ErrorAction SilentlyContinue
if (-not $Gh -and -not $DryRun) {
  throw "GitHub CLI 'gh' is required. Install it and authenticate before syncing labels."
}

$Labels = Get-Content -LiteralPath $LabelPath -Raw | ConvertFrom-Json
$Existing = @{}
if (-not $DryRun) {
  try {
    $RawExisting = & gh label list --json name --limit 500 | ConvertFrom-Json
    foreach ($Label in $RawExisting) {
      $Existing[$Label.name] = $true
    }
  } catch {
    throw "Unable to read labels with gh. Confirm repository access and authentication."
  }
}

foreach ($Label in $Labels) {
  $Name = [string]$Label.name
  $Color = [string]$Label.color
  $Description = [string]$Label.description

  if ([string]::IsNullOrWhiteSpace($Name) -or [string]::IsNullOrWhiteSpace($Color)) {
    throw "Invalid label entry in $LabelFile"
  }

  if (-not $DryRun -and $Existing.ContainsKey($Name)) {
    $Args = @("label", "edit", $Name, "--color", $Color, "--description", $Description)
  } else {
    $Args = @("label", "create", $Name, "--color", $Color, "--description", $Description)
  }

  if ($DryRun) {
    Write-Host "gh $($Args -join ' ')"
  } else {
    & gh @Args
    if ($LASTEXITCODE -ne 0) {
      throw "gh command failed for label: $Name"
    }
  }
}

Write-Host "GitHub labels sync completed."
