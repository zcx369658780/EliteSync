# Dashboard Metric Spec 2.4

## Goal

Define a stable metric panel for 2.4 so we can observe rollout health, explanation quality, and match quality without relying on ad hoc reports.

## Metric groups

### 1. Badge distribution
- `badge_high_confidence_rate`
- `badge_strong_evidence_rate`
- `badge_low_confidence_rate`
- `badge_legacy_rate`
- `badge_fallback_rate`
- `badge_western_lite_rate`

Purpose:
- Verify that low-quality paths are not over-exposed.
- Track how often high badges are emitted.

### 2. Explanation quality
- `explanation_view_rate`
- `explanation_expand_rate`
- `explanation_snapshot_diff_count`
- `explanation_p0_fail_count`
- `explanation_p1_fail_count`
- `explanation_p2_fix_count`

Purpose:
- Ensure explanation remains a release gate.
- Track whether users actually open explanations.

### 3. Match conversion funnel
- `mutual_like_rate`
- `first_message_rate`
- `reply_24h_rate`
- `sustained_7d_rate`
- `drop_release_rate`

Purpose:
- Measure whether scores translate into user behavior.

### 4. Data quality / fallback
- `legacy_estimate_rate`
- `fallback_rate`
- `partial_unknown_rate`
- `date_only_rate`
- `western_lite_rate`

Purpose:
- See how much of the traffic is still using degraded inputs.

### 5. Profile and tuning guardrails
- `display_score_mean`
- `rank_score_mean`
- `weight_change_guard_pass_rate`
- `weight_change_guard_fail_count`
- `stable_bucket_share`

Purpose:
- Ensure tuning remains controlled.
- Detect profile drift early.

## Required slices
Every metric should be sliced by:
- week tag
- module key
- confidence tier
- engine mode
- app/platform if available

## Dashboard rules
1. Always show current week and previous week.
2. Always show `stable_bucket` vs tuning bucket comparison.
3. Always show top 5 modules by fallback / low confidence.
4. Always highlight any guardrail failure in red.
5. Never mix display score and rank score in the same visual block.

## Suggested thresholds
- `badge_high_confidence_rate`: should not rise sharply without corresponding quality increase.
- `legacy_estimate_rate`: should trend down over time.
- `explanation_expand_rate`: should stay non-trivial; very low values may mean explanation is not useful.
- `weight_change_guard_fail_count`: must be 0 for release candidates.

## Output artifacts
- Weekly calibration report
- Weekly WeChat brief
- Guardrail failure summary
- Shadow compare summary
- Top drift dimensions summary

## Acceptance
The dashboard is considered complete when these metric groups can be produced automatically from the existing weekly calibration sources.
