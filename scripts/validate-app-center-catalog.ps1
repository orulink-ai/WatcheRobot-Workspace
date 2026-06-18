param(
    [string]$CatalogDir = "WatcheRobot_esp32\firmware\s3\app_center_sample"
)

$ErrorActionPreference = "Stop"

$workspaceRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$resolvedCatalogDir = if ([System.IO.Path]::IsPathRooted($CatalogDir)) {
    [System.IO.Path]::GetFullPath($CatalogDir)
} else {
    [System.IO.Path]::GetFullPath((Join-Path $workspaceRoot $CatalogDir))
}

$appsPath = Join-Path $resolvedCatalogDir "apps.json"
if (-not (Test-Path -LiteralPath $appsPath)) {
    throw "apps.json not found: $appsPath"
}

function Read-JsonFile {
    param([string]$Path)

    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    } catch {
        throw "Invalid JSON: $Path`n$($_.Exception.Message)"
    }
}

function Get-JsonString {
    param(
        [object]$Object,
        [string[]]$Keys
    )

    foreach ($key in $Keys) {
        if ($null -ne $Object.PSObject.Properties[$key]) {
            $value = $Object.PSObject.Properties[$key].Value
            if ($value -is [string] -and -not [string]::IsNullOrWhiteSpace($value)) {
                return $value
            }
        }
    }
    return $null
}

$catalog = Read-JsonFile $appsPath
$apps = $null
if ($catalog -is [array]) {
    $apps = $catalog
} elseif ($null -ne $catalog.PSObject.Properties["apps"]) {
    $apps = $catalog.apps
} elseif ($null -ne $catalog.PSObject.Properties["data"]) {
    $apps = $catalog.data
}

if ($null -eq $apps) {
    throw "apps.json must be an array or an object with apps/data array."
}
if ($apps -isnot [array]) {
    $apps = @($apps)
}
if ($apps.Count -eq 0) {
    throw "apps.json contains no apps."
}

$ids = @{}
$names = @{}
$localIds = @(
    "launcher",
    "basic",
    "ble.app",
    "client.app",
    "voice.app",
    "provision.app",
    "app.center"
)
$localNames = @(
    "Launcher",
    "Basic",
    "BLE App",
    "Bluetooth App",
    "Client App",
    "Voice App",
    "Provision App",
    "App.Center",
    "蓝牙 App",
    "客户端 App",
    "语音 App",
    "配网 App"
)

foreach ($app in $apps) {
    $id = Get-JsonString $app @("id", "appId", "key")
    $name = Get-JsonString $app @("name", "appName", "title")
    $packageUrl = Get-JsonString $app @("packageUrl", "downloadUrl", "appUrl", "url")

    if (-not $name) {
        throw "App entry is missing name/appName/title."
    }
    if (-not $packageUrl) {
        throw "App '$name' is missing packageUrl/downloadUrl/appUrl/url."
    }
    if ($id -and $localIds -contains $id) {
        throw "App '$name' uses local Launcher app id '$id'. Local apps must not be listed in App.Center."
    }
    if ($localNames -contains $name) {
        throw "App '$name' is a local Launcher app name. Local apps must not be listed in App.Center."
    }
    if ($id) {
        if ($ids.ContainsKey($id)) {
            throw "Duplicate app id: $id"
        }
        $ids[$id] = $true
    }
    if ($names.ContainsKey($name)) {
        throw "Duplicate app name: $name"
    }
    $names[$name] = $true

    if ($packageUrl -notmatch "^https?://") {
        $packagePath = Join-Path $resolvedCatalogDir $packageUrl
        if (-not (Test-Path -LiteralPath $packagePath)) {
            throw "App '$name' relative packageUrl not found: $packagePath"
        }

        $manifest = Read-JsonFile $packagePath
        $manifestName = Get-JsonString $manifest @("name", "title", "appName")
        if (-not $manifestName) {
            throw "Package manifest for '$name' is missing name/title/appName: $packagePath"
        }
    }

    Write-Host "OK app: $name"
}

Write-Host ""
Write-Host "App.Center catalog valid: $appsPath" -ForegroundColor Green
