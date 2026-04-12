# Calibration Tune Candidates (2026W13)

Generated: 2026-03-29 19:43:43
Dataset: `docs/devlogs/MATCH_CALIBRATION_DATASET.csv`

## 1) Sample Overview
- total: 481
- reply24h positives: 20 (4.16%)
- sustained7d positives: 4 (0.83%)

## 2) Signal Delta (positive - negative)
| field | delta_reply24h | delta_sustained7d |
|---|---:|---:|
| score_personality_total | 0.28 | -2.96 |
| score_mbti_total | 1.62 | 2.17 |
| score_astro_total | 1.01 | 1.58 |
| score_bazi | 0.33 | 2.08 |
| score_zodiac | 4.55 | 6.42 |
| score_constellation | -0.49 | -6.02 |
| score_natal_chart | -2.07 | -4.37 |

## 3) Current Weights (Round-1 Applied)
- core: personality=0.61, mbti=0.07, astro=0.32
- astro: bazi=0.45, zodiac=0.25, constellation=0.08, natal_chart=0.07, pair_chart=0.15

## 4) Candidate A (core small-step)
- Intent: prioritize early interaction conversion (reply24h).
- core: personality=0.65, mbti=0.07, astro=0.28
- Change vs current: personality +6.56%, astro -12.50% (NOTE: astro exceeds 10% guard, use split rollout: 0.32->0.30 first).
- Safe step-A1 (<=10% each): personality=0.64, mbti=0.07, astro=0.29

## 5) Candidate B (astro-internal rebalance)
- Intent: keep core stable, boost bazi/pair_chart explanatory strength.
- astro candidate: bazi=0.49, zodiac=0.22, constellation=0.07, natal_chart=0.06, pair_chart=0.16
- Per-field change: bazi +8.89%, zodiac -12.00%, constellation -12.50%, natal_chart -14.29%, pair_chart +6.67%
- Safe step-B1 (<=10% each): bazi=0.49, zodiac=0.23, constellation=0.075, natal_chart=0.065, pair_chart=0.14 (sum=1.00)

## 6) Recommended Next Action
1. Execute A1 first for 3-7 days (single objective: reply24h up, sustained7d not down).
2. If stable, execute B1 to improve astro explanation alignment.
3. Rollback trigger: reply24h or sustained7d drops >20% vs baseline window.
