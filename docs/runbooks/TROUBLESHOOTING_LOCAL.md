# Local Troubleshooting

## Quick Check
- Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check_debug_ready.ps1 -ProjectRoot D:\EliteSync
```

## Common Issues

### 1) Docker daemon not reachable
- Symptom: `permission denied ... //./pipe/docker_engine` or `Docker daemon: FAIL`.
- Fix:
  - Start Docker Desktop.
  - Re-open terminal after Docker is ready.

### 2) Backend HTTP health `/up` fails
- Symptom: `HTTP /up: FAIL`.
- Fix:
  - Start backend:
    - `powershell -ExecutionPolicy Bypass -File .\scripts\start_laravel_realtime_local.ps1`
  - Verify port:
    - `netstat -ano | findstr :8080`

### 3) WS port 8081 not listening
- Symptom: `WS tcp://127.0.0.1:8081: FAIL`.
- Fix:
  - Ensure websocket command is running:
    - `C:\tools\php85\php.exe artisan chat:ws --host=0.0.0.0 --port=8081`
  - Verify:
    - `netstat -ano | findstr :8081`

### 4) Android app shows `HTTP 500 could not find driver`
- Cause: missing SQLite PDO extension in PHP.
- Fix:
  - Enable `pdo_sqlite` and `sqlite3` in `php.ini`.
  - Re-run `php -m` to confirm extensions.

### 5) Match always says not available
- Cause:
  - Questionnaire not fully completed, or
  - No drop released match yet.
- Fix:
  - Save answers for all questions.
  - In match page, run `开发联调：生成并发布匹配`.

### 6) Login/Register works but wrong user data appears
- Fix:
  - Re-login to refresh token/session state.
  - If test data polluted, reset DB:
    - `C:\tools\php85\php.exe artisan migrate:fresh --seed`

## Request Trace
- API responses include `X-Request-Id`.
- Backend logs include:
  - `request_id`, `route`, `status`, `latency_ms`.
- Use `storage/logs/laravel.log` for correlation.

