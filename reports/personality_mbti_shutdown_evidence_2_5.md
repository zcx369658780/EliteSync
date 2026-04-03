# MBTI Shutdown Evidence Package 2.5

日期：2026-03-30

## 结论

MBTI / 性格测试已从 2.5 的活跃排序链路中关闭，保留历史数据与兼容读取，不再参与匹配排序和解释主流程。

## 证据 1：权重=0

`services/backend-laravel/config/matching.php`

- `personality` 权重：`0.0`
- `mbti` 权重：`0.0`
- `astro` 权重：`1.0`

说明：
- 2.5 中 personality / MBTI 不再是活跃排序因子。
- 数据仍保留，但不进入 `coreTotal`。

## 证据 2：API 禁用

`services/backend-laravel/app/Http/Controllers/Api/V1/MbtiProfileController.php`

- `quiz()`：返回 `410 feature_disabled`
- `result()`：返回 `410 feature_disabled`
- `submit()`：返回 `410 feature_disabled`

测试覆盖：
- `tests/Feature/MbtiApiVersioningTest.php`

## 证据 3：前端入口关闭

`apps/flutter_elitesync_module/lib/features/profile/presentation/pages/mbti_center_page.dart`

- 页面标题已改为 `性格测试已关闭`
- 页面正文明确说明测试入口已关闭
- 仅保留历史性格结果查看与“查看匹配解释”按钮

## 证据 4：explanation 中移除活跃模块

`services/backend-laravel/app/Services/MatchingEngineService.php`

- `personalityEnabled` 关闭时，不再构造 active personality ranking module
- `mbtiScore` 在关闭状态下固定为 disabled
- `buildReasonModules()` 仍保留兼容字段，但不作为活跃排序输入

`services/backend-laravel/app/Support/ExplanationTemplateRegistry.php`

- MBTI 模板保留为历史兼容提示，不再用于主排序解释

## 证据 5：用户可见文案收口

前台已把 MBTI 主语义收口为：
- `性格测试已关闭`
- `历史性格特征`
- `性格模块已关闭`

## 验证记录

- `php artisan test --filter=MbtiApiVersioningTest` 通过
- `php artisan test --filter=MatchPayloadContractTest` 通过
- `php -l` 对相关 PHP 文件通过

