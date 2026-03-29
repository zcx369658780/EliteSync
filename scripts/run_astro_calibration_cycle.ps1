param(
    [int]$ShadowLimit = 100,
    [switch]$OnlyMismatch = $true,
    [int]$OutcomeDays = 30,
    [int]$CalibrationDays = 90,
    [int]$CalibrationLimit = 0,
    [int]$OutcomeWindow = 7,
    [string]$WeekTag = '',
    [switch]$IncludeCalibrationInjected,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$backend = Join-Path $root 'services/backend-laravel'
$devlogs = Join-Path $root 'docs/devlogs'
$cycleLog = Join-Path $devlogs 'CALIBRATION_CYCLE_LOG.md'

if (-not (Test-Path $backend)) {
    throw "Backend path not found: $backend"
}
if (-not (Test-Path $devlogs)) {
    New-Item -ItemType Directory -Path $devlogs | Out-Null
}
if (-not (Test-Path $cycleLog)) {
    "# Calibration Cycle Log`n" | Set-Content -Encoding UTF8 $cycleLog
}

function Invoke-Artisan {
    param(
        [string[]]$CommandArgs,
        [string]$Title
    )

    $display = 'php artisan ' + ($CommandArgs -join ' ')
    Write-Host "`n=== $Title ==="
    Write-Host $display

    if ($DryRun) {
        return 0
    }

    Push-Location $backend
    try {
        & php artisan @CommandArgs
        return $LASTEXITCODE
    }
    finally {
        Pop-Location
    }
}

$shadowArgs = @('app:dev:astro-shadow-compare', "--limit=$ShadowLimit")
if ($OnlyMismatch) {
    $shadowArgs += '--only-mismatch'
}

$outcomeArgs = @('app:dev:pair-outcome-metrics', "--days=$OutcomeDays")
if ($WeekTag -ne '') {
    $outcomeArgs += "--week-tag=$WeekTag"
}
if ($IncludeCalibrationInjected) {
    $outcomeArgs += '--include-calibration-injected'
}

$calibrationArgs = @('app:dev:export-match-calibration', "--days=$CalibrationDays", "--outcome-window=$OutcomeWindow")
if ($CalibrationLimit -gt 0) {
    $calibrationArgs += "--limit=$CalibrationLimit"
}
if ($WeekTag -ne '') {
    $calibrationArgs += "--week-tag=$WeekTag"
}
if ($IncludeCalibrationInjected) {
    $calibrationArgs += '--include-calibration-injected'
}

$rc1 = Invoke-Artisan -CommandArgs $shadowArgs -Title 'Shadow Compare'
$rc2 = Invoke-Artisan -CommandArgs $outcomeArgs -Title 'Outcome Metrics'
$rc3 = Invoke-Artisan -CommandArgs $calibrationArgs -Title 'Calibration Export'

$ok = ($rc1 -eq 0 -and $rc2 -eq 0 -and $rc3 -eq 0)
$status = if ($ok) { 'PASS' } else { 'FAIL' }
$ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

$entry = @"
## $ts [$status]
- shadow: $rc1
- outcome: $rc2
- export: $rc3
- params: shadow_limit=$ShadowLimit, only_mismatch=$OnlyMismatch, outcome_days=$OutcomeDays, calibration_days=$CalibrationDays, calibration_limit=$CalibrationLimit, outcome_window=$OutcomeWindow, week_tag=$WeekTag, include_calibration_injected=$IncludeCalibrationInjected, dry_run=$DryRun

"@

Add-Content -Encoding UTF8 -Path $cycleLog -Value $entry

Write-Host "`n=== Calibration Cycle Summary ==="
Write-Host "status: $status"
Write-Host "log: $cycleLog"

if (-not $ok) {
    exit 1
}
