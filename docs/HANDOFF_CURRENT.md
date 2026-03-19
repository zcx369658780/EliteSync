# HANDOFF_CURRENT

更新时间：2026-03-19
分支：`phase-a-2026-03-12`

## 1. 当前项目状态
- 核心链路已可用：注册/登录 -> 问卷(20题) -> 匹配 -> 聊天。
- 云端后端已部署在阿里云：`101.133.161.203`。
- 题库已升级并可读化：`question_bank/` 共约 2100 题。
- 安全基线已上线：
  - 密码强度要求（字母+数字，>=8位）
  - 聊天消息数据库加密存储
  - 登录/消息接口限流
  - HTTPS 强制开关（默认关闭，待域名可用后开启）

## 2. 当前正在进行的主线
- 等待域名 `slowdate.top` 审核与解析生效后，执行 HTTPS/WSS 切换。
- 切换后将 Android 从 `http/ws` 改为 `https/wss` 并做端到端回归。

## 3. 关键地址
- 云端 API（当前）：`http://101.133.161.203/`
- 健康检查：`http://101.133.161.203/up`
- 云端 WS（当前）：`ws://101.133.161.203:8081/api/v1/messages/ws/{userId}`

## 4. 常用命令
### 本地后端测试
```powershell
cd D:\EliteSync\services\backend-laravel
C:\tools\php85\php.exe artisan test
```

### 本地 Android 构建
```powershell
cd D:\EliteSync\apps\android
.\gradlew.bat :app:assembleDebug
```

### 本地改动部署到阿里云
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\deploy_aliyun_backend.ps1 \
  -ServerHost 101.133.161.203 \
  -User root \
  -KeyPath C:\Users\zcxve\.ssh\CodexKey.pem
```

### 域名可用后启用 HTTPS/WSS
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\enable_https_wss_aliyun.ps1 \
  -Domain slowdate.top \
  -Email <your-email> \
  -ServerHost 101.133.161.203 \
  -User root \
  -KeyPath C:\Users\zcxve\.ssh\CodexKey.pem
```

## 5. 当前应优先查看的文档
- `docs/PROJECT_INTRO.md`：给新成员的项目介绍
- `docs/DEVELOPMENT_PLAN_UPDATED.md`：最新开发计划基线
- `docs/CLOUD_DEPLOY_RUNBOOK.md`：云端部署标准流程
- `docs/HTTPS_WSS_CUTOVER.md`：HTTPS/WSS 切换清单
- `docs/DEMO_RUNBOOK_2026Q1.md`：会议演示流程
- `docs/REGRESSION_CHECKLIST_2026Q1.md`：回归测试清单

## 6. 本轮清理说明
- 旧阶段文档、旧交接文档、旧联调文档已移动至：
  - `docs/archive/legacy_2026-03/`
- 归档目的是减少根目录文档噪音，不删除历史记录。

## 7. 下一步（域名可用后立即执行）
1. DNS 生效校验
2. 执行 HTTPS/WSS 一键切换
3. 开启 `SECURITY_ENFORCE_HTTPS=true`
4. Android 改为 `https/wss`
5. 完整回归并输出会议前稳定性报告
