# API P0 Contract (Laravel)

## Base
- Base URL: `http://127.0.0.1:8080`
- API Prefix: `/api/v1`
- Auth: `Authorization: Bearer <token>` (Sanctum)

## Unified Error Payload
- All `/api/*` errors return:

```json
{
  "ok": false,
  "error": {
    "code": "validation_error|unauthenticated|forbidden|http_error|internal_error",
    "message": "human readable message",
    "details": {}
  }
}
```

## P0 Endpoints

### Auth
- `POST /api/v1/auth/register`
  - req: `{ "phone": "138...", "password": "123456", "name": "optional" }`
  - resp: `{ "user": { "id": 1, "phone": "...", "name": "..." }, "access_token": "...", "token_type": "Bearer" }`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh` (auth required)

### Questionnaire
- `GET /api/v1/questionnaire/questions` (auth required)
  - resp: `{ "items": [Question...], "total": 3 }`
- `POST /api/v1/questionnaire/answers` (auth required)
  - req: `{ "answers": [{ "question_id": 1, "answer": "A" }] }`
  - note: matching eligibility requires full completion (`progress.complete=true`)
- `GET /api/v1/questionnaire/progress` (auth required)
  - resp: `{ "answered": 3, "total": 3, "complete": true }`

### Match
- `GET /api/v1/matches/current` (auth required)
  - returns `404 questionnaire incomplete` if not fully answered
  - returns `404 drop not available` if no released match
- `POST /api/v1/matches/confirm` (auth required)
  - req: `{ "match_id": 1, "like": true }`
  - resp: `{ "mutual": true|false }`
- `GET /api/v1/matches/history` (auth required)

### Messages
- `POST /api/v1/messages` (auth required)
  - req: `{ "receiver_id": 2, "content": "hello" }`
- `GET /api/v1/messages?peer_id=2&after_id=0` (auth required)
- `POST /api/v1/messages/read/{messageId}` (auth required)
- `GET /api/v1/messages/ws/{userId}` (HTTP stub for WS path)

### Admin / Dev
- `GET /api/v1/admin/users` (auth required)
- `GET /api/v1/admin/verify-queue` (auth required)
- `POST /api/v1/admin/verify/{uid}` (auth required)
- `POST /api/v1/admin/users/{uid}/disable` (auth required)
- `POST /api/v1/admin/dev/run-matching` (auth required)
  - only non-disabled users with fully completed questionnaire are eligible
- `POST /api/v1/admin/dev/release-drop` (auth required)

## Local Health Checks
- HTTP health: `GET /up`
- WS tcp listen: `127.0.0.1:8081`
- One-shot readiness script:
  - `powershell -ExecutionPolicy Bypass -File .\scripts\check_debug_ready.ps1 -ProjectRoot D:\EliteSync`

