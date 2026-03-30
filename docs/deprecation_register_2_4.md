# Deprecation Register 2.4

## Purpose
Track fields, routes, docs, and wording that are kept only for compatibility and should be retired in 2.5 if no longer needed.

## Current deprecation candidates

### User-visible wording
- Visible `MBTI` branding in any new screen copy
- Any new user-facing wording that implies MBTI is the primary match determinant

### Backend compat items
- Legacy questionnaire payload aliases
- Legacy MBTI route names for older clients
- Historical adapter code that exists only to bridge old mobile builds

### Documentation
- 2.2 process reports already superseded by 2.3 / 2.4 baselines
- Redundant explanation format drafts that no longer match the current schema

## Items to keep for now
- `public_mbti` as canonical persisted compatibility field
- `mbti_attempts` as history record
- `western_policy` runtime flag
- `mbtiCenter` route name as internal navigation compatibility

## Retire in 2.5 after verification
- Old MBTI-style user-facing copy paths
- Old question payload compatibility shims if no clients depend on them
- Duplicated historical reports already covered by baseline docs

## Rule
Nothing can be deleted from runtime or docs unless it has been:
1. Marked here first
2. Confirmed unused or superseded
3. Verified against current app/build compatibility
