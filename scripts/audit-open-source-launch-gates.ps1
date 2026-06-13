param(
  [switch]$RequirePassed,
  [switch]$Json,
  [string]$RootPath = "",
  [switch]$SkipExternal
)

$ErrorActionPreference = "Continue"
if ($RootPath) {
  $Root = Resolve-Path $RootPath
} else {
  $Root = Resolve-Path (Join-Path $PSScriptRoot "..")
}
$PendingToken = -join ([char]84, [char]66, [char]68)
$PendingPattern = "(?i)\b(TODO|TBD|PLACEHOLDER|REPLACE_ME|UNKNOWN)\b"

function New-GateResult {
  param(
    [string]$Name,
    [string]$Status,
    [string]$Detail
  )

  [pscustomobject]@{
    name = $Name
    status = $Status
    detail = $Detail
  }
}

function Test-PathExists {
  param([string]$RelativePath)
  Test-Path -LiteralPath (Join-Path $Root $RelativePath)
}

function Test-ValidNonFutureDate {
  param([string]$DateValue)

  if ($DateValue -notmatch "^\d{4}-\d{2}-\d{2}$") {
    return "Date format"
  }

  try {
    $ParsedDate = [datetime]::ParseExact($DateValue, "yyyy-MM-dd", [System.Globalization.CultureInfo]::InvariantCulture)
  } catch {
    return "Date value"
  }

  if ($ParsedDate.Date -gt (Get-Date).Date) {
    return "Date future"
  }

  return ""
}

function Get-EvidenceField {
  param(
    [string]$Content,
    [string]$FieldName
  )

  $Pattern = "(?im)^\s*$([regex]::Escape($FieldName))\s*:\s*(.*?)\s*$"
  $Match = [regex]::Match($Content, $Pattern)
  if ($Match.Success) {
    return $Match.Groups[1].Value.Trim()
  }

  return ""
}

function Test-TraceableEvidenceValue {
  param([string]$EvidenceValue)

  if ([string]::IsNullOrWhiteSpace($EvidenceValue)) {
    return $false
  }

  $TracePatterns = @(
    '(?i)https?://',
    '(?i)\b[A-Z]:\\',
    '(?i)(^|[\s"`''])\.?/?(docs|scripts|examples|\.github|WatcheRobot_[A-Za-z0-9_-]+)[/\\]',
    '(?i)\b(powershell|pwsh|git|gh|npm|yarn|python|node|gradle|java|idf\.py|cargo|cmake)\b',
    '(?i)\b(stdout|stderr)\s*[:=]',
    '(?i)\b(log file|screenshot|recording|transcript)\s*[:=]?\s*(https?://|[A-Z]:\\|\.?/?(docs|scripts|examples|\.github|WatcheRobot_[A-Za-z0-9_-]+)[/\\])',
    '(?i)\b(sha-?256|checksum)\s*[:=]?\s*[A-Fa-f0-9]{64}\b',
    '(?i)\b(release URL|artifact URL)\s*[:=]?\s*https?://',
    '(?i)\b(issue #|PR #|pull request)\s*\d+\b',
    '(?i)\bcommit\s+[0-9a-f]{7,40}\b',
    '(?i)\b[A-Fa-f0-9]{64}\b'
  )

  foreach ($Pattern in $TracePatterns) {
    if ($EvidenceValue -match $Pattern) {
      return $true
    }
  }

  return $false
}

function Test-EvidenceDocument {
  param(
    [string]$Name,
    [string]$RelativePath
  )

  $Path = Join-Path $Root $RelativePath
  if (-not (Test-Path -LiteralPath $Path)) {
    return New-GateResult $Name "unavailable" "$RelativePath is missing."
  }

  $Content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
  $Status = Get-EvidenceField $Content "Status"
  if ([string]::IsNullOrWhiteSpace($Status)) {
    return New-GateResult $Name "unavailable" "$RelativePath exists, but the Status field is missing."
  }

  if ($Status -notmatch "^(?i:Passed)$") {
    return New-GateResult $Name "unavailable" "$RelativePath status is '$Status', not Passed."
  }

  $RequiredFields = @("Owner", "Date", "Environment", "Evidence", "Result", "Follow-up")
  $IncompleteFields = New-Object System.Collections.Generic.List[string]
  foreach ($Field in $RequiredFields) {
    $Value = Get-EvidenceField $Content $Field
    if ([string]::IsNullOrWhiteSpace($Value)) {
      $IncompleteFields.Add($Field)
      continue
    }
    if ($Value -match "(?i)\b(TODO|TBD|PLACEHOLDER|REPLACE_ME|UNKNOWN)\b") {
      $IncompleteFields.Add($Field)
    }
    if ($Field -eq "Evidence" -and -not (Test-TraceableEvidenceValue -EvidenceValue $Value)) {
      $IncompleteFields.Add("Evidence trace")
    }
  }

  $DateValue = Get-EvidenceField $Content "Date"
  if ($DateValue) {
    $DateIssue = Test-ValidNonFutureDate -DateValue $DateValue
    if ($DateIssue) {
      $IncompleteFields.Add($DateIssue)
    }
  }

  if ($Content -match $PendingPattern) {
    $IncompleteFields.Add("placeholder token")
  }

  if ($IncompleteFields.Count -gt 0) {
    $UniqueFields = $IncompleteFields | Select-Object -Unique
    return New-GateResult $Name "failed" "$RelativePath claims Passed but has incomplete evidence fields: $($UniqueFields -join ', ')."
  }

  New-GateResult $Name "passed" "$RelativePath has Status: Passed, complete owner/date/environment/evidence/result/follow-up fields, traceable evidence, and no pending tokens."
}

