# 2.2 Baseline Snapshot (Frozen at 2026-03-30)

## Scope
- Snapshot type: Matching/astro explanation baseline before 2.3 refactor rollout.
- Source of truth: `services/backend-laravel` runtime config + current API contract.

## Runtime Weights
- Core weights (`config/matching.php`)
  - personality: `0.58`
  - mbti: `0.07`
  - astro: `0.35`
- Astro sub-weights (`config/match_rules.php`)
  - bazi: `0.45`
  - zodiac: `0.25`
  - constellation: `0.08`
  - natal_chart: `0.07`
  - pair_chart: `0.15`

## Hard Filters
- same city only: enabled
- opposite gender only: enabled
- casual-vs-marriage direct conflict: rejected
- recent-pair exclusion window: 14 days

## Canonical Rollout State
- bazi canonical: enabled by default
- western canonical: disabled by default (feature/whitelist controlled)

## Explanation Contract (2.2)
- Main payload still carries raw `evidence_tags`.
- Label mapping available via `match_evidence_tags`.
- Confidence narrative policy exists, but badge issuing lacks explicit display-guard contract.

## 2.2 Known Gaps (to be fixed by 2.3)
1. Engine state / confidence / UI wording are not fully unified in a single metadata contract.
2. Raw tag semantics may leak to UI when label mapping fallback occurs.
3. High-confidence/strong-evidence badge rules are not explicitly centralized.
4. Western module messaging can overstate certainty in non-canonical or partial-input cases.

## Freeze Note
- This file is baseline-only and should not be edited after 2.3 starts, except to append audit references.
