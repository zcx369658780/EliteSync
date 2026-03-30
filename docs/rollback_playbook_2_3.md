# Rollback Playbook 2.3

## Trigger conditions
- match detail parsing errors on client
- confidence badge behavior abnormal
- western explanation wording overstates certainty
- regression fail after deploy

## Fast rollback steps
1. Set conservative policy:
   - `WESTERN_POLICY_MODE=legacy_display`
2. Disable risky rollout paths if needed:
   - western canonical toggle/whitelist off
3. Refresh config:
   - `php artisan config:cache`
4. Re-run smoke:
   - version check
   - login
   - `/api/v1/match/current`
   - `/api/v1/match/explanation/{target}`

## Deep rollback (if schema/contract risk appears)
1. Revert backend commit to last stable tag
2. Clear opcache/restart php-fpm
3. Re-run release gate quick checks
4. Announce rollback reason + next action

## Data integrity notes
- 2.3 changes are mostly config/payload-layer additions; no destructive migration required for fallback.
