Param(
    [string]$ServerHost = "101.133.161.203",
    [string]$User = "root",
    [string]$KeyPath = "$env:USERPROFILE\.ssh\CodexKey.pem",
    [string]$RemoteRoot = "/opt/elitesync",
    [switch]$ValidateLocal,
    [switch]$SkipBackup,
    [switch]$SkipComposer,
    [switch]$SkipMigrate,
    [switch]$RunSeeder,
    [switch]$SkipServiceRestart
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
$backendDir = Join-Path $repoRoot "services\backend-laravel"
$questionBankDir = Join-Path $repoRoot "question_bank"
$infraNginx = Join-Path $repoRoot "infra\elitesync-nginx.conf"
$infraWsSvc = Join-Path $repoRoot "infra\elitesync-ws.service"
$backupScript = Join-Path $repoRoot "scripts\db_backup_aliyun_mysql.ps1"

if ($ValidateLocal) {
    Run-Step "Local backend quick check (artisan about)" {
        Push-Location $backendDir
        try {
            php artisan about | Out-Null
        }
        finally {
            Pop-Location
        }
    }
}

if (-not $SkipBackup) {
    if (-not (Test-Path $backupScript)) {
        throw "Backup script not found: $backupScript"
    }
    Run-Step "Pre-deploy database backup" {
        powershell -ExecutionPolicy Bypass -File $backupScript `
            -ServerHost $ServerHost `
            -User $User `
            -KeyPath $KeyPath `
            -RemoteRoot $RemoteRoot
    }
}

Run-Step "Ensure remote directories" {
    ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $KeyPath "$User@$ServerHost" `
        "mkdir -p $RemoteRoot/services $RemoteRoot/question_bank $RemoteRoot/infra"
}

Run-Step "Backup remote .env (if exists)" {
    ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $KeyPath "$User@$ServerHost" `
        "if [ -f $RemoteRoot/services/backend-laravel/.env ]; then cp $RemoteRoot/services/backend-laravel/.env /tmp/elitesync_backend.env.bak; fi"
}

Run-Step "Upload backend source" {
    scp -o StrictHostKeyChecking=no -i $KeyPath -r `
        "$backendDir" `
        "$User@${ServerHost}:$RemoteRoot/services/"
}

Run-Step "Restore remote .env" {
    ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $KeyPath "$User@$ServerHost" `
        "if [ -f /tmp/elitesync_backend.env.bak ]; then mv /tmp/elitesync_backend.env.bak $RemoteRoot/services/backend-laravel/.env; fi"
}

Run-Step "Upload question bank" {
    scp -o StrictHostKeyChecking=no -i $KeyPath -r `
        "$questionBankDir" `
        "$User@${ServerHost}:$RemoteRoot/"
}

if (Test-Path $infraNginx) {
    Run-Step "Upload nginx config" {
        scp -o StrictHostKeyChecking=no -i $KeyPath `
            "$infraNginx" `
            "$User@${ServerHost}:/etc/nginx/sites-available/elitesync.conf"
    }
}

if (Test-Path $infraWsSvc) {
    Run-Step "Upload websocket systemd unit" {
        scp -o StrictHostKeyChecking=no -i $KeyPath `
            "$infraWsSvc" `
            "$User@${ServerHost}:/etc/systemd/system/elitesync-ws.service"
    }
}

$doComposer = if ($SkipComposer) { "0" } else { "1" }
$doMigrate = if ($SkipMigrate) { "0" } else { "1" }
$doSeeder = if ($RunSeeder) { "1" } else { "0" }
$restart = if ($SkipServiceRestart) { "0" } else { "1" }

$remoteScript = @"
set -euo pipefail
cd $RemoteRoot/services/backend-laravel

if [ "$doComposer" = "1" ]; then
  export COMPOSER_ALLOW_SUPERUSER=1
  composer install --no-interaction --prefer-dist --optimize-autoloader
fi

php artisan optimize:clear

if [ "$doMigrate" = "1" ]; then
  php artisan migrate --force
fi

if [ "$doSeeder" = "1" ]; then
  php artisan db:seed --class=QuestionnaireQuestionSeeder --force
fi

php artisan config:cache
php artisan route:cache
php artisan view:cache

chown -R www-data:www-data storage bootstrap/cache || true
chmod -R ug+rwX storage bootstrap/cache || true

if [ -f /etc/nginx/sites-available/elitesync.conf ]; then
  rm -f /etc/nginx/sites-enabled/default || true
  ln -sf /etc/nginx/sites-available/elitesync.conf /etc/nginx/sites-enabled/elitesync.conf
  nginx -t
fi

if [ "$restart" = "1" ]; then
  systemctl daemon-reload
  systemctl restart php8.4-fpm
  systemctl restart nginx
  systemctl restart elitesync-ws
fi

systemctl is-active php8.4-fpm
systemctl is-active nginx
systemctl is-active elitesync-ws
curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1/up
"@

$tmpFile = Join-Path $env:TEMP "elitesync_remote_deploy.sh"
# Force LF line endings for remote bash execution.
$remoteScriptLf = ($remoteScript -replace "`r`n", "`n")
[System.IO.File]::WriteAllText($tmpFile, $remoteScriptLf, (New-Object System.Text.UTF8Encoding($false)))

Run-Step "Upload and run remote deploy script" {
    scp -o StrictHostKeyChecking=no -i $KeyPath `
        "$tmpFile" `
        "$User@${ServerHost}:/tmp/elitesync_remote_deploy.sh"

    ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $KeyPath "$User@$ServerHost" `
        "bash /tmp/elitesync_remote_deploy.sh"
}

Write-Host ""
Write-Host "Deploy completed."
Write-Host "API: http://$ServerHost"
Write-Host "Health: http://$ServerHost/up"
