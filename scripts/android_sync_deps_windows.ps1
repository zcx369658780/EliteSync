$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot\..\apps\android"

Write-Host "[1/2] Downloading Android/Gradle dependencies (including Material themes)..."
./gradlew.bat --refresh-dependencies :app:dependencies

Write-Host "[2/2] Running assembleDebug to validate resources..."
./gradlew.bat :app:assembleDebug
