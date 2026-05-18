# EliteSync Project Rule: Cross-layer Blockers

## 0. One-line conclusion

When a visible frontend/app symptom may be caused by backend, network, server, SDK, build, DB, or release-chain layers, Codex must stop blind fixes and switch to evidence-first blocker handling.

## 1. Purpose

This rule prevents Codex from repeatedly modifying UI/runtime while the true cause may be in server configuration, ports, protocol, API contract, environment, or release chain.

## 2. Trigger conditions

Use this rule when any of the following apply:

- frontend symptom conflicts with backend/server logs
- app shows success but backend state is missing
- backend/API looks healthy but app cannot reach it
- RTC / media / websocket / notification / version-check / storage behavior is inconsistent across layers
- staging / production / SSH tunnel / Nginx / firewall / port / SSL / SDK behavior is involved
- two consecutive Codex attempts do not reduce uncertainty

## 3. Required blocker report

Before further implementation, create a blocker report containing:

- observed symptom
- affected layers
- known facts
- unknowns
- commands already run
- files changed so far
- what has not been touched
- suspected layer candidates
- safe next evidence to collect
- explicit forbidden actions

Future references to this rule should use:

```text
docs/project_rules/PROJECT_RULE_CROSS_LAYER_BLOCKERS.md
```

## 4. Multi-agent review policy

- Claude may be used for architecture / cross-layer diagnosis.
- Gemini may be used for visual / UX / screenshot consistency.
- Neither subagent may bypass current authorization gates.
- Any server / DB / production / endpoint action still requires explicit user authorization.

## 5. Server and production safety

- no SSH write without explicit authorization
- no Nginx reload/restart without explicit authorization
- no endpoint verification without explicit authorization
- no staging/production request without explicit authorization
- no DB/migration/restore without explicit authorization
- no `.env` / secret output

## 6. Current A1 Option B note

- Option B symlink execution is a separate high-risk gate.
- This rule file does not authorize symlink creation, nginx -t, reload, endpoint verification, staging request, or production request.
- If symlink execution produces warning/failure, create blocker report before continuing.
