# HANDOFF

更新时间: 2026-03-18 (Asia/Shanghai)
分支: `phase-a-2026-03-12`

## 当前目标
- 以 Stage C 为主线推进部署就绪（服务器化、环境分层、发布流程），同时保持 Stage B 已完成功能稳定。
- 本次工作区重点是“题库与问卷链路升级收口”：把题库文件规范化到 `question_bank/`，并将问卷抽题逻辑切到多题库混合、单次 20 题。

## 已修改文件（当前工作区未提交）
- Android
  - `apps/android/app/src/main/java/com/elitesync/network/ApiService.kt`
  - `apps/android/app/src/main/java/com/elitesync/repo/AppRepository.kt`
  - `apps/android/app/src/main/java/com/elitesync/ui/AppNavHost.kt`
  - `apps/android/app/src/main/java/com/elitesync/ui/AppViewModel.kt`
  - `apps/android/app/src/main/java/com/elitesync/ui/screens/MatchScreen.kt`
  - `apps/android/app/src/main/java/com/elitesync/ui/screens/RegisterScreen.kt`
- Laravel
  - `services/backend-laravel/.env.example`
  - `services/backend-laravel/app/Http/Controllers/Api/V1/QuestionnaireController.php`
  - `services/backend-laravel/app/Models/QuestionnaireQuestion.php`
  - `services/backend-laravel/config/questionnaire.php`
  - `services/backend-laravel/database/seeders/QuestionnaireQuestionSeeder.php`
  - `services/backend-laravel/routes/api.php`
  - `services/backend-laravel/tests/Feature/AuthQuestionnaireApiTest.php`
  - `services/backend-laravel/database/migrations/2026_03_17_090000_add_bank_fields_to_questionnaire_questions_table.php` (新增)
- 文档与题库整理
  - 旧根目录文档已移动到 `docs/`（例如 `BACKEND_WINDOWS_RUNBOOK.md`、`DEVELOPMENT_PLAN.md`、设计文档等）
  - 新增目录 `question_bank/`，包含：
    - `question_bank/question_bank_core_v1.json`
    - `question_bank/question_bank_extended_v1.json`
    - `question_bank/question_bank_research_v1.json`
    - `question_bank/question_bank_taxonomy_v1.json`
    - `question_bank/dating_question_bank_v_1.json`（当前也在该目录）

## 已完成内容
- 问卷后端已支持多题库混合抽题：按 `config/questionnaire.php` 的比例（core/extended/research）抽取会话题目。
- 问卷题量配置已切到 20 题：
  - `.env.example` 默认 `QUESTIONNAIRE_SESSION_QUESTION_COUNT=20`
  - `.env.example` 默认 `QUESTIONNAIRE_REQUIRED_ANSWER_COUNT=20`
- `QuestionnaireQuestion` 模型与迁移已补充 `subtopic`、`recommended_bank` 字段，用于题库分层。
- Seeder 已支持从 `question_bank/question_bank_*_v1.json` 读取并入库，且保留 legacy 文件兜底。
- Android 登录后路由已按问卷进度跳转：
  - 已答完 -> 进入匹配页
  - 未答完 -> 进入问卷页
- 匹配页已具备“重新答题（reset）”入口与退出登录入口，符合“匹配页作为主界面”的方向。
- API 契约/测试已更新到 20 题预期（`AuthQuestionnaireApiTest` 断言 total/required 为 20）。

## 未完成内容
- `HANDOFF` 涉及的本批改动尚未提交/推送（当前仍是工作区改动状态）。
- 题库“抽样比例 + 题型分布 + 多选覆盖率”的产品侧校验尚未做完整回归（仅代码层面已接入）。
- Stage C 核心任务尚未落地：
  - 服务器部署编排（容器化、进程守护、反向代理、TLS）
  - 环境分层（local/staging/prod）与密钥治理
  - 线上可观测性与发布门禁完善
- 你已拿到阿里云服务器，但目前仍是“可 SSH 登录”阶段，应用尚未正式部署到该公网环境。

## 下一步建议（按优先级）
1. 先收口本批改动并做一次最小回归
- 后端：`php artisan migrate --seed`、`php artisan test`
- Android：`assembleDebug` + 真机/模拟器各跑一次“登录->问卷20题->匹配->聊天”

2. 提交并推送当前改动
- 形成一个独立 commit（主题建议：`feat: integrate mixed question banks and 20-question session flow`）。

3. 启动 Stage C 的服务器最小部署
- 在阿里云机上先跑通 Laravel API + MySQL/Redis（可先 Docker Compose）
- 打通公网访问（域名可后置，先 IP + 端口验证）
- Android 新增一套 `staging` base URL，先连云端验证

4. 做一次“本地->云端”切换演练
- 保留本地 LAN 联调能力（开发主路径）
- 云端仅做阶段性冒烟与协作验证，降低成本与风险
