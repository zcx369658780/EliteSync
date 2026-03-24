# Matching Algo P1 Runbook

Updated: 2026-03-24

Scope:
- Core score: `personality(50%) + mbti(15%) + astro(35%)`
- Astro sub-weights: `bazi(50%) + zodiac(25%) + constellation(15%) + natal_chart(10%)`
- Same-city hard filter with normalized city comparison (`南阳市` = `南阳`)
- Synthetic visibility controlled by debug switch

## 1) Prerequisites
1. Aliyun backend deployed and healthy:
- `http://101.133.161.203/up` => `200`
2. Required env/config is valid:
- `.env` contains non-empty `APP_KEY`
- DB connection works (`DB_HOST=127.0.0.1` in this deployment)

## 2) Run Matching (server)
Use:
`php artisan app:dev:run-matching --include-synthetic=1 --reset-week --release-drop`

Expected output:
- `pairs_created > 0`
- `released > 0`

## 3) Enable Synthetic Visibility (debug)
If current match is synthetic, `/api/v1/matches/current` returns `no match` unless debug is on.

Set enabled:
`php artisan tinker --execute="Cache::forever('matching_debug_include_synthetic_users', true); echo Cache::get('matching_debug_include_synthetic_users') ? 'enabled' : 'disabled';"`

Set disabled:
`php artisan tinker --execute="Cache::forever('matching_debug_include_synthetic_users', false); echo Cache::get('matching_debug_include_synthetic_users') ? 'enabled' : 'disabled';"`

## 4) Smoke Validation (local runner)
Full smoke:
`powershell -ExecutionPolicy Bypass -File .\scripts\smoke_backend_alpha.ps1 -ServerHost 101.133.161.203 -Phone 13800000022 -Password "1234567aa"`

Should pass:
- Version API
- Download URL
- Login
- Profile Basic GET/POST
- MBTI Quiz/Result
- Astro GET

## 5) E2E Validation (manual API chain)
1. Login test user
2. `GET /api/v1/matches/current`
3. `POST /api/v1/messages` with `receiver_id = partner_id`
4. `GET /api/v1/messages?peer_id=<partner_id>`

Expected:
- `current` returns `match_id/partner_id/core_scores`
- `send` returns `ok=true`
- `list.total >= 1` after send

## 6) Troubleshooting
1. `no match`
- Check if user is in this week pool
- Check hard filters:
  - same-city (`normalizeCityForMatch`)
  - opposite-gender
  - required questionnaire count
- If partner synthetic and debug off, API will return `no match` by design

2. `No application encryption key has been specified`
- Ensure `.env` has `APP_KEY`
- Fix:
  - `php artisan key:generate --force`
  - `php artisan optimize:clear`
  - `php artisan config:cache`
  - `php artisan route:cache`
  - restart `php8.4-fpm`

3. Login/DB errors
- Verify `.env`: `DB_HOST/DB_PORT/DB_DATABASE/DB_USERNAME/DB_PASSWORD`
- Rebuild Laravel caches after edits

## 7) Release Notes Guidance
When this matching bundle changes, include in changelog:
- MBTI scoring model upgrade
- reason module output changes
- city normalization behavior
- synthetic debug switch behavior
