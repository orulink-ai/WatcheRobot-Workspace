[CmdletBinding()]
param(
    [string]$EspAlias = "esp32-s3",
    [string]$Stm32Alias = "stm32-f103",
    [string]$Feature = "stm32-uart2-bringup",
    [int]$DurationSec = 15,
    [string]$EspBuildPath = "build-esp32s3-local",
    [string]$Stm32Preset = "Debug",
    [string]$EspRepoRoot,
    [string]$Stm32RepoRoot,
    [string]$EspPort,
    [string]$Stm32Port,
    [switch]$AutoDetectPorts,
    [switch]$NoSavePorts,
    [switch]$SkipStm32Build,
    [Alias("EspNoBuild")]
    [switch]$SkipEsp32Build,
    [switch]$SkipStm32Flash,
    [switch]$SkipEsp32Flash,
    [switch]$RestartStm32,
    [switch]$RestartEsp32,
    [switch]$SkipSession
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-WorkspaceRoot {
    $current = $PSScriptRoot
    while ($current) {
        $agentsSkills = Join-Path $current ".agents\skills"
        $espRepo = Join-Path $current "WatcheRobot_esp32"
        $stm32Repo = Join-Path $current "WatcheRobot_stm32"
        if ((Test-Path $agentsSkills) -and ((Test-Path $espRepo) -or (Test-Path $stm32Repo))) {
            return $current
        }

        $parent = Split-Path -Parent $current
        if (-not $parent -or $parent -eq $current) { break }
        $current = $parent
    }

    throw "Workspace root not found. Pass -EspRepoRoot and -Stm32RepoRoot explicitly."
}

function Resolve-FirstAvailablePath {
    param([Parameter(Mandatory = $true)][string[]]$Candidates)

    foreach ($candidate in $Candidates) {
        if (-not $candidate) { continue }

        $command = Get-Command $candidate -ErrorAction SilentlyContinue
        if ($command -and $command.Source) { return $command.Source }
        if (Test-Path $candidate) { return (Resolve-Path $candidate).Path }
    }

    throw "No usable path found: $($Candidates -join ', ')"
}

function Resolve-OptionalPath {
    param(
        [Parameter(Mandatory = $true)][string]$BasePath,
        [string]$RequestedPath
    )

    if (-not $RequestedPath) { return $null }
    if (Test-Path $RequestedPath) { return (Resolve-Path $RequestedPath).Path }
    if ([System.IO.Path]::IsPathRooted($RequestedPath)) {
        return [System.IO.Path]::GetFullPath($RequestedPath)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $BasePath $RequestedPath))
}

function Resolve-EspProjectDescriptionPath {
    param(
        [Parameter(Mandatory = $true)][string]$ResolvedProjectPath,
        [string]$ResolvedBuildPath
    )

    if ($ResolvedBuildPath) {
        $candidate = Join-Path $ResolvedBuildPath "project_description.json"
        if (Test-Path $candidate) { return $candidate }
    }

    $defaultCandidate = Join-Path $ResolvedProjectPath "build\project_description.json"
    if (Test-Path $defaultCandidate) { return $defaultCandidate }
    return $null
}

function Resolve-EspIdfPath {
    param(
        [Parameter(Mandatory = $true)][string]$ResolvedProjectPath,
        [string]$ResolvedBuildPath
    )

    if ($env:IDF_PATH -and (Test-Path $env:IDF_PATH)) { return $env:IDF_PATH }

    $projectDescriptionPath = Resolve-EspProjectDescriptionPath -ResolvedProjectPath $ResolvedProjectPath -ResolvedBuildPath $ResolvedBuildPath
    if ($projectDescriptionPath) {
        $projectDescription = Get-Content $projectDescriptionPath -Raw | ConvertFrom-Json
        if ($projectDescription.idf_path -and (Test-Path $projectDescription.idf_path)) {
            return $projectDescription.idf_path
        }
    }

    foreach ($candidate in @("C:\Espressif\frameworks\esp-idf-v5.2.1", "C:\Espressif\frameworks\esp-idf")) {
        if (Test-Path $candidate) { return $candidate }
    }

    throw "ESP-IDF was not found. Set IDF_PATH or build once so project_description.json contains idf_path."
}

