# Cloud Backend Operation Boundary

更新时间：2026-04-28

## 目的

定义云端后端、RTC、媒体、通知、数据库等操作的职责边界，避免前端误改云端真值。

## 原则

- 本地只做前端 / 文档 / 诊断；
- 云端写操作由云端脚本或远端命令执行；
- 任何恢复前先做 checkpoint；
- 任何跨层 blocker 先写 blocker report。

## 结论

骨架文件，待 4.9 完整收口后补齐执行约束。
