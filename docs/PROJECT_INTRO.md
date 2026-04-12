# EliteSync 项目介绍（新同事快速上手）

更新时间：2026-03-18
分支：`phase-a-2026-03-12`

## 1. 项目目标
EliteSync 是一个“慢约会”应用，核心闭环：
1. 注册/登录
2. 问卷作答（当前会话抽取 20 题）
3. 每周匹配（含匹配解释）
4. 双向确认
5. 实时聊天

## 2. 当前技术栈
- Android：Kotlin + Jetpack Compose + Retrofit + OkHttp WebSocket
- Backend：Laravel 11 + MySQL + Redis
- 部署：
  - 本地开发：Windows + Android Studio + Laravel
  - 云端联调：阿里云 Ubuntu 24.04（Nginx + PHP-FPM + MariaDB + Redis + systemd）

## 3. 当前已完成进度
### A 阶段（已完成）
- 本地开发链路打通（注册、问卷、匹配、聊天）
- Android 与 Laravel API 契约对齐
- 实时消息与基础已读逻辑可用

### B 阶段（核心完成）
- 匹配算法 V2.1：`base -> penalty -> fairness`
- 匹配解释字段与分数信息可回传 App
- 问卷 UI 完成低点击交互与滚动适配
- CI 基线可用（Backend Tests / Android Assemble）

### 云端部署（本次完成）
- 阿里云后端服务已可用：
  - HTTP：`http://101.133.161.203`
  - Health：`http://101.133.161.203/up`
  - WebSocket：`ws://101.133.161.203:8081/api/v1/messages/ws/{userId}`
- Android 已切换到云端 API/WS 地址，可直接联调

## 4. 题库现状
- 题库文件位置：`question_bank/`
- 已接入三库：`core + extended + research`
- 总量约 2100 题
- 已完成“人类可读化”批量处理（不再出现“偏向A/B、题号模板文案”）
- 后端抽题策略：每次会话 20 题，按比例混合题库

## 5. 关键目录
- `apps/android/`：Android 客户端
- `services/backend-laravel/`：Laravel 后端
- `question_bank/`：题库 JSON
- `infra/`：部署与运维配置
- `docs/`：计划、报告、交接资料

## 6. 已知约束
- 当前云端仍为测试环境（未配置 HTTPS 域名与正式风控策略）
- WebSocket 当前使用明文 `ws://`（测试可用）
- 部分运维动作仍以手工脚本为主，后续需要收敛为标准化发布流程

## 7. 下一步建议（阶段 C）
1. 云端稳定性收口：部署脚本、回滚脚本、日志与监控
2. 安全与合规：HTTPS、密钥管理、限流、审计
3. 产品细化：题库持续优化、匹配策略校准、聊天体验增强
4. 版本化发布：建立 staging/prod 环境与发布门禁

## 8. 快速验证（联调）
1. 启动 Android App
2. 注册/登录新账号
3. 完成问卷并进入匹配
4. 双端匹配后进入聊天，验证消息收发

---
当前有效入口：
- `docs/DOC_INDEX_CURRENT.md`

如需查看历史规划与阶段报告：
- `docs/archive/legacy_2026-03/STAGE_B_COMPLETION_REPORT.md`
- `docs/archive/legacy_2026-03/STAGE_C_HANDOVER_20260315.md`
