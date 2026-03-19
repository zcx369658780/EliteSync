# Ngrok Local Staging Guide

## Purpose
- Expose local backend to internet for "quasi-online" testing before cloud deployment.
- Reduce migration risk by validating network, auth, and websocket behavior first.

## Prerequisites
- Local backend running:
  - HTTP: `http://127.0.0.1:8080`
  - WS: `ws://127.0.0.1:8081`
- Ngrok installed and authenticated (`ngrok config add-authtoken ...`).

## 1) Start Tunnels

### Option A: two terminal commands
```powershell
ngrok http 8080
ngrok http 8081
```

### Option B: single ngrok config (recommended)
`%USERPROFILE%\\.ngrok2\\ngrok.yml`:
```yaml
version: "2"
tunnels:
  api:
    proto: http
    addr: 8080
  ws:
    proto: http
    addr: 8081
```
Run:
```powershell
ngrok start --all
```

## 2) Get Public URLs
- Example:
  - API: `https://abc123.ngrok-free.app`
  - WS: `https://def456.ngrok-free.app` (use `wss://` in client)

## 3) Android Debug Build Mapping
- API base URL -> `https://abc123.ngrok-free.app/`
- WS URL template -> `wss://def456.ngrok-free.app/api/v1/messages/ws/{userId}`

## 4) CORS / Host Notes
- Current Laravel setup is API-first and generally works for Android app calls.
- If browser H5 tests are added later, confirm CORS origin list.

## 5) Security Notes
- Ngrok URL is public; treat it as temporary.
- Do not expose admin endpoints in shared demos without admin whitelist set.
- Set `ADMIN_PHONES` for non-local environments.

## 6) Known Limits
- Free ngrok domains may rotate each restart.
- Latency may be higher than cloud VM in mainland China.