function New-EvidenceBoundGateResult {
  param(
    [string]$Name,
    [string]$RelativePath,
    [string]$PassedDetail
  )

  $Evidence = Test-EvidenceDocument $Name $RelativePath
  if ($Evidence.status -eq "passed") {
    return New-GateResult $Name "passed" "$PassedDetail Evidence file is launch-ready: $($Evidence.detail)"
  }

  New-GateResult $Name $Evidence.status "$PassedDetail However, $RelativePath is not launch-ready: $($Evidence.detail)"
}

function Test-OwnerDecisions {
  $Path = Join-Path $Root "docs/owner-decision-record.md"
  if (-not (Test-Path -LiteralPath $Path)) {
    return New-GateResult "owner decisions" "failed" "docs/owner-decision-record.md is missing."
  }

  $Rows = Get-Content -LiteralPath $Path -Encoding UTF8 |
    Where-Object { $_ -match '^\|\s*OQ-\d{3}\b' }

  if (-not $Rows) {
    return New-GateResult "owner decisions" "failed" "No owner-decision rows found."
  }

  $ExpectedIds = 1..9 | ForEach-Object { "OQ-{0:D3}" -f $_ }
  $SeenIds = New-Object System.Collections.Generic.HashSet[string]
  $Closed = 0
  $InvalidClosedRows = New-Object System.Collections.Generic.List[string]
  foreach ($Row in $Rows) {
    $Cells = $Row.Trim("|") -split "\|" | ForEach-Object { $_.Trim() }
    if ($Cells.Count -lt 7) {
      $InvalidClosedRows.Add("malformed row")
      continue
    }

    $Id = ($Cells[0] -split "\s+")[0]
    if ($ExpectedIds -notcontains $Id) {
      $InvalidClosedRows.Add("$Id unexpected owner decision id")
      continue
    }
    if (-not $SeenIds.Add($Id)) {
      $InvalidClosedRows.Add("$Id duplicate owner decision row")
      continue
    }

    $FinalDecision = $Cells[3]
    $Evidence = $Cells[4]
    $Date = $Cells[5]
    $Status = $Cells[6]

    if ($Status -notin @("Open", "Closed")) {
      $InvalidClosedRows.Add("$Id invalid status '$Status'")
      continue
    }

    if ($Status -eq "Open") {
      continue
    }

    $Issues = New-Object System.Collections.Generic.List[string]
    foreach ($NamedValue in @(
      @{ name = "Final decision"; value = $FinalDecision },
      @{ name = "Evidence / link"; value = $Evidence },
      @{ name = "Date"; value = $Date }
    )) {
      if ([string]::IsNullOrWhiteSpace($NamedValue.value) -or $NamedValue.value -match $PendingPattern) {
        $Issues.Add($NamedValue.name)
      }
    }

    $DateIssue = Test-ValidNonFutureDate -DateValue $Date
    if ($DateIssue) {
      $Issues.Add($DateIssue)
    }
    if (-not (Test-TraceableEvidenceValue -EvidenceValue $Evidence)) {
      $Issues.Add("Evidence trace")
    }

    if ($Issues.Count -gt 0) {
      $InvalidClosedRows.Add("$Id incomplete closed row: $($Issues -join ', ')")
      continue
    }

    $Closed += 1
  }

  foreach ($ExpectedId in $ExpectedIds) {
    if (-not $SeenIds.Contains($ExpectedId)) {
      $InvalidClosedRows.Add("$ExpectedId missing owner decision row")
    }
  }

  if ($InvalidClosedRows.Count -gt 0) {
    return New-GateResult "owner decisions" "failed" "Invalid closed owner decisions: $($InvalidClosedRows -join '; ')."
  }

  if ($Closed -eq $Rows.Count) {
    return New-EvidenceBoundGateResult "owner decisions" "docs/launch-evidence/owner-decisions.md" "$Closed/$($Rows.Count) owner decisions are closed."
  }

  New-GateResult "owner decisions" "unavailable" "$Closed/$($Rows.Count) owner decisions are closed."
}

