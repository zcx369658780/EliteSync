# Stage C Handover

## Goal

Stage C focuses on deployment hardening and online operations after local feature completeness.

## Input Baseline

- Matching pipeline: reciprocal V2.1 + penalties + fairness rerank.
- Question bank source of truth: `dating_question_bank_v_1.json`.
- Design references:
  - `dating_system_design_integrated.md`
  - `dating_system_design_supplement_for_codex.md`
- Daily metrics command available: `php artisan metrics:daily --days=7`.

## Recommended Stage C Tasks

1. Deployment packaging
- Finalize Docker files for backend + ws service + db.
- Add `.env` templates for staging/prod.

2. Security and ops
- Secret management (no plaintext tokens in repo).
- Rate limiting for auth/messages.
- Access and error logging policy.

3. CI/CD and release gates
- CI green gate for backend tests and Android build.
- Release checklist with migration rollback steps.

4. Observability
- Export daily metrics and trend snapshots.
- Add guardrail alerts for reply-rate and exposure concentration.

5. Pre-production dry-run
- Staging smoke test:
  - register/login
  - questionnaire
  - matching
  - chat realtime

## Commands

```powershell
cd D:\EliteSync\services\backend-laravel
C:\tools\php85\php.exe artisan migrate --force
C:\tools\php85\php.exe artisan metrics:daily --days=7
```

