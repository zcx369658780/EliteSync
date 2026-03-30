# ADR: Western Canonical Route (2.3)

Date: 2026-03-30
Status: Accepted (architecture), Pending (commercial authorization)

## Context
Current western astrology output is partly engine-assisted but not yet in fully authorized canonical production mode.
Risk: UI wording can overstate certainty when engine/data completeness is limited.

## Decision
Adopt a policy-driven route:
1. **Current default**: `legacy_display`
   - western output usable for display and process hints.
   - no high-confidence badge / no strong deterministic wording.
2. **Transition**: `hybrid_candidate`
   - whitelist + shadow-compare + regression guard.
3. **Target**: `canonical_authorized`
   - only after license/commercial/legal approval and production SLO validation.

Policy file: `config/western_policy.php`

## Consequences
- Backend can prevent confidence overstatement without waiting for full engine migration.
- Frontend receives coherent metadata (`engine_mode`, `display_guard`) and can render consistent cues.
- Legal/compliance gate is embedded in runtime policy, not only process docs.

## Out of Scope
- This ADR does not approve any AGPL/commercially restricted dependency for default closed-source production.
