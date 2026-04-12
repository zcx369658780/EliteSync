# 2.6 数据库备份运行日志

日期：2026-03-31

## 执行命令

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\db_backup_aliyun_mysql.ps1 `
  -ServerHost 101.133.161.203 `
  -User root `
  -KeyPath C:\Users\zcxve\.ssh\CodexKey.pem
```

## 执行结果

- 远端备份目录：
  - `/opt/backups/elitesync/mysql/20260331_165200`
- 本地留存目录：
  - `D:\EliteSync\backups\aliyun_mysql\20260331_165200`

## 产物

- `elitesync_20260331_165200.sql.gz`
- `elitesync_20260331_165200.sql.gz.sha256`
- `manifest.json`

## 运行摘要

- 远端 MySQL 备份成功
- 校验文件生成成功
- 本地拉取成功
- manifest 中记录：
  - database=`elitesync`
  - tables=`18`
  - rows_estimated=`21573`

## 结论

- 2.6 的数据库双备份链路已进入可运行状态
- 后续只需把恢复演练和定时调度补齐

