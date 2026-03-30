# Release Checklist 2.3

## Pre-check
- [ ] `php artisan test` core suites pass
- [ ] `scripts/run_explanation_regression.ps1` pass
- [ ] Version API check pass
- [ ] Android debug assemble pass
- [ ] License registry updated (`LICENSE_DEPENDENCY_STATUS.md`)

## Config check
- [ ] `display_guard.php` loaded and cached
- [ ] `western_policy.php` mode confirmed
- [ ] `astro_rollout.php` whitelist/override reviewed

## Functional check
- [ ] Match detail returns `display_tags`
- [ ] Match detail returns `display_guard`
- [ ] `explanation_blocks` exists and structured
- [ ] no UI raw tag leakage

## Safety
- [ ] Rollback playbook reviewed
- [ ] Gray release plan approved
- [ ] Last known stable profile recorded
