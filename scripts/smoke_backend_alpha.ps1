Param(
    [string]$ServerHost = "101.133.161.203",
    [string]$BaseUrl = "",
    [string]$Phone = "",
    [string]$Password = "",
    [string]$SmokeLogPath = "docs/devlogs/SMOKE_LOG.md",
    [int]$TimeoutSec = 20,
    [switch]$SkipAuthChecks
)

$ErrorActionPreference = "Stop"

$curlCmd = $null

# Prefer Windows curl.exe when available; otherwise use first curl application found.
$curlExe = @(Get-Command "curl.exe" -ErrorAction SilentlyContinue)
if ($curlExe.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace([string]$curlExe[0].Source)) {
    $curlCmd = [string]$curlExe[0].Source
}
else {
    $curlCandidates = @(Get-Command "curl" -CommandType Application -All -ErrorAction SilentlyContinue)
    if ($curlCandidates.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace([string]$curlCandidates[0].Source)) {
        $curlCmd = [string]$curlCandidates[0].Source
    }
}

function Invoke-CurlText {
    param(
        [string[]]$CurlArgs
    )
    if ($null -eq $curlCmd -or [string]::IsNullOrWhiteSpace([string]$curlCmd)) {
        throw "curl executable not found"
    }
    return & $curlCmd @CurlArgs
}

function Add-Result {
    param(
        [System.Collections.Generic.List[object]]$List,
        [string]$Name,
        [bool]$Pass,
        [string]$Detail
    )
    $List.Add([PSCustomObject]@{
        Name = $Name
        Pass = $Pass
        Detail = $Detail
    }) | Out-Null
}

if ([string]::IsNullOrWhiteSpace($BaseUrl)) {
    $BaseUrl = "http://$ServerHost"
}
$BaseUrl = $BaseUrl.TrimEnd("/")

$results = New-Object 'System.Collections.Generic.List[object]'
$token = ""
$latestVersionName = ""
$latestVersionCode = 0
$downloadUrl = ""

# 1) App version check (public)
try {
    $vcUrl = "$BaseUrl/api/v1/app/version/check?platform=android&version_name=0.00.01&version_code=1&channel=stable"
    $vcRaw = Invoke-CurlText -CurlArgs @("-s", "$vcUrl")
    $vc = $vcRaw | ConvertFrom-Json
    $latestVersionName = [string]$vc.latest_version_name
    $latestVersionCode = [int]$vc.latest_version_code
    $downloadUrl = [string]$vc.download_url
    $pass = -not [string]::IsNullOrWhiteSpace($latestVersionName) -and $latestVersionCode -gt 0
    Add-Result -List $results -Name "Version API" -Pass $pass -Detail ("latest={0}({1})" -f $latestVersionName, $latestVersionCode)
}
catch {
    Add-Result -List $results -Name "Version API" -Pass $false -Detail $_.Exception.Message
}

# 2) Download URL HEAD (public)
try {
    if ([string]::IsNullOrWhiteSpace($downloadUrl)) {
        throw "download_url is empty"
    }
    $head = Invoke-CurlText -CurlArgs @("-I", "-s", "--max-time", "$TimeoutSec", "$downloadUrl")
    $statusLine = ($head -split "`n" | Select-Object -First 1).Trim()
    $statusCode = 0
    if ($statusLine -match 'HTTP/\d+(\.\d+)?\s+(\d{3})') {
        $statusCode = [int]$Matches[2]
    }
    $pass = ($statusCode -ge 200 -and $statusCode -lt 400)
    Add-Result -List $results -Name "Download URL" -Pass $pass -Detail $statusLine
}
catch {
    Add-Result -List $results -Name "Download URL" -Pass $false -Detail $_.Exception.Message
}

$runAuth = -not $SkipAuthChecks
if ($runAuth -and ([string]::IsNullOrWhiteSpace($Phone) -or [string]::IsNullOrWhiteSpace($Password))) {
    Add-Result -List $results -Name "Auth chain" -Pass $false -Detail "Phone/Password missing (or pass -SkipAuthChecks)"
    $runAuth = $false
}

if ($runAuth) {
    # 3) Login
    try {
        $loginBody = @{ phone = $Phone; password = $Password } | ConvertTo-Json -Compress
        $login = Invoke-RestMethod -Uri "$BaseUrl/api/v1/auth/login" -Method Post -ContentType "application/json" -Body $loginBody -TimeoutSec $TimeoutSec
        $token = [string]$login.access_token
        $pass = -not [string]::IsNullOrWhiteSpace($token)
        $loginDetail = if ($pass) { "token ok" } else { "empty token" }
        Add-Result -List $results -Name "Login" -Pass $pass -Detail $loginDetail
    }
    catch {
        Add-Result -List $results -Name "Login" -Pass $false -Detail $_.Exception.Message
        $runAuth = $false
    }
}

