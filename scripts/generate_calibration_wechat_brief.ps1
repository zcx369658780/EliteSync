param(
  [string]$WeekTag = '',
  [string]$ReportPath = '',
  [string]$OutPath = ''
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($WeekTag)) {
  $WeekTag = (Get-Date).ToString('yyyy') + 'W' + [System.Globalization.ISOWeek]::GetWeekOfYear([datetime]::Now).ToString('00')
}
if ([string]::IsNullOrWhiteSpace($ReportPath)) {
  $ReportPath = "docs/devlogs/CALIBRATION_WEEKLY_REPORT_${WeekTag}_AUTO.md"
}
if ([string]::IsNullOrWhiteSpace($OutPath)) {
  $OutPath = "docs/devlogs/CALIBRATION_WECHAT_BRIEF_${WeekTag}.txt"
}
if (-not (Test-Path $ReportPath)) { throw "Report not found: $ReportPath" }

$content = Get-Content -Raw $ReportPath

function PickRate([string]$name) {
  if ($content -match ("- " + [regex]::Escape($name) + ":\s*([0-9]+(?:\.[0-9]+)?)")) {
    return $Matches[1]
  }
  return "N/A"
}

function PickInt([string]$name) {
  if ($content -match ("- " + [regex]::Escape($name) + ":\s*([0-9]+)")) {
    return $Matches[1]
  }
  return "N/A"
}

$totalPairs = PickInt "total_pairs"
$reply = PickRate "reply_24h_rate_pct"
$sustain = PickRate "sustained_7d_rate_pct"
$firstMsg = PickRate "first_message_rate_pct"
$mutual = PickRate "mutual_like_rate_pct"
$anyDiff = PickRate "any_diff_rate_pct"
$degraded = PickRate "degraded sample ratio"

$lines = @()
$lines += "[Calibration Weekly Brief $WeekTag]"
$lines += "1) Sample size: $totalPairs pairs; mutual_like=$mutual%, first_message=$firstMsg%."
$lines += "2) Core conversion: reply_24h=$reply%, sustained_7d=$sustain%."
$lines += "3) Shadow compare: any_diff_rate=$anyDiff%; current top gaps remain in house/aspect support."
$lines += "4) Data quality: degraded_sample_ratio=$degraded. Current round is for tuning validation, not production KPI claim."
$lines += "5) Decision: keep small-step tuning + gray rollout; re-check with real user samples next cycle."

$outDir = Split-Path -Parent $OutPath
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
$lines -join "`r`n" | Set-Content -Encoding UTF8 $OutPath

Write-Host "generated: $OutPath"

