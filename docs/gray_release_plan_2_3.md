# Gray Release Plan 2.3

## Stage 0: Internal verification
- Run `scripts/run_explanation_regression.ps1`
- Validate key payload fields in staging:
  - `display_tags`
  - `display_guard`
  - `explanation_blocks`
- Recommended command:
  - `powershell -ExecutionPolicy Bypass -File .\scripts\run_23_stage1_checks.ps1`

## Stage 1: Whitelist canary
- Keep `WESTERN_POLICY_MODE=legacy_display`
- Enable new payload consumption for internal test users only
- Observe:
  - API error rate
  - client parsing failures
  - match detail load latency
- Recommended rehearsal command:
  - `powershell -ExecutionPolicy Bypass -File .\scripts\run_23_gray_rehearsal.ps1 -Phone <test_phone> -Password <test_password>`

## Stage 2: Wider rollout
- Expand to synthetic + internal accounts
- Compare before/after snapshots of explanation outputs
- Confirm no raw tag leakage

## Stage 3: Full rollout
- Enable for all users
- Keep rollback switch ready
- Monitor for 24h and 72h windows

## Script outputs
- Stage1 check summary:
  - `scripts/run_23_stage1_checks.ps1`
- Gray rehearsal report:
  - `reports/explanation_snapshot_diff/gray_rehearsal_2_3_latest.md`

## Guard metrics
- `match/current` success rate
- `match/explanation` success rate
- client-side parse error count
- complaint rate regarding misleading confidence wording
