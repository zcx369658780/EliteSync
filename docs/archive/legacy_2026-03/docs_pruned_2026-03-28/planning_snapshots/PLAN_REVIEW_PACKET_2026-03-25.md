# EliteSync Plan Review Packet (2026-03-25)

## 1. Current Progress Summary

### 1.1 Product / Runtime Status
- Android app and Laravel backend are in stable Alpha baseline.
- Version released: `0.01.07`.
- In-app update flow is working against Aliyun-hosted latest APK metadata.
- CI + Regression pipeline currently green after fixing missing committed dependencies issue.

### 1.2 Matching System (Core)
- Matching output has been unified into module-based structured payloads.
- Current modules include:
  - Personality
  - MBTI
  - Bazi
  - Zodiac
  - Constellation
  - Natal-chart (lightweight layer)
- Each module now supports normalized fields:
  - `score`, `verdict`, `confidence`
  - `reason_short`, `reason_detail`
  - `risk_short`, `risk_detail`
  - `evidence_tags`, `evidence`
  - `degraded`, `degrade_reason`

### 1.3 Frontend Alignment
- Android model and match UI are aligned to new payload contract.
- Match screen renders standardized fields first and falls back to legacy highlights/risks.
- Evidence tags are displayed.

### 1.4 Governance / Release Hygiene
- Release checklist has explicit match payload contract regression checks.
- Version changelog process is working and sorted newest-first.
- Server keeps only latest two APK versions.

### 1.5 Known Gaps / Pending
- User-facing password change flow is not yet implemented.
- Deeper astrology/Bazi algorithm still in staged form (intended for Beta major upgrade).
- Need continued prevention of synthetic-account side effects in production-like envs.

## 2. Current Roadmap Intent

### 2.1 Near-term (Alpha hardening)
- Keep core flows stable: login/profile/match/messages/update-check.
- Continue regression discipline and contract-based checks.
- Avoid risky architectural shifts.

### 2.2 Beta Major Upgrade (planned)
- Bazi rule depth upgrade (relations matrix, positional weighting, richer explainability).
- MBTI scoring refinement (4-dimension + function-level nuance with conservative claims).
- Rule versioning and weight profiles for controlled tuning.
- Better explainability pipeline and confidence/degradation governance.
- Algorithm regression baseline + drift alerts.

## 3. Constraints
- Backend PHP/Laravel remains single source of truth for matching runtime.
- Android remains consumer/rendering layer (no second scoring runtime).
- Team values predictable delivery and low regression risk over novelty.

## 4. Questions for Advisor (Android Studio Developer)
1. Given current architecture, what are the top 5 plan improvements with best risk/benefit?
2. What should be deferred to avoid destabilizing Alpha?
3. Is current Beta algorithm-upgrade decomposition sound, or should milestones be reshaped?
4. Any recommended additions for release quality gates (especially around matching payload and UX consistency)?
5. Any obvious UX/engineering debt items that should be solved before Beta starts?

## 5. Expected Output Format
- `Keep` (what to keep unchanged)
- `Adjust` (what to refine now)
- `Defer` (what to postpone)
- `Concrete next steps` (1-2 week actionable items)
