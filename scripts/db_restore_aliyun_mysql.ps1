Param(
    [Parameter(Mandatory = $true)]
    [string]$BackupGzPath,
    [string]$ServerHost = "101.133.161.203",
    [string]$User = "root",
    [string]$KeyPath = "$env:USERPROFILE\.ssh\CodexKey.pem",
    [string]$RemoteRoot = "/opt/elitesync",
    [string]$TargetDatabase = "elitesync_restore"
)

$ErrorActionPreference = "Stop"

function Assert-Tool([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Missing required command: $Name"
    }
}

Assert-Tool "ssh"
Assert-Tool "scp"

if (-not (Test-Path $KeyPath)) {
    throw "SSH key not found: $KeyPath"
}

if (-not (Test-Path $BackupGzPath)) {
    throw "Backup archive not found: $BackupGzPath"
}

$backupBase = [IO.Path]::GetFileNameWithoutExtension([IO.Path]::GetFileNameWithoutExtension($BackupGzPath))
$remoteTmp = "/tmp/$([IO.Path]::GetFileName($BackupGzPath))"

Write-Host "Uploading backup archive..."
scp -o StrictHostKeyChecking=no -i $KeyPath "$BackupGzPath" "${User}@${ServerHost}:$remoteTmp"

$remoteScript = @'
set -euo pipefail
ARCHIVE="__REMOTE_TMP__"
TARGET_DB="__TARGET_DB__"

if command -v mysql >/dev/null 2>&1; then
  MYSQL_BIN=mysql
elif command -v mariadb >/dev/null 2>&1; then
  MYSQL_BIN=mariadb
else
  echo "mysql/mariadb client not found" >&2
  exit 1
fi

if [ ! -f "__REMOTE_ROOT__/services/backend-laravel/.env" ]; then
  echo "Missing .env at __REMOTE_ROOT__/services/backend-laravel/.env" >&2
  exit 1
fi

get_env() {
  local key="$1"
  grep -E "^${key}=" "__REMOTE_ROOT__/services/backend-laravel/.env" | tail -n 1 | cut -d= -f2- | tr -d '"' | tr -d '\r'
}

DB_HOST=$(get_env DB_HOST)
DB_PORT=$(get_env DB_PORT)
DB_USERNAME=$(get_env DB_USERNAME)
DB_PASSWORD=$(get_env DB_PASSWORD)

if [ -z "$DB_PASSWORD" ] || [ "$DB_PASSWORD" = "null" ]; then
  export MYSQL_PWD=""
else
  export MYSQL_PWD="$DB_PASSWORD"
fi

if sudo -n true >/dev/null 2>&1; then
  sudo mysql -e "CREATE DATABASE IF NOT EXISTS \`$TARGET_DB\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  sudo bash -lc "gzip -dc '$ARCHIVE' | mysql '$TARGET_DB'"
elif command -v mysql >/dev/null 2>&1; then
  mysql -uroot -e "CREATE DATABASE IF NOT EXISTS \`$TARGET_DB\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  bash -lc "gzip -dc '$ARCHIVE' | mysql -uroot '$TARGET_DB'"
elif command -v mariadb >/dev/null 2>&1; then
  mariadb -uroot -e "CREATE DATABASE IF NOT EXISTS \`$TARGET_DB\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  bash -lc "gzip -dc '$ARCHIVE' | mariadb -uroot '$TARGET_DB'"
else
  echo "No usable DB admin command found" >&2
  exit 1
fi
'@

$remoteScript = $remoteScript.Replace('__REMOTE_TMP__', $remoteTmp).Replace('__TARGET_DB__', $TargetDatabase).Replace('__REMOTE_ROOT__', $RemoteRoot)

$tmpRemoteScript = Join-Path $env:TEMP "elitesync_remote_mysql_restore.sh"
[System.IO.File]::WriteAllText($tmpRemoteScript, ($remoteScript -replace "`r`n", "`n"), (New-Object System.Text.UTF8Encoding($false)))

scp -o StrictHostKeyChecking=no -i $KeyPath "$tmpRemoteScript" "${User}@${ServerHost}:/tmp/elitesync_remote_mysql_restore.sh" | Out-Null
ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $KeyPath "${User}@${ServerHost}" "bash /tmp/elitesync_remote_mysql_restore.sh"

Write-Host "Restore completed to database: $TargetDatabase"
