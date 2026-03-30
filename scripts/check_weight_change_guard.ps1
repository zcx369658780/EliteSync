param(
  [ValidateSet('baseline','a1','b1')]
  [string]$FromProfile = 'baseline',
  [ValidateSet('baseline','a1','b1')]
  [string]$ToProfile = 'b1',
  [double]$MaxRelativeChange = 0.10
)

$ErrorActionPreference = 'Stop'

$profiles = @{
  baseline = @{
    MATCH_WEIGHT_PERSONALITY = 0.58
    MATCH_WEIGHT_MBTI = 0.07
    MATCH_WEIGHT_ASTRO = 0.35
    MATCH_ASTRO_WEIGHT_BAZI = 0.45
    MATCH_ASTRO_WEIGHT_ZODIAC = 0.25
    MATCH_ASTRO_WEIGHT_CONSTELLATION = 0.08
    MATCH_ASTRO_WEIGHT_NATAL_CHART = 0.07
    MATCH_ASTRO_WEIGHT_PAIR_CHART = 0.15
  }
  a1 = @{
    MATCH_WEIGHT_PERSONALITY = 0.62
    MATCH_WEIGHT_MBTI = 0.07
    MATCH_WEIGHT_ASTRO = 0.315
    MATCH_ASTRO_WEIGHT_BAZI = 0.45
    MATCH_ASTRO_WEIGHT_ZODIAC = 0.25
    MATCH_ASTRO_WEIGHT_CONSTELLATION = 0.08
    MATCH_ASTRO_WEIGHT_NATAL_CHART = 0.07
    MATCH_ASTRO_WEIGHT_PAIR_CHART = 0.15
  }
  b1 = @{
    MATCH_WEIGHT_PERSONALITY = 0.64
    MATCH_WEIGHT_MBTI = 0.07
    MATCH_WEIGHT_ASTRO = 0.29
    MATCH_ASTRO_WEIGHT_BAZI = 0.49
    MATCH_ASTRO_WEIGHT_ZODIAC = 0.23
    MATCH_ASTRO_WEIGHT_CONSTELLATION = 0.075
    MATCH_ASTRO_WEIGHT_NATAL_CHART = 0.065
    MATCH_ASTRO_WEIGHT_PAIR_CHART = 0.14
  }
}

$from = $profiles[$FromProfile]
$to = $profiles[$ToProfile]
if (-not $from -or -not $to) {
  throw "Unknown profile pair: $FromProfile -> $ToProfile"
}

$keys = $from.Keys | Sort-Object
$fail = 0

Write-Host "=== Weight Change Guard ==="
Write-Host "From: $FromProfile  To: $ToProfile  MaxRelativeChange: $([math]::Round($MaxRelativeChange*100,2))%"

foreach ($k in $keys) {
  $a = [double]$from[$k]
  $b = [double]$to[$k]
  if ($a -eq 0) {
    $relative = if ($b -eq 0) { 0.0 } else { [double]::PositiveInfinity }
  } else {
    $relative = [math]::Abs(($b - $a) / $a)
  }
  $status = if ($relative -le $MaxRelativeChange) { "PASS" } else { "FAIL" }
  if ($status -eq "FAIL") { $fail++ }
  $relPct = if ([double]::IsInfinity($relative)) { "INF" } else { ([math]::Round($relative * 100, 2)).ToString() + "%" }
  Write-Host ("[{0}] {1}: {2} -> {3} (delta={4})" -f $status, $k, $a, $b, $relPct)
}

if ($fail -gt 0) {
  Write-Host "Overall: FAIL (fail=$fail)"
  exit 2
}

Write-Host "Overall: PASS"
exit 0
