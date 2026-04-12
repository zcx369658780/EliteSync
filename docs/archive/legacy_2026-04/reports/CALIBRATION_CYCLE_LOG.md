# Calibration Cycle Log

## 2026-03-29 18:34:55 [PASS]
- shadow: 0
- outcome: 0
- export: 0
- params: shadow_limit=100, only_mismatch=True, outcome_days=30, calibration_days=90, calibration_limit=0, outcome_window=7, week_tag=, dry_run=True

## 2026-03-29 18:35:25 [PASS]
- shadow: 0
- outcome: 0
- export: 0
- params: shadow_limit=100, only_mismatch=True, outcome_days=30, calibration_days=90, calibration_limit=0, outcome_window=7, week_tag=, dry_run=True

## 2026-03-29 18:40:15 [PASS]
- shadow: 0
- outcome: 0
- export: 0
- params: shadow_limit=100, only_mismatch=True, outcome_days=30, calibration_days=90, calibration_limit=0, outcome_window=7, week_tag=, dry_run=True

## 2026-03-29 19:02:27 [FAIL]
- shadow:                                                The "--week-tag" option does not exist.                                                1
- outcome:                                                      The "--outcome-window" option does not exist.                                                      1
- export:     Illuminate\Database\QueryException     could not find driver (Connection: mysql, SQL: select `id`, `week_tag`, `created_at`, `user_a`, `user_b`, `like_a`, `like_b`, `score_final`, `score_fair`, `score_personality_total`, `score_mbti_total`, `score_astro_total`, `score_bazi`, `score_zodiac`, `score_constellation`, `score_natal_chart`, `match_reasons` from `dating_matches` where `drop_released` = 1 and `created_at` >= 2025-12-29 11:02:27 and `week_tag` = 2026W13 order by `id` desc)    at vendor\laravel\framework\src\Illuminate\Database\Connection.php:825     821▕                     $this->getName(), $query, $this->prepareBindings($bindings), $e     822▕                 );     823▕             }     824▕    ➜ 825▕             throw new QueryException(     826▕                 $this->getName(), $query, $this->prepareBindings($bindings), $e     827▕             );     828▕         }     829▕     }    1   vendor\laravel\framework\src\Illuminate\Database\Connectors\Connector.php:67       PDOException::("could not find driver")    2   vendor\laravel\framework\src\Illuminate\Database\Connectors\Connector.php:67       PDO::connect()  1
- params: shadow_limit=100, only_mismatch=True, outcome_days=30, calibration_days=90, calibration_limit=0, outcome_window=7, week_tag=2026W13, dry_run=False

## 2026-03-29 19:26:57 [PASS-REMOTE]
- shadow: 0 (aliyun)
- outcome: 0 (aliyun)
- export: 0 (aliyun)
- params: shadow_limit=100, only_mismatch=True, outcome_days=30, calibration_days=90, outcome_window=7, week_tag=2026W13(for shadow only), runner=remote
- note: local runner failed due unsupported options (fixed) + local php missing pdo_mysql; remote backend used for canonical run.

## 2026-03-29 19:35:34 [PASS-REMOTE-INJECT]
- inject: 0 (aliyun)
- outcome: 0 (aliyun)
- export: 0 (aliyun)
- params: days=30, limit=200, seed=20260329, mutual_like_rate=0.35, first_message_rate=0.30, reply24h_rate=0.20, sustained7d_rate=0.10, explanation_view_rate=0.40
- summary: pairs=481, mutual=61, first_msg=59, reply24h=14, sustained7d=3, explanation_view=73

## 2026-03-29 19:42:22 [TUNE-ROUND1-APPLIED]
- env: MATCH_WEIGHT_PERSONALITY=0.61, MATCH_WEIGHT_MBTI=0.07, MATCH_WEIGHT_ASTRO=0.32
- matching_refresh: app:dev:run-matching --include-synthetic=1 --reset-week --release-drop -> pairs_created=474, released=474
- post_inject_metrics: pairs=481, mutual=62, first_msg=63, reply24h=20, sustained7d=4, explanation_view=85

## 2026-03-29 19:47:35 [TUNE-A1-APPLIED]
- env: MATCH_WEIGHT_PERSONALITY=0.64, MATCH_WEIGHT_MBTI=0.07, MATCH_WEIGHT_ASTRO=0.29
- matching_refresh: pairs_created=474, released=474
- post_metrics: pairs=481, mutual=64, first_msg=75, reply24h=24, sustained7d=10, explanation_view=74
- rates: mutual=13.31%, first_msg=15.59%, reply24h=4.99%, sustained7d=2.08%, explanation_view=15.38%

## 2026-03-29 19:50:56 [TUNE-B1-APPLIED]
- env_astro: bazi=0.49, zodiac=0.23, constellation=0.075, natal_chart=0.065, pair_chart=0.14
- matching_refresh: pairs_created=474, released=474
- post_metrics: pairs=481, mutual=76, first_msg=109, reply24h=43, sustained7d=17, explanation_view=84
- rates: mutual=15.80%, first_msg=22.66%, reply24h=8.94%, sustained7d=3.53%, explanation_view=17.46%
- note: calibration-mode data includes synthetic positive injection.

## 2026-03-29 19:59:57 [PASS]
- shadow: 0
- outcome: 0
- export: 0
- params: shadow_limit=100, only_mismatch=True, outcome_days=30, calibration_days=90, calibration_limit=0, outcome_window=7, week_tag=, include_calibration_injected=True, dry_run=True

## 2026-03-29 20:00:04 [PASS]
- shadow: 0
- outcome: 0
- export: 0
- params: shadow_limit=100, only_mismatch=True, outcome_days=30, calibration_days=90, calibration_limit=0, outcome_window=7, week_tag=, include_calibration_injected=True, dry_run=True

## 2026-03-29 20:05:28 [CALIBRATION-MODE-GUARDED]
- mode: inject_only
- env: MATCHING_CALIBRATION_INJECTOR_ENABLED=true, MATCHING_CALIBRATION_INJECTOR_ALLOW_IN_PRODUCTION=true, MATCHING_CALIBRATION_INCLUDE_IN_METRICS=false
- note: metrics/export now default-exclude calibration injected rows/events unless --include-calibration-injected.

## 2026-03-29 20:27:29 [AUTO-REPORT-SCRIPT]
- added: scripts/generate_calibration_weekly_report.ps1
- output: docs/devlogs/CALIBRATION_WEEKLY_REPORT_2026W13_AUTO.md
- fallback: shadow JSON parse failure -> use ASTRO_SHADOW_COMPARE.md summary extraction

## 2026-03-29 20:29:39 [WECHAT-BRIEF-SCRIPT]
- added: scripts/generate_calibration_wechat_brief.ps1
- output: docs/devlogs/CALIBRATION_WECHAT_BRIEF_2026W13.txt

