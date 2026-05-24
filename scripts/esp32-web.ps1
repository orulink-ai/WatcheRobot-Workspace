param(
    [int]$Port = 5175,
    [string]$HostName = "127.0.0.1",
    [switch]$Install,
    [switch]$NoOpen,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$consoleRoot = Join-Path $repoRoot "WatcheRobot_esp32\tools\esp32-debug-console"
$packageJson = Join-Path $consoleRoot "package.json"
$nodeModules = Join-Path $consoleRoot "node_modules"
$viteBin = Join-Path $consoleRoot "node_modules\.bin\vite.cmd"

if (-not (Test-Path -LiteralPath $packageJson)) {
    throw "ESP32 debug console is missing: $packageJson"
}

Push-Location $consoleRoot
try {
    $viteArgs = @("--host", $HostName, "--port", "$Port")
    if (-not $NoOpen) {
        $viteArgs += "--open"
    }

    if ($DryRun) {
        Write-Host "Console root: $consoleRoot"
        Write-Host "Would start: $viteBin $($viteArgs -join ' ')"
        return
    }

    if ($Install -or -not (Test-Path -LiteralPath $nodeModules)) {
        Write-Host "Installing ESP32 debug console dependencies..."
        npm install
    }

    if (-not (Test-Path -LiteralPath $viteBin)) {
        Write-Host "Vite executable not found; installing dependencies..."
        npm install
    }

    Write-Host "Starting ESP32 debug console: http://${HostName}:$Port"
    & $viteBin @viteArgs
}
finally {
    Pop-Location
}