function Test-FinalLicense {
  $HasFinalLicense = Test-PathExists "LICENSE"
  $HasTemporaryLicense = Test-PathExists "LICENSE-TBD.md"
  if ($HasFinalLicense -and -not $HasTemporaryLicense) {
    return New-EvidenceBoundGateResult "final license" "docs/launch-evidence/final-license.md" "Final LICENSE exists and temporary license placeholder is absent."
  }

  New-GateResult "final license" "unavailable" "Final LICENSE is not confirmed; LICENSE-TBD.md is still present or LICENSE is missing."
}

function Test-CommunityEntrance {
  $Readme = Join-Path $Root "README.md"
  if (-not (Test-Path -LiteralPath $Readme)) {
    return New-GateResult "community entrance" "failed" "README.md is missing."
  }

  $Content = Get-Content -LiteralPath $Readme -Raw -Encoding UTF8
  if ($Content -match "Community entrance is not confirmed|GitHub Issues until confirmed|community entrance has not been finalized") {
    return New-GateResult "community entrance" "unavailable" "README still uses a temporary community route."
  }

  $SectionMatch = [regex]::Match($Content, "(?s)## Open Source and Community\s*(?<section>.*?)(\r?\n## |\z)")
  if (-not $SectionMatch.Success) {
    return New-GateResult "community entrance" "unavailable" "README has no Open Source and Community section."
  }

  $Section = $SectionMatch.Groups["section"].Value
  $HasOfficialCommunityLink = $Section -match "(?i)https?://|mailto:"
  $HasDiscussionsRoute = $Section -match "(?i)GitHub Discussions|/discussions"
  if ($HasOfficialCommunityLink -or $HasDiscussionsRoute) {
    return New-EvidenceBoundGateResult "community entrance" "docs/launch-evidence/community-entrance.md" "README includes a concrete community route."
  }

  New-GateResult "community entrance" "unavailable" "README community section exists, but no concrete official community route is present."
}

function Test-DemoAsset {
  $Readme = Join-Path $Root "README.md"
  if (-not (Test-Path -LiteralPath $Readme)) {
    return New-GateResult "approved demo asset" "failed" "README.md is missing."
  }

  $Content = Get-Content -LiteralPath $Readme -Raw -Encoding UTF8
  if ($Content -match "PLACEHOLDER|Add the verified product photo|approved product photo") {
    return New-GateResult "approved demo asset" "unavailable" "README still contains the demo asset placeholder."
  }

  $SectionMatch = [regex]::Match($Content, "(?s)## Demo\s*(?<section>.*?)(\r?\n## |\z)")
  if (-not $SectionMatch.Success) {
    return New-GateResult "approved demo asset" "unavailable" "README has no Demo section."
  }

  $Section = $SectionMatch.Groups["section"].Value
  $HasMarkdownMedia = $Section -match '!\[[^\]]*\]\([^)]+\)'
  $HasVideoOrImageLink = $Section -match "(?i)https?://\S*(youtube|youtu\.be|bilibili|vimeo|\.mp4|\.mov|\.gif|\.png|\.jpg|\.jpeg)"
  if ($HasMarkdownMedia -or $HasVideoOrImageLink) {
    return New-EvidenceBoundGateResult "approved demo asset" "docs/launch-evidence/demo-asset.md" "README Demo section contains media."
  }

  New-GateResult "approved demo asset" "unavailable" "README Demo section exists, but no approved media is present."
}

