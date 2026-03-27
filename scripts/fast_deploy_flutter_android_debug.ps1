param(
    [string]$DeviceId = "emulator-5554",
    [switch]$SkipAar
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$androidDir = Join-Path $repoRoot "apps\android"
$apkPath = Join-Path $androidDir "app\build\outputs\apk\debug\app-debug.apk"
$aarScript = Join-Path $repoRoot "scripts\build_flutter_module_aar.ps1"

if (-not $SkipAar) {
    & powershell -ExecutionPolicy Bypass -File $aarScript -DebugOnly
}

Push-Location $androidDir
try {
    & .\gradlew.bat :app:assembleDebug
} finally {
    Pop-Location
}

& adb -s $DeviceId install -r $apkPath
& adb -s $DeviceId shell am start -n "com.elitesync/com.elitesync.MainActivity"

Write-Host ("Deployed to {0}: {1}" -f $DeviceId, $apkPath)
