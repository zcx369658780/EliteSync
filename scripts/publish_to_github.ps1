Param(
    [string]$ConfigPath = "C:\Users\zcxve\.codex\memories\secrets\elitesync_github_push.env",
    [string]$CommitMessage = "chore: daily progress update"
)

$ErrorActionPreference = "Stop"

function Import-EnvFile {
    param([string]$Path)
    if (!(Test-Path $Path)) {
        throw "Config file not found: $Path"
    }
    Get-Content $Path | ForEach-Object {
        $line = $_.Trim()
        if ($line -eq "" -or $line.StartsWith("#")) { return }
        $parts = $line -split "=", 2
        if ($parts.Count -eq 2) {
            [Environment]::SetEnvironmentVariable($parts[0], $parts[1])
        }
    }
}

Import-EnvFile -Path $ConfigPath

$repoUrl = $env:GITHUB_REPO_URL
$branch = if ($env:GIT_BRANCH) { $env:GIT_BRANCH } else { "main" }
$userName = $env:GIT_USER_NAME
$userEmail = $env:GIT_USER_EMAIL
$token = $env:GITHUB_TOKEN

if (-not $repoUrl -or -not $userName -or -not $userEmail) {
    throw "Missing required values in ${ConfigPath}: GITHUB_REPO_URL, GIT_USER_NAME, GIT_USER_EMAIL"
}

if (!(Test-Path ".git")) {
    git init
    git branch -M $branch
}

git config user.name $userName
git config user.email $userEmail

$hasOrigin = (git remote) -contains "origin"
if ($hasOrigin) {
    git remote set-url origin $repoUrl
} else {
    git remote add origin $repoUrl
}

git add -A

$hasChanges = (git status --porcelain)
if (-not $hasChanges) {
    Write-Host "No changes to commit."
    exit 0
}

git commit -m $CommitMessage

if ($token) {
    $authUrl = $repoUrl -replace "^https://", ("https://x-access-token:{0}@" -f $token)
    git push -u $authUrl $branch
} else {
    git push -u origin $branch
}

Write-Host "Push completed."
