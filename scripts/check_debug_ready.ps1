Param(
    [string]$ProjectRoot = "."
)

$ErrorActionPreference = "SilentlyContinue"

Write-Host "== EliteSync Debug Readiness =="
Write-Host "ProjectRoot: $ProjectRoot"

Write-Host "`n[1/5] Docker"
docker --version
docker info | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Docker daemon: OK"
} else {
    Write-Host "Docker daemon: FAIL (start Docker Desktop or fix permissions)"
}

Write-Host "`n[2/5] PHP / Composer"
php -v | Select-Object -First 1
composer --version

Write-Host "`n[3/5] PHP Extensions"
$mods = php -m
if ($mods -match "^fileinfo$") {
    Write-Host "ext-fileinfo: OK"
} else {
    Write-Host "ext-fileinfo: MISSING"
}

Write-Host "`n[4/5] Android Toolchain"
java -version
adb version

Write-Host "`n[5/5] Android Build"
Push-Location (Join-Path $ProjectRoot "apps/android")
.\gradlew.bat -q tasks --all | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Gradle wrapper: OK"
} else {
    Write-Host "Gradle wrapper: FAIL"
}
Pop-Location

Write-Host "`nDone."
