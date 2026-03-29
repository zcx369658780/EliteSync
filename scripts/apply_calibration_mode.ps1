param(
  [ValidateSet('off','inject_only','inject_and_include')]
  [string]$Mode = 'off',
  [string]$ServerHost = '101.133.161.203',
  [string]$User = 'root',
  [string]$KeyPath = "$env:USERPROFILE\.ssh\CodexKey.pem",
  [string]$RemoteDir = '/opt/elitesync/services/backend-laravel'
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path $KeyPath)) { throw "SSH key not found: $KeyPath" }

$enabled = if ($Mode -eq 'off') { 'false' } else { 'true' }
$allowProd = if ($Mode -eq 'off') { 'false' } else { 'true' }
$includeMetrics = if ($Mode -eq 'inject_and_include') { 'true' } else { 'false' }

$lines = @(
  'set -e',
  "cd $RemoteDir",
  @'
set_kv() {
  key="$1"; val="$2"
  if grep -q "^${key}=" .env; then
    sed -i "s/^${key}=.*/${key}=${val}/" .env
  else
    echo "${key}=${val}" >> .env
  fi
}
'@,
  "set_kv MATCHING_CALIBRATION_INJECTOR_ENABLED $enabled",
  "set_kv MATCHING_CALIBRATION_INJECTOR_ALLOW_IN_PRODUCTION $allowProd",
  "set_kv MATCHING_CALIBRATION_INCLUDE_IN_METRICS $includeMetrics",
  'php artisan config:cache >/dev/null 2>&1',
  "echo `"CALIBRATION_MODE=$Mode`"",
  "awk '/^(MATCHING_CALIBRATION_INJECTOR_ENABLED|MATCHING_CALIBRATION_INJECTOR_ALLOW_IN_PRODUCTION|MATCHING_CALIBRATION_INCLUDE_IN_METRICS)=/' .env"
)
$script = ($lines -join "`n")

$script = $script -replace "`r`n","`n"
$script = $script -replace "`r",""
$tmpLocal = Join-Path $env:TEMP ("apply_calibration_mode_" + [guid]::NewGuid().ToString("N") + ".sh")
[System.IO.File]::WriteAllText($tmpLocal, $script, (New-Object System.Text.UTF8Encoding($false)))
$tmpRemote = "/tmp/apply_calibration_mode_$Mode.sh"

scp -o StrictHostKeyChecking=no -i $KeyPath $tmpLocal "$User@${ServerHost}:$tmpRemote" | Out-Null
ssh -o StrictHostKeyChecking=no -i $KeyPath "$User@$ServerHost" "bash $tmpRemote"
