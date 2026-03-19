# Cloud Deploy Runbook (Aliyun)

Updated: 2026-03-18

## Goal
Use one standard flow:
1. verify backend changes locally
2. upload to Aliyun
3. apply migrate/cache/restart
4. verify health endpoint

## Prerequisites
- Windows has `ssh` and `scp`
- Server key exists:
  - `C:\Users\zcxve\.ssh\CodexKey.pem`
- Server already bootstrapped with:
  - nginx
  - php8.4-fpm
  - mariadb
  - redis
  - systemd service `elitesync-ws`
- Project path on server:
  - `/opt/elitesync`

## Standard command
Run from repo root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\deploy_aliyun_backend.ps1 `
  -ServerHost 101.133.161.203 `
  -User root `
  -KeyPath C:\Users\zcxve\.ssh\CodexKey.pem `
  -ValidateLocal `
  -RunSeeder
```

## Common modes
- Backend code only (no question reseed):

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\deploy_aliyun_backend.ps1 `
  -ServerHost 101.133.161.203 -User root -KeyPath C:\Users\zcxve\.ssh\CodexKey.pem
```

- Skip migrations:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\deploy_aliyun_backend.ps1 `
  -ServerHost 101.133.161.203 -User root -KeyPath C:\Users\zcxve\.ssh\CodexKey.pem `
  -SkipMigrate
```

- Skip composer (fast sync for pure config change):

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\deploy_aliyun_backend.ps1 `
  -ServerHost 101.133.161.203 -User root -KeyPath C:\Users\zcxve\.ssh\CodexKey.pem `
  -SkipComposer
```

## Post-deploy checks
1. Health:
   - `http://101.133.161.203/up`
2. API quick check:
   - `POST /api/v1/auth/register`
3. WS port:
   - `ws://101.133.161.203:8081/api/v1/messages/ws/{userId}`
4. Service status on server:
   - `systemctl status nginx php8.4-fpm mariadb redis-server elitesync-ws`

## Notes
- Android app currently points to cloud host:
  - API: `http://101.133.161.203/`
  - WS: `ws://101.133.161.203:8081/...`
- For production release later, switch to domain + HTTPS/WSS.
