[CmdletBinding()]
param(
    [ValidateSet("auto", "cube", "openocd")]
    [string]$Tool = "auto",

    [string]$Preset = "Debug",

    [switch]$NoBuild,

    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "device-map.ps1")

function Resolve-Stm32ProgrammerCli {
    if ($env:STM32_PROGRAMMER_CLI -and (Test-Path $env:STM32_PROGRAMMER_CLI)) {
        return (Resolve-Path $env:STM32_PROGRAMMER_CLI).Path
    }

    $command = Get-Command STM32_Programmer_CLI.exe -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $bundleRoot = Join-Path $env:LOCALAPPDATA "stm32cube\bundles\programmer"
    if (Test-Path $bundleRoot) {
        $candidate = Get-ChildItem -Path $bundleRoot -Recurse -Filter STM32_Programmer_CLI.exe -File -ErrorAction SilentlyContinue |
            Sort-Object FullName -Descending |
            Select-Object -First 1
        if ($candidate) {
            return $candidate.FullName
        }
    }

    return $null
}

function Resolve-OpenOcd {
    if ($env:OPENOCD -and (Test-Path $env:OPENOCD)) {
        return (Resolve-Path $env:OPENOCD).Path
    }

    $command = Get-Command openocd.exe -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $candidates = @()
    $arduinoRoot = Join-Path $env:LOCALAPPDATA "Arduino15\packages"
    if (Test-Path $arduinoRoot) {
        $candidates += Get-ChildItem -Path $arduinoRoot -Recurse -Filter openocd.exe -File -ErrorAction SilentlyContinue
    }

    $candidate = $candidates | Sort-Object FullName -Descending | Select-Object -First 1
    if ($candidate) {
        return $candidate.FullName
    }

    return $null
}

$workspaceRoot = Get-WatcheWorkspaceRoot
$stm32Root = Join-Path $workspaceRoot "WatcheRobot_stm32"
$firmwareBin = Join-Path $stm32Root "build\$Preset\watcheRobot_STM32.bin"

if (-not (Test-Path $stm32Root)) {
    throw "STM32 repository not found: $stm32Root"
}

$programmer = Resolve-Stm32ProgrammerCli
$openocd = Resolve-OpenOcd
$selectedTool = $Tool

if ($selectedTool -eq "auto") {
    if ($programmer) {
        $selectedTool = "cube"
    } elseif ($openocd) {
        $selectedTool = "openocd"
    } else {
        throw "No STM32 flash tool found. Install STM32CubeProgrammer or OpenOCD."
    }
}

if ($selectedTool -eq "cube" -and -not $programmer) {
    throw "STM32CubeProgrammer CLI not found. Set STM32_PROGRAMMER_CLI or install STM32CubeProgrammer."
}

if ($selectedTool -eq "openocd" -and -not $openocd) {
    throw "OpenOCD not found. Set OPENOCD or install OpenOCD."
}

Write-Host "Project : $stm32Root"
Write-Host "Preset  : $Preset"
Write-Host "Tool    : $selectedTool"
if ($selectedTool -eq "cube") {
    Write-Host "CLI     : $programmer"
} else {
    Write-Host "OpenOCD : $openocd"
}
Write-Host "Binary  : $firmwareBin"

if (-not $NoBuild) {
    Write-Host "Build   : cmake --preset $Preset; cmake --build --preset $Preset"
}

if ($selectedTool -eq "cube") {
    Write-Host "Flash   : STM32_Programmer_CLI -c port=SWD mode=UR -w build/$Preset/watcheRobot_STM32.bin 0x08000000 -v -rst"
} else {
    Write-Host "Flash   : openocd -f interface/stlink.cfg -f target/stm32f1x.cfg -c `"program build/$Preset/watcheRobot_STM32.bin verify reset exit 0x08000000`""
}

if ($DryRun) {
    exit 0
}

Push-Location $stm32Root
try {
    if (-not $NoBuild) {
        & cmake --preset $Preset
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }

        & cmake --build --preset $Preset
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }
    }

    if (-not (Test-Path $firmwareBin)) {
        throw "Firmware binary not found: $firmwareBin"
    }

    if ($selectedTool -eq "cube") {
        & $programmer -c "port=SWD" "mode=UR" -w $firmwareBin "0x08000000" -v -rst
        exit $LASTEXITCODE
    }

    $relativeBin = "build/$Preset/watcheRobot_STM32.bin"
    & $openocd -f "interface/stlink.cfg" -f "target/stm32f1x.cfg" -c "program $relativeBin verify reset exit 0x08000000"
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