function Resolve-EspIdfBootstrapScript {
    param([Parameter(Mandatory = $true)][string]$ResolvedIdfPath)

    $exportScript = Join-Path $ResolvedIdfPath "export.ps1"
    if (Test-Path $exportScript) { return $exportScript }

    $installRoot = Split-Path -Parent (Split-Path -Parent $ResolvedIdfPath)
    $initializeScript = Join-Path $installRoot "Initialize-Idf.ps1"
    if (Test-Path $initializeScript) { return $initializeScript }

    throw "ESP-IDF bootstrap script was not found. Checked: $initializeScript, $exportScript"
}

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [string[]]$Arguments = @(),
        [string]$WorkingDirectory
    )

    Write-Host ">> $FilePath $($Arguments -join ' ')"
    if ($WorkingDirectory) { Push-Location $WorkingDirectory }

    try {
        & $FilePath @Arguments
        if ($LASTEXITCODE -ne 0) {
            throw "Command failed with exit code $LASTEXITCODE"
        }
    }
    finally {
        if ($WorkingDirectory) { Pop-Location }
    }
}

function Invoke-Esp32Idf {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectPath,
        [string]$BuildPath,
        [Parameter(Mandatory = $true)][string[]]$IdfArguments
    )

    $resolvedProjectPath = (Resolve-Path $ProjectPath).Path
    $resolvedBuildPath = Resolve-OptionalPath -BasePath $resolvedProjectPath -RequestedPath $BuildPath
    $idfPath = Resolve-EspIdfPath -ResolvedProjectPath $resolvedProjectPath -ResolvedBuildPath $resolvedBuildPath
    $idfBootstrapScript = Resolve-EspIdfBootstrapScript -ResolvedIdfPath $idfPath

    $commandArgs = @()
    if ($resolvedBuildPath) {
        $commandArgs += "-B"
        $commandArgs += $resolvedBuildPath
    }
    $commandArgs += $IdfArguments

    Write-Host ">> idf.py $($commandArgs -join ' ')"
    Push-Location $resolvedProjectPath
    try {
        $env:IDF_PATH = $idfPath
        . $idfBootstrapScript | Out-Null
        if (-not (Get-Command "idf.py" -ErrorAction SilentlyContinue)) {
            throw "ESP-IDF was loaded, but idf.py is unavailable."
        }

        & idf.py @commandArgs
        if ($LASTEXITCODE -ne 0) {
            throw "Command failed with exit code $LASTEXITCODE"
        }
    }
    finally {
        Pop-Location
    }
}

function Invoke-Esp32HardReset {
    param([Parameter(Mandatory = $true)][string]$Port)

    $script = "import sys,time,serial; port=sys.argv[1]; ser=serial.Serial(); ser.port=port; ser.baudrate=115200; ser.timeout=0.2; ser.rtscts=False; ser.dsrdtr=False; ser.dtr=False; ser.rts=False; ser.open(); time.sleep(0.05); ser.dtr=False; ser.rts=True; time.sleep(0.1); ser.rts=False; ser.close()"
    Invoke-Checked -FilePath "python" -Arguments @("-c", $script, $Port)
}

function Get-CodexDeviceMapPath {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [string]$DeviceMapPath
    )

    if ($DeviceMapPath) {
        if ([System.IO.Path]::IsPathRooted($DeviceMapPath)) { return $DeviceMapPath }
        return Join-Path $RepoRoot $DeviceMapPath
    }

    if ($env:CODEX_DEVICE_MAP_PATH) {
        if ([System.IO.Path]::IsPathRooted($env:CODEX_DEVICE_MAP_PATH)) { return $env:CODEX_DEVICE_MAP_PATH }
        return Join-Path $RepoRoot $env:CODEX_DEVICE_MAP_PATH
    }

    return Join-Path $RepoRoot ".codex\local\device-map.toml"
}

