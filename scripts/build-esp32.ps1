[CmdletBinding()]
param(
    [string]$BuildPath,

    [string]$IdfPath,

    [string]$IdfPythonEnvPath,

    [switch]$WakeWord,

    [switch]$DryRun,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraIdfArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-ExistingPath {
    param(
        [string]$PathValue,
        [string]$BasePath
    )

    if (-not $PathValue) {
        return $null
    }

    if (Test-Path $PathValue) {
        return (Resolve-Path $PathValue).Path
    }

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $BasePath $PathValue))
}

function Test-IdfPythonEnv {
    param([string]$PythonEnvPath)

    $pythonPath = Join-Path $PythonEnvPath "Scripts\python.exe"
    if (-not (Test-Path $pythonPath)) {
        return $false
    }

    & $pythonPath -c "import esp_idf_monitor" 2>$null
    return ($LASTEXITCODE -eq 0)
}

function Resolve-IdfPythonEnvPath {
    param([string]$RequestedPath)

    if ($RequestedPath -and (Test-IdfPythonEnv $RequestedPath)) {
        return (Resolve-Path $RequestedPath).Path
    }

    if ($env:IDF_PYTHON_ENV_PATH -and (Test-IdfPythonEnv $env:IDF_PYTHON_ENV_PATH)) {
        return (Resolve-Path $env:IDF_PYTHON_ENV_PATH).Path
    }

    $preferred = "C:\Espressif\python_env\idf5.2_py3.11_env"
    if (Test-IdfPythonEnv $preferred) {
        return $preferred
    }

    $pythonEnvRoot = "C:\Espressif\python_env"
    if (Test-Path $pythonEnvRoot) {
        $candidate = Get-ChildItem -Path $pythonEnvRoot -Directory -Filter "idf5.2_py*_env" -ErrorAction SilentlyContinue |
            Where-Object { Test-IdfPythonEnv $_.FullName } |
            Sort-Object Name |
            Select-Object -First 1
        if ($candidate) {
            return $candidate.FullName
        }
    }

    return $null
}

function Resolve-IdfPath {
    param(
        [string]$RequestedPath,
        [string]$ProjectPath,
        [string]$ResolvedBuildPath
    )

    if ($RequestedPath -and (Test-Path (Join-Path $RequestedPath "export.ps1"))) {
        return (Resolve-Path $RequestedPath).Path
    }

    if ($env:IDF_PATH -and (Test-Path (Join-Path $env:IDF_PATH "export.ps1"))) {
        return (Resolve-Path $env:IDF_PATH).Path
    }

    foreach ($descriptionPath in @(
        $(if ($ResolvedBuildPath) { Join-Path $ResolvedBuildPath "project_description.json" }),
        (Join-Path $ProjectPath "build-no-wake\project_description.json"),
        (Join-Path $ProjectPath "build\project_description.json")
    )) {
        if ($descriptionPath -and (Test-Path $descriptionPath)) {
            $description = Get-Content $descriptionPath -Raw | ConvertFrom-Json
            if ($description.idf_path -and (Test-Path (Join-Path $description.idf_path "export.ps1"))) {
                return $description.idf_path
            }
        }
    }

    foreach ($candidate in @(
        "C:\Espressif\frameworks\esp-idf-v5.2.1",
        "C:\Espressif\frameworks\esp-idf"
    )) {
        if (Test-Path (Join-Path $candidate "export.ps1")) {
            return $candidate
        }
    }

    throw "ESP-IDF not found. Set -IdfPath or IDF_PATH."
}

function Clear-ProblemIdfRegistryEnv {
    if ($env:IDF_COMPONENT_REGISTRY_URL -like "file:///C:/Espressif/registry*") {
        Remove-Item Env:\IDF_COMPONENT_REGISTRY_URL -ErrorAction SilentlyContinue
    }
    if ($env:IDF_COMPONENT_STORAGE_URL -like "file:///C:/Espressif/registry*") {
        Remove-Item Env:\IDF_COMPONENT_STORAGE_URL -ErrorAction SilentlyContinue
    }
}

$workspaceRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$projectPath = Join-Path $workspaceRoot "WatcheRobot_esp32\firmware\s3"
if (-not (Test-Path (Join-Path $projectPath "CMakeLists.txt"))) {
    throw "ESP32 project not found: $projectPath"
}

$useNoWake = -not $WakeWord
$resolvedBuildPath = Resolve-ExistingPath -PathValue $BuildPath -BasePath $projectPath
if (-not $resolvedBuildPath) {
    $resolvedBuildPath = Join-Path $projectPath $(if ($useNoWake) { "build-no-wake" } else { "build" })
}

$resolvedIdfPath = Resolve-IdfPath -RequestedPath $IdfPath -ProjectPath $projectPath -ResolvedBuildPath $resolvedBuildPath
$resolvedIdfPythonEnvPath = Resolve-IdfPythonEnvPath -RequestedPath $IdfPythonEnvPath
$idfBootstrapScript = Join-Path $resolvedIdfPath "export.ps1"

$buildArgs = @("-B", $resolvedBuildPath)
if ($useNoWake) {
    $sdkconfigPath = Join-Path $projectPath "sdkconfig.no-wake"
    $sdkconfigDefaults = @(
        (Join-Path $projectPath "sdkconfig.defaults"),
        (Join-Path $projectPath "sdkconfig.no-wake.defaults")
    )
    foreach ($path in @($sdkconfigPath) + $sdkconfigDefaults) {
        if (-not (Test-Path $path)) {
            throw "No-wake build config missing: $path"
        }
    }

    $buildArgs += "-D"
    $buildArgs += "SDKCONFIG=$sdkconfigPath"
    $buildArgs += "-D"
    $buildArgs += "SDKCONFIG_DEFAULTS=$($sdkconfigDefaults -join ';')"
}
$buildArgs += "build"
if ($ExtraIdfArgs) {
    $buildArgs += $ExtraIdfArgs
}

Write-Host "Project : $projectPath"
Write-Host "Variant : $(if ($useNoWake) { 'no-wake' } else { 'wake-word' })"
Write-Host "Build   : $resolvedBuildPath"
Write-Host "IDF     : $resolvedIdfPath"
if ($resolvedIdfPythonEnvPath) {
    Write-Host "IDF Py  : $resolvedIdfPythonEnvPath"
}
Write-Host "Command : idf.py $($buildArgs -join ' ')"

if ($DryRun) {
    exit 0
}

Clear-ProblemIdfRegistryEnv

Push-Location $projectPath
try {
    if (-not (Get-Variable -Name IsWindows -ErrorAction SilentlyContinue)) {
        $IsWindows = $true
    }
    $env:IDF_PATH = $resolvedIdfPath
    if ($resolvedIdfPythonEnvPath) {
        $env:IDF_PYTHON_ENV_PATH = $resolvedIdfPythonEnvPath
    }

    . $idfBootstrapScript | Out-Null
    if (-not (Get-Command "idf.py" -ErrorAction SilentlyContinue)) {
        throw "ESP-IDF environment loaded, but idf.py was not found."
    }

    & idf.py @buildArgs
    exit $LASTEXITCODE
} finally {
    Pop-Location
}
