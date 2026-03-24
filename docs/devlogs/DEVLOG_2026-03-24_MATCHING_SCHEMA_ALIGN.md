# DEVLOG 2026-03-24 - Matching Schema Align (P1.2)

## Scope
- Keep backend (Laravel/PHP) as single source of truth for matching rules.
- Align Android rendering with unified `match_reasons.modules` fields.
- Add regression tests to lock payload shape.

## Changes
- Backend config:
  - Expanded [`services/backend-laravel/config/match_rules.php`](D:/EliteSync/services/backend-laravel/config/match_rules.php) with:
    - zodiac templates
    - constellation templates
    - bazi templates/fallback
    - mbti weights/templates
- Backend services:
  - Updated [`services/backend-laravel/app/Services/AstroCompatibilityService.php`](D:/EliteSync/services/backend-laravel/app/Services/AstroCompatibilityService.php)
    - `scoreBazi/scoreZodiac/scoreConstellation` now read config-driven templates/params.
  - Updated [`services/backend-laravel/app/Services/MbtiCompatibilityService.php`](D:/EliteSync/services/backend-laravel/app/Services/MbtiCompatibilityService.php)
    - dimension/stack/lifestyle scores and formula factors now config-driven.
  - Updated [`services/backend-laravel/app/Services/MatchingEngineService.php`](D:/EliteSync/services/backend-laravel/app/Services/MatchingEngineService.php)
    - unified module fields:
      - `reason_short`, `reason_detail`, `risk_short`, `risk_detail`
      - `evidence_tags`, `evidence`
      - plus existing `confidence/degraded/degrade_reason`
- Android:
  - Updated [`apps/android/app/src/main/java/com/elitesync/model/Models.kt`](D:/EliteSync/apps/android/app/src/main/java/com/elitesync/model/Models.kt)
    - `MatchReasonModule` and `MatchReasonItem` with new fields.
  - Updated [`apps/android/app/src/main/java/com/elitesync/ui/screens/MatchScreen.kt`](D:/EliteSync/apps/android/app/src/main/java/com/elitesync/ui/screens/MatchScreen.kt)
    - consume new fields first, fallback to legacy highlights/risks.
    - show evidence tags.
- Test:
  - Updated [`services/backend-laravel/tests/Feature/AdminApiTest.php`](D:/EliteSync/services/backend-laravel/tests/Feature/AdminApiTest.php)
    - added schema assertion for `match_reasons.modules[*]` unified fields.

## Validation
- PHP syntax checks: PASS
  - AstroCompatibilityService
  - MbtiCompatibilityService
  - MatchingEngineService
  - config files
- Android compile: PASS (`:app:compileDebugKotlin`)
- Backend tests: PASS
  - `php artisan test --filter="MatchApiTest|AdminApiTest"`
  - 10 tests, 118 assertions

## Next
- Beta phase: continue rule-table hardening and explanation quality uplift without introducing dual runtime engines.
- Keep synthetic dataset regression as algorithm baseline before major scoring changes.