if ($runAuth) {
    $headers = @{ Authorization = "Bearer $token" }

    # 4) Profile basic GET
    try {
        $basic = Invoke-RestMethod -Uri "$BaseUrl/api/v1/profile/basic" -Method Get -Headers $headers -TimeoutSec $TimeoutSec
        $pass = ($null -ne $basic.id) -and (-not [string]::IsNullOrWhiteSpace([string]$basic.phone))
        Add-Result -List $results -Name "Profile Basic GET" -Pass $pass -Detail ("id={0}, phone={1}" -f $basic.id, $basic.phone)
    }
    catch {
        Add-Result -List $results -Name "Profile Basic GET" -Pass $false -Detail $_.Exception.Message
    }

    # 5) Profile basic POST (save)
    try {
        $saveBody = @{
            name = "SmokeUser"
            birthday = "1998-01-01"
            gender = "male"
            city = "Nanyang"
            relationship_goal = "dating"
        } | ConvertTo-Json -Compress
        $saveResp = Invoke-RestMethod -Uri "$BaseUrl/api/v1/profile/basic" -Method Post -Headers $headers -ContentType "application/json" -Body $saveBody -TimeoutSec $TimeoutSec
        $pass = ($saveResp.ok -eq $true) -and ($saveResp.user.city -eq "Nanyang")
        Add-Result -List $results -Name "Profile Basic POST" -Pass $pass -Detail ("ok={0}, city={1}" -f $saveResp.ok, $saveResp.user.city)
    }
    catch {
        Add-Result -List $results -Name "Profile Basic POST" -Pass $false -Detail $_.Exception.Message
    }

    # 6) MBTI quiz GET
    try {
        $quiz = Invoke-RestMethod -Uri "$BaseUrl/api/v1/profile/mbti/quiz?version=lite3_v1" -Method Get -Headers $headers -TimeoutSec $TimeoutSec
        $count = @($quiz.items).Count
        $pass = ($quiz.version_code -eq "lite3_v1") -and ($count -eq 3)
        Add-Result -List $results -Name "MBTI Quiz GET" -Pass $pass -Detail ("version={0}, total={1}" -f $quiz.version_code, $count)
    }
    catch {
        Add-Result -List $results -Name "MBTI Quiz GET" -Pass $false -Detail $_.Exception.Message
    }

    # 7) MBTI result GET
    try {
        $mr = Invoke-RestMethod -Uri "$BaseUrl/api/v1/profile/mbti/result" -Method Get -Headers $headers -TimeoutSec $TimeoutSec
        $pass = ($mr.PSObject.Properties.Name -contains "exists")
        Add-Result -List $results -Name "MBTI Result GET" -Pass $pass -Detail ("exists={0}" -f $mr.exists)
    }
    catch {
        Add-Result -List $results -Name "MBTI Result GET" -Pass $false -Detail $_.Exception.Message
    }

    # 8) Astro profile GET
    try {
        $astro = Invoke-RestMethod -Uri "$BaseUrl/api/v1/profile/astro" -Method Get -Headers $headers -TimeoutSec $TimeoutSec
        $pass = ($astro.PSObject.Properties.Name -contains "profile") -or ($astro.PSObject.Properties.Name -contains "astro")
        $detail = if ($astro.PSObject.Properties.Name -contains "profile") { "profile field present" } elseif ($astro.PSObject.Properties.Name -contains "astro") { "astro field present" } else { "missing profile/astro field" }
        Add-Result -List $results -Name "Astro GET" -Pass $pass -Detail $detail
    }
    catch {
        Add-Result -List $results -Name "Astro GET" -Pass $false -Detail $_.Exception.Message
    }
}

$failCount = @($results | Where-Object { -not $_.Pass }).Count
$overall = if ($failCount -eq 0) { "PASS" } else { "FAIL" }

Write-Host ""
Write-Host "=== Smoke Summary ==="
foreach ($r in $results) {
    $flag = if ($r.Pass) { "[PASS]" } else { "[FAIL]" }
    Write-Host ("{0} {1} -> {2}" -f $flag, $r.Name, $r.Detail)
}
Write-Host ("Overall: {0} (fail={1})" -f $overall, $failCount)

# Append markdown log
$repoRoot = (Resolve-Path "$PSScriptRoot\..").Path
$logPath = Join-Path $repoRoot $SmokeLogPath
$logDir = Split-Path -Parent $logPath
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
}
if (-not (Test-Path $logPath)) {
    Set-Content -Path $logPath -Value "# Smoke Log`r`n" -Encoding utf8
}

$ts = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$md = New-Object System.Collections.Generic.List[string]
$md.Add("")
$md.Add("## $ts")
$md.Add("- BaseUrl: $BaseUrl")
$md.Add("- Overall: $overall")
if ($SkipAuthChecks) {
    $md.Add("- AuthChecks: SKIPPED")
} else {
    $md.Add("- AuthChecks: ENABLED")
}
$md.Add("- Details:")
foreach ($r in $results) {
    $flag = if ($r.Pass) { "PASS" } else { "FAIL" }
    $md.Add("  - [$flag] $($r.Name): $($r.Detail)")
}
Add-Content -Path $logPath -Value ($md -join "`r`n") -Encoding utf8
Write-Host "Smoke log appended: $logPath"

if ($failCount -gt 0) {
    exit 2
}
exit 0
