# Android Release Regression Checklist

Updated: 2026-03-24

Related:
- `docs/runbooks/GITHUB_BRANCH_PROTECTION_SETUP.md`

## 1) Pre-release (local)
0. Gate check (recommended):
- Quick update path:
`powershell -ExecutionPolicy Bypass -File .\scripts\release_gate_alpha.ps1 -QuickUpdateOnly`
- Full gate (compile + full smoke):
`powershell -ExecutionPolicy Bypass -File .\scripts\release_gate_alpha.ps1 -Phone 13800000022 -Password "******"`
- Optional (algorithm calibration cycle, default is off):
`powershell -ExecutionPolicy Bypass -File .\scripts\release_gate_alpha.ps1 -RunCalibrationCycle -CalibrationOnlyMismatch`
- Optional dry-run (preview only):
`powershell -ExecutionPolicy Bypass -File .\scripts\release_gate_alpha.ps1 -RunCalibrationCycle -CalibrationDryRun -CalibrationOnlyMismatch -SkipAndroidBuild -SkipBackendSmoke -SkipAstroRegression`

1. Update version in `apps/android/app/build.gradle.kts` (`versionName`, `versionCode`).
2. Append release notes in `apps/android/app/src/main/assets/changelog_v0.txt`.
3. Build passes: `:app:assembleDebug`.
4. Smoke test:
- Login/Register
- Basic profile save
- Auto city location
- Birth-place search + select
- MBTI submit + display
- Match current returns data (not only `no match`) for designated test account
- Match reasons render module fields (weight/confidence/degraded)
- Match reasons render standardized fields (`reason_short/reason_detail/risk_short/risk_detail/evidence_tags`)
- Message send + list works after entering match
- About -> Check update returns server latest version
5. Server config sanity:
- `.env` `APP_KEY` is non-empty
- DB host/user/password are valid for current deploy target
- If testing synthetic matches, ensure `matching_debug_include_synthetic_users=true`
- In production, ensure `MATCHING_ALLOW_SYNTHETIC_COMMANDS_IN_PRODUCTION=false` (unless explicit controlled operation)

## 2) Release to Aliyun
Use:
`powershell -ExecutionPolicy Bypass -File .\scripts\release_android_update_aliyun.ps1 -VersionName <x.x.xx> -Changelog "..."`

Verify during release:
1. APK uploaded to `/opt/elitesync/services/backend-laravel/public/downloads/`.
2. Version metadata updated in `.env` and `app_release_versions`.
3. Keep only latest two APKs on server.

## 3) Post-release (online)
1. `GET /api/v1/app/version/check` returns:
- `latest_version_name` = released version
- `has_update=true` for previous client versions
- valid `download_url`
2. APK url returns HTTP 200.
3. Old app can check update, download and install.
4. New app launches and core flows remain normal.

## 3.1) Match payload contract regression (required)
Use a designated account that should have current match and check `GET /api/v1/matches/current`.

Required payload path:
- `match_reasons.modules[]`

Required fields for each module:
- `key`, `label`, `score`, `weight`, `confidence`, `verdict`
- `reason_short`, `reason_detail`
- `risk_short`, `risk_detail`
- `evidence_tags`, `evidence`
- `degraded`, `degrade_reason`

UI verification (Android):
- Match screen shows module summary (`score + verdict + weight + confidence`)
- Match screen shows short/detail reasons and risk lines (fallback to highlights/risks only when new fields are empty)
- Match screen can show evidence tags without crash

## 4) Rollback hint
If update path breaks:
1. Repoint `ANDROID_*` env to previous working apk/version.
2. `php artisan config:cache`
3. Restart `php8.4-fpm` and `nginx`.
