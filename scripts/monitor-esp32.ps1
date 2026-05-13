[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Port,

    [string]$DeviceAlias = "esp32-s3",

    [string]$DeviceMapPath,

    [int]$Baud = 115200,

    [string]$BuildPath,

    [switch]$Raw,

    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "device-map.ps1")

function Resolve-ProjectDescriptionPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResolvedProjectPath,

        [string]$ResolvedBuildPath
    )

    if ($ResolvedBuildPath) {
        $candidate = Join-Path $ResolvedBuildPath "project_description.json"
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    $defaultCandidate = Join-Path $ResolvedProjectPath "build\project_description.json"
    if (Test-Path $defaultCandidate) {
        return $defaultCandidate
    }

    return $null
}

function Resolve-IdfPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResolvedProjectPath,

        [string]$ResolvedBuildPath
    )

    if ($env:IDF_PATH -and (Test-Path $env:IDF_PATH)) {
        return $env:IDF_PATH
    }

    $projectDescriptionPath = Resolve-ProjectDescriptionPath -ResolvedProjectPath $ResolvedProjectPath -ResolvedBuildPath $ResolvedBuildPath
    if ($projectDescriptionPath) {
        $projectDescription = Get-Content $projectDescriptionPath -Raw | ConvertFrom-Json
        if ($projectDescription.idf_path -and (Test-Path $projectDescription.idf_path)) {
            return $projectDescription.idf_path
        }
    }

    $fallbacks = @(
        "C:\Espressif\frameworks\esp-idf-v5.2.1",
        "C:\Espressif\frameworks\esp-idf"
    )

    foreach ($candidate in $fallbacks) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    throw "ESP-IDF not found. Set IDF_PATH or build the ESP32 project once."
}

function Resolve-IdfPythonEnvPath {
    if ($env:IDF_PYTHON_ENV_PATH -and (Test-Path (Join-Path $env:IDF_PYTHON_ENV_PATH "Scripts\python.exe"))) {
        return $env:IDF_PYTHON_ENV_PATH
    }

    $preferred = "C:\Espressif\python_env\idf5.2_py3.11_env"
    if (Test-Path (Join-Path $preferred "Scripts\python.exe")) {
        return $preferred
    }

    $pythonEnvRoot = "C:\Espressif\python_env"
    if (Test-Path $pythonEnvRoot) {
        $candidate = Get-ChildItem -Path $pythonEnvRoot -Directory -Filter "idf5.2_py*_env" -ErrorAction SilentlyContinue |
            Where-Object { Test-Path (Join-Path $_.FullName "Scripts\python.exe") } |
            Sort-Object Name |
            Select-Object -First 1
        if ($candidate) {
            return $candidate.FullName
        }
    }

    return $null
}

function Resolve-IdfBootstrapScript {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResolvedIdfPath
    )

    $exportScript = Join-Path $ResolvedIdfPath "export.ps1"
    if (Test-Path $exportScript) {
        return $exportScript
    }

    $installRoot = Split-Path -Parent (Split-Path -Parent $ResolvedIdfPath)
    $initializeScript = Join-Path $installRoot "Initialize-Idf.ps1"
    if (Test-Path $initializeScript) {
        return $initializeScript
    }

    throw "ESP-IDF bootstrap script not found. Checked: $initializeScript, $exportScript"
}

$workspaceRoot = Get-WatcheWorkspaceRoot
$esp32Project = Join-Path $workspaceRoot "WatcheRobot_esp32\firmware\s3"
$resolvedPort = Resolve-WatcheDevicePort -Port $Port `
    -Alias $DeviceAlias `
    -Firmware "s3" `
    -DeviceMapPath $DeviceMapPath `
    -WorkspaceRoot $workspaceRoot

Write-Host "Device  : $DeviceAlias"

if ($Raw) {
    Start-WatcheSerialMonitor -Port $resolvedPort -Baud $Baud -DryRun:$DryRun
    exit $LASTEXITCODE
}

$resolvedProjectPath = (Resolve-Path $esp32Project).Path
$resolvedBuildPath = $null
if ($BuildPath) {
    if (Test-Path $BuildPath) {
        $resolvedBuildPath = (Resolve-Path $BuildPath).Path
    } elseif ([System.IO.Path]::IsPathRooted($BuildPath)) {
        $resolvedBuildPath = [System.IO.Path]::GetFullPath($BuildPath)
    } else {
        $resolvedBuildPath = [System.IO.Path]::GetFullPath((Join-Path $resolvedProjectPath $BuildPath))
    }
}

$idfPath = Resolve-IdfPath -ResolvedProjectPath $resolvedProjectPath -ResolvedBuildPath $resolvedBuildPath
$idfBootstrapScript = Resolve-IdfBootstrapScript -ResolvedIdfPath $idfPath
$idfPythonEnvPath = Resolve-IdfPythonEnvPath

$monitorArgs = @()
if ($resolvedBuildPath) {
    $monitorArgs += "-B"
    $monitorArgs += $resolvedBuildPath
}
$monitorArgs += "-p"
$monitorArgs += $resolvedPort
$monitorArgs += "monitor"
$monitorArgs += "--force-color"

Write-Host "Project : $resolvedProjectPath"
if ($resolvedBuildPath) {
    Write-Host "Build   : $resolvedBuildPath"
}
Write-Host "IDF     : $idfPath"
if ($idfPythonEnvPath) {
    Write-Host "IDF Py  : $idfPythonEnvPath"
}
Write-Host "Port    : $resolvedPort"
Write-Host "Monitor : idf.py $($monitorArgs -join ' ')"

if ($DryRun) {
    exit 0
}

Push-Location $resolvedProjectPath
try {
    if (-not (Get-Variable -Name IsWindows -ErrorAction SilentlyContinue)) {
        $IsWindows = $true
    }
    $env:IDF_PATH = $idfPath
    if ($idfPythonEnvPath) {
        $env:IDF_PYTHON_ENV_PATH = $idfPythonEnvPath
    }
    . $idfBootstrapScript | Out-Null
    if (-not (Get-Command "idf.py" -ErrorAction SilentlyContinue)) {
        throw "ESP-IDF environment loaded, but idf.py was not found."
    }

    & idf.py @monitorArgs
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
