param(
    [Parameter(Mandatory = $true)]
    [int] $IssueNumber,

    [string] $Repo = "zcx369658780/EliteSync",

    [string] $OutDir = ".codex/tasks"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "gh CLI is required but was not found on PATH."
}

$json = & gh issue view $IssueNumber --repo $Repo --json number,title,body,labels,state,url
if ($LASTEXITCODE -ne 0) {
    throw "gh issue view failed for issue #$IssueNumber in $Repo."
}

$issue = $json | ConvertFrom-Json
if ($issue.state -ne "OPEN") {
    throw "Issue #$IssueNumber is not open. Current state: $($issue.state)"
}

New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

$labels = @()
if ($issue.labels) {
    $labels = @($issue.labels | ForEach-Object {
        if ($_.name) { $_.name } else { [string] $_ }
    })
}

$outPath = Join-Path $OutDir ("github_issue_{0}.md" -f $IssueNumber)
$labelText = if ($labels.Count -gt 0) { $labels -join ", " } else { "(none)" }

$content = @"
# GitHub Issue #$($issue.number): $($issue.title)

- URL: $($issue.url)
- State: $($issue.state)
- Labels: $labelText

## Body

$($issue.body)
"@

Set-Content -LiteralPath $outPath -Value $content -Encoding UTF8

Write-Output "Wrote issue task file: $outPath"
Write-Output "Suggested Codex instruction:"
Write-Output "Please read $outPath and execute it according to AGENTS.md."

$ignored = $false
if (Get-Command git -ErrorAction SilentlyContinue) {
    & git check-ignore -q -- $OutDir 2>$null
    $ignored = ($LASTEXITCODE -eq 0)
}

if (-not $ignored) {
    Write-Output "NOTE: $OutDir is local scratch. It appears not to be ignored by git; do not commit generated task files."
}