function Get-SerialPortInventory {
    $items = @()
    $seen = @{}

    $serialPorts = @(Get-CimInstance Win32_SerialPort -ErrorAction SilentlyContinue)
    foreach ($port in $serialPorts) {
        if (-not $port.DeviceID -or $seen.ContainsKey($port.DeviceID)) { continue }
        $seen[$port.DeviceID] = $true
        $items += [pscustomobject]@{
            Port = [string]$port.DeviceID
            Name = [string]$port.Name
            Description = [string]$port.Description
            PnpDeviceId = [string]$port.PNPDeviceID
        }
    }

    $entities = @(Get-CimInstance Win32_PnPEntity -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '\(COM\d+\)' })
    foreach ($entity in $entities) {
        if ($entity.Name -notmatch '(COM\d+)') { continue }
        $portName = $Matches[1]
        if ($seen.ContainsKey($portName)) { continue }
        $seen[$portName] = $true
        $items += [pscustomobject]@{
            Port = $portName
            Name = [string]$entity.Name
            Description = [string]$entity.Description
            PnpDeviceId = [string]$entity.PNPDeviceID
        }
    }

    return $items | Sort-Object {
        if ($_.Port -match '^COM(\d+)$') { [int]$Matches[1] } else { 9999 }
    }
}

function Get-SerialPortScore {
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Item,
        [Parameter(Mandatory = $true)][string]$Firmware
    )

    $text = "$($Item.Port) $($Item.Name) $($Item.Description) $($Item.PnpDeviceId)"
    $score = 0

    if ($text -match 'BTHENUM|Bluetooth|蓝牙|ACPI\\PNP0501|Communications Port') { $score -= 100 }

    if ($Firmware -eq "s3") {
        if ($text -match 'VID_303A|Espressif|ESP32|USB JTAG/serial|USB Serial/JTAG') { $score += 100 }
        if ($text -match 'CP210|VID_10C4|CH340|CH341|VID_1A86|USB-SERIAL|USB Serial') { $score += 35 }
    }
    elseif ($Firmware -eq "stm32") {
        if ($text -match 'VID_0483|STMicroelectronics|STLink|ST-Link|STM32 Virtual COM') { $score += 100 }
        if ($text -match 'CP210|VID_10C4|CH340|CH341|VID_1A86|USB-SERIAL|USB Serial') { $score += 25 }
    }

    return $score
}

function Resolve-AutoDetectedDeviceMapping {
    param(
        [Parameter(Mandatory = $true)][string]$Alias,
        [Parameter(Mandatory = $true)][string]$Firmware,
        [string]$ExcludePort
    )

    $inventory = @(Get-SerialPortInventory)
    $ranked = @(
        foreach ($item in $inventory) {
            if ($ExcludePort -and $item.Port -eq $ExcludePort) { continue }
            $score = Get-SerialPortScore -Item $item -Firmware $Firmware
            [pscustomobject]@{
                Port = $item.Port
                Firmware = $Firmware
                Score = $score
                Name = $item.Name
                Description = $item.Description
                PnpDeviceId = $item.PnpDeviceId
            }
        }
    ) | Sort-Object Score -Descending

    $best = @($ranked | Where-Object { $_.Score -gt 0 } | Select-Object -First 2)
    if ($best.Count -eq 1 -or ($best.Count -ge 2 -and $best[0].Score -ge ($best[1].Score + 20))) {
        Write-Host "Auto-detected $Alias ($Firmware) -> $($best[0].Port) [$($best[0].Name)]"
        return [pscustomobject]@{
            Alias = $Alias
            Firmware = $Firmware
            Port = $best[0].Port
            SourcePath = "auto-detected"
        }
    }

    $lines = @("Unable to auto-detect a unique $Firmware port for alias '$Alias'.")
    if ($inventory.Count -eq 0) {
        $lines += "No COM ports were found."
    }
    else {
        $lines += "Candidates:"
        foreach ($item in $ranked) {
            $lines += ("  {0,-6} score={1,4}  {2}  {3}" -f $item.Port, $item.Score, $item.Name, $item.PnpDeviceId)
        }
    }
    $lines += "Pass -EspPort/-Stm32Port, set CODEX_DEVICE_MAP_PATH, or create WatcheRobot_esp32\.codex\local\device-map.toml."
    throw ($lines -join [Environment]::NewLine)
}

