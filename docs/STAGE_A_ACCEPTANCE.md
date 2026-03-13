# Stage A Acceptance Checklist

## Scope
- Goal: close Phase A with a stable local end-to-end flow.
- Date: 2026-03-13.

## Environment
- [x] PHP local runtime available (`8.5.x`).
- [x] Composer dependencies installed.
- [x] Laravel migration + seeding completed.
- [x] Android debug build succeeds.
- [x] WebSocket gateway command runs (`artisan chat:ws`).

## Backend API
- [x] Auth APIs: register/login/refresh.
- [x] Questionnaire APIs: questions/answers/progress.
- [x] Match APIs: current/confirm/history.
- [x] Chat APIs: send/list/read.
- [x] Admin APIs: users/verify-queue/verify/disable.
- [x] Dev match APIs: run-matching/release-drop.

## Client Flow
- [x] Register and login on Android.
- [x] Load questionnaire and submit answers.
- [x] Match page can refresh and show result after dev trigger.
- [x] Chat page can send messages.
- [x] Chat page can receive real-time messages via WebSocket.

## Test Baseline
- [x] Laravel test suite passes (`7 passed`).
- [x] Android `assembleDebug` passes.

## Exit Criteria for Stage B
- [x] Main flow is repeatable on a clean local run.
- [x] No blocking P0 crash/500 in the default demo path.
- [ ] Add CI gates (backend tests + android build) in repository pipeline.
- [ ] Finalize fastapi-to-laravel cutover checklist.
