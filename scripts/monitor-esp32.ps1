[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Port,

    [string]$DeviceAlias = "esp32-s3",

    [string]$DeviceMapPath,

    [int]$Baud = 115200,

    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "device-map.ps1")

$workspaceRoot = Get-WatcheWorkspaceRoot
$resolvedPort = Resolve-WatcheDevicePort -Port $Port `
    -Alias $DeviceAlias `
    -Firmware "s3" `
    -DeviceMapPath $DeviceMapPath `
    -WorkspaceRoot $workspaceRoot

Write-Host "Device  : $DeviceAlias"
Start-WatcheSerialMonitor -Port $resolvedPort -Baud $Baud -DryRun:$DryRun
