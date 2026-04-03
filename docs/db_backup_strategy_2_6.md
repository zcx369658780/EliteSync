# 2.6 数据库备份策略

更新时间：2026-03-31

## 目标
- 发布前自动执行数据库备份。
- 同时保留一份云端备份和一份本地留存。

## 当前执行方式
- 备份脚本：`scripts/db_backup_aliyun_mysql.ps1`
- 发布脚本前置调用：`scripts/deploy_aliyun_backend.ps1`

## 备份内容
- `users`
- `user_astro_profiles`
- `dating_matches`
- `messages`
- `app_release_versions`

## 备份产物
- `*.sql.gz`
- `*.sha256`
- `manifest.json`

## 存储位置
- 云端：`/opt/backups/elitesync/mysql/`
- 本地：`backups/aliyun_mysql/`

## 运行方式
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\db_backup_aliyun_mysql.ps1 `
  -ServerHost 101.133.161.203 `
  -User root `
  -KeyPath C:\Users\zcxve\.ssh\CodexKey.pem
```

## 发布前置
- `scripts/deploy_aliyun_backend.ps1` 默认先跑备份。
- 若明确需要跳过，可用 `-SkipBackup`。

