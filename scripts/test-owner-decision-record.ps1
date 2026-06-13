param(
  [string]$RootPath = ""
)

$ErrorActionPreference = "Stop"
if ($RootPath) {
  $Root = Resolve-Path $RootPath
} else {
  $Root = Resolve-Path (Join-Path $PSScriptRoot "..")
}
$Failures = New-Object System.Collections.Generic.List[string]
$PendingPattern = "(?i)\b(TODO|TBD|PLACEHOLDER|REPLACE_ME|UNKNOWN)\b"

function Add-Failure {
  param([string]$Message)
  $script:Failures.Add($Message)
}

function Get-TableRowsById {
  param(
    [string]$RelativePath,
    [string]$IdPattern
  )

  $Path = Join-Path $Root $RelativePath
  if (-not (Test-Path -LiteralPath $Path)) {
    Add-Failure "Missing file: $RelativePath"
    return @{}
  }

  $RowsById = @{}
  $Lines = Get-Content -LiteralPath $Path -Encoding UTF8
  foreach ($Line in $Lines) {
    if ($Line -notmatch "^\|\s*($IdPattern)\b") {
      continue
    }

    $Id = $Matches[1]
    if ($RowsById.ContainsKey($Id)) {
      Add-Failure "$RelativePath contains duplicate row for $Id"
      continue
    }

    $Cells = @($Line.Trim("|") -split "\|" | ForEach-Object { $_.Trim() })
    $RowsById[$Id] = $Cells
  }

  return $RowsById
}

function Test-ExactIds {
  param(
    [string]$Name,
    [hashtable]$RowsById,
    [string[]]$ExpectedIds
  )

  foreach ($ExpectedId in $ExpectedIds) {
    if (-not $RowsById.ContainsKey($ExpectedId)) {
      Add-Failure "$Name is missing $ExpectedId"
    }
  }

  foreach ($FoundId in $RowsById.Keys) {
    if ($ExpectedIds -notcontains $FoundId) {
      Add-Failure "$Name contains unexpected decision id: $FoundId"
    }
  }
}

function Test-ValidNonFutureDate {
  param([string]$DateValue)

  if ($DateValue -notmatch "^\d{4}-\d{2}-\d{2}$") {
    return "is not yyyy-mm-dd"
  }

  try {
    $ParsedDate = [datetime]::ParseExact($DateValue, "yyyy-MM-dd", [System.Globalization.CultureInfo]::InvariantCulture)
  } catch {
    return "is not a valid calendar date"
  }

  if ($ParsedDate.Date -gt (Get-Date).Date) {
    return "is in the future"
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

$ExpectedIds = 1..9 | ForEach-Object { "OQ-{0:D3}" -f $_ }
$OwnerDecisionPath = "docs/owner-decision-record.md"
$OpenQuestionsPath = "docs/open-questions.md"

$OwnerDecisionFile = Join-Path $Root $OwnerDecisionPath
if (Test-Path -LiteralPath $OwnerDecisionFile) {
  $OwnerDecisionContent = Get-Content -LiteralPath $OwnerDecisionFile -Raw -Encoding UTF8
  foreach ($RequiredHeader in @("Open question", "Decision needed", "Owner", "Final decision", "Evidence / link", "Date", "Status")) {
    if ($OwnerDecisionContent -notmatch [regex]::Escape($RequiredHeader)) {
      Add-Failure "$OwnerDecisionPath is missing required table header: $RequiredHeader"
    }
  }
}

$OwnerRows = Get-TableRowsById -RelativePath $OwnerDecisionPath -IdPattern "OQ-\d{3}"
$OpenQuestionRows = Get-TableRowsById -RelativePath $OpenQuestionsPath -IdPattern "OQ-\d{3}"

Test-ExactIds -Name $OwnerDecisionPath -RowsById $OwnerRows -ExpectedIds $ExpectedIds
Test-ExactIds -Name $OpenQuestionsPath -RowsById $OpenQuestionRows -ExpectedIds $ExpectedIds

foreach ($ExpectedId in $ExpectedIds) {
  if ($OwnerRows.ContainsKey($ExpectedId) -and -not $OpenQuestionRows.ContainsKey($ExpectedId)) {
    Add-Failure "$OwnerDecisionPath references $ExpectedId but $OpenQuestionsPath does not"
  }
  if ($OpenQuestionRows.ContainsKey($ExpectedId) -and -not $OwnerRows.ContainsKey($ExpectedId)) {
    Add-Failure "$OpenQuestionsPath references $ExpectedId but $OwnerDecisionPath does not"
  }
}

foreach ($Id in ($OwnerRows.Keys | Sort-Object)) {
  $Cells = @($OwnerRows[$Id])
  if ($Cells.Count -ne 7) {
    Add-Failure "$OwnerDecisionPath row $Id has $($Cells.Count) cells; expected 7"
    continue
  }

  $OpenQuestion = $Cells[0]
  $DecisionNeeded = $Cells[1]
  $Owner = $Cells[2]
  $FinalDecision = $Cells[3]
  $Evidence = $Cells[4]
  $Date = $Cells[5]
  $Status = $Cells[6]

  if ([string]::IsNullOrWhiteSpace($OpenQuestion) -or $OpenQuestion -notmatch "^$Id\b") {
    Add-Failure "$OwnerDecisionPath row $Id must start with the matching decision id"
  }
  if ([string]::IsNullOrWhiteSpace($DecisionNeeded)) {
    Add-Failure "$OwnerDecisionPath row $Id is missing decision-needed text"
  }
  if ([string]::IsNullOrWhiteSpace($Owner) -or $Owner -match $PendingPattern) {
    Add-Failure "$OwnerDecisionPath row $Id must name an owner role instead of a placeholder"
  }
  if ($Status -notin @("Open", "Closed")) {
    Add-Failure "$OwnerDecisionPath row $Id has invalid status '$Status'; expected Open or Closed"
  }

  if ($Status -eq "Open") {
    if ($FinalDecision -ne "TBD") {
      Add-Failure "$OwnerDecisionPath row $Id is Open but Final decision is not TBD"
    }
    if ($Date -ne "TBD") {
      Add-Failure "$OwnerDecisionPath row $Id is Open but Date is not TBD"
    }
    if ([string]::IsNullOrWhiteSpace($Evidence)) {
      Add-Failure "$OwnerDecisionPath row $Id should point to the evidence or decision guide even while Open"
    }
  }

  if ($Status -eq "Closed") {
    foreach ($NamedValue in @(
      @{ name = "Final decision"; value = $FinalDecision },
      @{ name = "Evidence / link"; value = $Evidence },
      @{ name = "Date"; value = $Date }
    )) {
      if ([string]::IsNullOrWhiteSpace($NamedValue.value) -or $NamedValue.value -match $PendingPattern) {
        Add-Failure "$OwnerDecisionPath row $Id is Closed but $($NamedValue.name) is incomplete"
      }
    }
    $DateIssue = Test-ValidNonFutureDate -DateValue $Date
    if ($DateIssue) {
      Add-Failure "$OwnerDecisionPath row $Id is Closed but Date $DateIssue"
    }
    if (-not (Test-TraceableEvidenceValue -EvidenceValue $Evidence)) {
      Add-Failure "$OwnerDecisionPath row $Id is Closed but Evidence / link is not traceable"
    }
  }
}

if ($Failures.Count -gt 0) {
  Write-Host "Owner decision record tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Owner decision record tests passed."
