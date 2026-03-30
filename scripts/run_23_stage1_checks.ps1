param(
  [switch]$SkipFlutterAnalyze
)

$ErrorActionPreference = 'Stop'
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$backendDir = Join-Path $repoRoot "services/backend-laravel"
$flutterDir = Join-Path $repoRoot "apps/flutter_elitesync_module"
$flutterBat = "C:\\tools\\flutter\\bin\\flutter.bat"

$fails = 0
function Run-Step {
  param(
    [string]$Name,
    [scriptblock]$Body
  )
  try {
    & $Body
    Write-Host "[PASS] $Name"
  } catch {
    $script:fails++
    Write-Host "[FAIL] $Name -> $($_.Exception.Message)"
  }
}

Write-Host "=== 2.3 Stage1 Checks ==="

Run-Step "Backend Explanation Regression" {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $repoRoot "scripts/run_explanation_regression.ps1")
  if ($LASTEXITCODE -ne 0) { throw "run_explanation_regression exit=$LASTEXITCODE" }
}

Push-Location $backendDir
try {
  Run-Step "MatchPayloadContractTest" {
    php artisan test --filter=MatchPayloadContractTest
    if ($LASTEXITCODE -ne 0) { throw "MatchPayloadContractTest exit=$LASTEXITCODE" }
  }

  Run-Step "MatchApiTest" {
    php artisan test --filter=MatchApiTest
    if ($LASTEXITCODE -ne 0) { throw "MatchApiTest exit=$LASTEXITCODE" }
  }
} finally {
  Pop-Location
}

if (-not $SkipFlutterAnalyze) {
  Run-Step "Flutter Analyze (match module)" {
    if (-not (Test-Path $flutterBat)) {
      throw "flutter.bat not found at $flutterBat"
    }
    Push-Location $flutterDir
    try {
      & $flutterBat analyze lib/features/match
      if ($LASTEXITCODE -ne 0) { throw "flutter analyze exit=$LASTEXITCODE" }
    } finally {
      Pop-Location
    }
  }
}

if ($fails -gt 0) {
  Write-Host "Overall: FAIL (fail=$fails)"
  exit 2
}

Write-Host "Overall: PASS"
exit 0

