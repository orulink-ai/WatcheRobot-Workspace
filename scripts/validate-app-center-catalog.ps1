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

function Get-JsonNumber {
    param(
        [object]$Object,
        [string[]]$Keys
    )

    foreach ($key in $Keys) {
        if ($null -ne $Object.PSObject.Properties[$key]) {
            $value = $Object.PSObject.Properties[$key].Value
            if ($value -is [int] -or $value -is [long] -or $value -is [double]) {
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
        $manifestVersion = Get-JsonNumber $manifest @("manifestVersion", "manifest_version")
        $manifestId = Get-JsonString $manifest @("id", "appId", "app_id")
        $manifestName = Get-JsonString $manifest @("name", "title", "appName")
        $manifestPackageVersion = Get-JsonString $manifest @("version", "fwVersion", "firmwareVersion")
        $signature = $null
        if ($null -ne $manifest.PSObject.Properties["signature"]) {
            $signature = $manifest.PSObject.Properties["signature"].Value
        }

        if ($null -eq $manifestVersion) {
            throw "Package manifest for '$name' is missing manifestVersion/manifest_version: $packagePath"
        }
        if ($id -and $manifestId -and $manifestId -ne $id) {
            throw "Package manifest id '$manifestId' does not match catalog id '$id': $packagePath"
        }
        if (-not $manifestName) {
            throw "Package manifest for '$name' is missing name/title/appName: $packagePath"
        }
        if ($manifestPackageVersion -and $null -ne $app.PSObject.Properties["version"] -and $manifestPackageVersion -ne $app.version) {
            throw "Package manifest version '$manifestPackageVersion' does not match catalog version '$($app.version)': $packagePath"
        }
        if ($null -eq $signature -or $signature -isnot [pscustomobject]) {
            throw "Package manifest for '$name' must declare signature metadata, at least unsigned-dev for local samples: $packagePath"
        }
        $signatureAlgorithm = Get-JsonString $signature @("algorithm", "alg", "type")
        if (-not $signatureAlgorithm) {
            throw "Package manifest for '$name' signature is missing algorithm/alg/type: $packagePath"
        }
    }

    Write-Host "OK app: $name"
}

Write-Host ""
Write-Host "App.Center catalog valid: $appsPath" -ForegroundColor Green
