# Ziwei Shadow Compare Report 2.5

日期：2026-03-30

## 目标

对比旧实现与 2.5 的紫微 canonical 输出，确认紫微画像路径可灰度、可回退、可统计。

## 命令

```powershell
php artisan app:dev:astro-shadow-compare --limit=50 --out=docs/devlogs/ASTRO_SHADOW_COMPARE.md --json=docs/devlogs/ASTRO_SHADOW_COMPARE.json
```

## 本轮对拍维度

- `bazi_sun_diff`
- `bazi_text_diff`
- `bazi_wuxing_diff`
- `western_sun_diff`
- `western_moon_diff`
- `western_asc_diff`
- `western_precision_diff`
- `western_engine_diff`
- `western_confidence_major_diff`
- `ziwei_diff`

## 紫微对拍输出结构

每个用户样本都包含：
- legacy 紫微画像
- candidate 紫微画像
- diff 标记

示例字段：
- `life_palace`
- `body_palace`
- `major_themes`
- `palaces`
- `summary`
- `engine`
- `precision`
- `confidence`

## 说明

- `ziwei` 已纳入 shadow compare 报告
- 这意味着后续回填和版本迁移时，可以单独观察紫微链路是否稳定

## 相关代码

- `services/backend-laravel/app/Console/Commands/DevAstroShadowCompareCommand.php`

