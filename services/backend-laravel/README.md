# EliteSync Backend (Laravel 11)

当前目录已经初始化为 Laravel 11 项目骨架，并完成了第一批 P0 迁移（认证 + 问卷基础接口）。

## 版本建议（当前仓库要求）

- PHP: `8.4+`（`composer.lock` 当前包含 Symfony 8 组件，需 8.4）
- Composer: `2.9.x` ✅
- Docker CLI: `29.x` ✅
- phpMyAdmin: `5.2.3` ✅
- Redis: 建议优先用容器版（避免 Windows 发行版兼容问题）
- MySQL: 建议优先使用容器中的 `8.0.36`（与当前迁移脚本一致）

> 即使你本机安装了 MySQL 9.x，也建议先用容器里的 MySQL 8.0.36 进行迁移联调，避免语法/默认行为差异影响开发。

## 已知环境阻塞（2026-03-12）

- 本机 PHP 8.3.6 + 缺失 `ext-fileinfo` 时，`composer install` 会失败。
- 若 Docker Desktop 配置了不可达代理，`docker compose up --build` 可能在拉 `composer/php` 镜像时失败。

建议优先顺序：
1. 修复 Docker 代理并使用容器启动（推荐）。
2. 或升级本机 PHP 到 8.4 并启用 `fileinfo` 后执行本地调试。

## 已迁移接口（Phase 2 - batch 2）

- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`（需 Bearer Token）
- `GET /api/v1/questionnaire/questions`（需 Bearer Token）
- `POST /api/v1/questionnaire/answers`（需 Bearer Token）
- `GET /api/v1/questionnaire/progress`（需 Bearer Token）
- `GET /api/v1/matches/current`（需 Bearer Token）
- `POST /api/v1/matches/confirm`（需 Bearer Token）
- `GET /api/v1/matches/history`（需 Bearer Token）
- 兼容别名：`/api/v1/match/current|like|history`

## 快速启动（推荐 Docker）

仓库根目录：

```bash
# 优先
./scripts/start_laravel_stack.sh

# 或手动
# docker compose -f infra/docker-compose.laravel.yml up -d --build
# 若你的环境没有 compose 子命令，就用：
# docker-compose -f infra/docker-compose.laravel.yml up -d --build
```

服务端口：
- API（Nginx）: `http://localhost:8080`
- phpMyAdmin: `http://localhost:8081`
- MySQL: `localhost:3306`
- Redis: `localhost:6379`

## 本地（非 Docker）调试

```bash
cd services/backend-laravel
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve --host=0.0.0.0 --port=8001
```

## 测试

```bash
cd services/backend-laravel
php artisan test
```

## 聊天 WebSocket 网关（已可用）

```bash
cd services/backend-laravel
php artisan chat:ws --host=0.0.0.0 --port=8081
```

Android 客户端默认连接：
- `ws://10.0.2.2:8081/api/v1/messages/ws/{userId}`

可与 HTTP 服务并行启动：
- `php artisan serve --host=0.0.0.0 --port=8080`

## 调试就绪检查（必过）

```bash
# 1) 依赖安装成功
composer install --no-interaction --prefer-dist

# 2) 应用密钥 + 迁移
php artisan key:generate
php artisan migrate --seed

# 3) 冒烟测试
php artisan test
```
