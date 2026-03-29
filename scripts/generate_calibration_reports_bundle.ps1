param(
  [string]$WeekTag = '',
  [switch]$RunCycleFirst,
  [switch]$IncludeCalibrationInjected,
  [switch]$DryRunCycle
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($WeekTag)) {
  $WeekTag = (Get-Date).ToString('yyyy') + 'W' + [System.Globalization.ISOWeek]::GetWeekOfYear([datetime]::Now).ToString('00')
}

if ($RunCycleFirst) {
  $cycleArgs = @(
    '-ExecutionPolicy', 'Bypass',
    '-File', 'scripts\run_astro_calibration_cycle.ps1',
    '-WeekTag', $WeekTag
  )
  if ($IncludeCalibrationInjected) { $cycleArgs += '-IncludeCalibrationInjected' }
  if ($DryRunCycle) { $cycleArgs += '-DryRun' }
  & powershell @cycleArgs
  if ($LASTEXITCODE -ne 0) {
    throw "run_astro_calibration_cycle failed with exit code: $LASTEXITCODE"
  }
}

& powershell -ExecutionPolicy Bypass -File scripts\generate_calibration_weekly_report.ps1 -WeekTag $WeekTag
if ($LASTEXITCODE -ne 0) { throw "generate_calibration_weekly_report failed: $LASTEXITCODE" }

& powershell -ExecutionPolicy Bypass -File scripts\generate_calibration_wechat_brief.ps1 -WeekTag $WeekTag
if ($LASTEXITCODE -ne 0) { throw "generate_calibration_wechat_brief failed: $LASTEXITCODE" }

Write-Host "bundle generated:"
Write-Host ("- docs/devlogs/CALIBRATION_WEEKLY_REPORT_{0}_AUTO.md" -f $WeekTag)
Write-Host ("- docs/devlogs/CALIBRATION_WECHAT_BRIEF_{0}.txt" -f $WeekTag)

