Param(
    [string]$ProjectRoot = ".",
    [string]$ApiHost = "127.0.0.1",
    [int]$ApiPort = 8080,
    [int]$WsPort = 8081
)

$ErrorActionPreference = "SilentlyContinue"

Write-Host "== EliteSync Debug Readiness =="
Write-Host "ProjectRoot: $ProjectRoot"

Write-Host "`n[1/8] Docker"
docker --version
docker info | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Docker daemon: OK"
} else {
    Write-Host "Docker daemon: FAIL (start Docker Desktop or fix permissions)"
}

Write-Host "`n[2/8] PHP / Composer"
php -v | Select-Object -First 1
composer --version

Write-Host "`n[3/8] PHP Extensions"
$mods = php -m
if ($mods -match "^fileinfo$") {
    Write-Host "ext-fileinfo: OK"
} else {
    Write-Host "ext-fileinfo: MISSING"
}
if ($mods -match "^pdo_sqlite$") {
    Write-Host "ext-pdo_sqlite: OK"
} else {
    Write-Host "ext-pdo_sqlite: MISSING"
}
if ($mods -match "^sqlite3$") {
    Write-Host "ext-sqlite3: OK"
} else {
    Write-Host "ext-sqlite3: MISSING"
}

Write-Host "`n[4/8] Android Toolchain"
java -version
adb version

Write-Host "`n[5/8] Android Build"
Push-Location (Join-Path $ProjectRoot "apps/android")
.\gradlew.bat -q tasks --all | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Gradle wrapper: OK"
} else {
    Write-Host "Gradle wrapper: FAIL"
}
Pop-Location

Write-Host "`n[6/8] Backend DB File"
$dbFile = Join-Path $ProjectRoot "services/backend-laravel/database/database.sqlite"
if (Test-Path $dbFile) {
    Write-Host "SQLite file: OK ($dbFile)"
} else {
    Write-Host "SQLite file: MISSING ($dbFile)"
}

Write-Host "`n[7/8] Backend HTTP Health"
$healthUrl = "http://$ApiHost`:$ApiPort/up"
try {
    $resp = Invoke-WebRequest -Uri $healthUrl -TimeoutSec 3
    if ($resp.StatusCode -eq 200) {
        Write-Host "HTTP /up: OK ($healthUrl)"
    } else {
        Write-Host "HTTP /up: FAIL status=$($resp.StatusCode)"
    }
} catch {
    Write-Host "HTTP /up: FAIL ($healthUrl)"
}

Write-Host "`n[8/8] Backend WS Port"
$wsListen = Test-NetConnection -ComputerName $ApiHost -Port $WsPort -WarningAction SilentlyContinue
if ($wsListen.TcpTestSucceeded) {
    Write-Host "WS tcp://$ApiHost`:${WsPort}: OK"
} else {
    Write-Host "WS tcp://$ApiHost`:${WsPort}: FAIL"
}

Write-Host "`nDone."
