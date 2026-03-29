param(
  [ValidateSet('baseline','a1','b1')]
  [string]$Profile = 'b1',
  [string]$ServerHost = '101.133.161.203',
  [string]$User = 'root',
  [string]$KeyPath = "$env:USERPROFILE\.ssh\CodexKey.pem",
  [string]$RemoteDir = '/opt/elitesync/services/backend-laravel'
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path $KeyPath)) { throw "SSH key not found: $KeyPath" }

$profiles = @{
  baseline = @{
    MATCH_WEIGHT_PERSONALITY = '0.58'
    MATCH_WEIGHT_MBTI = '0.07'
    MATCH_WEIGHT_ASTRO = '0.35'
    MATCH_ASTRO_WEIGHT_BAZI = '0.45'
    MATCH_ASTRO_WEIGHT_ZODIAC = '0.25'
    MATCH_ASTRO_WEIGHT_CONSTELLATION = '0.08'
    MATCH_ASTRO_WEIGHT_NATAL_CHART = '0.07'
    MATCH_ASTRO_WEIGHT_PAIR_CHART = '0.15'
  }
  a1 = @{
    MATCH_WEIGHT_PERSONALITY = '0.64'
    MATCH_WEIGHT_MBTI = '0.07'
    MATCH_WEIGHT_ASTRO = '0.29'
    MATCH_ASTRO_WEIGHT_BAZI = '0.45'
    MATCH_ASTRO_WEIGHT_ZODIAC = '0.25'
    MATCH_ASTRO_WEIGHT_CONSTELLATION = '0.08'
    MATCH_ASTRO_WEIGHT_NATAL_CHART = '0.07'
    MATCH_ASTRO_WEIGHT_PAIR_CHART = '0.15'
  }
  b1 = @{
    MATCH_WEIGHT_PERSONALITY = '0.64'
    MATCH_WEIGHT_MBTI = '0.07'
    MATCH_WEIGHT_ASTRO = '0.29'
    MATCH_ASTRO_WEIGHT_BAZI = '0.49'
    MATCH_ASTRO_WEIGHT_ZODIAC = '0.23'
    MATCH_ASTRO_WEIGHT_CONSTELLATION = '0.075'
    MATCH_ASTRO_WEIGHT_NATAL_CHART = '0.065'
    MATCH_ASTRO_WEIGHT_PAIR_CHART = '0.14'
  }
}

$selected = $profiles[$Profile]
if (-not $selected) { throw "Unknown profile: $Profile" }

$lines = @(
  'set -e',
  "cd $RemoteDir",
  "cp .env .env.bak_`$(date +%Y%m%d_%H%M%S)_$Profile",
  @'
set_kv() {
  key="$1"; val="$2"
  if grep -q "^${key}=" .env; then
    sed -i "s/^${key}=.*/${key}=${val}/" .env
  else
    echo "${key}=${val}" >> .env
  fi
}
'@
)

foreach ($k in $selected.Keys) {
  $v = $selected[$k]
  $lines += "set_kv $k $v"
}

$lines += @(
  'php artisan config:cache',
  "echo 'APPLIED_PROFILE=$Profile'",
  "awk '/^(MATCH_WEIGHT_PERSONALITY|MATCH_WEIGHT_MBTI|MATCH_WEIGHT_ASTRO|MATCH_ASTRO_WEIGHT_BAZI|MATCH_ASTRO_WEIGHT_ZODIAC|MATCH_ASTRO_WEIGHT_CONSTELLATION|MATCH_ASTRO_WEIGHT_NATAL_CHART|MATCH_ASTRO_WEIGHT_PAIR_CHART)=/' .env"
)

$script = ($lines -join "`n")
$script = $script -replace "`r`n","`n"
$script = $script -replace "`r",""
$script = $script -replace "^\uFEFF",""

$tmpLocal = Join-Path $env:TEMP ("apply_match_tuning_" + [guid]::NewGuid().ToString("N") + ".sh")
[System.IO.File]::WriteAllText($tmpLocal, $script, (New-Object System.Text.UTF8Encoding($false)))
$tmpRemote = "/tmp/apply_match_tuning_$Profile.sh"

scp -o StrictHostKeyChecking=no -i $KeyPath $tmpLocal "$User@${ServerHost}:$tmpRemote" | Out-Null
ssh -o StrictHostKeyChecking=no -i $KeyPath "$User@$ServerHost" "bash $tmpRemote"
