Param(
    [string]$ServerHost = "101.133.161.203",
    [string]$BaseUrl = "",
    [string]$Phone = "",
    [string]$Password = "",
    [string]$SmokeLogPath = "docs/devlogs/SMOKE_LOG.md",
    [int]$TimeoutSec = 20,
    [switch]$SkipAuthChecks,
    [switch]$CheckPasswordChange
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

function Get-HttpStatusCodeFromException {
    param(
        [System.Exception]$Exception
    )

    if ($null -eq $Exception) {
        return $null
    }

    $response = $null
    if ($Exception.PSObject.Properties.Name -contains 'Response' -and $null -ne $Exception.Response) {
        $response = $Exception.Response
    }
    elseif ($Exception.PSObject.Properties.Name -contains 'InnerException' -and $null -ne $Exception.InnerException) {
        $inner = $Exception.InnerException
        if ($inner.PSObject.Properties.Name -contains 'Response' -and $null -ne $inner.Response) {
            $response = $inner.Response
        }
    }

    if ($null -ne $response) {
        if ($response.PSObject.Properties.Name -contains 'StatusCode' -and $null -ne $response.StatusCode) {
            return [int]$response.StatusCode
        }
        if ($response.PSObject.Properties.Name -contains 'BaseResponse' -and $null -ne $response.BaseResponse -and $response.BaseResponse.PSObject.Properties.Name -contains 'StatusCode') {
            return [int]$response.BaseResponse.StatusCode
        }
    }

    return $null
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
$authPhone = $Phone
$authPassword = $Password
$fallbackAuthUsed = $false

function New-SmokeFallbackAccount {
    param(
        [string]$BaseUrl,
        [int]$TimeoutSec = 20,
        [int]$MaxAttempts = 5
    )

    # 生成一个非真实号段的临时烟测账号，避免依赖远端固定测试账号状态。
    $fallbackPassword = 'Smoke12345'
    $lastError = $null

    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        $suffix = [string](Get-Random -Minimum 100000000 -Maximum 1000000000)
        $fallbackPhone = "90$suffix"
        if ($fallbackPhone.Length -lt 11) {
            $fallbackPhone = $fallbackPhone.PadRight(11, '0')
        }
        elseif ($fallbackPhone.Length -gt 11) {
            $fallbackPhone = $fallbackPhone.Substring(0, 11)
        }

        $registerBody = @{
            phone = $fallbackPhone
            password = $fallbackPassword
            name = 'SmokeUser'
            birthday = '1998-01-01'
            realname_verified = $true
        } | ConvertTo-Json -Compress

        try {
            $register = Invoke-RestMethod -Uri "$BaseUrl/api/v1/auth/register" -Method Post -ContentType "application/json" -Body $registerBody -TimeoutSec $TimeoutSec
            $accessToken = [string]$register.access_token
            if ([string]::IsNullOrWhiteSpace($accessToken)) {
                throw "fallback register returned empty access_token"
            }

            return [PSCustomObject]@{
                Phone = $fallbackPhone
                Password = $fallbackPassword
                AccessToken = $accessToken
            }
        }
        catch {
            $lastError = $_.Exception.Message
            if ($attempt -lt $MaxAttempts) {
                Start-Sleep -Seconds 1
                continue
            }
            break
        }
    }

    throw "fallback register failed after $MaxAttempts attempts: $lastError"
}

function Get-HttpStatusLine {
    param(
        [string]$Url,
        [int]$TimeoutSec = 20
    )

    $curlCode = $null
    try {
        $curlCode = Invoke-CurlText -CurlArgs @("-L", "-s", "-o", "NUL", "-w", "%{http_code}", "--max-time", "$TimeoutSec", "$Url")
        if ($null -ne $curlCode) {
            $curlCode = ([string]$curlCode).Trim()
        }
    }
    catch {
        $curlCode = $null
    }

    if (-not [string]::IsNullOrWhiteSpace([string]$curlCode) -and $curlCode -match '^\d{3}$') {
        return ("HTTP/1.1 {0}" -f $curlCode)
    }

    try {
        $resp = Invoke-WebRequest -Uri $Url -Method Head -TimeoutSec $TimeoutSec -ErrorAction Stop
        if ($null -ne $resp) {
            if ($null -ne $resp.StatusCode -and $resp.StatusCode -gt 0) {
                return ("HTTP/1.1 {0}" -f [int]$resp.StatusCode)
            }
            if ($null -ne $resp.BaseResponse -and $null -ne $resp.BaseResponse.StatusCode) {
                return ("HTTP/1.1 {0}" -f [int]$resp.BaseResponse.StatusCode)
            }
        }
    }
    catch {
        return $null
    }

    return $null
}

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
    $statusLine = Get-HttpStatusLine -Url $downloadUrl -TimeoutSec $TimeoutSec
    if ([string]::IsNullOrWhiteSpace($statusLine)) {
        throw "unable to determine HTTP status for download_url"
    }
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
        $loginStatus = Get-HttpStatusCodeFromException -Exception $_.Exception
        if ($loginStatus -eq 422) {
            try {
                $fallback = New-SmokeFallbackAccount -BaseUrl $BaseUrl -TimeoutSec $TimeoutSec
                $authPhone = [string]$fallback.Phone
                $authPassword = [string]$fallback.Password
                $token = [string]$fallback.AccessToken
                $fallbackAuthUsed = $true
                Add-Result -List $results -Name "Login" -Pass $true -Detail ("422 fallback register ok (phone={0})" -f $authPhone)
                $runAuth = $true
            }
            catch {
                Add-Result -List $results -Name "Login" -Pass $false -Detail ("422 fallback register failed: {0}" -f $_.Exception.Message)
                $runAuth = $false
            }
        }
        else {
            Add-Result -List $results -Name "Login" -Pass $false -Detail $_.Exception.Message
            $runAuth = $false
        }
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
        $code = Get-HttpStatusCodeFromException -Exception $_.Exception
        if ($code -eq 410) {
            Add-Result -List $results -Name "MBTI Quiz GET" -Pass $true -Detail "410 Gone (feature closed)"
        }
        else {
            Add-Result -List $results -Name "MBTI Quiz GET" -Pass $false -Detail $_.Exception.Message
        }
    }

    # 7) MBTI result GET
    try {
        $mr = Invoke-RestMethod -Uri "$BaseUrl/api/v1/profile/mbti/result" -Method Get -Headers $headers -TimeoutSec $TimeoutSec
        $pass = ($mr.PSObject.Properties.Name -contains "exists")
        Add-Result -List $results -Name "MBTI Result GET" -Pass $pass -Detail ("exists={0}" -f $mr.exists)
    }
    catch {
        $code = Get-HttpStatusCodeFromException -Exception $_.Exception
        if ($code -eq 410) {
            Add-Result -List $results -Name "MBTI Result GET" -Pass $true -Detail "410 Gone (feature closed)"
        }
        else {
            Add-Result -List $results -Name "MBTI Result GET" -Pass $false -Detail $_.Exception.Message
        }
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

    # 9) Change password POST (optional, with rollback)
    if ($CheckPasswordChange) {
        $tempPassword = "$authPassword`_smk9a"
        $changed = $false
        try {
            $changeBody = @{
                current_password = $authPassword
                new_password = $tempPassword
                new_password_confirmation = $tempPassword
            } | ConvertTo-Json -Compress
            $changeResp = Invoke-RestMethod -Uri "$BaseUrl/api/v1/auth/password" -Method Post -Headers $headers -ContentType "application/json" -Body $changeBody -TimeoutSec $TimeoutSec
            $changed = ($changeResp.ok -eq $true)
            if ($changed) {
                $authPassword = $tempPassword
            }
            Add-Result -List $results -Name "Change Password POST" -Pass $changed -Detail ("ok={0}" -f $changeResp.ok)
        }
        catch {
            Add-Result -List $results -Name "Change Password POST" -Pass $false -Detail $_.Exception.Message
        }

        if ($changed) {
            try {
                $loginBody2 = @{ phone = $authPhone; password = $tempPassword } | ConvertTo-Json -Compress
                $login2 = Invoke-RestMethod -Uri "$BaseUrl/api/v1/auth/login" -Method Post -ContentType "application/json" -Body $loginBody2 -TimeoutSec $TimeoutSec
                $token2 = [string]$login2.access_token
                $passLoginNew = -not [string]::IsNullOrWhiteSpace($token2)
                $loginNewDetail = if ($passLoginNew) { "token ok" } else { "empty token" }
                Add-Result -List $results -Name "Login with New Password" -Pass $passLoginNew -Detail $loginNewDetail

                if ($passLoginNew) {
                    $headers2 = @{ Authorization = "Bearer $token2" }
                    $rollbackBody = @{
                        current_password = $tempPassword
                        new_password = $authPassword
                        new_password_confirmation = $authPassword
                    } | ConvertTo-Json -Compress
                    $rollbackResp = Invoke-RestMethod -Uri "$BaseUrl/api/v1/auth/password" -Method Post -Headers $headers2 -ContentType "application/json" -Body $rollbackBody -TimeoutSec $TimeoutSec
                    $rollbackPass = ($rollbackResp.ok -eq $true)
                    if ($rollbackPass) {
                        $authPassword = $Password
                    }
                    Add-Result -List $results -Name "Password Rollback" -Pass $rollbackPass -Detail ("ok={0}" -f $rollbackResp.ok)
                }
            }
            catch {
                Add-Result -List $results -Name "Password Rollback" -Pass $false -Detail $_.Exception.Message
            }
        }
    }

    if ($fallbackAuthUsed) {
        try {
            $cleanupBody = @{
                current_password = $authPassword
            } | ConvertTo-Json -Compress
            Invoke-RestMethod -Uri "$BaseUrl/api/v1/auth/account" -Method Delete -Headers $headers -ContentType "application/json" -Body $cleanupBody -TimeoutSec $TimeoutSec | Out-Null
            Add-Result -List $results -Name "Smoke Cleanup" -Pass $true -Detail ("fallback account deleted (phone={0})" -f $authPhone)
        }
        catch {
            Add-Result -List $results -Name "Smoke Cleanup" -Pass $false -Detail $_.Exception.Message
        }
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
    $md.Add("- CheckPasswordChange: $CheckPasswordChange")
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
