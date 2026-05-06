# Backup, Restore, and Migration Check Runbook

Updated: 2026-05-05

## 1. Purpose

Define the minimum 5.4 readiness checks for backup, restore, and migration safety before small-sample testing.

This runbook is a verification checklist. It does not execute backup, restore, migration, or rollback by itself.

## 2. Scope

Allowed:

- Verify that a backup exists for the intended environment.
- Verify that restore instructions are documented.
- Verify migration status from a read-only perspective.
- Record evidence and observations.

Not allowed:

- Running production restore without explicit approval.
- Running schema migrations as part of this check.
- Deleting, truncating, or rewriting production data.
- Repo-level rollback.
- Mixing backend recovery work with Flutter UI changes.

## 3. Pre-checks

1. Identify environment: dev / staging / production.
2. Identify backup owner and storage location without copying secrets into the repo.
3. Confirm latest successful backup timestamp.
4. Confirm whether restore has been tested on a non-production target.
5. Confirm current migration level through read-only inspection or deployment logs.

## 4. Evidence To Capture

Minimum evidence:

- Backup existence and timestamp.
- Restore runbook path or console page reference.
- Migration status source.
- Whether restore was only documented or actually drilled.
- Any blocker preventing safe restore verification.

## 5. Decision Rules

- If backup existence cannot be confirmed, mark as observation or blocker depending on target environment.
- If restore has never been drilled outside production, do not claim restore readiness.
- If migration status is unclear, do not run migrations from Codex; write a blocker report.
- If UI testing is unrelated, do not touch Flutter runtime files during this runbook check.

## 6. Audit Record Template

```text
Date:
Environment:
Backup timestamp:
Restore drill status:
Migration status source:
Result:
Evidence path:
Observation:
```

