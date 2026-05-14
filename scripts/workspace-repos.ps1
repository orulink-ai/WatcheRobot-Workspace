function Get-WatcheWorkspaceRepositories {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspaceRoot
    )

    return @(
        [pscustomobject]@{
            Name = "workspace"
            Path = $WorkspaceRoot
            Kind = "meta"
        },
        [pscustomobject]@{
            Name = "mobile-app"
            Path = Join-Path $WorkspaceRoot "WatcheRobot_app"
            Kind = "react-native"
        },
        [pscustomobject]@{
            Name = "desktop-app"
            Path = Join-Path $WorkspaceRoot "WatcheRobot_client"
            Kind = "tauri"
        },
        [pscustomobject]@{
            Name = "server"
            Path = Join-Path $WorkspaceRoot "WatcheRobot_server"
            Kind = "python"
        },
        [pscustomobject]@{
            Name = "esp32-firmware"
            Path = Join-Path $WorkspaceRoot "WatcheRobot_esp32"
            Kind = "esp-idf"
        },
        [pscustomobject]@{
            Name = "stm32-firmware"
            Path = Join-Path $WorkspaceRoot "WatcheRobot_stm32"
            Kind = "stm32"
        }
    )
}
