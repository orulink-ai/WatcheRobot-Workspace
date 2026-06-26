param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Url,

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Assert-AppCenterUrl {
    param([string]$Value)

    $uri = $null
    if (-not [System.Uri]::TryCreate($Value, [System.UriKind]::Absolute, [ref]$uri)) {
        throw "Invalid App.Center URL: $Value"
    }
    if ($uri.Scheme -ne "http" -and $uri.Scheme -ne "https") {
        throw "App.Center URL must use http or https: $Value"
    }
    if ([string]::IsNullOrWhiteSpace($uri.Host)) {
        throw "App.Center URL must include a host: $Value"
    }
    if (-not $uri.AbsolutePath.EndsWith("/apps.json")) {
        throw "App.Center URL should point to apps.json: $Value"
    }
}

function Set-KconfigString {
    param(
        [string]$Path,
        [string]$Key,
        [string]$Value
    )

    $line = "$Key=`"$Value`""

    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }

    $content = Get-Content -LiteralPath $Path -Raw
    if ($content -match "(?m)^$([regex]::Escape($Key))=.*$") {
        $content = [regex]::Replace($content, "(?m)^$([regex]::Escape($Key))=.*$", $line)
    } else {
        if ($content.Length -gt 0 -and -not $content.EndsWith("`n")) {
            $content += "`r`n"
        }
        $content += "$line`r`n"
    }

    if (-not $DryRun) {
        Set-Content -LiteralPath $Path -Value $content -NoNewline
    }
    return $true
}

$workspaceRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$projectDir = Join-Path $workspaceRoot "WatcheRobot_esp32\firmware\s3"
$targets = @(
    (Join-Path $projectDir "sdkconfig.no-wake"),
    (Join-Path $projectDir "sdkconfig")
)

Assert-AppCenterUrl $Url

Write-Host "Setting App.Center remote list URL:" -ForegroundColor Cyan
Write-Host "  $Url"
Write-Host ""

$updated = 0
foreach ($target in $targets) {
    if (Set-KconfigString -Path $target -Key "CONFIG_APP_CENTER_REMOTE_LIST_URL" -Value $Url) {
        ++$updated
        Write-Host "$(if ($DryRun) { 'Would update' } else { 'Updated' }): $target"
    }
}

if ($updated -eq 0) {
    throw "No sdkconfig files were found under $projectDir"
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  yarn esp32:build"
Write-Host "  yarn esp32"
