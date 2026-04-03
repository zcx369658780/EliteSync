# 紫微回填实际结果报告 2.5

日期：2026-03-30

## 执行目标

在阿里云环境中验证紫微画像回填与镜像同步是否可执行，并统计真实结果。

## 执行环境

- 机器：阿里云后端 `101.133.161.203`
- 代码目录：`/opt/elitesync/services/backend-laravel`
- 数据库：`elitesync`
- 目标字段：
  - `user_astro_profiles.ziwei`
  - `users.private_ziwei`

## 实际执行命令

```powershell
ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $env:USERPROFILE\.ssh\CodexKey.pem root@101.133.161.203 'cd /opt/elitesync/services/backend-laravel && php artisan app:dev:fill-synthetic-astro --limit=200 --seed=20260330'
ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $env:USERPROFILE\.ssh\CodexKey.pem root@101.133.161.203 'cd /opt/elitesync/services/backend-laravel && php artisan app:dev:sync-user-astro-mirror --limit=200 --users-to-profiles=1'
ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $env:USERPROFILE\.ssh\CodexKey.pem root@101.133.161.203 'mysql -h 127.0.0.1 -P 3306 -uelitesync -pelitesync123 -D elitesync -e "SELECT COUNT(*) AS c FROM users WHERE is_synthetic=1;"'
```

## 实际输出

### 1) 紫微回填

```text
No synthetic users found for this filter.
```

### 2) 镜像同步

```text
users_selected=200
dry_run=false
bootstrap_users_to_profiles=true
include_ziwei=true
synced=189
bootstrapped_profiles=0
```

### 3) 线上 synthetic 用户计数

```text
c
0
```

## 统计结果

- 总目标用户数：0
- 成功写入：0
- 失败：0
- 失败原因：阿里云当前快照下不存在 `is_synthetic=1` 的用户，因此回填命令没有可处理对象
- 低置信占比：N/A

## 结论

当前阿里云环境中，紫微回填命令本轮没有找到 synthetic 回填对象，但镜像同步命令已成功跑通，且开启了 `include_ziwei=true`。
如果后续需要更完整的回填统计，需要先在阿里云环境补齐 synthetic 测试账号，再重跑该命令。
