# Ziwei Backfill Report 2.5

日期：2026-03-30

## 目标

将 synthetic 测试账号补齐紫微 canonical 画像，保证后续 shadow compare 与匹配解释可用。

## 实施方式

命令：

```powershell
php artisan app:dev:fill-synthetic-ziwei --batch=<synthetic_batch> --overwrite=0 --limit=0
```

支持：
- `--batch`
- `--overwrite`
- `--limit`
- `--dry-run`

## 读取与写入路径

- 读取用户基础资料：`users`
- 读取/写入紫微画像：`user_astro_profiles.ziwei`
- 镜像字段：`users.private_ziwei`

## 当前实现特征

- 画像生成由 `ZiweiCanonicalService` 负责
- 若 `user_astro_profiles.ziwei` 已存在且未启用 overwrite，则跳过
- 写入时合并 `notes`

## 结果口径

本轮回填策略的设计目标是：
- 可重复执行
- 对已有数据不破坏
- 对失败用户可单独重跑

## 相关代码

- `services/backend-laravel/app/Console/Commands/DevFillSyntheticZiweiCommand.php`
- `services/backend-laravel/app/Services/ZiweiCanonicalService.php`
- `services/backend-laravel/app/Services/UserAstroMirrorService.php`

