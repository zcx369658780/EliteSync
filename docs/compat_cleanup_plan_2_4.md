# Compat Cleanup Plan 2.4

## Goal

Reduce long-term maintenance noise by classifying fields, modes, and docs into `active`, `compat`, and `deprecated`.

## Field classes

### active
Current production-facing fields and routes that must remain stable in 2.4.

Examples:
- `engine_source`
- `engine_mode`
- `data_quality`
- `precision_level`
- `confidence`
- `confidence_reason`
- `display_guard`
- `display_tags`
- `explanation_blocks`
- `compatibility_sections`
- `public_mbti` (backend canonical read source for personality compatibility)

### compat
Fields, routes, or docs kept for backward compatibility with older app builds or historical pipeline behavior.

Examples:
- legacy questionnaire payload shapes
- legacy MBTI route names
- legacy western policy aliases if any old reports still reference them
- `mbti_attempts` history table
- old payload adapters in questionnaire endpoints

### deprecated
Items that should be retired after 2.4 or explicitly removed in 2.5.

Examples:
- old raw display wording tied to `MBTI` branding in user-facing copy
- redundant docs that are fully superseded by 2.3/2.4 baseline and decision docs
- duplicate or obsolete explanation formatting paths

## Current cleanup targets

### Backend
- Keep `public_mbti` as canonical persisted source for compatibility.
- Keep `mbti_attempts` only as history.
- Keep questionnaire legacy adapters for older clients until 2.5.
- Keep `western_policy` runtime flag, but standardize on `western_lite`.

### Flutter
- Keep route name `mbtiCenter` only as internal navigation compatibility.
- Keep `mbti` backend keys only as contract compatibility.
- Replace visible MBTI wording with `性格` / `性格测试`.

### Documentation
- Keep 2.3 / 2.4 baseline and decision docs.
- Move older process docs into archive or delete if already superseded.

## Cleanup order
1. Mark deprecated items in docs.
2. Keep active items stable.
3. Preserve compat items until 2.5.
4. Remove duplicated historical reports.

## 2.5 deletion candidates
- legacy user-facing MBTI text paths
- outdated 2.2 process reports already covered by 2.3/2.4 baselines
- any duplicated explanation format docs that no longer match current schema

## Acceptance
- Every retained field must be labeled `active` or `compat`.
- Every removed field must appear in a deprecation register first.
