# Branch Protection Recommendation

## Target
- Protected branch: `main` (or your default release branch).

## Required Rules
1. Require a pull request before merging.
2. Require status checks to pass before merging.
3. Require branches to be up to date before merging.
4. Do not allow force pushes.
5. Do not allow branch deletion.

## Required CI Checks
- `backend-tests` (Laravel `php artisan test`)
- `android-build` (Android `:app:assembleDebug`)

## Suggested Optional Rules
1. Require at least 1 approval review.
2. Dismiss stale approvals when new commits are pushed.
3. Require conversation resolution before merge.
4. Restrict who can push directly to protected branches.

## Why
- Prevents regressions from entering stable branch.
- Makes every merge reproducible in a clean CI environment.
- Reduces local-environment-only success cases.

## Setup Path (GitHub UI)
- Repository -> `Settings` -> `Branches` -> `Add branch protection rule`.

