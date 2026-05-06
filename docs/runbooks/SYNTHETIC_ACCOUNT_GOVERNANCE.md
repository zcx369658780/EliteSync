# Synthetic Account Governance Runbook

Updated: 2026-05-05

## 1. Purpose

Define how EliteSync tracks smoke / synthetic / test accounts during 5.4 testing operations readiness.

Synthetic accounts are for safe product flow validation. They must not pollute production user metrics or relationship recommendations.

## 2. Account Categories

- Real user: normal account, not controlled by the test team.
- Smoke account: manually managed account for route and login validation.
- Synthetic account: generated or prepared account for repeatable tests.
- Excluded metric account: account that should not count toward operational metrics.

## 3. Minimum Fields To Verify

If available from backend or admin data:

- `account_type`
- `is_synthetic`
- `exclude_from_metrics`
- `visibility_scope`
- `synthetic_batch`
- `synthetic_batch_id`
- `synthetic_seed`
- `generation_version`
- `cleanup_token`
- `account_status`

Do not invent these fields in frontend UI. If a field is unavailable, record it as unavailable.

## 4. Safe Handling Rules

- Do not publish synthetic accounts into real recommendation pools unless explicitly intended.
- Do not allow synthetic accounts to inflate metrics.
- Do not store account passwords in the repository.
- Do not perform bulk cleanup from Codex unless the user explicitly approves a concrete command and environment.
- Prefer read-only dashboard summaries first.

## 5. Evidence To Capture

Minimum 5.4 evidence:

- Admin dashboard showing test / synthetic / metric-excluded counts.
- Source of account state: mock admin data, staging backend, or read-only cloud check.
- Any unresolved difference between UI counts and backend/read-only audit.

## 6. Cleanup Decision Template

```text
Batch:
Environment:
Synthetic count:
Metric-excluded count:
Visibility scope:
Cleanup needed:
Cleanup method:
Approval required:
Observation:
```

