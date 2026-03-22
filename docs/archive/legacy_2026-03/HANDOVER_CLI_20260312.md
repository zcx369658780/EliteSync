# EliteSync Codex CLI 迁移交接文档

> 目标：让任何新接手的 Codex CLI / ChatGPT 协作者在 2 分钟内理解项目现状并继续开发。

## 1) 项目目标（P0 范围）

EliteSync 当前处于 P0 阶段，核心目标是建立一个可联调、可验证、可迭代的最小闭环：

- **后端主线**：从 FastAPI 迁移到 Laravel 11。
- **客户端**：Android Compose 骨架可调用核心 API。
- **开发模式**：优先容器化（Docker），尽量避免本地环境差异导致的问题。

### 当前技术决策

- FastAPI 保留为历史备份：`backups/api_fastapi_legacy/`
- Laravel 作为主线后端：`services/backend-laravel/`
- 统一通过 GitHub 承载代码与决策文档，减少“口头上下文”丢失。

---

## 2) 当前完成度（已完成功能）

### 2.1 已完成迁移（Laravel）

- 鉴权（Sanctum Token）：
  - `POST /api/v1/auth/register`
  - `POST /api/v1/auth/login`
  - `POST /api/v1/auth/refresh`
- 问卷：
  - `GET /api/v1/questionnaire/questions`
  - `POST /api/v1/questionnaire/answers`
  - `GET /api/v1/questionnaire/progress`
- 匹配（Phase 2 batch 2）：
  - `GET /api/v1/matches/current`
  - `POST /api/v1/matches/confirm`
  - `GET /api/v1/matches/history`
  - 兼容旧路径：`/api/v1/match/current|like|history`
- 聊天（Phase 2 batch 3）：
  - `POST /api/v1/messages`
  - `GET /api/v1/messages?peer_id={uid}&after_id={id}`
  - `POST /api/v1/messages/read/{messageId}`
  - WebSocket 网关命令：`php artisan chat:ws --port=8081`
  - WS 路径：`ws://<host>:8081/api/v1/messages/ws/{userId}`
- Admin 审核（最小可用）：
  - `GET /api/v1/admin/users`
  - `POST /api/v1/admin/users/{uid}/disable`
  - `GET /api/v1/admin/verify-queue`
  - `POST /api/v1/admin/verify/{uid}`

### 2.2 数据层

- 用户、问卷题、问卷答题、匹配表已建模（Laravel migration + model + feature tests）。
- 问卷有种子数据（Seeder），用于本地快速联调。

### 2.3 工程结构（关键路径）

- Laravel 主线：`services/backend-laravel/`
- FastAPI 备份：`backups/api_fastapi_legacy/`
- 启动脚本：`scripts/start_laravel_stack.sh`
- 迁移计划：`services/backend-laravel/MIGRATION_PLAN.md`

---

## 3) 下一步优先级（必须按顺序）

1. **Android 字段对齐（收尾）**
   - Retrofit 模型与 Laravel 响应字段逐项对齐。
2. **FastAPI 下线切流计划**
   - Laravel 跑通后做灰度切换。

---

## 4) 本地启动/调试标准流程（Codex CLI 推荐）

## 4.1 首次拉取

```bash
git clone <repo-url>
cd EliteSync
```

## 4.2 启动 Laravel 栈（推荐 Docker）

```bash
./scripts/start_laravel_stack.sh
```

脚本会：
- 自动识别 `docker compose` 或 `docker-compose`
- 启动容器
- 执行 `php artisan key:generate`
- 执行 `php artisan migrate --seed`

服务地址：
- API: http://localhost:8080
- phpMyAdmin: http://localhost:8081

## 4.3 运行测试

```bash
cd services/backend-laravel
php artisan test
```

> 若看到 deprecation 提示，先区分为环境告警还是功能失败。以断言是否通过为主。

## 4.4 常见问题排查

- **Q: push 失败（non-fast-forward）**
  - 先 `git fetch`，再决定 rebase / merge，避免强推覆盖他人提交。
- **Q: Windows 环境差异导致命令不一致**
  - 优先使用脚本与 Docker，减少宿主机差异。
- **Q: 迁移思路丢失**
  - 优先阅读：
    1) 本文件 `docs/archive/legacy_2026-03/HANDOVER_CLI_20260312.md`
    2) `services/backend-laravel/MIGRATION_PLAN.md`
    3) `services/backend-laravel/README.md`

---

## 5) 协作约定（建议）

- 每次功能迁移必须包含：
  - 路由
  - 控制器
  - 迁移/模型
  - 至少 1 条 Feature Test
- 每完成一个批次，更新：
  - `services/backend-laravel/MIGRATION_PLAN.md`
  - 本文档（如果交接信息发生变化）
