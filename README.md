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

- 迁移与协作交接：`docs/archive/legacy_2026-03/HANDOVER_CLI_20260312.md`

## 文档命名规则（自动日期后缀）

- 项目配置文件：`infra/project_config.json`
- 规则：`.md/.pptx/.docx/.txt` 生成文档文件名必须带 `_yyyyMMdd` 后缀
- 执行脚本：
  - 预览（不改名）：`powershell -ExecutionPolicy Bypass -File .\scripts\enforce_document_suffix.ps1`
  - 实际改名：`powershell -ExecutionPolicy Bypass -File .\scripts\enforce_document_suffix.ps1 -Apply`
