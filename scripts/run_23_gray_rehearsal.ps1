param(
  [string]$ServerHost = "101.133.161.203",
  [string]$BaseUrl = "",
  [string]$Phone = "",
  [string]$Password = "",
  [int]$TargetUserId = 0,
  [switch]$SkipFlutterAnalyze,
  [switch]$SkipAuthChecks,
  [string]$ReportPath = "reports/explanation_snapshot_diff/gray_rehearsal_2_3_latest.md"
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($BaseUrl)) {
  $BaseUrl = "http://$ServerHost"
}
$BaseUrl = $BaseUrl.TrimEnd("/")

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$stage1Script = Join-Path $repoRoot "scripts/run_23_stage1_checks.ps1"

if (-not (Test-Path $stage1Script)) {
  throw "Stage1 check script not found: $stage1Script"
}

Write-Host "=== 2.3 Gray Rehearsal ==="
Write-Host "BaseUrl: $BaseUrl"

# 1) Run stage1 checks first.
$stage1Args = @(
  "-ExecutionPolicy", "Bypass",
  "-File", $stage1Script
)
if ($SkipFlutterAnalyze) { $stage1Args += "-SkipFlutterAnalyze" }
powershell @stage1Args
if ($LASTEXITCODE -ne 0) {
  throw "Stage1 checks failed: exit=$LASTEXITCODE"
}

$reportLines = New-Object System.Collections.Generic.List[string]
$ts = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$reportLines.Add("# 2.3 Gray Rehearsal Report")
$reportLines.Add("")
$reportLines.Add("- Generated at: $ts")
$reportLines.Add("- BaseUrl: $BaseUrl")
$reportLines.Add("- Stage1 checks: PASS")

if ($SkipAuthChecks) {
  $reportLines.Add("- Auth rehearsal: SKIPPED")
} else {
  if ([string]::IsNullOrWhiteSpace($Phone) -or [string]::IsNullOrWhiteSpace($Password)) {
    throw "Phone/Password required when auth rehearsal is enabled."
  }

  # 2) Login
  $loginBody = @{
    phone = $Phone
    password = $Password
  } | ConvertTo-Json -Compress
  $loginResp = Invoke-RestMethod -Uri "$BaseUrl/api/v1/auth/login" -Method Post -ContentType "application/json" -Body $loginBody -TimeoutSec 20
  $token = [string]$loginResp.access_token
  if ([string]::IsNullOrWhiteSpace($token)) {
    throw "Login succeeded but token is empty."
  }
  $headers = @{ Authorization = "Bearer $token" }
  $reportLines.Add("- Login: PASS")

  # 3) Current match contract check (no-match should be treated as skip, not failure)
  $current = $null
  $currentAvailable = $false
  try {
    $current = Invoke-RestMethod -Uri "$BaseUrl/api/v1/matches/current" -Method Get -Headers $headers -TimeoutSec 20
    $currentAvailable = $true
  } catch {
    $msg = $_.Exception.Message
    if ($msg -match '\(404\)') {
      $reportLines.Add("- Current match contract check: SKIPPED (no active match)")
    } else {
      throw
    }
  }

  if ($currentAvailable) {
    $reasons = @{}
    if ($current.match_reasons -is [System.Collections.IDictionary]) {
      $reasons = $current.match_reasons
    }

    $hasModules = ($reasons.ContainsKey("modules"))
    $hasModuleExplanations = ($reasons.ContainsKey("module_explanations"))
    $hasExplanationBlocks = ($reasons.ContainsKey("explanation_blocks"))

    if (-not ($hasModules -and $hasModuleExplanations -and $hasExplanationBlocks)) {
      throw "Current match payload missing required fields: modules/module_explanations/explanation_blocks"
    }

    $blocks = @($reasons.explanation_blocks)
    if ($blocks.Count -le 0) {
      throw "explanation_blocks is empty"
    }
    $b0 = $blocks[0]
    $requiredBlockKeys = @("summary", "process", "risks", "advice", "core_evidence", "supporting_evidence", "confidence", "priority")
    foreach ($k in $requiredBlockKeys) {
      if (-not ($b0.PSObject.Properties.Name -contains $k)) {
        throw "explanation_blocks[0] missing key: $k"
      }
    }
    $reportLines.Add("- Current match payload fields: PASS")
    $reportLines.Add("- explanation_blocks count: $($blocks.Count)")
  }

  # 4) Explanation endpoint check (optional if target available)
  if ($TargetUserId -le 0 -and $currentAvailable) {
    $pid = 0
    if ($null -ne $current -and $current.PSObject.Properties.Name -contains "partner_id") {
      $pid = [int]$current.partner_id
    }
    $TargetUserId = $pid
  }
  if ($TargetUserId -gt 0) {
    try {
      $exp = Invoke-RestMethod -Uri "$BaseUrl/api/v1/matches/$TargetUserId/explanation" -Method Get -Headers $headers -TimeoutSec 20
      $expReasons = @{}
      if ($exp.match_reasons -is [System.Collections.IDictionary]) {
        $expReasons = $exp.match_reasons
      }
      if (-not $expReasons.ContainsKey("module_explanations")) {
        throw "explanation payload missing module_explanations"
      }
      $rows = @($expReasons.module_explanations)
      if ($rows.Count -le 0) {
        throw "module_explanations is empty"
      }
      $r0 = $rows[0]
      $requiredRowKeys = @("engine_source","engine_mode","data_quality","precision_level","confidence_reason","display_guard","display_tags")
      foreach ($k in $requiredRowKeys) {
        if (-not ($r0.PSObject.Properties.Name -contains $k)) {
          throw "module_explanations[0] missing key: $k"
        }
      }
      $reportLines.Add("- Explanation endpoint contract: PASS")
      $reportLines.Add("- module_explanations count: $($rows.Count)")
    } catch {
      $msg = $_.Exception.Message
      if ($msg -match '\(404\)') {
        $reportLines.Add("- Explanation endpoint contract: SKIPPED (no match for target user)")
      } else {
        throw
      }
    }
  } else {
    $reportLines.Add("- Explanation endpoint contract: SKIPPED (no target user)")
  }
}

# 5) Write report
$reportFullPath = Join-Path $repoRoot $ReportPath
$reportDir = Split-Path -Parent $reportFullPath
if (-not (Test-Path $reportDir)) {
  New-Item -ItemType Directory -Force -Path $reportDir | Out-Null
}
Set-Content -Path $reportFullPath -Value ($reportLines -join "`r`n") -Encoding UTF8
Write-Host "Gray rehearsal report written: $reportFullPath"
Write-Host "Overall: PASS"
exit 0
