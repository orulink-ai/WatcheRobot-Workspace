param()

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$Validator = Join-Path $Root "scripts/validate-release-manifest.ps1"
$TempBase = [System.IO.Path]::GetTempPath()
$FixtureRoot = Join-Path $TempBase ("watche-release-manifest-test-" + [guid]::NewGuid().ToString("N"))

function Set-FixtureFile {
  param(
    [string]$FileName,
    [string]$Content
  )

  if (-not (Test-Path -LiteralPath $FixtureRoot)) {
    New-Item -ItemType Directory -Path $FixtureRoot | Out-Null
  }

  $Path = Join-Path $FixtureRoot $FileName
  Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
  return $Path
}

function Invoke-ManifestValidation {
  param(
    [string]$ManifestPath,
    [ValidateSet("Manifest", "Path")]
    [string]$ParameterName = "Manifest",
    [switch]$AllowPlaceholders
  )

  $Arguments = @("-ExecutionPolicy", "Bypass", "-File", $Validator, "-$ParameterName", $ManifestPath)
  if ($AllowPlaceholders) {
    $Arguments += "-AllowPlaceholders"
  }

  $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
  $ProcessInfo.FileName = "powershell"
  $ProcessInfo.Arguments = ($Arguments | ForEach-Object {
    if ($_ -match "\s") {
      '"' + ($_ -replace '"', '\"') + '"'
    } else {
      $_
    }
  }) -join " "
  $ProcessInfo.RedirectStandardOutput = $true
  $ProcessInfo.RedirectStandardError = $true
  $ProcessInfo.UseShellExecute = $false

  $Process = [System.Diagnostics.Process]::Start($ProcessInfo)
  $StandardOutput = $Process.StandardOutput.ReadToEnd()
  $StandardError = $Process.StandardError.ReadToEnd()
  $Process.WaitForExit()

  [pscustomobject]@{
    exit_code = [int]$Process.ExitCode
    output = (($StandardOutput, $StandardError | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -join [Environment]::NewLine).Trim()
  }
}

function Assert-ExitCode {
  param(
    [object]$Result,
    [int]$Expected,
    [string]$CaseName
  )

  if ($Result.exit_code -ne $Expected) {
    throw "$CaseName expected exit code $Expected, got $($Result.exit_code). Output: $($Result.output)"
  }
}

$PlaceholderManifest = @'
{
  "version": "v0.1.0-alpha",
  "release_date": "TBD",
  "release_url": "TBD",
  "components": {
    "workspace": "TBD",
    "app": "TBD",
    "desktop": "TBD",
    "server": "TBD",
    "esp32": "TBD",
    "stm32": "TBD"
  },
  "artifacts": [
    {
      "name": "desktop-windows-installer",
      "type": "desktop-installer",
      "path_or_url": "TBD",
      "sha256": "TBD",
      "required": true
    },
    {
      "name": "esp32-firmware-package",
      "type": "firmware",
      "path_or_url": "TBD",
      "sha256": "TBD",
      "required": true
    }
  ],
  "checks": {
    "readiness_script": "TBD",
    "hardware_smoke": "TBD",
    "clean_machine": "TBD"
  }
}
'@

$ValidManifest = @'
{
  "version": "v0.1.0-alpha",
  "release_date": "2026-06-11",
  "release_url": "https://example.com/releases/v0.1.0-alpha",
  "components": {
    "workspace": "0123456",
    "app": "1234567",
    "desktop": "2345678",
    "server": "3456789",
    "esp32": "456789a",
    "stm32": "56789ab"
  },
  "artifacts": [
    {
      "name": "desktop-windows-installer",
      "type": "desktop-installer",
      "path_or_url": "https://example.com/watche-robot-setup.exe",
      "sha256": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
      "required": true
    },
    {
      "name": "esp32-firmware-package",
      "type": "firmware",
      "path_or_url": "https://example.com/watche-robot-esp32.zip",
      "sha256": "abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789",
      "required": true
    }
  ],
  "checks": {
    "readiness_script": "passed",
    "hardware_smoke": "passed",
    "clean_machine": "passed"
  }
}
'@

$InvalidComponentRefManifest = @'
{
  "version": "v0.1.0-alpha",
  "release_date": "2026-06-11",
  "release_url": "https://example.com/releases/v0.1.0-alpha",
  "components": {
    "workspace": "0123456",
    "app": "not-a-ref",
    "desktop": "2345678",
    "server": "3456789",
    "esp32": "456789a",
    "stm32": "56789ab"
  },
  "artifacts": [
    {
      "name": "desktop-windows-installer",
      "type": "desktop-installer",
      "path_or_url": "https://example.com/watche-robot-setup.exe",
      "sha256": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
      "required": true
    },
    {
      "name": "esp32-firmware-package",
      "type": "firmware",
      "path_or_url": "https://example.com/watche-robot-esp32.zip",
      "sha256": "abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789",
      "required": true
    }
  ],
  "checks": {
    "readiness_script": "passed",
    "hardware_smoke": "passed",
    "clean_machine": "passed"
  }
}
'@

$InvalidVersionManifest = @'
{
  "version": "release-candidate",
  "release_date": "2026-06-11",
  "release_url": "https://example.com/releases/v0.1.0-alpha",
  "components": {
    "workspace": "0123456",
    "app": "1234567",
    "desktop": "2345678",
    "server": "3456789",
    "esp32": "456789a",
    "stm32": "56789ab"
  },
  "artifacts": [
    {
      "name": "desktop-windows-installer",
      "type": "desktop-installer",
      "path_or_url": "https://example.com/watche-robot-setup.exe",
      "sha256": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
      "required": true
    },
    {
      "name": "esp32-firmware-package",
      "type": "firmware",
      "path_or_url": "https://example.com/watche-robot-esp32.zip",
      "sha256": "abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789",
      "required": true
    }
  ],
  "checks": {
    "readiness_script": "passed",
    "hardware_smoke": "passed",
    "clean_machine": "passed"
  }
}
'@

$FutureReleaseDateManifest = @'
{
  "version": "v0.1.0-alpha",
  "release_date": "2999-01-01",
  "release_url": "https://example.com/releases/v0.1.0-alpha",
  "components": {
    "workspace": "0123456",
    "app": "1234567",
    "desktop": "2345678",
    "server": "3456789",
    "esp32": "456789a",
    "stm32": "56789ab"
  },
  "artifacts": [
    {
      "name": "desktop-windows-installer",
      "type": "desktop-installer",
      "path_or_url": "https://example.com/watche-robot-setup.exe",
      "sha256": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
      "required": true
    },
    {
      "name": "esp32-firmware-package",
      "type": "firmware",
      "path_or_url": "https://example.com/watche-robot-esp32.zip",
      "sha256": "abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789",
      "required": true
    }
  ],
  "checks": {
    "readiness_script": "passed",
    "hardware_smoke": "passed",
    "clean_machine": "passed"
  }
}
'@

$InvalidReleaseUrlManifest = @'
{
  "version": "v0.1.0-alpha",
  "release_date": "2026-06-11",
  "release_url": "ftp://example.com/releases/v0.1.0-alpha",
  "components": {
    "workspace": "0123456",
    "app": "1234567",
    "desktop": "2345678",
    "server": "3456789",
    "esp32": "456789a",
    "stm32": "56789ab"
  },
  "artifacts": [
    {
      "name": "desktop-windows-installer",
      "type": "desktop-installer",
      "path_or_url": "https://example.com/watche-robot-setup.exe",
      "sha256": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
      "required": true
    },
    {
      "name": "esp32-firmware-package",
      "type": "firmware",
      "path_or_url": "https://example.com/watche-robot-esp32.zip",
      "sha256": "abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789",
      "required": true
    }
  ],
  "checks": {
    "readiness_script": "passed",
    "hardware_smoke": "passed",
    "clean_machine": "passed"
  }
}
'@

$InvalidShaManifest = @'
{
  "version": "v0.1.0-alpha",
  "release_date": "2026-06-11",
  "release_url": "https://example.com/releases/v0.1.0-alpha",
  "components": {
    "workspace": "0123456",
    "app": "1234567",
    "desktop": "2345678",
    "server": "3456789",
    "esp32": "456789a",
    "stm32": "56789ab"
  },
  "artifacts": [
    {
      "name": "desktop-windows-installer",
      "type": "desktop-installer",
      "path_or_url": "https://example.com/watche-robot-setup.exe",
      "sha256": "not-a-sha",
      "required": true
    }
  ],
  "checks": {
    "readiness_script": "passed",
    "hardware_smoke": "passed",
    "clean_machine": "passed"
  }
}
'@

$InvalidArtifactLocationManifest = @'
{
  "version": "v0.1.0-alpha",
  "release_date": "2026-06-11",
  "release_url": "https://example.com/releases/v0.1.0-alpha",
  "components": {
    "workspace": "0123456",
    "app": "1234567",
    "desktop": "2345678",
    "server": "3456789",
    "esp32": "456789a",
    "stm32": "56789ab"
  },
  "artifacts": [
    {
      "name": "desktop-windows-installer",
      "type": "desktop-installer",
      "path_or_url": "release asset",
      "sha256": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
      "required": true
    },
    {
      "name": "esp32-firmware-package",
      "type": "firmware",
      "path_or_url": "https://example.com/watche-robot-esp32.zip",
      "sha256": "abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789",
      "required": true
    }
  ],
  "checks": {
    "readiness_script": "passed",
    "hardware_smoke": "passed",
    "clean_machine": "passed"
  }
}
'@

$DuplicateArtifactNameManifest = @'
{
  "version": "v0.1.0-alpha",
  "release_date": "2026-06-11",
  "release_url": "https://example.com/releases/v0.1.0-alpha",
  "components": {
    "workspace": "0123456",
    "app": "1234567",
    "desktop": "2345678",
    "server": "3456789",
    "esp32": "456789a",
    "stm32": "56789ab"
  },
  "artifacts": [
    {
      "name": "desktop-windows-installer",
      "type": "desktop-installer",
      "path_or_url": "https://example.com/watche-robot-setup.exe",
      "sha256": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
      "required": true
    },
    {
      "name": "desktop-windows-installer",
      "type": "desktop-installer",
      "path_or_url": "https://example.com/watche-robot-setup-copy.exe",
      "sha256": "abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789",
      "required": true
    },
    {
      "name": "esp32-firmware-package",
      "type": "firmware",
      "path_or_url": "https://example.com/watche-robot-esp32.zip",
      "sha256": "fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210",
      "required": true
    }
  ],
  "checks": {
    "readiness_script": "passed",
    "hardware_smoke": "passed",
    "clean_machine": "passed"
  }
}
'@

$StringRequiredFlagManifest = @'
{
  "version": "v0.1.0-alpha",
  "release_date": "2026-06-11",
  "release_url": "https://example.com/releases/v0.1.0-alpha",
  "components": {
    "workspace": "0123456",
    "app": "1234567",
    "desktop": "2345678",
    "server": "3456789",
    "esp32": "456789a",
    "stm32": "56789ab"
  },
  "artifacts": [
    {
      "name": "desktop-windows-installer",
      "type": "desktop-installer",
      "path_or_url": "https://example.com/watche-robot-setup.exe",
      "sha256": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
      "required": "true"
    },
    {
      "name": "esp32-firmware-package",
      "type": "firmware",
      "path_or_url": "https://example.com/watche-robot-esp32.zip",
      "sha256": "abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789",
      "required": true
    }
  ],
  "checks": {
    "readiness_script": "passed",
    "hardware_smoke": "passed",
    "clean_machine": "passed"
  }
}
'@

$NonArtifactPlaceholderManifest = @'
{
  "version": "v0.1.0-alpha",
  "release_date": "TBD",
  "release_url": "https://example.com/releases/v0.1.0-alpha",
  "components": {
    "workspace": "TBD"
  },
  "artifacts": [
    {
      "name": "desktop-windows-installer",
      "type": "desktop-installer",
      "path_or_url": "https://example.com/watche-robot-setup.exe",
      "sha256": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
      "required": true
    }
  ],
  "checks": {
    "readiness_script": "TBD",
    "hardware_smoke": "passed",
    "clean_machine": "passed"
  }
}
'@

$MissingRequiredArtifactManifest = @'
{
  "version": "v0.1.0-alpha",
  "release_date": "2026-06-11",
  "release_url": "https://example.com/releases/v0.1.0-alpha",
  "components": {
    "workspace": "0123456",
    "app": "1234567",
    "desktop": "2345678",
    "server": "3456789",
    "esp32": "456789a",
    "stm32": "56789ab"
  },
  "artifacts": [
    {
      "name": "desktop-windows-installer",
      "type": "desktop-installer",
      "path_or_url": "https://example.com/watche-robot-setup.exe",
      "sha256": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
      "required": true
    }
  ],
  "checks": {
    "readiness_script": "passed",
    "hardware_smoke": "passed",
    "clean_machine": "passed"
  }
}
'@

$MissingReleaseUrlManifest = @'
{
  "version": "v0.1.0-alpha",
  "release_date": "2026-06-11",
  "components": {
    "workspace": "0123456"
  },
  "artifacts": [
    {
      "name": "desktop-windows-installer",
      "type": "desktop-installer",
      "path_or_url": "https://example.com/watche-robot-setup.exe",
      "sha256": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
      "required": true
    },
    {
      "name": "esp32-firmware-package",
      "type": "firmware",
      "path_or_url": "https://example.com/watche-robot-esp32.zip",
      "sha256": "abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789",
      "required": true
    }
  ],
  "checks": {
    "readiness_script": "passed",
    "hardware_smoke": "passed",
    "clean_machine": "passed"
  }
}
'@

$MissingRequiredChecksManifest = @'
{
  "version": "v0.1.0-alpha",
  "release_date": "2026-06-11",
  "release_url": "https://example.com/releases/v0.1.0-alpha",
  "components": {
    "workspace": "0123456",
    "app": "1234567",
    "desktop": "2345678",
    "server": "3456789",
    "esp32": "456789a",
    "stm32": "56789ab"
  },
  "artifacts": [
    {
      "name": "desktop-windows-installer",
      "type": "desktop-installer",
      "path_or_url": "https://example.com/watche-robot-setup.exe",
      "sha256": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
      "required": true
    },
    {
      "name": "esp32-firmware-package",
      "type": "firmware",
      "path_or_url": "https://example.com/watche-robot-esp32.zip",
      "sha256": "abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789",
      "required": true
    }
  ],
  "checks": {
    "readiness_script": "passed"
  }
}
'@

$FailedRequiredCheckManifest = @'
{
  "version": "v0.1.0-alpha",
  "release_date": "2026-06-11",
  "release_url": "https://example.com/releases/v0.1.0-alpha",
  "components": {
    "workspace": "0123456",
    "app": "1234567",
    "desktop": "2345678",
    "server": "3456789",
    "esp32": "456789a",
    "stm32": "56789ab"
  },
  "artifacts": [
    {
      "name": "desktop-windows-installer",
      "type": "desktop-installer",
      "path_or_url": "https://example.com/watche-robot-setup.exe",
      "sha256": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
      "required": true
    },
    {
      "name": "esp32-firmware-package",
      "type": "firmware",
      "path_or_url": "https://example.com/watche-robot-esp32.zip",
      "sha256": "abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789",
      "required": true
    }
  ],
  "checks": {
    "readiness_script": "passed",
    "hardware_smoke": "failed",
    "clean_machine": "passed"
  }
}
'@

$MissingArtifactsManifest = @'
{
  "version": "v0.1.0-alpha",
  "release_date": "2026-06-11",
  "release_url": "https://example.com/releases/v0.1.0-alpha",
  "components": {
    "workspace": "0123456",
    "app": "1234567",
    "desktop": "2345678",
    "server": "3456789",
    "esp32": "456789a",
    "stm32": "56789ab"
  },
  "checks": {
    "readiness_script": "passed",
    "hardware_smoke": "passed",
    "clean_machine": "passed"
  }
}
'@

$MissingRequiredComponentsManifest = @'
{
  "version": "v0.1.0-alpha",
  "release_date": "2026-06-11",
  "release_url": "https://example.com/releases/v0.1.0-alpha",
  "components": {
    "workspace": "0123456"
  },
  "artifacts": [
    {
      "name": "desktop-windows-installer",
      "type": "desktop-installer",
      "path_or_url": "https://example.com/watche-robot-setup.exe",
      "sha256": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
      "required": true
    },
    {
      "name": "esp32-firmware-package",
      "type": "firmware",
      "path_or_url": "https://example.com/watche-robot-esp32.zip",
      "sha256": "abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789",
      "required": true
    }
  ],
  "checks": {
    "readiness_script": "passed",
    "hardware_smoke": "passed",
    "clean_machine": "passed"
  }
}
'@

try {
  $PlaceholderPath = Set-FixtureFile "placeholder.json" $PlaceholderManifest
  Assert-ExitCode -Result (Invoke-ManifestValidation -ManifestPath $PlaceholderPath -AllowPlaceholders) -Expected 0 -CaseName "placeholder manifest with AllowPlaceholders"
  Assert-ExitCode -Result (Invoke-ManifestValidation -ManifestPath $PlaceholderPath) -Expected 1 -CaseName "placeholder manifest without AllowPlaceholders"

  $ValidPath = Set-FixtureFile "valid.json" $ValidManifest
  Assert-ExitCode -Result (Invoke-ManifestValidation -ManifestPath $ValidPath) -Expected 0 -CaseName "valid final manifest"
  Assert-ExitCode -Result (Invoke-ManifestValidation -ManifestPath $ValidPath -ParameterName "Path") -Expected 0 -CaseName "valid final manifest through Path alias"

  $InvalidComponentRefPath = Set-FixtureFile "invalid-component-ref.json" $InvalidComponentRefManifest
  Assert-ExitCode -Result (Invoke-ManifestValidation -ManifestPath $InvalidComponentRefPath) -Expected 1 -CaseName "invalid release component ref manifest"

  $InvalidVersionPath = Set-FixtureFile "invalid-version.json" $InvalidVersionManifest
  Assert-ExitCode -Result (Invoke-ManifestValidation -ManifestPath $InvalidVersionPath) -Expected 1 -CaseName "invalid release version manifest"

  $FutureReleaseDatePath = Set-FixtureFile "future-release-date.json" $FutureReleaseDateManifest
  Assert-ExitCode -Result (Invoke-ManifestValidation -ManifestPath $FutureReleaseDatePath) -Expected 1 -CaseName "future release date manifest"

  $InvalidReleaseUrlPath = Set-FixtureFile "invalid-release-url.json" $InvalidReleaseUrlManifest
  Assert-ExitCode -Result (Invoke-ManifestValidation -ManifestPath $InvalidReleaseUrlPath) -Expected 1 -CaseName "invalid release url manifest"

  $InvalidShaPath = Set-FixtureFile "invalid-sha.json" $InvalidShaManifest
  Assert-ExitCode -Result (Invoke-ManifestValidation -ManifestPath $InvalidShaPath) -Expected 1 -CaseName "invalid sha manifest"

  $InvalidArtifactLocationPath = Set-FixtureFile "invalid-artifact-location.json" $InvalidArtifactLocationManifest
  Assert-ExitCode -Result (Invoke-ManifestValidation -ManifestPath $InvalidArtifactLocationPath) -Expected 1 -CaseName "invalid artifact location manifest"

  $DuplicateArtifactNamePath = Set-FixtureFile "duplicate-artifact-name.json" $DuplicateArtifactNameManifest
  Assert-ExitCode -Result (Invoke-ManifestValidation -ManifestPath $DuplicateArtifactNamePath) -Expected 1 -CaseName "duplicate artifact name manifest"

  $StringRequiredFlagPath = Set-FixtureFile "string-required-flag.json" $StringRequiredFlagManifest
  Assert-ExitCode -Result (Invoke-ManifestValidation -ManifestPath $StringRequiredFlagPath) -Expected 1 -CaseName "string required flag manifest"

  $NonArtifactPlaceholderPath = Set-FixtureFile "non-artifact-placeholder.json" $NonArtifactPlaceholderManifest
  Assert-ExitCode -Result (Invoke-ManifestValidation -ManifestPath $NonArtifactPlaceholderPath) -Expected 1 -CaseName "non-artifact placeholder manifest"

  $MissingRequiredArtifactPath = Set-FixtureFile "missing-required-artifact.json" $MissingRequiredArtifactManifest
  Assert-ExitCode -Result (Invoke-ManifestValidation -ManifestPath $MissingRequiredArtifactPath) -Expected 1 -CaseName "missing required release artifact manifest"

  $MissingReleaseUrlPath = Set-FixtureFile "missing-release-url.json" $MissingReleaseUrlManifest
  Assert-ExitCode -Result (Invoke-ManifestValidation -ManifestPath $MissingReleaseUrlPath) -Expected 1 -CaseName "missing release url manifest"

  $MissingRequiredChecksPath = Set-FixtureFile "missing-required-checks.json" $MissingRequiredChecksManifest
  Assert-ExitCode -Result (Invoke-ManifestValidation -ManifestPath $MissingRequiredChecksPath) -Expected 1 -CaseName "missing required release checks manifest"

  $FailedRequiredCheckPath = Set-FixtureFile "failed-required-check.json" $FailedRequiredCheckManifest
  Assert-ExitCode -Result (Invoke-ManifestValidation -ManifestPath $FailedRequiredCheckPath) -Expected 1 -CaseName "failed required release check manifest"

  $MissingArtifactsPath = Set-FixtureFile "missing-artifacts.json" $MissingArtifactsManifest
  Assert-ExitCode -Result (Invoke-ManifestValidation -ManifestPath $MissingArtifactsPath) -Expected 1 -CaseName "missing artifacts manifest"

  $MissingRequiredComponentsPath = Set-FixtureFile "missing-required-components.json" $MissingRequiredComponentsManifest
  Assert-ExitCode -Result (Invoke-ManifestValidation -ManifestPath $MissingRequiredComponentsPath) -Expected 1 -CaseName "missing required release components manifest"

  Write-Host "Release manifest validation regression tests passed."
} finally {
  if (Test-Path -LiteralPath $FixtureRoot) {
    $ResolvedFixture = [System.IO.Path]::GetFullPath($FixtureRoot)
    $ResolvedTemp = [System.IO.Path]::GetFullPath($TempBase)
    if ($ResolvedFixture.StartsWith($ResolvedTemp, [System.StringComparison]::OrdinalIgnoreCase)) {
      Remove-Item -LiteralPath $FixtureRoot -Recurse -Force
    }
  }
}
