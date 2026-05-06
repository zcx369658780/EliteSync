# elitesync-runtime-slice

## Purpose

Implement the smallest safe runtime/UI slice for the current EliteSync version.

## Trigger

- A version slice has been approved for implementation.
- The target is Discover / Chat / Me / Settings or another UI/runtime slice.

## Required workflow

1. State the exact slice and the files in scope.
2. State what must not change.
3. Implement the smallest useful UI/runtime increment.
4. Run the minimum tests needed for that slice.
5. Hand off to evidence closeout if the slice is stable.

## Stop condition

- The smallest safe slice is implemented.
- The minimum tests pass.
- No protected surface has been broken.
- If the slice starts touching backend contracts, truth chains, release logic, or unclear boundaries, stop and switch to cross-layer-blocker.

## Must not do

- Do not touch backend contracts.
- Do not touch truth chains.
- Do not rewrite release logic.
- Do not widen the slice without approval.
