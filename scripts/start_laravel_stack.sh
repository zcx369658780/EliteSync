#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if docker compose version >/dev/null 2>&1; then
  DC="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  DC="docker-compose"
else
  echo "[ERROR] 未检测到 docker compose / docker-compose，请先安装 Docker Compose。"
  exit 1
fi

$DC -f infra/docker-compose.laravel.yml up -d --build
$DC -f infra/docker-compose.laravel.yml exec -T app php artisan key:generate --force
$DC -f infra/docker-compose.laravel.yml exec -T app php artisan migrate --seed --force

echo "[OK] Laravel stack started and migrated."
echo "API: http://localhost:8080"
echo "phpMyAdmin: http://localhost:8081"
