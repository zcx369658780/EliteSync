# 紫微 Rollback Drill 实际执行记录 2.5

日期：2026-03-30

## 执行目标

验证紫微权重降级后，系统仍可完成配置缓存与匹配契约测试，并能恢复到原配置。

## 实际执行命令

```powershell
ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $env:USERPROFILE\.ssh\CodexKey.pem root@101.133.161.203 'set -e; cd /opt/elitesync/services/backend-laravel; cp .env .env.bak_rollback_20260330; if grep -q "^MATCH_ASTRO_WEIGHT_ZIWEI=" .env; then sed -i "s/^MATCH_ASTRO_WEIGHT_ZIWEI=.*/MATCH_ASTRO_WEIGHT_ZIWEI=0/" .env; else echo "MATCH_ASTRO_WEIGHT_ZIWEI=0" >> .env; fi; php artisan config:cache; php artisan test --filter=MatchPayloadContractTest; mv .env.bak_rollback_20260330 .env; php artisan config:cache'
```

## 实际输出

```text
INFO  Configuration cached successfully.

PASS  Tests\Feature\MatchPayloadContractTest
  ✓ current match payload contains contract fields and module algo vers… 5.75s
  ✓ current match payload contains all module contracts from matching e… 4.61s

Tests:    2 passed (339 assertions)
Duration: 10.62s

INFO  Configuration cached successfully.
```

## 验证结果

- 紫微权重降级配置可写入 `.env`
- `php artisan config:cache` 成功
- `MatchPayloadContractTest` 通过
- 回滚后配置已恢复

## 结论

紫微模块具备配置级回滚能力，且回滚过程中未破坏匹配契约。
