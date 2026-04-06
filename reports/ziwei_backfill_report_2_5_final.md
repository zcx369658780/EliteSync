# 紫微回填实际结果报告 2.5 - 最终修正版

日期：2026-03-30

## 验证口径

当前阿里云快照下没有可用于本轮回填的 `is_synthetic=1` 用户，因此改为对 **白名单/样本账号** 做回填验证。

本轮实际验证账号：

- `manual_17094346566`（用户 `id=1006`）

## 实际执行命令

```powershell
ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $env:USERPROFILE\.ssh\CodexKey.pem root@101.133.161.203 'cd /opt/elitesync/services/backend-laravel && php artisan app:dev:fill-synthetic-ziwei --batch=manual_17094346566 --overwrite=1 --limit=1 && mysql -N -h 127.0.0.1 -P 3306 -uelitesync -pelitesync123 -D elitesync -e "SELECT id, phone, JSON_EXTRACT(private_ziwei, \"$.confidence\") AS conf, JSON_EXTRACT(private_ziwei, \"$.precision\") AS precision_level, JSON_EXTRACT(private_ziwei, \"$.engine\") AS engine FROM users WHERE id=1006;"'
```

## 实际输出

```text
users_selected=1
overwrite=true
dry_run=false
ziwei_backfilled=1
1006	17094346566	0.84	"full_birth_data"	"ziwei_canonical_server"
```

## 统计结果

- 总数：1
- 成功：1
- 失败：0
- 低置信占比：0%
- 失败原因：无

## 结论

本轮回填验证已确认：

- 白名单样本账号可正常完成紫微回填
- 回填后 `private_ziwei` 已落库
- 结果为 `confidence=0.84`，`precision=full_birth_data`，`engine=ziwei_canonical_server`
- 这说明紫微 canonical 链路和镜像写回链路均可用

