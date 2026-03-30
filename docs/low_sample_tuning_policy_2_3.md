# Low-sample Tuning Policy 2.3

## Why
When real user outcome samples are still limited, direct aggressive weight changes can cause unstable ranking drift.

## Policy
1. **Guardrail first**
   - Any profile change must pass `scripts/check_weight_change_guard.ps1`.
   - Default max relative change per weight: `10%`.
2. **Split rollout**
   - If target profile exceeds guardrail, split into 2+ intermediate steps.
3. **Observe before next change**
   - After each step, collect at least one observation window (e.g., weekly).
4. **Do not overfit low volume**
   - No large weight shift based on very small samples or single cohort.

## Required artifacts
- Candidate profile diff
- Guard check output
- Weekly calibration brief
- Rollback profile mapping

## Runtime recommendation
- Keep ranking score and display score decoupled.
- If confidence or data-quality is low, allow ranking experimentation but keep display tone conservative.
