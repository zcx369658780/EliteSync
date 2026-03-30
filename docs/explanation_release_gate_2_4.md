# Explanation Release Gate 2.4

## Gate Goal

Ensure explanation quality is part of the release contract, not a post-release review item.

## Gate Levels

### P0 - Block release
- Empty explanation
- Missing required structure fields
- Module explanation unavailable for a critical contract path
- Contract payload shape mismatch

### P1 - Block release
- Low confidence paired with high-confidence wording
- Legacy / fallback module shown with overly strong language
- Missing or inconsistent confidence_reason / display_guard
- Snapshot regression failure on golden cases

### P2 - Allow with fix
- Natural language feels rough
- Minor label drift
- Non-critical formatting inconsistencies

## Required checks before release
- `run_explanation_regression.ps1`
- `ExplanationFixturesTest`
- `ExplanationComposerTest`
- `MatchPayloadContractTest`

## Golden set policy
- Maintain at least 10 golden cases.
- Maintain at least 40 total explanation cases.
- Any new module or new wording pattern must add coverage before release.

## Rollback rule
If any P0 or P1 gate fails, release must stop and revert to the last stable explanation template/profile.
