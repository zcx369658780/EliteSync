param(
  [string]$WeekTag = '',
  [string]$ShadowJson = 'docs/devlogs/ASTRO_SHADOW_COMPARE.json',
  [string]$ShadowMd = 'docs/devlogs/ASTRO_SHADOW_COMPARE.md',
  [string]$OutcomeJson = 'docs/devlogs/PAIR_OUTCOME_METRICS.json',
  [string]$DatasetCsv = 'docs/devlogs/MATCH_CALIBRATION_DATASET.csv',
  [string]$OutPath = ''
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $ShadowJson) -and -not (Test-Path $ShadowMd)) { throw "Missing shadow source: $ShadowJson / $ShadowMd" }
if (-not (Test-Path $OutcomeJson)) { throw "Missing file: $OutcomeJson" }
if (-not (Test-Path $DatasetCsv)) { throw "Missing file: $DatasetCsv" }

if ([string]::IsNullOrWhiteSpace($WeekTag)) {
  $WeekTag = (Get-Date).ToString('yyyy') + 'W' + [System.Globalization.ISOWeek]::GetWeekOfYear([datetime]::Now).ToString('00')
}
if ([string]::IsNullOrWhiteSpace($OutPath)) {
  $OutPath = "docs/devlogs/CALIBRATION_WEEKLY_REPORT_${WeekTag}_AUTO.md"
}

$shadowSummary = $null
try {
  if (Test-Path $ShadowJson) {
    $shadowObj = Get-Content -Raw $ShadowJson | ConvertFrom-Json
    $shadowSummary = $shadowObj.summary
  }
}
catch {
  $shadowSummary = $null
}

if ($null -eq $shadowSummary) {
  if (-not (Test-Path $ShadowMd)) { throw "Shadow JSON parse failed and MD missing: $ShadowMd" }
  $mdText = Get-Content -Raw $ShadowMd
  $anyRate = 0
  if ($mdText -match 'any_diff:\s*\d+\s*\(([\d\.]+)%\)') { $anyRate = [double]$Matches[1] }
  $topDims = @()
  $topUsers = @()
  $lines = Get-Content $ShadowMd
  $inDims = $false
  $inUsers = $false
  foreach ($ln in $lines) {
    if ($ln -match '^##\s+Top Diff Dimensions') { $inDims = $true; $inUsers = $false; continue }
    if ($ln -match '^##\s+Top Diff Users') { $inDims = $false; $inUsers = $true; continue }
    if ($ln -match '^##\s+') { $inDims = $false; $inUsers = $false; continue }
    if ($inDims -and $ln -match '^-+\s*([a-zA-Z0-9_]+):\s*(\d+)') {
      $topDims += [pscustomobject]@{ dimension = $Matches[1]; count = [int]$Matches[2] }
    }
    if ($inUsers -and $ln -match '^-+\s*user\s+(\d+):\s*(\d+)') {
      $topUsers += [pscustomobject]@{ user_id = [int]$Matches[1]; diff_score = [int]$Matches[2] }
    }
  }
  $shadowSummary = [pscustomobject]@{
    any_diff_rate_pct = $anyRate
    top_diff_dimensions = $topDims
    top_diff_users = $topUsers
  }
}
$outcome = Get-Content -Raw $OutcomeJson | ConvertFrom-Json
$rows = Import-Csv $DatasetCsv

$total = @($rows).Count
$replyPos = @($rows | Where-Object { $_.label_positive_reply24h -eq '1' }).Count
$sustPos = @($rows | Where-Object { $_.label_positive_sustained7d -eq '1' }).Count
$degradedRows = 0
foreach ($r in $rows) {
  $hit = $false
  foreach ($p in $r.PSObject.Properties) {
    if ($p.Name -like 'm_*_degraded' -and [int]$p.Value -eq 1) { $hit = $true; break }
  }
  if ($hit) { $degradedRows++ }
}

$replyPct = [math]::Round(($replyPos * 100.0) / [math]::Max(1, $total), 2)
$sustPct = [math]::Round(($sustPos * 100.0) / [math]::Max(1, $total), 2)
$degradedPct = [math]::Round(($degradedRows * 100.0) / [math]::Max(1, $total), 2)

$summary = $shadowSummary
$topDims = @($summary.top_diff_dimensions | Select-Object -First 3)
$topUsers = @($summary.top_diff_users | Select-Object -First 3)
$o = $outcome.summary
$win = $outcome.window
$includeInjected = $false
if ($win.PSObject.Properties.Name -contains 'include_calibration_injected') {
  $includeInjected = [bool]$win.include_calibration_injected
}

$md = New-Object System.Collections.Generic.List[string]
$md.Add("# Calibration Weekly Report ($WeekTag) [AUTO]")
$md.Add("")
$md.Add("Generated: " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
$md.Add("Sources:")
$md.Add("- $ShadowJson")
$md.Add("- $ShadowMd")
$md.Add("- $OutcomeJson")
$md.Add("- $DatasetCsv")
$md.Add("")
$md.Add("## 1. Window")
$md.Add("- WeekTag: $WeekTag")
$md.Add("- Outcome days: $($win.days)")
$md.Add("- Week filter in outcome: " + ($(if ([string]::IsNullOrWhiteSpace([string]$win.week_tag)) { '(none)' } else { [string]$win.week_tag })))
$md.Add("- Include calibration injected: " + ($(if ($includeInjected) { 'true' } else { 'false' })))
$md.Add("")
$md.Add("## 2. Shadow Compare Summary")
$md.Add("- any_diff_rate_pct: $($summary.any_diff_rate_pct)")
$md.Add("- top_diff_dimensions (Top 3):")
for ($i = 0; $i -lt $topDims.Count; $i++) {
  $d = $topDims[$i]
  $md.Add(('{0}. {1} ({2})' -f ($i+1), [string]$d.dimension, [string]$d.count))
}
$md.Add("- top_diff_users (Top 3):")
for ($i = 0; $i -lt $topUsers.Count; $i++) {
  $u = $topUsers[$i]
  $md.Add(('{0}. user_id={1} (diff_score={2})' -f ($i+1), [string]$u.user_id, [string]$u.diff_score))
}
$md.Add("")
$md.Add("## 3. Outcome Funnel Summary")
$md.Add("- total_pairs: $($o.total_pairs)")
$md.Add("- mutual_like_rate_pct: $($o.mutual_like_rate_pct)")
$md.Add("- first_message_rate_pct: $($o.first_message_rate_pct)")
$md.Add("- reply_24h_rate_pct: $($o.reply_24h_rate_pct)")
$md.Add("- sustained_7d_rate_pct: $($o.sustained_7d_rate_pct)")
$md.Add("- explanation_view_rate_pct: $($o.explanation_view_rate_pct)")
$md.Add("")
$md.Add("## 4. Calibration Dataset Snapshot")
$md.Add("- rows: $total")
$md.Add("- positive label (reply24h) ratio: $replyPct%")
$md.Add("- positive label (sustained7d) ratio: $sustPct%")
$md.Add("- degraded sample ratio: $degradedPct%")
$md.Add("")
$md.Add("## 5. Notes")
$md.Add("- This file is auto-generated for advisor handoff.")
$md.Add("- If calibration injector is enabled, do not treat metrics as production KPI.")
$md.Add("- Use this report with `docs/devlogs/CALIBRATION_CYCLE_LOG.md` for context.")

$outDir = Split-Path -Parent $OutPath
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
$md -join "`r`n" | Set-Content -Encoding UTF8 $OutPath

Write-Host "generated: $OutPath"
