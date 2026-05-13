[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Port,

    [string]$DeviceAlias = "esp32-s3",

    [string]$DeviceMapPath,

    [switch]$NoBuild,

    [switch]$Monitor,

    [switch]$DryRun,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "device-map.ps1")

$workspaceRoot = Get-WatcheWorkspaceRoot
$esp32Project = Join-Path $workspaceRoot "WatcheRobot_esp32\firmware\s3"
$flashScript = Join-Path $esp32Project "tools\flash-monitor.ps1"

if (-not (Test-Path $flashScript)) {
    throw "ESP32 flash script not found: $flashScript"
}

$resolvedDeviceMapPath = Get-WatcheDeviceMapPath -WorkspaceRoot $workspaceRoot -DeviceMapPath $DeviceMapPath

$argsList = @(
    "-NoProfile",
    "-ExecutionPolicy",
    "Bypass",
    "-File",
    $flashScript
)

if ($Port) {
    $argsList += $Port
} else {
    $argsList += "-DeviceAlias"
    $argsList += $DeviceAlias
    $argsList += "-DeviceMapPath"
    $argsList += $resolvedDeviceMapPath
}

if ($NoBuild) {
    $argsList += "-NoBuild"
}

if (-not $Monitor) {
    $argsList += "-NoMonitor"
}

if ($DryRun) {
    $argsList += "-DryRun"
}

if ($ExtraArgs) {
    $argsList += $ExtraArgs
}

Write-Host "Project : $esp32Project"
if ($Port) {
    Write-Host "Port    : $Port"
} else {
    Write-Host "Device  : $DeviceAlias"
    Write-Host "Map     : $resolvedDeviceMapPath"
}
Write-Host "Monitor : $([bool]$Monitor)"

& powershell @argsList
exit $LASTEXITCODE
