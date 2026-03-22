# FastAPI -> Laravel 迁移执行清单

## 已完成
- [x] 备份旧后端：`backups/api_fastapi_legacy/`
- [x] 初始化 Laravel 11 项目骨架
- [x] 接入 Sanctum Token 鉴权
- [x] 迁移第一批 P0 接口：auth + questionnaire（questions/answers/progress）
- [x] 增加 API 端到端测试（Feature Test）

## 进行中
- [ ] 对齐 Android 端字段（逐项对照 Retrofit 模型）
- [ ] 扩展问卷题库到 P0 目标规模

## 待执行
- [x] 迁移匹配接口（current / like / history）
- [x] 迁移聊天 HTTP 接口（send/list/read）
- [x] 迁移聊天 WebSocket 推送网关（artisan `chat:ws`）
- [x] 迁移运营后台审核接口（verify-queue / verify / disable / users）
- [ ] FastAPI 下线切流与回归验证
