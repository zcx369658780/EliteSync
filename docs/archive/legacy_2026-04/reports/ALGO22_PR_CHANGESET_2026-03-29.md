# 算法2.2 PR变更清单（待提交）

## A. 服务端核心能力
- canonical/灰度/置信策略：
  - `services/backend-laravel/config/astro_canonical.php`
  - `services/backend-laravel/config/astro_rollout.php`
  - `services/backend-laravel/config/confidence_policy.php`
  - `services/backend-laravel/config/western_natal.php`
- 引擎与服务：
  - `app/Services/BaziEngine.php`
  - `app/Services/LunarPhpBaziEngine.php`
  - `app/Services/LegacyClientBaziEngine.php`
  - `app/Services/WesternNatalEngine.php`
  - `app/Services/LegacyInputWesternNatalEngine.php`
  - `app/Services/BaziCanonicalService.php`
  - `app/Services/WesternNatalCanonicalService.php`
  - `app/Services/AstroCanonicalRolloutService.php`
  - `app/Services/AstrologyDependencyGateService.php`

## B. 匹配与解释升级
- `app/Services/MatchingEngineService.php`
- `app/Services/AstroCompatibilityService.php`
- `app/Services/MbtiCompatibilityService.php`
- `app/Http/Controllers/Api/V1/MatchController.php`
- `app/Http/Controllers/Api/V1/AstroProfileController.php`

## C. 校准与运维命令
- `app/Console/Commands/DevAstroShadowCompareCommand.php`
- `app/Console/Commands/DevPairOutcomeMetricsCommand.php`
- `app/Console/Commands/DevExportMatchCalibrationDatasetCommand.php`
- `app/Console/Commands/DevInjectCalibrationPositivesCommand.php`
- `app/Console/Commands/DevCleanupCalibrationInjectedCommand.php`
- `app/Console/Commands/DevDiffBaziEnginesCommand.php`
- `app/Console/Commands/EvalAstroV2Command.php`

## D. 脚本与运行手册
- `scripts/run_astro_calibration_cycle.ps1`
- `scripts/generate_weight_candidates.ps1`
- `scripts/generate_calibration_weekly_report.ps1`
- `scripts/generate_calibration_wechat_brief.ps1`
- `scripts/generate_calibration_reports_bundle.ps1`
- `scripts/apply_match_tuning_profile.ps1`
- `scripts/apply_calibration_mode.ps1`
- `scripts/release_gate_alpha.ps1`
- `docs/runbooks/MATCHING_ALGO_P1_RUNBOOK_20260324.md`

## E. Flutter 展示层对齐
- `apps/flutter_elitesync_module/lib/features/match/...`
  - dto / mapper / entity / page / insight_card

## F. 测试
- Feature:
  - `AstroCanonicalApiTest`
  - `EvalAstroV2CommandTest`
  - `PairOutcomeMetricsCommandTest`
  - `ExportMatchCalibrationDatasetCommandTest`
  - `InjectCalibrationPositivesCommandTest`
  - `CleanupCalibrationInjectedCommandTest`
- Unit:
  - `AstroCanonicalRolloutServiceTest`

## G. 许可证/依赖治理
- `LICENSE_DEPENDENCY_STATUS.md`
- `docs/dependency_audit_astrology.md`
- `docs/licenses/` (如存在新增条目)

---

## 回滚清单（最小化）
1. 环境切换：
- 关闭 canonical：`ASTRO_CANONICAL_ENABLED=false`
- rollout 置 legacy：对应平台/白名单开关关停
- 关闭校准注入：`MATCHING_CALIBRATION_INJECTOR_ENABLED=false`

2. 权重回滚：
- 执行 `./scripts/apply_match_tuning_profile.ps1 -Profile baseline`

3. 数据清理：
- 执行 `php artisan app:dev:cleanup-calibration-injected`

4. 客户端兜底：
- 若展示不兼容，临时隐藏新增解释字段，仅展示基础分数。
