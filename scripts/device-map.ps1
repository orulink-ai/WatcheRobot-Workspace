[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-WatcheWorkspaceRoot {
    [CmdletBinding()]
    param(
        [string]$StartPath = $PSScriptRoot
    )

    $current = (Resolve-Path $StartPath).Path
    while ($true) {
        if ((Test-Path (Join-Path $current "WatcheRobot_esp32")) -and
            (Test-Path (Join-Path $current "WatcheRobot_stm32")) -and
            (Test-Path (Join-Path $current "AGENTS.md"))) {
            return $current
        }

        $parent = Split-Path -Parent $current
        if (-not $parent -or $parent -eq $current) {
            break
        }

        $current = $parent
    }

    throw "Workspace root not found. Run from inside watcheRobot_Firmware."
}

function Get-WatcheDeviceMapPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspaceRoot,

        [string]$DeviceMapPath
    )

    if ($DeviceMapPath) {
        if ([System.IO.Path]::IsPathRooted($DeviceMapPath)) {
            return [System.IO.Path]::GetFullPath($DeviceMapPath)
        }

        return [System.IO.Path]::GetFullPath((Join-Path $WorkspaceRoot $DeviceMapPath))
    }

    if ($env:CODEX_DEVICE_MAP_PATH) {
        if ([System.IO.Path]::IsPathRooted($env:CODEX_DEVICE_MAP_PATH)) {
            return [System.IO.Path]::GetFullPath($env:CODEX_DEVICE_MAP_PATH)
        }

        return [System.IO.Path]::GetFullPath((Join-Path $WorkspaceRoot $env:CODEX_DEVICE_MAP_PATH))
    }

    return Join-Path $WorkspaceRoot ".codex\local\device-map.toml"
}

function Read-WatcheDeviceMap {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        $example = Join-Path (Get-WatcheWorkspaceRoot) ".codex\device-map.example.toml"
        throw "Device map file not found: $Path. Copy $example to .codex\local\device-map.toml and edit local COM ports."
    }

    $devices = @{}
    $currentAlias = $null
    $lineNumber = 0

    foreach ($rawLine in [System.IO.File]::ReadLines($Path)) {
        $lineNumber += 1
        $line = $rawLine.Trim()

        if (-not $line -or $line.StartsWith("#")) {
            continue
        }

        if ($line -match '^\[(?<section>[^\]]+)\]$') {
            $section = $Matches.section
            if ($section -match '^devices\.(?<alias>[A-Za-z0-9._-]+)$') {
                $currentAlias = $Matches.alias
                if (-not $devices.ContainsKey($currentAlias)) {
                    $devices[$currentAlias] = @{}
                }
            } else {
                $currentAlias = $null
            }
            continue
        }

        if (-not $currentAlias) {
            continue
        }

        if ($line -notmatch '^(?<key>[A-Za-z0-9_-]+)\s*=\s*"(?<value>[^"]*)"\s*$') {
            throw "Device map parse error: ${Path}:$lineNumber -> $rawLine"
        }

        $devices[$currentAlias][$Matches.key] = $Matches.value
    }

    return $devices
}

function Resolve-WatcheDevicePort {
    [CmdletBinding()]
    param(
        [string]$Port,

        [Parameter(Mandatory = $true)]
        [string]$Alias,

        [string]$Firmware,

        [string]$DeviceMapPath,

        [string]$WorkspaceRoot = (Get-WatcheWorkspaceRoot)
    )

    if ($Port) {
        if ($Port -match '^COM\d+$') {
            return $Port.ToUpperInvariant()
        }

        return $Port
    }

    $mapPath = Get-WatcheDeviceMapPath -WorkspaceRoot $WorkspaceRoot -DeviceMapPath $DeviceMapPath
    $resolvedMapPath = $mapPath
    if (Test-Path $mapPath) {
        $resolvedMapPath = (Resolve-Path $mapPath).Path
    }

    $devices = Read-WatcheDeviceMap -Path $resolvedMapPath
    if (-not $devices.ContainsKey($Alias)) {
        throw "Alias '$Alias' not found in device map: $resolvedMapPath"
    }

    $entry = $devices[$Alias]
    $mappedFirmware = [string]$entry["firmware"]
    $mappedPort = [string]$entry["port"]

    if ($Firmware -and $mappedFirmware -and $mappedFirmware -ne $Firmware) {
        throw "Alias '$Alias' has firmware=$mappedFirmware, expected firmware=$Firmware."
    }

    if (-not $mappedPort) {
        throw "Alias '$Alias' is missing port in device map: $resolvedMapPath"
    }

    return $mappedPort.ToUpperInvariant()
}

function Get-WatchePython {
    [CmdletBinding()]
    param()

    $python = Get-Command python -ErrorAction SilentlyContinue
    if ($python) {
        return $python.Source
    }

    throw "python was not found on PATH. Install Python or add it to PATH."
}

function Start-WatcheSerialMonitor {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Port,

        [Parameter(Mandatory = $true)]
        [int]$Baud,

        [switch]$DryRun
    )

    $python = Get-WatchePython
    & $python -c "import serial, serial.tools.miniterm" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "pyserial is not available for $python. Install it with: python -m pip install pyserial"
    }

    Write-Host "Port    : $Port"
    Write-Host "Baud    : $Baud"
    Write-Host "Monitor : python -m serial.tools.miniterm $Port $Baud"

    if ($DryRun) {
        return
    }

    & $python -m serial.tools.miniterm $Port $Baud
    exit $LASTEXITCODE
}