function Read-CodexDeviceMap {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path $Path)) {
        return $null
    }

    $devices = @{}
    $currentAlias = $null
    $lineNumber = 0

    foreach ($rawLine in [System.IO.File]::ReadLines($Path)) {
        $lineNumber += 1
        $line = $rawLine.Trim()
        if (-not $line -or $line.StartsWith("#")) { continue }

        if ($line -match '^\[(?<section>[^\]]+)\]$') {
            $section = $Matches.section
            if ($section -match '^devices\.(?<alias>[A-Za-z0-9._-]+)$') {
                $currentAlias = $Matches.alias
                if (-not $devices.ContainsKey($currentAlias)) { $devices[$currentAlias] = @{} }
            }
            else {
                $currentAlias = $null
            }
            continue
        }

        if (-not $currentAlias) { continue }

        if ($line -notmatch '^(?<key>[A-Za-z0-9_-]+)\s*=\s*"(?<value>[^"]*)"\s*$') {
            throw "Invalid device map format: ${Path}:$lineNumber -> $rawLine"
        }

        $devices[$currentAlias][$Matches.key] = $Matches.value
    }

    return $devices
}

function Write-CodexDeviceMap {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][hashtable]$Devices
    )

    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }

    $lines = @(
        "# Local machine device map for WatcheRobot dual-MCU bring-up.",
        "# Keep aliases stable; update only the COM port values when Windows renumbers devices.",
        ""
    )

    foreach ($alias in ($Devices.Keys | Sort-Object)) {
        $entry = $Devices[$alias]
        $firmware = [string]$entry["firmware"]
        $port = [string]$entry["port"]
        if (-not $firmware -or -not $port) { continue }
        $lines += "[devices.$alias]"
        $lines += "firmware = `"$firmware`""
        $lines += "port = `"$port`""
        $lines += ""
    }

    Set-Content -LiteralPath $Path -Value $lines -Encoding UTF8
}

function Update-CodexDeviceMapPorts {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [string]$DeviceMapPath,
        [string]$EspAlias,
        [string]$EspPort,
        [string]$Stm32Alias,
        [string]$Stm32Port
    )

    $mapPath = Get-CodexDeviceMapPath -RepoRoot $RepoRoot -DeviceMapPath $DeviceMapPath
    $devices = Read-CodexDeviceMap -Path $mapPath
    if (-not $devices) { $devices = @{} }

    if ($EspPort) {
        $devices[$EspAlias] = @{ firmware = "s3"; port = $EspPort }
    }
    if ($Stm32Port) {
        $devices[$Stm32Alias] = @{ firmware = "stm32"; port = $Stm32Port }
    }

    Write-CodexDeviceMap -Path $mapPath -Devices $devices
    Write-Host "Updated device map: $mapPath"
}

