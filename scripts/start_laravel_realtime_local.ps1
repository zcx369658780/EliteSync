Param(
    [string]$PhpPath = "C:\tools\php85\php.exe",
    [string]$Host = "0.0.0.0",
    [int]$HttpPort = 8080,
    [int]$WsPort = 8081
)

$root = Split-Path -Parent $PSScriptRoot
$backend = Join-Path $root "services\backend-laravel"

if (!(Test-Path $PhpPath)) {
    Write-Error "PHP not found: $PhpPath"
    exit 1
}

if (!(Test-Path (Join-Path $backend "artisan"))) {
    Write-Error "Laravel backend not found: $backend"
    exit 1
}

Write-Host "Starting Laravel HTTP server on http://$Host`:$HttpPort ..."
Start-Process -FilePath $PhpPath -WorkingDirectory $backend -ArgumentList "artisan","serve","--host=$Host","--port=$HttpPort"

Write-Host "Starting Chat WebSocket gateway on ws://$Host`:$WsPort ..."
Start-Process -FilePath $PhpPath -WorkingDirectory $backend -ArgumentList "artisan","chat:ws","--host=$Host","--port=$WsPort"

Write-Host "Started. Use Task Manager or Stop-Process to terminate php.exe workers."
