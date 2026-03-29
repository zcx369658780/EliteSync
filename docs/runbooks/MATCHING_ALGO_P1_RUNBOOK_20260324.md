# Matching Algo P1 Runbook

Updated: 2026-03-29

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

## 8) Weekly Calibration Cycle (Astro 2.2)
Goal:
- Keep matching score explainable and calibratable with real outcomes.
- Run as weekly operation before large weight changes.

Primary command:
`powershell -ExecutionPolicy Bypass -File .\scripts\run_astro_calibration_cycle.ps1`

If calibration injector data should be counted:
`powershell -ExecutionPolicy Bypass -File .\scripts\run_astro_calibration_cycle.ps1 -IncludeCalibrationInjected`

Optional variants:
- Only mismatch rows for shadow compare:
`powershell -ExecutionPolicy Bypass -File .\scripts\run_astro_calibration_cycle.ps1 -OnlyMismatch`
- Limit export size:
`powershell -ExecutionPolicy Bypass -File .\scripts\run_astro_calibration_cycle.ps1 -CalibrationLimit 3000`
- With explicit week tag:
`powershell -ExecutionPolicy Bypass -File .\scripts\run_astro_calibration_cycle.ps1 -WeekTag 2026W13`
- Preview only:
`powershell -ExecutionPolicy Bypass -File .\scripts\run_astro_calibration_cycle.ps1 -DryRun`

Artifacts:
- `docs/devlogs/ASTRO_SHADOW_COMPARE.md`
- `docs/devlogs/PAIR_OUTCOME_METRICS.md`
- `docs/devlogs/MATCH_CALIBRATION_DATASET.csv`
- `docs/devlogs/CALIBRATION_CYCLE_LOG.md`
- Weekly report template:
`docs/devlogs/CALIBRATION_WEEKLY_REPORT_TEMPLATE.md`
- Auto advisor report:
`powershell -ExecutionPolicy Bypass -File .\scripts\generate_calibration_weekly_report.ps1 -WeekTag 2026W13`
- WeChat brief (short text):
`powershell -ExecutionPolicy Bypass -File .\scripts\generate_calibration_wechat_brief.ps1 -WeekTag 2026W13`

Pass criteria (minimum):
1. Command exits with code 0.
2. Four artifacts above are updated.
3. No abnormal spike in shadow compare diff dimensions.
4. Outcome funnel report is readable and complete for current sample window.

Note:
- For release gate integration, use:
`powershell -ExecutionPolicy Bypass -File .\scripts\release_gate_alpha.ps1 -RunCalibrationCycle -CalibrationOnlyMismatch`
- Calibration step in release gate is optional and disabled by default.

### 8.1) Test-data bootstrap for calibration labels (staging/dev only)
When labels are all zeros (e.g., `reply_24h=0`, `sustained_7d=0`), inject controlled positive samples first:

Prerequisite gate (required):
- `MATCHING_CALIBRATION_INJECTOR_ENABLED=true`
- If server is production env: `MATCHING_CALIBRATION_INJECTOR_ALLOW_IN_PRODUCTION=true`

One-click mode switch:
`powershell -ExecutionPolicy Bypass -File .\scripts\apply_calibration_mode.ps1 -Mode off|inject_only|inject_and_include`

```bash
php artisan app:dev:inject-calibration-positives --days=30 --limit=200 --seed=20260329 --mutual-like-rate=0.35 --first-message-rate=0.30 --reply24h-rate=0.20 --sustained7d-rate=0.10 --explanation-view-rate=0.40
```

Dry run:

```bash
php artisan app:dev:inject-calibration-positives --days=30 --limit=200 --dry-run
```

Then rerun:
1. `app:dev:pair-outcome-metrics`
2. `app:dev:export-match-calibration`

Notes:
- Injected chat rows are marked with `[[calibration_injector]]` prefix.
- Injected explanation events use `match_explanation_view_calibration`.
- Metrics/export default behavior is to exclude injected rows/events unless `--include-calibration-injected` is specified.

Cleanup injected rows after calibration run:
```bash
php artisan app:dev:cleanup-calibration-injected --days=30 --limit=500
```

### 8.2) Core/Astro weight tuning via .env
Core weights (default):
- `MATCH_WEIGHT_PERSONALITY=0.58`
- `MATCH_WEIGHT_MBTI=0.07`
- `MATCH_WEIGHT_ASTRO=0.35`

Astro sub-weights (default):
- `MATCH_ASTRO_WEIGHT_BAZI=0.45`
- `MATCH_ASTRO_WEIGHT_ZODIAC=0.25`
- `MATCH_ASTRO_WEIGHT_CONSTELLATION=0.08`
- `MATCH_ASTRO_WEIGHT_NATAL_CHART=0.07`
- `MATCH_ASTRO_WEIGHT_PAIR_CHART=0.15`

Apply after editing `.env`:
```bash
php artisan config:cache
```

Recommended rule:
- At most 1-2 fields per round.
- Each single field change <= 10%.
- Keep rollback values in the same change ticket.

One-click profile switch script:
`powershell -ExecutionPolicy Bypass -File .\scripts\apply_match_tuning_profile.ps1 -Profile baseline|a1|b1`
