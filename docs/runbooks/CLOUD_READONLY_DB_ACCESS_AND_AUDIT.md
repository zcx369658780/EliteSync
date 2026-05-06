# Cloud Read-only DB Access and Audit Runbook

Updated: 2026-05-05

## 1. Purpose

Define the minimum safe procedure for read-only cloud database verification during EliteSync 5.4 testing operations readiness.

This runbook does not grant write permission, does not define migration steps, and does not store credentials.

## 2. Scope

Allowed:

- Confirm the target environment and connection identity.
- Use a read-only account or read-only replica where available.
- Inspect schema version, row counts, and sample non-sensitive aggregate state.
- Record audit notes in 5.4 evidence materials.

Not allowed:

- Production writes.
- Schema changes.
- Data backfill.
- Destructive SQL.
- Exporting private user data into the repo.
- Storing passwords, tokens, PEM files, or connection strings in docs.

## 3. Pre-checks

Before connecting:

1. Confirm the target environment: dev / staging / production.
2. Confirm the account is read-only.
3. Confirm the reason for access and the exact tables or views to inspect.
4. Capture `git status --short` if local code changes are part of the same verification session.
5. Do not run any command that changes schema or rows.

## 4. Minimum Read-only Checks

Recommended checks:

- Database server reachable from the approved machine.
- App migration table exists and current migration level is recorded.
- User count can be checked as an aggregate only.
- Synthetic / smoke account count can be checked as an aggregate only.
- Notification / media / RTC / queue tables or equivalent surfaces are present if they exist in the current backend.
- No private payload is copied into repository files.

## 5. Audit Record Template

Use this format in the 5.4 evidence index or handoff:

```text
Date:
Environment:
Operator:
Read-only identity:
Checked surfaces:
Commands or console pages used:
Result:
Evidence path:
Observation:
```

## 6. Failure Handling

If read-only access fails:

- Record the blocker without retry loops.
- Do not switch to a write-capable account as a shortcut.
- Do not alter firewall, security group, database user, or production config from Codex without explicit user approval.
- Treat unclear backend / cloud / credential boundaries as a cross-layer blocker.