function Resolve-CodexDeviceMapping {
    param(
        [Parameter(Mandatory = $true)][string]$Alias,
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [string]$Firmware,
        [string]$DeviceMapPath
    )

    $mapPath = Get-CodexDeviceMapPath -RepoRoot $RepoRoot -DeviceMapPath $DeviceMapPath
    $resolvedMapPath = $mapPath
    if (Test-Path $mapPath) { $resolvedMapPath = (Resolve-Path $mapPath).Path }

    $devices = Read-CodexDeviceMap -Path $resolvedMapPath
    if (-not $devices) {
        if ($AutoDetectPorts) {
            return Resolve-AutoDetectedDeviceMapping -Alias $Alias -Firmware $Firmware
        }
        throw "Device map not found: $resolvedMapPath. Ask the user for the $Firmware port, then rerun with -EspPort/-Stm32Port so it can be saved."
    }

    if (-not $devices.ContainsKey($Alias)) {
        if ($AutoDetectPorts) {
            return Resolve-AutoDetectedDeviceMapping -Alias $Alias -Firmware $Firmware
        }
        throw "Alias '$Alias' was not found in $resolvedMapPath. Ask the user for the $Firmware port, then rerun with -EspPort/-Stm32Port so it can be saved."
    }

    $entry = $devices[$Alias]
    $mappedFirmware = [string]$entry["firmware"]
    $mappedPort = [string]$entry["port"]

    if (-not $mappedPort) {
        throw "Alias '$Alias' is missing the port field in $resolvedMapPath."
    }

    if ($Firmware -and $mappedFirmware -and $mappedFirmware -ne $Firmware) {
        throw "Alias '$Alias' firmware=$mappedFirmware does not match expected firmware=$Firmware."
    }

    return [pscustomobject]@{
        Alias = $Alias
        Firmware = $mappedFirmware
        Port = $mappedPort
        SourcePath = $resolvedMapPath
    }
}

$workspaceRoot = Resolve-WorkspaceRoot
if (-not $EspRepoRoot) {
    $EspRepoRoot = Join-Path $workspaceRoot "WatcheRobot_esp32"
}
if (-not $Stm32RepoRoot) {
    $Stm32RepoRoot = Join-Path $workspaceRoot "WatcheRobot_stm32"
}
if (-not (Test-Path $EspRepoRoot)) {
    throw "ESP32 repo root not found: $EspRepoRoot. Pass -EspRepoRoot explicitly."
}
if (-not (Test-Path $Stm32RepoRoot)) {
    throw "STM32 repo root not found: $Stm32RepoRoot. Pass -Stm32RepoRoot explicitly."
}

if (($EspPort -or $Stm32Port) -and -not $NoSavePorts) {
    Update-CodexDeviceMapPorts -RepoRoot $EspRepoRoot -DeviceMapPath $env:CODEX_DEVICE_MAP_PATH -EspAlias $EspAlias -EspPort $EspPort -Stm32Alias $Stm32Alias -Stm32Port $Stm32Port
}

if ($EspPort) {
    $espMapping = [pscustomobject]@{ Alias = $EspAlias; Firmware = "s3"; Port = $EspPort; SourcePath = "argument" }
}
else {
    $espMapping = Resolve-CodexDeviceMapping -Alias $EspAlias -RepoRoot $EspRepoRoot -Firmware "s3" -DeviceMapPath $env:CODEX_DEVICE_MAP_PATH
}

if ($Stm32Port) {
    $stm32Mapping = [pscustomobject]@{ Alias = $Stm32Alias; Firmware = "stm32"; Port = $Stm32Port; SourcePath = "argument" }
}
else {
    $stm32Mapping = Resolve-CodexDeviceMapping -Alias $Stm32Alias -RepoRoot $EspRepoRoot -Firmware "stm32" -DeviceMapPath $env:CODEX_DEVICE_MAP_PATH
}

if ($espMapping.Port -eq $stm32Mapping.Port) {
    throw "ESP32 and STM32 resolved to the same port ($($espMapping.Port)). Pass -EspPort and -Stm32Port explicitly."
}

$cmakePath = Resolve-FirstAvailablePath -Candidates @(
    "cmake",
    "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
)

$ninjaPath = Resolve-FirstAvailablePath -Candidates @(
    "ninja",
    "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe"
)

