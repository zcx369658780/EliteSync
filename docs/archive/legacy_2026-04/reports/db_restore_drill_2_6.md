# 2.6 数据库恢复演练记录

日期：2026-03-31

## 演练目标
- 将阿里云备份恢复到独立测试库。
- 验证恢复后库结构与数据可读。

## 执行命令

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\db_restore_aliyun_mysql.ps1 `
  -BackupGzPath .\backups\aliyun_mysql\20260331_165200\elitesync_20260331_165200.sql.gz `
  -ServerHost 101.133.161.203 `
  -User root `
  -KeyPath C:\Users\zcxve\.ssh\CodexKey.pem `
  -TargetDatabase elitesync_restore_2_6
```

## 执行结果

- 恢复目标库：`elitesync_restore_2_6`
- 恢复成功
- 远端数据库存在确认：
  - `elitesync_restore_2_6`

## 核验结果

- `users` 表存在
- `users` 行数：
  - `1002`

## 结论

- 2.6 的数据库恢复链路可用
- 备份文件可在独立测试库成功恢复
- 后续可继续补：
  - 恢复后的接口健康检查
  - 定时任务
  - 告警链路

