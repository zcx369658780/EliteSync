# 2.6 数据库恢复手册

更新时间：2026-03-31

## 目标
- 用备份包恢复到测试数据库。

## 当前执行方式
- 恢复脚本：`scripts/db_restore_aliyun_mysql.ps1`

## 用法
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\db_restore_aliyun_mysql.ps1 `
  -BackupGzPath .\backups\aliyun_mysql\<timestamp>\elitesync_<timestamp>.sql.gz `
  -ServerHost 101.133.161.203 `
  -User root `
  -KeyPath C:\Users\zcxve\.ssh\CodexKey.pem `
  -TargetDatabase elitesync_restore
```

## 恢复目标
- 使用独立数据库名进行恢复验证，避免覆盖线上主库。

## 验收建议
- 恢复后检查：
  - 表是否存在
  - 用户数是否合理
  - 画像接口是否可查询
  - 匹配接口是否能正常跑查询

