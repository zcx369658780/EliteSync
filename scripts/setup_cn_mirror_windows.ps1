param(
    [string]$PackagistMirror = "https://mirrors.aliyun.com/composer/",
    [string]$GitHubGitMirror = "https://gitclone.com/github.com/"
)

$ErrorActionPreference = "Stop"

Write-Host "[1/4] Configure Composer global mirror..."
composer config -g repos.packagist composer $PackagistMirror
composer config -g github-protocols https
composer config -g secure-http true
composer config -g use-github-api false

Write-Host "[2/4] Configure GitHub clone mirror..."
try { git config --global --unset-all url."https://ghproxy.com/https://github.com/".insteadOf } catch {}
try { git config --global --unset-all url."https://ghproxy.com/https://api.github.com/".insteadOf } catch {}
git config --global url."$GitHubGitMirror".insteadOf "https://github.com/"

Write-Host "[3/4] Show effective config..."
composer config -g --list | Select-String "repositories.0.url|github-protocols|use-github-api|secure-http"
git config --global --get-regexp "^url\..*insteadOf$"

Write-Host "[4/4] Done."
Write-Host "Tip: if composer hits shallow-cache issues, run:"
Write-Host "  composer install --no-interaction --prefer-dist --no-progress --no-cache"
