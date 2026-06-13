param(
  [Alias("Path")]
  [string]$Manifest = "docs/release-manifest.example.json",
  [switch]$AllowPlaceholders
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
if ([System.IO.Path]::IsPathRooted($Manifest)) {
  $ManifestPath = $Manifest
} else {
  $ManifestPath = Join-Path $Root $Manifest
}
$Failures = New-Object System.Collections.Generic.List[string]
$PendingPattern = "(?i)\b(TODO|TBD|PLACEHOLDER|REPLACE_ME|UNKNOWN)\b"

function Add-Failure {
  param([string]$Message)
  $script:Failures.Add($Message)
}

function Test-ValidNonFutureDate {
  param(
    [string]$DateValue,
    [string]$FieldName
  )

  if ($DateValue -notmatch "^\d{4}-\d{2}-\d{2}$") {
    Add-Failure "$FieldName must use YYYY-MM-DD format."
    return
  }

  try {
    $ParsedDate = [datetime]::ParseExact($DateValue, "yyyy-MM-dd", [System.Globalization.CultureInfo]::InvariantCulture)
  } catch {
    Add-Failure "$FieldName must be a valid calendar date."
    return
  }

  if ($ParsedDate.Date -gt (Get-Date).Date) {
    Add-Failure "$FieldName must not be in the future."
  }
}

function Test-HttpUrl {
  param(
    [string]$Value,
    [string]$FieldName
  )

  if ($Value -notmatch "^https?://") {
    Add-Failure "$FieldName must be an http(s) URL."
  }
}

function Test-SemanticVersionTag {
  param(
    [string]$Value,
    [string]$FieldName
  )

  $SemanticVersionTagPattern = "^(?i:v?\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?)$"
  if ($Value -notmatch $SemanticVersionTagPattern) {
    Add-Failure "$FieldName must be a semantic version tag such as v0.1.0-alpha."
  }
}

function Test-TraceableComponentRef {
  param(
    [string]$Value,
    [string]$ComponentName
  )

  $CommitHashOrVersionTagPattern = "^(?i:([0-9a-f]{7,40}|v?\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?))$"
  if ($Value -notmatch $CommitHashOrVersionTagPattern) {
    Add-Failure "Component ref $ComponentName must be a commit hash or semantic version tag."
  }
}

function Test-ArtifactPathOrUrl {
  param(
    [string]$Value,
    [string]$ArtifactName
  )

  $HttpUrlPattern = "^https?://"
  $WindowsAbsolutePathPattern = "^[A-Za-z]:[\\/].+"
  $RepositoryOrBuildPathPattern = "^(?:\.?[\\/])?(?:docs|release|releases|dist|build|artifacts|output|outputs|firmware|hardware|WatcheRobot_[A-Za-z0-9_-]+)[\\/].+"
  $PosixBuildPathPattern = "^/(?:home|mnt|tmp|workspace|artifacts|dist|build|release|releases)/.+"

  if (
    $Value -notmatch $HttpUrlPattern -and
    $Value -notmatch $WindowsAbsolutePathPattern -and
    $Value -notmatch $RepositoryOrBuildPathPattern -and
    $Value -notmatch $PosixBuildPathPattern
  ) {
    Add-Failure "Artifact $ArtifactName path_or_url must be an http(s) URL or traceable file path."
  }
}

function Test-NoPendingToken {
  param(
    [object]$Value,
    [string]$Path
  )

  if ($null -eq $Value) {
    Add-Failure "$Path is null."
    return
  }

  if ($Value -is [System.Management.Automation.PSCustomObject]) {
    foreach ($Property in $Value.PSObject.Properties) {
      Test-NoPendingToken -Value $Property.Value -Path "$Path.$($Property.Name)"
    }
    return
  }

  if ($Value -is [System.Collections.IEnumerable] -and -not ($Value -is [string])) {
    $Index = 0
    foreach ($Item in $Value) {
      Test-NoPendingToken -Value $Item -Path "${Path}[$Index]"
      $Index += 1
    }
    return
  }

  $Text = [string]$Value
  if ([string]::IsNullOrWhiteSpace($Text)) {
    Add-Failure "$Path is empty."
    return
  }

  if ($Text -match $PendingPattern) {
    Add-Failure "$Path still contains a pending token."
  }
}

if (-not (Test-Path -LiteralPath $ManifestPath)) {
  throw "Release manifest not found: $Manifest"
}

$Data = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json

foreach ($Field in @("version", "release_date", "release_url", "components", "artifacts", "checks")) {
  if (-not $Data.PSObject.Properties.Name.Contains($Field)) {
    Add-Failure "Missing required field: $Field"
  }
}

$RequiredChecks = @("readiness_script", "hardware_smoke", "clean_machine")
if ($Data.PSObject.Properties.Name.Contains("checks")) {
  foreach ($CheckName in $RequiredChecks) {
    if (-not $Data.checks.PSObject.Properties.Name.Contains($CheckName)) {
      Add-Failure "Missing required check result: $CheckName."
      continue
    }

    if (-not $AllowPlaceholders) {
      $CheckValue = [string]$Data.checks.$CheckName
      if ($CheckValue -cnotmatch "^(?i:passed)$") {
        Add-Failure "Required check result $CheckName must be passed."
      }
    }
  }
}

$RequiredComponents = @("workspace", "app", "desktop", "server", "esp32", "stm32")
if ($Data.PSObject.Properties.Name.Contains("components")) {
  foreach ($ComponentName in $RequiredComponents) {
    if (-not $Data.components.PSObject.Properties.Name.Contains($ComponentName)) {
      Add-Failure "Missing required component ref: $ComponentName."
      continue
    }

    if (-not $AllowPlaceholders) {
      Test-TraceableComponentRef -Value ([string]$Data.components.$ComponentName) -ComponentName $ComponentName
    }
  }
}

if (-not $AllowPlaceholders) {
  Test-NoPendingToken -Value $Data -Path "manifest"

  if ($Data.PSObject.Properties.Name.Contains("version")) {
    Test-SemanticVersionTag -Value ([string]$Data.version) -FieldName "version"
  }
  if ($Data.PSObject.Properties.Name.Contains("release_date")) {
    Test-ValidNonFutureDate -DateValue ([string]$Data.release_date) -FieldName "release_date"
  }
  if ($Data.PSObject.Properties.Name.Contains("release_url")) {
    Test-HttpUrl -Value ([string]$Data.release_url) -FieldName "release_url"
  }
}

if (-not $Data.artifacts -or @($Data.artifacts).Count -eq 0) {
  Add-Failure "Manifest must include at least one artifact."
}

$RequiredArtifacts = @(
  @{ name = "desktop-windows-installer"; type = "desktop-installer" },
  @{ name = "esp32-firmware-package"; type = "firmware" }
)
$ArtifactsByName = @{}

foreach ($Artifact in @($Data.artifacts)) {
  foreach ($Field in @("name", "type", "path_or_url", "sha256", "required")) {
    if (-not $Artifact.PSObject.Properties.Name.Contains($Field)) {
      Add-Failure "Artifact is missing field '$Field'."
    }
  }

  if ($Artifact.PSObject.Properties.Name.Contains("required") -and $Artifact.required -isnot [bool]) {
    Add-Failure "Artifact $($Artifact.name) required must be a JSON boolean."
  }

  if ($Artifact.PSObject.Properties.Name.Contains("name")) {
    $ArtifactName = [string]$Artifact.name
    if (-not [string]::IsNullOrWhiteSpace($ArtifactName)) {
      if ($ArtifactsByName.ContainsKey($ArtifactName)) {
        Add-Failure "Duplicate artifact name: $ArtifactName."
      }
      $ArtifactsByName[$ArtifactName] = $Artifact
    }
  }

  if (-not $AllowPlaceholders) {
    if ([string]$Artifact.path_or_url -eq "TBD" -or [string]$Artifact.sha256 -eq "TBD") {
      Add-Failure "Artifact $($Artifact.name) still contains TBD placeholders."
    }

    Test-ArtifactPathOrUrl -Value ([string]$Artifact.path_or_url) -ArtifactName ([string]$Artifact.name)
  }

  $Sha = [string]$Artifact.sha256
  if ($Sha -ne "TBD" -and $Sha -notmatch "^[a-fA-F0-9]{64}$") {
    Add-Failure "Artifact $($Artifact.name) sha256 is not a 64-character hex digest."
  }
}

foreach ($RequiredArtifact in $RequiredArtifacts) {
  $RequiredName = [string]$RequiredArtifact.name
  $RequiredType = [string]$RequiredArtifact.type
  if (-not $ArtifactsByName.ContainsKey($RequiredName)) {
    Add-Failure "Missing required artifact: $RequiredName."
    continue
  }

  $Artifact = $ArtifactsByName[$RequiredName]
  if ([string]$Artifact.type -ne $RequiredType) {
    Add-Failure "Required artifact $RequiredName must have type '$RequiredType'."
  }

  if ($Artifact.required -ne $true) {
    Add-Failure "Required artifact $RequiredName must set required to true."
  }
}

if ($Failures.Count -gt 0) {
  Write-Host "Release manifest validation failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Release manifest validation passed."
