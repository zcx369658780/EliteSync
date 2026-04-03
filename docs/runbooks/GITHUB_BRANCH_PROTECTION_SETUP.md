# GitHub Branch Protection Setup (main)

Updated: 2026-03-22

## Goal
Prevent unstable code from being merged into `main` by requiring CI checks.

## Recommended Required Status Checks
Enable branch protection on `main`, then mark these checks as required:

1. `Release Gate (Quick)`
2. `Backend Laravel Tests`
3. `Android Assemble Debug`

## GitHub UI Steps
1. Open repo -> `Settings` -> `Branches`.
2. Click `Add branch protection rule`.
3. Branch name pattern: `main`.
4. Enable:
   - `Require a pull request before merging`
   - `Require approvals` (recommend 1+)
   - `Require status checks to pass before merging`
   - `Require branches to be up to date before merging` (recommended)
5. In required checks, select:
   - `Release Gate (Quick)`
   - `Backend Laravel Tests`
   - `Android Assemble Debug`
6. Save.

## Optional Hardening
1. Enable `Require conversation resolution before merging`.
2. Enable `Do not allow bypassing the above settings`.
3. Enable `Restrict who can push to matching branches` (for protected repos).

## Operational Notes
1. `Release Gate (Quick)` only validates update-chain public checks.
2. Full gate is still required before actual release:
   - `powershell -ExecutionPolicy Bypass -File .\scripts\release_gate_alpha.ps1 -Phone 13800000022 -Password "******"`
3. Gate logs are uploaded as workflow artifacts and appended locally to:
   - `docs/devlogs/RELEASE_GATE_LOG.md`
   - `docs/devlogs/REGRESSION_BASELINE_LOG.md`

## Manual Full Regression Workflow
Use workflow `regression-full-manual` when you need full baseline validation in GitHub Actions.

### Required Secrets
Configure in `Settings -> Secrets and variables -> Actions`:
1. `ELITESYNC_TEST_PHONE`
2. `ELITESYNC_TEST_PASSWORD`

### Trigger
1. Open `Actions` -> `regression-full-manual`.
2. Click `Run workflow`.
3. Optional input: `base_url` (defaults to `http://101.133.161.203`).
4. Run and wait for:
   - `Regression Full Baseline` job
   - artifact `regression-full-logs`
