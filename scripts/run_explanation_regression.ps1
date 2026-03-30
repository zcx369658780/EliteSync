param(
  [string]$OutputDir = "reports/explanation_snapshot_diff"
)

$ErrorActionPreference = 'Stop'
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$backendDir = Join-Path $repoRoot "services/backend-laravel"
$outDir = Join-Path $repoRoot $OutputDir
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$latestPath = Join-Path $outDir "latest.md"
$diffPath = Join-Path $outDir "latest_diff.md"
$fixturePath = Join-Path $backendDir "tests/Fixtures/explanations/explanation_cases_20.json"

Push-Location $backendDir
try {
  php artisan test --filter=ExplanationComposerTest
  if ($LASTEXITCODE -ne 0) { throw "ExplanationComposerTest failed: $LASTEXITCODE" }

  php artisan test --filter=ExplanationFixturesTest
  if ($LASTEXITCODE -ne 0) { throw "ExplanationFixturesTest failed: $LASTEXITCODE" }

  php artisan test --filter=MatchPayloadContractTest
  if ($LASTEXITCODE -ne 0) { throw "MatchPayloadContractTest failed: $LASTEXITCODE" }
}
finally {
  Pop-Location
}

$now = Get-Date
$stamp = $now.ToString("yyyy-MM-dd HH:mm:ss")
$hash = ""
if (Test-Path $fixturePath) {
  $hash = (Get-FileHash -Algorithm SHA256 -Path $fixturePath).Hash
}
$prevContent = ""
if (Test-Path $latestPath) {
  $prevContent = Get-Content -Path $latestPath -Raw
}
$lines = @(
  "# Explanation Regression Snapshot",
  "",
  "- Run at: $stamp",
  "- Fixture: tests/Fixtures/explanations/explanation_cases_20.json",
  "- Fixture SHA256: $hash",
  "- Scope:",
  "  - ExplanationComposerTest",
  "  - ExplanationFixturesTest",
  "  - MatchPayloadContractTest",
  "- Result: PASS",
  "",
  "## Notes",
  "- This snapshot validates explanation template shape and contract stability.",
  "- For semantic tuning, compare API payload diffs in future iterations."
)
Set-Content -Path $latestPath -Value $lines -Encoding UTF8

$newContent = Get-Content -Path $latestPath -Raw
$diffLines = @(
  "# Explanation Regression Diff (latest vs previous)",
  "",
  "- Generated at: $stamp",
  ""
)
if ([string]::IsNullOrWhiteSpace($prevContent)) {
  $diffLines += "- Previous snapshot not found (first run)."
} elseif ($prevContent -eq $newContent) {
  $diffLines += "- No content diff detected."
} else {
  $diffLines += "- Diff detected between previous and latest snapshot."
  $prevArr = $prevContent -split "`r?`n"
  $newArr = $newContent -split "`r?`n"
  $rawDiff = Compare-Object -ReferenceObject $prevArr -DifferenceObject $newArr -IncludeEqual:$false
  if ($rawDiff.Count -gt 0) {
    $diffLines += ""
    $diffLines += "## Changed Lines"
    foreach ($d in $rawDiff | Select-Object -First 80) {
      $prefix = if ($d.SideIndicator -eq "=>") { "+" } else { "-" }
      $diffLines += "$prefix $($d.InputObject)"
    }
    if ($rawDiff.Count -gt 80) {
      $diffLines += "... (truncated, total diff lines: $($rawDiff.Count))"
    }
  }
}
Set-Content -Path $diffPath -Value $diffLines -Encoding UTF8

Write-Host "Explanation regression: PASS"
Write-Host "Snapshot written: $latestPath"
Write-Host "Diff written: $diffPath"
exit 0
