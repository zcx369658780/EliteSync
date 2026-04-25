# Smoke / Regression 测试账号清单

更新时间：2026-04-21

本文件用于后续 smoke、regression、beta 验证时直接复用服务器上的稳定测试账号。

## 当前可用账号

| ID | Phone | Name | 备注 |
|---|---|---|---|
| 7 | 17094346566 | SmokeUser | 主烟测号 / 2026-04-19 已恢复 |
| 8 | 13772423130 | test1 | 次烟测号 / 2026-04-19 已恢复 |
| 9 | 90000000000 | SmokeUser | 稳定烟测号 |
| 10 | 90161086331 | SmokeUser | 稳定烟测号 |
| 11 | 90806462146 | SmokeUser | 稳定烟测号 |
| 12 | 90902669655 | SmokeUser | 稳定烟测号 |
| 13 | 90123456788 | SmokeUser | 稳定烟测号 |

## 口径说明

- `phone=90` 的旧 fallback 账号已删除。
- 当前 `is_synthetic = true` 为 0 个。
- `17094346566` 当前密码为 `1234567aa`（2026-04-21 用户再次确认）。
- `13772423130` 当前密码为 `zcx658023`（2026-04-21 用户再次确认）。
- 后续 smoke / regression / beta 验证默认复用以上 7 个账号。
- 如果要优先选一个稳定主账号，默认用 `17094346566`。

## 使用建议

1. smoke / regression 优先使用 `17094346566`。
2. `13772423130` 可作为次烟测号与主号交叉验证。
3. 如需减少单账号历史干扰，可轮换使用其余 5 个账号。
4. 不要再恢复 `phone=90` 作为长期 fallback 账号。

## 常用执行示例

### 1. 先确认账号是否仍可用
```powershell
cd D:\EliteSync\services\backend-laravel
php artisan tinker --execute="echo App\\Models\\User::where('phone','17094346566')->exists() ? 'ok' : 'missing';"
```

### 2. 跑 smoke
```powershell
cd D:\EliteSync
./scripts/smoke_backend_alpha.ps1 -Phone 17094346566 -Password 1234567aa
```

### 3. 跑 regression baseline
```powershell
cd D:\EliteSync
./scripts/regression_alpha_baseline.ps1 -Phone 17094346566 -Password 1234567aa
```

### 4. 轮换其它账号时
```powershell
./scripts/smoke_backend_alpha.ps1 -Phone 90161086331 -Password 1234567aa
```

### 5. 次烟测号
```powershell
./scripts/smoke_backend_alpha.ps1 -Phone 13772423130 -Password zcx658023
```

### 6. 账号口径变更时
- 先更新 `docs/project_memory.md`
- 再更新 `docs/DOC_INDEX_CURRENT.md`
- 最后更新本文件和总交接文档
