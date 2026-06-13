param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$Failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([string]$Message)
  $script:Failures.Add($Message)
}

function Get-Frontmatter {
  param([string]$Path)

  $Text = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
  if ($Text -notmatch "(?s)^---\s*(?<front>.*?)\s*---\s*(?<body>.*)$") {
    Add-Failure "Template is missing frontmatter: $Path"
    return $null
  }

  $Front = $Matches.front
  $Body = $Matches.body.Trim()
  $Fields = @{}
  foreach ($Line in ($Front -split "`r?`n")) {
    if ($Line -match "^(?<key>[A-Za-z0-9_-]+):\s*`"?(?<value>.*?)`"?\s*$") {
      $Fields[$Matches.key] = $Matches.value.Trim()
    }
  }

  [pscustomobject]@{
    fields = $Fields
    body = $Body
  }
}

function Assert-Section {
  param(
    [string]$Body,
    [string]$Section,
    [string]$FileName
  )

  $Pattern = "(?im)^#+\s*$([regex]::Escape($Section))\s*$"
  if ($Body -notmatch $Pattern) {
    Add-Failure "$FileName is missing section: $Section"
  }
}

$LabelPath = Join-Path $Root ".github/labels.json"
$LabelNames = New-Object "System.Collections.Generic.HashSet[string]"
if (-not (Test-Path -LiteralPath $LabelPath)) {
  Add-Failure "Missing label config: .github/labels.json"
} else {
  $Labels = Get-Content -LiteralPath $LabelPath -Raw -Encoding UTF8 | ConvertFrom-Json
  foreach ($Label in @($Labels)) {
    [void]$LabelNames.Add([string]$Label.name)
  }
}

$TemplateSpecs = @(
  [pscustomobject]@{
    path = ".github/ISSUE_TEMPLATE/bug_report.md"
    label = "bug"
    sections = @("Summary", "Affected Area", "Environment", "Steps to Reproduce", "Expected Result", "Actual Result", "Logs / Screenshots")
  },
  [pscustomobject]@{
    path = ".github/ISSUE_TEMPLATE/feature_request.md"
    label = "feature"
    sections = @("Problem", "Proposed Solution", "Affected Area", "Acceptance Criteria", "Notes")
  },
  [pscustomobject]@{
    path = ".github/ISSUE_TEMPLATE/documentation_feedback.md"
    label = "docs"
    sections = @("Document", "What Was Confusing or Missing?", "Suggested Change", "Did You Try the Steps?", "Environment")
  },
  [pscustomobject]@{
    path = ".github/ISSUE_TEMPLATE/hardware_issue.md"
    label = "hardware"
    sections = @("Hardware Version / Build", "Issue Type", "What Happened?", "What Did You Expect?", "Photos / Logs")
  },
  [pscustomobject]@{
    path = ".github/ISSUE_TEMPLATE/connection_issue.md"
    label = "connection"
    sections = @("Connection Path", "Device State", "Steps", "Expected Result", "Actual Result", "Logs")
  }
)

foreach ($Spec in $TemplateSpecs) {
  $Path = Join-Path $Root $Spec.path
  if (-not (Test-Path -LiteralPath $Path)) {
    Add-Failure "Missing issue template: $($Spec.path)"
    continue
  }

  $Template = Get-Frontmatter -Path $Path
  if (-not $Template) {
    continue
  }

  foreach ($Field in @("name", "about", "labels")) {
    if (-not $Template.fields.ContainsKey($Field) -or [string]::IsNullOrWhiteSpace([string]$Template.fields[$Field])) {
      Add-Failure "$($Spec.path) frontmatter is missing field: $Field"
    }
  }

  $TemplateLabels = @(([string]$Template.fields["labels"]).Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ })
  if ($TemplateLabels -notcontains $Spec.label) {
    Add-Failure "$($Spec.path) must include expected label: $($Spec.label)"
  }
  foreach ($Label in $TemplateLabels) {
    if (-not $LabelNames.Contains($Label)) {
      Add-Failure "$($Spec.path) references unknown label: $Label"
    }
  }

  foreach ($Section in $Spec.sections) {
    Assert-Section -Body $Template.body -Section $Section -FileName $Spec.path
  }
}

$PrTemplatePath = Join-Path $Root ".github/PULL_REQUEST_TEMPLATE.md"
if (-not (Test-Path -LiteralPath $PrTemplatePath)) {
  Add-Failure "Missing PR template: .github/PULL_REQUEST_TEMPLATE.md"
} else {
  $PrBody = Get-Content -LiteralPath $PrTemplatePath -Raw -Encoding UTF8
  foreach ($Section in @("Summary", "Affected Repository / Area", "What Changed", "How It Was Tested", "Cross-Repository Dependencies", "Safety Checklist")) {
    Assert-Section -Body $PrBody -Section $Section -FileName ".github/PULL_REQUEST_TEMPLATE.md"
  }
  foreach ($Phrase in @("Commands or evidence", "No API keys", "TODO/TBD/PLACEHOLDER")) {
    if ($PrBody -notmatch [regex]::Escape($Phrase)) {
      Add-Failure ".github/PULL_REQUEST_TEMPLATE.md is missing phrase: $Phrase"
    }
  }
}

if ($Failures.Count -gt 0) {
  Write-Host "GitHub template tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "GitHub template tests passed."