$openOcdPath = Resolve-FirstAvailablePath -Candidates @(
    "openocd"
)

$espProjectRoot = Join-Path $EspRepoRoot "firmware\s3"
$stm32BinPath = Join-Path $Stm32RepoRoot "build\$Stm32Preset\watcheRobot_STM32.bin"
$espFlashScript = Join-Path $espProjectRoot "tools\flash-monitor.ps1"
$sessionScript = Join-Path $EspRepoRoot "tools\stm32_bringup_session.py"
$projectRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$closePortHelper = Join-Path $projectRoot ".agents\skills\watche-s3-flash-monitor\scripts\close-com-port.ps1"

Write-Host "ESP32 : $EspAlias -> $($espMapping.Port)"
Write-Host "STM32 : $Stm32Alias -> $($stm32Mapping.Port)"

if (-not $SkipStm32Build) {
    Invoke-Checked -FilePath $cmakePath -Arguments @(
        "--preset", $Stm32Preset,
        "-DCMAKE_MAKE_PROGRAM=$ninjaPath"
    ) -WorkingDirectory $Stm32RepoRoot

    Invoke-Checked -FilePath $cmakePath -Arguments @(
        "--build", "--preset", $Stm32Preset
    ) -WorkingDirectory $Stm32RepoRoot
}

if (-not $SkipEsp32Build) {
    Invoke-Esp32Idf -ProjectPath $espProjectRoot -BuildPath $EspBuildPath -IdfArguments @("build")
}

if (-not $SkipStm32Flash) {
    if (-not (Test-Path $stm32BinPath)) {
        throw "STM32 flash artifact was not found: $stm32BinPath"
    }

    $stm32BinOpenOcdPath = $stm32BinPath.Replace('\', '/')
    Invoke-Checked -FilePath $openOcdPath -Arguments @(
        "-f", "interface/stlink.cfg",
        "-f", "target/stm32f1x.cfg",
        "-c", "transport select hla_swd",
        "-c", "program $stm32BinOpenOcdPath verify reset exit 0x08000000"
    ) -WorkingDirectory $Stm32RepoRoot
}

if (-not $SkipEsp32Flash) {
    if (Test-Path $closePortHelper) {
        Invoke-Checked -FilePath "powershell" -Arguments @(
            "-ExecutionPolicy", "Bypass",
            "-File", $closePortHelper,
            "-Port", $espMapping.Port
        ) -WorkingDirectory $espProjectRoot
    }

    Invoke-Checked -FilePath "powershell" -Arguments @(
        "-ExecutionPolicy", "Bypass",
        "-File", $espFlashScript,
        "-Port", $espMapping.Port,
        "-BuildPath", ".\$EspBuildPath",
        "-NoMonitor",
        "-NoBuild"
    ) -WorkingDirectory $espProjectRoot
}

if ($RestartStm32) {
    Invoke-Checked -FilePath $openOcdPath -Arguments @(
        "-f", "interface/stlink.cfg",
        "-f", "target/stm32f1x.cfg",
        "-c", "transport select hla_swd",
        "-c", "init; reset run; shutdown"
    ) -WorkingDirectory $Stm32RepoRoot
}

if ($RestartEsp32) {
    if (Test-Path $closePortHelper) {
        Invoke-Checked -FilePath "powershell" -Arguments @(
            "-ExecutionPolicy", "Bypass",
            "-File", $closePortHelper,
            "-Port", $espMapping.Port
        ) -WorkingDirectory $espProjectRoot
    }

    Invoke-Esp32HardReset -Port $espMapping.Port
}

if (-not $SkipSession) {
    Invoke-Checked -FilePath "python" -Arguments @(
        $sessionScript,
        "--esp-alias", $EspAlias,
        "--stm32-alias", $Stm32Alias,
        "--feature", $Feature,
        "--duration-sec", [string]$DurationSec
    ) -WorkingDirectory $Stm32RepoRoot
}
