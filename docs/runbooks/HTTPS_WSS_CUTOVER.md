# HTTPS/WSS Cutover Checklist

Updated: 2026-03-19

## Preconditions
- Domain approved and resolved:
  - `slowdate.top` or `api.slowdate.top` -> `101.133.161.203`
- SSH key available:
  - `C:\Users\zcxve\.ssh\CodexKey.pem`
- Server baseline already running:
  - nginx / php8.4-fpm / mariadb / redis / elitesync-ws

## Step 1: Verify DNS from server
```bash
dig +short slowdate.top
```
Expected: `101.133.161.203`

## Step 2: Enable HTTPS + enforce backend secure transport
Run in repo root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\enable_https_wss_aliyun.ps1 `
  -Domain slowdate.top `
  -Email your-email@example.com `
  -ServerHost 101.133.161.203 `
  -User root `
  -KeyPath C:\Users\zcxve\.ssh\CodexKey.pem
```

What this script does:
- Generates nginx vhost for Laravel + websocket proxy
- Issues Let's Encrypt certificate via `certbot --nginx`
- Redirects HTTP -> HTTPS
- Sets backend `.env`:
  - `APP_URL=https://slowdate.top`
  - `SECURITY_ENFORCE_HTTPS=true`

## Step 3: Switch Android endpoints to HTTPS/WSS
Update `apps/android/app/build.gradle.kts`:
- `API_BASE_URL = "https://slowdate.top/"`
- `WS_BASE_URL = "wss://slowdate.top/"`

Then rebuild and install APK.

## Step 4: Post-checks
- `https://slowdate.top/up` returns 200
- Register/login works
- Questionnaire/match/chat all work
- WebSocket connects on `wss://slowdate.top/api/v1/messages/ws/{userId}`

## Rollback (temporary)
If certificate or DNS has issues:
- set `SECURITY_ENFORCE_HTTPS=false` in backend `.env`
- restart services
- keep app on current IP-based HTTP/WS until DNS/SSL is fixed
