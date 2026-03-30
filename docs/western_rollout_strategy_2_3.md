# Western Rollout Strategy 2.3

## Phased rollout
1. **Phase A: legacy_display (default)**
   - `WESTERN_POLICY_MODE=legacy_display`
   - no high confidence badge for western modules
   - focus on explanation consistency and fallback clarity

2. **Phase B: hybrid_candidate**
   - `WESTERN_POLICY_MODE=hybrid_candidate`
   - whitelist users only
   - run shadow compare and monitor drift

3. **Phase C: canonical_authorized**
   - `WESTERN_POLICY_MODE=canonical_authorized`
   - enable high-confidence/precise wording only after:
     - legal/commercial license clearance
     - regression pass
     - rollback rehearsal pass

## Safety gates
- Contract regression: `MatchPayloadContractTest`
- API behavior regression: `MatchApiTest`
- Explanation snapshot diff (planned in 2.3-2 follow-up)

## Rollback
- Immediate rollback by env-only change:
  - set `WESTERN_POLICY_MODE=legacy_display`
  - clear config cache
- No schema migration required for rollback.
