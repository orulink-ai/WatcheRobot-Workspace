param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")

function Invoke-ExampleDryRun {
  param(
    [string]$Name,
    [string[]]$Arguments,
    [scriptblock]$Validate
  )

  Push-Location $Root
  try {
    $Output = & python @Arguments 2>&1
    $ExitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
    $Text = ($Output | Out-String).Trim()
    if ($ExitCode -ne 0) {
      throw "$Name failed with exit code $ExitCode. Output: $Text"
    }

    & $Validate $Text
    Write-Host "$Name passed."
  } finally {
    Pop-Location
  }
}

Invoke-ExampleDryRun `
  -Name "BLE ping dry run" `
  -Arguments @("examples\ble-control-minimal\ble_control_minimal.py", "--command", "ping", "--dry-run") `
  -Validate {
    param([string]$Text)
    $Payload = $Text | ConvertFrom-Json
    if ($Payload.type -ne "sys.ping") {
      throw "Expected sys.ping payload, got: $Text"
    }
  }

Invoke-ExampleDryRun `
  -Name "BLE servo dry run" `
  -Arguments @("examples\ble-control-minimal\ble_control_minimal.py", "--command", "servo-x", "--angle", "90", "--dry-run") `
  -Validate {
    param([string]$Text)
    $Payload = $Text | ConvertFrom-Json
    if ($Payload.type -ne "ctrl.servo.angle" -or $Payload.data.x_deg -ne 90) {
      throw "Expected servo-x 90 payload, got: $Text"
    }
  }

Invoke-ExampleDryRun `
  -Name "BLE AI status dry run" `
  -Arguments @("examples\ble-control-minimal\ble_control_minimal.py", "--command", "ai-status", "--status", "happy", "--dry-run") `
  -Validate {
    param([string]$Text)
    $Payload = $Text | ConvertFrom-Json
    if ($Payload.type -ne "evt.ai.status" -or $Payload.data.status -ne "happy") {
      throw "Expected evt.ai.status happy payload, got: $Text"
    }
  }

Invoke-ExampleDryRun `
  -Name "AI reminder dry run" `
  -Arguments @("examples\ai-reminder-minimal\ai_reminder_minimal.py", "--dry-run") `
  -Validate {
    param([string]$Text)
    $Request = $Text | ConvertFrom-Json
    if ($Request.url -ne "http://127.0.0.1:8766/api/admin/scheduled-intents") {
      throw "Unexpected reminder URL, got: $Text"
    }
    if ($Request.payload.text -ne "Remind me to drink water in one minute") {
      throw "Unexpected reminder text, got: $Text"
    }
  }

Write-Host "Open-source example dry-run checks passed."
