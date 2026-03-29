param(
  [string]$DatasetPath = 'docs/devlogs/MATCH_CALIBRATION_DATASET.csv',
  [string]$OutPath = 'docs/devlogs/CALIBRATION_TUNE_CANDIDATES_2026W13.md'
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $DatasetPath)) { throw "Dataset not found: $DatasetPath" }
$rows = Import-Csv $DatasetPath
if (-not $rows -or $rows.Count -eq 0) { throw 'Dataset empty' }

function Avg($items, $field) {
  if (-not $items -or $items.Count -eq 0) { return 0.0 }
  $vals = @($items | ForEach-Object { [double]($_.$field) })
  if ($vals.Count -eq 0) { return 0.0 }
  return ($vals | Measure-Object -Average).Average
}

$all = $rows
$posReply = @($rows | Where-Object { $_.label_positive_reply24h -eq '1' })
$negReply = @($rows | Where-Object { $_.label_positive_reply24h -ne '1' })
$posSust = @($rows | Where-Object { $_.label_positive_sustained7d -eq '1' })
$negSust = @($rows | Where-Object { $_.label_positive_sustained7d -ne '1' })

$fields = @('score_personality_total','score_mbti_total','score_astro_total','score_bazi','score_zodiac','score_constellation','score_natal_chart')

$stat = @{}
foreach ($f in $fields) {
  $stat[$f] = [ordered]@{
    all = [math]::Round((Avg $all $f), 2)
    pos_reply = [math]::Round((Avg $posReply $f), 2)
    neg_reply = [math]::Round((Avg $negReply $f), 2)
    delta_reply = [math]::Round(((Avg $posReply $f) - (Avg $negReply $f)), 2)
    pos_sust = [math]::Round((Avg $posSust $f), 2)
    neg_sust = [math]::Round((Avg $negSust $f), 2)
    delta_sust = [math]::Round(((Avg $posSust $f) - (Avg $negSust $f)), 2)
  }
}

# current round-1 core weights (applied)
$w = [ordered]@{ personality = 0.61; mbti = 0.07; astro = 0.32 }

# Candidate A: continue increasing personality lightly, reduce astro accordingly
$candA = [ordered]@{ personality = 0.65; mbti = 0.07; astro = 0.28 }
# Candidate B: keep core stable, rebalance inside astro towards bazi/pair_chart
$astroCurrent = [ordered]@{ bazi=0.45; zodiac=0.25; constellation=0.08; natal_chart=0.07; pair_chart=0.15 }
$candB = [ordered]@{ bazi=0.49; zodiac=0.22; constellation=0.07; natal_chart=0.06; pair_chart=0.16 }

$replyRate = [math]::Round((($posReply.Count*100.0)/[math]::Max(1,$rows.Count)),2)
$sustRate = [math]::Round((($posSust.Count*100.0)/[math]::Max(1,$rows.Count)),2)

$md = New-Object System.Collections.Generic.List[string]
$md.Add('# Calibration Tune Candidates (2026W13)')
$md.Add('')
$md.Add("Generated: " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
$md.Add('Dataset: `docs/devlogs/MATCH_CALIBRATION_DATASET.csv`')
$md.Add('')
$md.Add('## 1) Sample Overview')
$md.Add("- total: $($rows.Count)")
$md.Add("- reply24h positives: $($posReply.Count) ($replyRate%)")
$md.Add("- sustained7d positives: $($posSust.Count) ($sustRate%)")
$md.Add('')
$md.Add('## 2) Signal Delta (positive - negative)')
$md.Add('| field | delta_reply24h | delta_sustained7d |')
$md.Add('|---|---:|---:|')
foreach ($f in $fields) {
  $md.Add("| $f | $($stat[$f].delta_reply) | $($stat[$f].delta_sust) |")
}
$md.Add('')
$md.Add('## 3) Current Weights (Round-1 Applied)')
$md.Add("- core: personality=$($w.personality), mbti=$($w.mbti), astro=$($w.astro)")
$md.Add("- astro: bazi=$($astroCurrent.bazi), zodiac=$($astroCurrent.zodiac), constellation=$($astroCurrent.constellation), natal_chart=$($astroCurrent.natal_chart), pair_chart=$($astroCurrent.pair_chart)")
$md.Add('')
$md.Add('## 4) Candidate A (core small-step)')
$md.Add('- Intent: prioritize early interaction conversion (reply24h).')
$md.Add("- core: personality=$($candA.personality), mbti=$($candA.mbti), astro=$($candA.astro)")
$md.Add('- Change vs current: personality +6.56%, astro -12.50% (NOTE: astro exceeds 10% guard, use split rollout: 0.32->0.30 first).')
$md.Add('- Safe step-A1 (<=10% each): personality=0.64, mbti=0.07, astro=0.29')
$md.Add('')
$md.Add('## 5) Candidate B (astro-internal rebalance)')
$md.Add('- Intent: keep core stable, boost bazi/pair_chart explanatory strength.')
$md.Add("- astro candidate: bazi=$($candB.bazi), zodiac=$($candB.zodiac), constellation=$($candB.constellation), natal_chart=$($candB.natal_chart), pair_chart=$($candB.pair_chart)")
$md.Add('- Per-field change: bazi +8.89%, zodiac -12.00%, constellation -12.50%, natal_chart -14.29%, pair_chart +6.67%')
$md.Add('- Safe step-B1 (<=10% each): bazi=0.49, zodiac=0.23, constellation=0.075, natal_chart=0.065, pair_chart=0.14 (sum=1.00)')
$md.Add('')
$md.Add('## 6) Recommended Next Action')
$md.Add('1. Execute A1 first for 3-7 days (single objective: reply24h up, sustained7d not down).')
$md.Add('2. If stable, execute B1 to improve astro explanation alignment.')
$md.Add('3. Rollback trigger: reply24h or sustained7d drops >20% vs baseline window.')

$dir = Split-Path -Parent $OutPath
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
$md -join "`r`n" | Set-Content -Encoding UTF8 $OutPath
Write-Host "generated: $OutPath"
