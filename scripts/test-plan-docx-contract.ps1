param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$Failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([string]$Message)
  $script:Failures.Add($Message)
}

function Get-DocxText {
  param([string]$RelativePath)

  $Path = Join-Path $Root $RelativePath
  if (-not (Test-Path -LiteralPath $Path)) {
    Add-Failure "Missing file: $RelativePath"
    return ""
  }

  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $Archive = [System.IO.Compression.ZipFile]::OpenRead($Path)
  try {
    $TextParts = New-Object System.Collections.Generic.List[string]
    foreach ($Entry in $Archive.Entries | Where-Object { $_.FullName -match "^word/.*\.xml$" }) {
      $Reader = New-Object System.IO.StreamReader($Entry.Open(), [System.Text.Encoding]::UTF8)
      try {
        $Xml = $Reader.ReadToEnd()
      } finally {
        $Reader.Dispose()
      }

      foreach ($Match in [regex]::Matches($Xml, '<w:t[^>]*>(.*?)</w:t>')) {
        $TextParts.Add([System.Net.WebUtility]::HtmlDecode($Match.Groups[1].Value))
      }
    }

    return ($TextParts -join "")
  } finally {
    $Archive.Dispose()
  }
}

function Assert-Contains {
  param(
    [string]$Content,
    [string]$Needle,
    [string]$Context
  )

  if (-not $Content.Contains($Needle)) {
    Add-Failure "$Context is missing required text: $Needle"
  }
}

function Assert-DoesNotContain {
  param(
    [string]$Content,
    [string]$Needle,
    [string]$Context
  )

  if ($Content.Contains($Needle)) {
    Add-Failure "$Context contains outdated text: $Needle"
  }
}

$DocxItem = Get-ChildItem -LiteralPath $Root -Filter "*.docx" -File |
  Where-Object { $_.Name -like "*Codex*" -and $_.Name -like "*Sub-Agent*" } |
  Select-Object -First 1

if (-not $DocxItem) {
  Add-Failure "Missing reference plan docx matching *Codex*Sub-Agent*.docx"
  $DocxRelativePath = ""
  $DocxText = ""
} else {
  $DocxRelativePath = $DocxItem.Name
  $DocxText = Get-DocxText $DocxRelativePath
}

foreach ($RequiredText in @(
  'WatcheRobot',
  'Target Table /',
  'Todo List /',
  'WOS-01',
  'WOS-45',
  'docs/product-name-policy.md',
  'scripts/test-product-name-policy.ps1',
  'scripts/test-readiness-score-contract.ps1',
  'docs/launch-gate-closeout-plan.md',
  'scripts/test-launch-gate-closeout-plan.ps1',
  'scripts/audit-publication-hygiene.ps1',
  'scripts/test-publication-hygiene.ps1',
  'docs/sub-agent-work-orders/README.md',
  'scripts/test-sub-agent-work-orders.ps1',
  'scripts/test-wos-evidence-trace.ps1',
  'scripts/audit-markdown-links.ps1',
  'scripts/test-markdown-link-audit.ps1',
  'scripts/test-evidence-collector-coverage.ps1',
  'scripts/audit-docx-render-prerequisites.ps1',
  'scripts/test-docx-render-prerequisites-audit.ps1',
  'DOCX render prerequisites are either available',
  'Launch gate evidence-bound',
  'owner/date/environment/evidence/result/follow-up',
  'traceable source marker',
  'owner decision traceable evidence',
  'no pending tokens',
  'scripts/test-open-source-launch-gates.ps1',
  'docs/launch-evidence/*.md',
  'non-future launch evidence date',
  'owner decision non-future date',
  'root docx staging',
  'Final evidence refresh and self-score'
)) {
  Assert-Contains -Content $DocxText -Needle $RequiredText -Context $DocxRelativePath
}

foreach ($ForbiddenText in @(
  'Watcherobot'
)) {
  Assert-DoesNotContain -Content $DocxText -Needle $ForbiddenText -Context $DocxRelativePath
}

if ($Failures.Count -gt 0) {
  Write-Host "Plan docx contract tests failed:"
  foreach ($Failure in $Failures) {
    Write-Host "  - $Failure"
  }
  exit 1
}

Write-Host "Plan docx contract tests passed."
