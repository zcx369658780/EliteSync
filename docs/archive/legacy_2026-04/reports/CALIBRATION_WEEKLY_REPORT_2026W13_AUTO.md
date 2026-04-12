# Calibration Weekly Report (2026W13) [AUTO]

Generated: 2026-03-30 17:24:56
Sources:
- docs/devlogs/ASTRO_SHADOW_COMPARE.json
- docs/devlogs/ASTRO_SHADOW_COMPARE.md
- docs/devlogs/PAIR_OUTCOME_METRICS.json
- docs/devlogs/MATCH_CALIBRATION_DATASET.csv

## 1. Window
- WeekTag: 2026W13
- Outcome days: 30
- Week filter in outcome: (none)
- Include calibration injected: false

## 2. Shadow Compare Summary
- any_diff_rate_pct: 97
- top_diff_dimensions (Top 3):
1. house_unsupported (100)
2. aspect_unsupported (100)
3. bazi_text (97)
- top_diff_users (Top 3):
1. user_id=9 (diff_score=5)
2. user_id=1016 (diff_score=4)
3. user_id=1017 (diff_score=4)

## 3. Outcome Funnel Summary
- total_pairs: 481
- mutual_like_rate_pct: 15.8
- first_message_rate_pct: 22.66
- reply_24h_rate_pct: 8.94
- sustained_7d_rate_pct: 3.53
- explanation_view_rate_pct: 17.46

## 4. Calibration Dataset Snapshot
- rows: 481
- positive label (reply24h) ratio: 8.94%
- positive label (sustained7d) ratio: 3.53%
- degraded sample ratio: 0.42%

## 5. Notes
- This file is auto-generated for advisor handoff.
- If calibration injector is enabled, do not treat metrics as production KPI.
- Use this report with docs/devlogs/CALIBRATION_CYCLE_LOG.md for context.