function Test-GitHubAdmin {
  if ($SkipExternal) {
    return New-GateResult "github admin state" "unavailable" "External GitHub admin audit skipped."
  }

  $AuditScript = Join-Path $Root "scripts/audit-github-readiness.ps1"
  if (-not (Test-Path -LiteralPath $AuditScript)) {
    return New-GateResult "github admin state" "failed" "scripts/audit-github-readiness.ps1 is missing."
  }

  Push-Location $Root
  try {
    $Output = powershell -ExecutionPolicy Bypass -File .\scripts\audit-github-readiness.ps1 -Json 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
      return New-GateResult "github admin state" "unavailable" $Output.Trim()
    }

    try {
      $Parsed = $Output | ConvertFrom-Json
    } catch {
      return New-GateResult "github admin state" "unavailable" "Unable to parse GitHub audit output: $($_.Exception.Message)"
    }

    if ($Parsed.api_status -ne "ok") {
      return New-GateResult "github admin state" "unavailable" ($Output.Trim())
    }

    $MissingRemoteContents = @()
    foreach ($Property in $Parsed.remote_contents.PSObject.Properties) {
      if ([string]$Property.Value -ne "present") {
        $MissingRemoteContents += $Property.Name
      }
    }

    $MissingLabels = @($Parsed.missing_labels)
    $BranchProtected = [string]$Parsed.branch_protection -notin @("not_enabled_or_no_permission", "unknown_or_unconfigured", "")
    $HasDiscussions = [bool]$Parsed.has_discussions

    if ($MissingLabels.Count -eq 0 -and $MissingRemoteContents.Count -eq 0 -and $BranchProtected -and $HasDiscussions) {
      return New-EvidenceBoundGateResult "github admin state" "docs/launch-evidence/github-admin.md" "Templates, labels, Discussions, and branch protection look ready remotely."
    }

    return New-GateResult "github admin state" "unavailable" "Remote admin gates remain open: missing_labels=$($MissingLabels.Count), missing_remote_contents=$($MissingRemoteContents.Count), discussions=$HasDiscussions, branch_protection=$($Parsed.branch_protection)."
  } finally {
    Pop-Location
  }
}

function Test-ReleaseManifest {
  if ($SkipExternal) {
    return New-GateResult "release manifest" "unavailable" "External release manifest validation skipped."
  }

  Push-Location $Root
  try {
    $Output = powershell -ExecutionPolicy Bypass -File .\scripts\validate-release-manifest.ps1 2>&1 | Out-String
    if ($LASTEXITCODE -eq 0) {
      return New-EvidenceBoundGateResult "release manifest" "docs/launch-evidence/release-artifacts.md" "Release manifest has real artifact values."
    }

    return New-GateResult "release manifest" "unavailable" $Output.Trim()
  } finally {
    Pop-Location
  }
}

function Test-JavaGradleEvidence {
  $Java = Get-Command java -ErrorAction SilentlyContinue
  $Evidence = Test-EvidenceDocument "java and app gradle" "docs/launch-evidence/app-gradle.md"
  if ($Evidence.status -eq "passed") {
    return $Evidence
  }

  if ($Java) {
    return New-GateResult "java and app gradle" $Evidence.status "Java is available, but App Gradle evidence is not launch-ready: $($Evidence.detail)"
  }

  New-GateResult "java and app gradle" $Evidence.status "Java is not available in PATH and App Gradle evidence is not launch-ready: $($Evidence.detail)"
}

function Test-LaunchEvidenceFile {
  param(
    [string]$Name,
    [string]$RelativePath
  )

  Test-EvidenceDocument $Name $RelativePath
}

$Results = @(
  (Test-OwnerDecisions),
  (Test-FinalLicense),
  (Test-CommunityEntrance),
  (Test-DemoAsset),
  (Test-GitHubAdmin),
  (Test-ReleaseManifest),
  (Test-JavaGradleEvidence),
  (Test-LaunchEvidenceFile "clean-machine validation" "docs/launch-evidence/clean-machine.md"),
  (Test-LaunchEvidenceFile "hardware smoke validation" "docs/launch-evidence/hardware-smoke.md")
)

$Summary = [pscustomobject]@{
  passed = @($Results | Where-Object { $_.status -eq "passed" }).Count
  unavailable = @($Results | Where-Object { $_.status -eq "unavailable" }).Count
  failed = @($Results | Where-Object { $_.status -eq "failed" }).Count
}

$Report = [pscustomobject]@{
  generated_at = (Get-Date).ToString("o")
  score_rule = "Do not claim 100/100 until every launch gate is passed."
  summary = $Summary
  gates = $Results
}

if ($Json) {
  $Report | ConvertTo-Json -Depth 6
} else {
  Write-Host "Open-source launch gate summary"
  Write-Host "Passed: $($Summary.passed)"
  Write-Host "Unavailable: $($Summary.unavailable)"
  Write-Host "Failed: $($Summary.failed)"
  foreach ($Gate in $Results) {
    Write-Host "- [$($Gate.status)] $($Gate.name): $($Gate.detail)"
  }
}

if ($Summary.failed -gt 0) {
  exit 1
}

if ($RequirePassed -and ($Summary.unavailable -gt 0 -or $Summary.failed -gt 0)) {
  exit 2
}
