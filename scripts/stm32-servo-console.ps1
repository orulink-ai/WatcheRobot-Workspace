param(
    [int]$Port = 5174,
    [string]$HostName = "127.0.0.1",
    [switch]$Install,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$consoleRoot = Join-Path $repoRoot "WatcheRobot_stm32\Tools\servo-motion-console"
$packageJson = Join-Path $consoleRoot "package.json"
$nodeModules = Join-Path $consoleRoot "node_modules"
$viteBin = Join-Path $consoleRoot "node_modules\.bin\vite.cmd"

if (-not (Test-Path -LiteralPath $packageJson)) {
    throw "STM32 debug web page is missing: $packageJson"
}

Push-Location $consoleRoot
try {
    if ($DryRun) {
        Write-Host "STM32 web root: $consoleRoot"
        Write-Host "Would start: $viteBin --host $HostName --port $Port"
        return
    }

    if ($Install -or -not (Test-Path -LiteralPath $nodeModules)) {
        Write-Host "Installing STM32 debug web page dependencies..."
        npm install
    }

    if (-not (Test-Path -LiteralPath $viteBin)) {
        Write-Host "Vite executable not found; installing dependencies..."
        npm install
    }

    Write-Host "Starting STM32 debug web page: http://${HostName}:$Port"
    & $viteBin --host $HostName --port $Port
}
finally {
    Pop-Location
}
