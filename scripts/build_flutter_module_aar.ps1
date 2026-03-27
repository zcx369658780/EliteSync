param(
    [switch]$DebugOnly
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$moduleDir = Join-Path $repoRoot "apps\flutter_elitesync_module"
$flutter = "C:\tools\flutter\bin\flutter.bat"

if (-not (Test-Path $flutter)) {
    throw "Flutter not found at $flutter"
}
if (-not (Test-Path $moduleDir)) {
    throw "Flutter module dir not found: $moduleDir"
}

Push-Location $moduleDir
try {
    & $flutter pub get
    if ($DebugOnly) {
        & $flutter build aar --debug --no-profile --no-release
    } else {
        & $flutter build aar --debug --release
    }
} finally {
    Pop-Location
}

Write-Host "Flutter module AAR built successfully."
