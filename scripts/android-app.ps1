[CmdletBinding()]
param(
    [string]$Device,
    [switch]$NoLaunch
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent $PSScriptRoot
$appRoot = Join-Path $workspaceRoot "WatcheRobot_app"
$androidRoot = Join-Path $appRoot "android"
$gradlew = Join-Path $androidRoot "gradlew.bat"
$packageName = "com.watcherrobotapp.debug"

if (-not (Test-Path $gradlew)) {
    throw "Android Gradle wrapper not found: $gradlew"
}

if (-not (Test-Path (Join-Path $appRoot "node_modules\.bin\react-native.cmd"))) {
    Write-Host "Dependencies missing; running yarn install in WatcheRobot_app..."
    & yarn --cwd $appRoot install
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

if (-not $Device) {
    $devices = @(
        adb devices |
            Select-String "^\S+\s+device$" |
            ForEach-Object { ($_.Line -split "\s+")[0] }
    )

    if ($devices.Count -eq 0) {
        throw "No online Android device found. Connect a phone or start an emulator, then run yarn android again."
    }

    $Device = $devices[0]
    if ($devices.Count -gt 1) {
        Write-Host "Multiple Android devices online; using $Device. Pass -Device <serial> to override."
    }
}

Write-Host "Project : $appRoot"
Write-Host "Device  : $Device"
Write-Host "Install : gradlew app:installDebug"

Push-Location $androidRoot
try {
    & $gradlew "app:installDebug"
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
finally {
    Pop-Location
}

adb -s $Device reverse tcp:8081 tcp:8081 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Warning "adb reverse tcp:8081 failed; the app may not reach Metro over USB."
}

if (-not $NoLaunch) {
    Write-Host "Launch  : $packageName"
    adb -s $Device shell monkey -p $packageName -c android.intent.category.LAUNCHER 1
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
