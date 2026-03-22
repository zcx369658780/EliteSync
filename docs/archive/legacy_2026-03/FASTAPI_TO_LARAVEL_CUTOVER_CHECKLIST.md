# FastAPI to Laravel Cutover Checklist

## Scope
- Goal: switch runtime traffic from legacy FastAPI endpoints to Laravel endpoints with minimal risk.

## 1) Contract Alignment
- [ ] Confirm all P0 APIs are implemented in Laravel.
- [ ] Confirm request/response schema compatibility (or app-side adapter is ready).
- [ ] Confirm unified error payload format is accepted by clients.
- [ ] Freeze route map and deprecation list for legacy FastAPI routes.

## 2) Data and State
- [ ] Confirm production DB schema parity for required tables.
- [ ] Confirm migration scripts are repeatable and reversible.
- [ ] Confirm seed/demo data scripts are environment-gated (no prod pollution).
- [ ] Confirm token/auth model migration strategy (if legacy token exists).

## 3) Runtime Readiness
- [ ] HTTP health endpoint ready (`/up`).
- [ ] WS gateway readiness verified (`:8081` or target port).
- [ ] Request trace enabled (`request_id`, `route`, `status`, `latency_ms`).
- [ ] Basic rate limiting and timeout policy reviewed.

## 4) CI/CD Gate
- [ ] Backend tests passing in remote CI.
- [ ] Android build passing in remote CI.
- [ ] Branch protection requiring CI checks is enabled.
- [ ] Rollback instructions are documented and tested once.

## 5) Release Plan
- [ ] Choose cutover window and freeze period.
- [ ] Canary release plan (internal users first).
- [ ] Monitor error rate, p95 latency, WS connection health.
- [ ] Define rollback threshold and decision owner.

## 6) Rollback Plan
- [ ] Keep FastAPI service deployable during initial cutover.
- [ ] Keep previous infra config snapshot.
- [ ] One-command rollback path documented.
- [ ] Post-rollback data reconciliation plan prepared.

## 7) Acceptance Criteria
- [ ] Register/login/questionnaire/match/chat all pass in E2E smoke test.
- [ ] No P0 regression in first 24h of canary.
- [ ] No unresolved critical alerts in logs/monitoring.

