Param(
    [string]$ServerHost = "101.133.161.203",
    [string]$User = "root",
    [string]$KeyPath = "$env:USERPROFILE\.ssh\CodexKey.pem",
    [string]$RemoteRoot = "/opt/elitesync",
    [string]$RemoteBackupRoot = "/opt/backups/elitesync/mysql",
    [string]$LocalBackupRoot = (Join-Path (Resolve-Path "$PSScriptRoot\..").Path "backups\aliyun_mysql")
)

$ErrorActionPreference = "Stop"

function Assert-Tool([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Missing required command: $Name"
    }
}

function Run-Step([string]$Title, [scriptblock]$Action) {
    Write-Host "==> $Title"
    & $Action
    if ($LASTEXITCODE -ne 0) {
        throw "Step failed: $Title (exit=$LASTEXITCODE)"
    }
    Write-Host "OK: $Title"
}

Assert-Tool "ssh"
Assert-Tool "scp"

if (-not (Test-Path $KeyPath)) {
    throw "SSH key not found: $KeyPath"
}

$repoRoot = (Resolve-Path "$PSScriptRoot\..").Path
$tmpRemoteScript = Join-Path $env:TEMP "elitesync_remote_mysql_backup.sh"
New-Item -ItemType Directory -Force -Path $LocalBackupRoot | Out-Null

$remoteScript = @'
set -euo pipefail

BACKUP_ROOT="__REMOTE_BACKUP_ROOT__"
APP_DIR="__REMOTE_ROOT__/services/backend-laravel"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RUN_DIR="$BACKUP_ROOT/$TIMESTAMP"
mkdir -p "$RUN_DIR"

if [ ! -f "$APP_DIR/.env" ]; then
  echo "Missing .env at $APP_DIR/.env" >&2
  exit 1
fi

get_env() {
  local key="$1"
  grep -E "^${key}=" "$APP_DIR/.env" | tail -n 1 | cut -d= -f2- | tr -d '"' | tr -d '\r'
}

DB_CONNECTION=$(get_env DB_CONNECTION)
DB_HOST=$(get_env DB_HOST)
DB_PORT=$(get_env DB_PORT)
DB_DATABASE=$(get_env DB_DATABASE)
DB_USERNAME=$(get_env DB_USERNAME)
DB_PASSWORD=$(get_env DB_PASSWORD)

if [ -z "${DB_HOST}" ] || [ -z "${DB_DATABASE}" ] || [ -z "${DB_USERNAME}" ]; then
  echo "Missing DB settings in .env" >&2
  exit 1
fi

if command -v mysqldump >/dev/null 2>&1; then
  DUMP_BIN=mysqldump
elif command -v mariadb-dump >/dev/null 2>&1; then
  DUMP_BIN=mariadb-dump
else
  echo "Neither mysqldump nor mariadb-dump found" >&2
  exit 1
fi

if command -v mysql >/dev/null 2>&1; then
  MYSQL_BIN=mysql
elif command -v mariadb >/dev/null 2>&1; then
  MYSQL_BIN=mariadb
else
  echo "Neither mysql nor mariadb client found" >&2
  exit 1
fi

SQL_FILE="$RUN_DIR/elitesync_${TIMESTAMP}.sql"
GZ_FILE="$SQL_FILE.gz"
SHA_FILE="$GZ_FILE.sha256"
MANIFEST_FILE="$RUN_DIR/manifest.json"

if [ -n "$DB_PASSWORD" ] && [ "$DB_PASSWORD" != "null" ]; then
  export MYSQL_PWD="$DB_PASSWORD"
fi

"$DUMP_BIN" \
  -h "$DB_HOST" \
  -P "$DB_PORT" \
  -u "$DB_USERNAME" \
  --single-transaction \
  --routines \
  --triggers \
  --events \
  "$DB_DATABASE" > "$SQL_FILE"

gzip -f "$SQL_FILE"
sha256sum "$GZ_FILE" | awk '{print $1"  "$2}' > "$SHA_FILE"
TABLES=$("$MYSQL_BIN" -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USERNAME" -N -B -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_DATABASE';")
ROWS=$("$MYSQL_BIN" -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USERNAME" -N -B -e "SELECT COALESCE(SUM(table_rows), 0) FROM information_schema.tables WHERE table_schema='$DB_DATABASE';")

cat > "$MANIFEST_FILE" <<EOF
{
  "timestamp": "$TIMESTAMP",
  "database": "$DB_DATABASE",
  "db_host": "$DB_HOST",
  "db_port": "$DB_PORT",
  "tables": "$TABLES",
  "rows_estimated": "$ROWS",
  "sql_gz": "$(basename "$GZ_FILE")",
  "sha256_file": "$(basename "$SHA_FILE")"
}
EOF

find "$RUN_DIR" -maxdepth 1 -type f | sort
'@

$remoteScript = $remoteScript.Replace('__REMOTE_BACKUP_ROOT__', $RemoteBackupRoot).Replace('__REMOTE_ROOT__', $RemoteRoot)

$remoteScriptLf = ($remoteScript -replace "`r`n", "`n")
[System.IO.File]::WriteAllText($tmpRemoteScript, $remoteScriptLf, (New-Object System.Text.UTF8Encoding($false)))

Run-Step "Ensure remote backup directory" {
    ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $KeyPath "$User@$ServerHost" `
        "mkdir -p $RemoteBackupRoot"
}

Run-Step "Run remote MySQL backup" {
    scp -o StrictHostKeyChecking=no -i $KeyPath `
        "$tmpRemoteScript" `
        "$User@${ServerHost}:/tmp/elitesync_remote_mysql_backup.sh"
    ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $KeyPath "$User@$ServerHost" `
        "bash /tmp/elitesync_remote_mysql_backup.sh"
}

$latestRunDir = ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $KeyPath "$User@$ServerHost" `
    "find $RemoteBackupRoot -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1"

if ([string]::IsNullOrWhiteSpace($latestRunDir)) {
    throw "Remote backup did not produce a run directory."
}

Run-Step "Download backup artifacts" {
    $localRunDir = Join-Path $LocalBackupRoot ([IO.Path]::GetFileName($latestRunDir.Trim()))
    New-Item -ItemType Directory -Force -Path $localRunDir | Out-Null
    foreach ($pattern in @(
        "$latestRunDir/manifest.json",
        "$latestRunDir/*.sql.gz",
        "$latestRunDir/*.sha256"
    )) {
        scp -o StrictHostKeyChecking=no -i $KeyPath `
            "$User@${ServerHost}:$pattern" `
            "$localRunDir\"
    }
}

Write-Host ""
Write-Host "Backup completed."
Write-Host "Remote run: $latestRunDir"
Write-Host "Local root: $LocalBackupRoot"
