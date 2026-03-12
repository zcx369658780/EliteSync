# EliteSync

国内版慢约会 APP 开发（CODEX）。

## 后端迁移状态（Laravel）

- 已从 FastAPI 启动向 Laravel 11 迁移。
- 旧后端备份：`backups/api_fastapi_legacy/`
- 新后端目录：`services/backend-laravel/`
- 容器编排：`infra/docker-compose.laravel.yml`

## 启动 Laravel 技术栈

```bash
./scripts/start_laravel_stack.sh
```

访问地址：
- API（Nginx）：http://localhost:8080
- phpMyAdmin：http://localhost:8081


## CLI 交接文档

- 迁移与协作交接：`docs/HANDOVER_CLI.md`
