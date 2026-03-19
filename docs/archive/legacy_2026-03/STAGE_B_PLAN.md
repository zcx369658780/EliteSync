# Stage B Plan

## Goal
- Move from "locally runnable" to "engineering-stable and repeatable".
- Establish minimum quality gates in repository CI.

## B1. CI Baseline (in progress)
- [x] Add GitHub Actions workflow for backend Laravel tests.
- [x] Add GitHub Actions workflow for Android `assembleDebug`.
- [ ] Verify workflow green on remote branch.

## B2. Contract and Error Handling
- [x] Freeze P0 API response schema (auth/questionnaire/match/messages/admin).
- [x] Unify backend error payload format and Android error mapping.
- [x] Add one regression test for each critical API group.

## B3. Runtime Observability
- [x] Add startup/runbook checks for API + WS status.
- [x] Define minimum log fields for request tracing (`request_id`, route, status, latency).
- [x] Add troubleshooting section for common local failures.

## B4. Release Hygiene
- [x] Clean tracked build artifacts from repository and tighten `.gitignore`.
- [x] Add branch protection recommendation (require CI checks).
- [x] Prepare fastapi cutover checklist draft.

## Exit Criteria
- [ ] CI checks pass consistently on pull requests.
- [ ] End-to-end flow is reproducible from clean checkout.
- [ ] No P0 blocking defect in default demo path.
