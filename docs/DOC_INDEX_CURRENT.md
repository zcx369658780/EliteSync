# 文档索引（当前有效）

更新时间：2026-05-15

## 当前主入口

- `docs/DEVELOPMENT_PLAN_CURRENT.md`：当前整体开发计划入口
- `docs/DOC_INDEX_CURRENT.md`：当前文档阅读顺序
- `docs/project_memory.md`：项目长期记忆
- `docs/version_plans/README.md`：版本计划总索引
- `docs/version_plans/ELITESYNC_6_0_ALPHA_MASTER_PLAN_2026_05_12.md`：6.0 Alpha 内测准备线主计划
- `docs/version_plans/v_6_0_A0_Alpha内测准备_商用化底座与路线冻结版_开发计划书_2026_05_12.md`：6.0-A0 planning-only 路线冻结计划书
- `docs/version_plans/v_6_0_A1_后端v2与位置链路最小闭环_开发计划书_2026_05_12.md`：6.0-A1 顾问计划书；先看 Framework / Runtime Support Gate，不得直接进入 v2 skeleton runtime
- `docs/version_plans/6.0_A1_HANDOFF_MASTER.md`：6.0-A1 当前默认主交接入口；已同步 R1 readonly v2 runtime slice remote-published / verification pass，但不代表 A1 final acceptance complete 或 production ready
- `docs/version_plans/6.0_A1_V2_RUNTIME_SLICE_AUTHORIZATION_PACKAGE.md`：v2 runtime authorization package；R1 实施前 supporting evidence，历史授权包，不等同于 A1 complete
- `docs/version_plans/6.0_A1_V2_HEALTH_READINESS_LOCATION_CONTRACT_SKELETON_PLAN.md`：narrow readonly v2 skeleton planning；R1 实施前 planning-only / supporting evidence，后续事实以 R1 commit `90436e2d` 为准
- `docs/version_plans/6.0_A1_CLAUDE_HORIZONTAL_REVIEW_REPORT.md`：6.0-A1 Claude review report archive；verdict `pass with observations`，supporting evidence only
- `docs/version_plans/6.0_A1_CLAUDE_REVIEW_RESPONSE.md`：Codex response to Claude review；supporting evidence only
- `docs/version_plans/6.0_A1_CLAUDE_HORIZONTAL_REVIEW_INPUT_PACKAGE.md`：Claude 横向复评输入包；supporting evidence only
- `docs/agents/CLAUDE_HORIZONTAL_REVIEW_GATE_RULES.md`：Claude 横向复评门禁长期规则
- `docs/agents/PROJECT_RULE_DEVELOPMENT_PLAN_FORMAT_CURRENT.md`：版本开发计划书格式长期规则
- `docs/agents/PROJECT_RULE_CLAUDE_SOUL_CECE_HORIZONTAL_REVIEW.md`：Claude 使用 Soul + 测测 / CECE 横向评测长期规则
- `docs/agents/CODEX_CYBER_SAFE_UI_RESEARCH_RULES.md`：竞品 UI research 安全规则

## 新会话阅读顺序

1. `docs/DEVELOPMENT_PLAN_CURRENT.md`
2. `docs/DOC_INDEX_CURRENT.md`
3. `docs/project_memory.md`
4. `docs/version_plans/6.0_A1_HANDOFF_MASTER.md`
5. `docs/version_plans/6.0_A1_V2_RUNTIME_SLICE_AUTHORIZATION_PACKAGE.md`
6. `docs/version_plans/6.0_A1_V2_HEALTH_READINESS_LOCATION_CONTRACT_SKELETON_PLAN.md`
7. `docs/version_plans/6.0_A1_CLAUDE_HORIZONTAL_REVIEW_REPORT.md`
8. `docs/version_plans/6.0_A1_CLAUDE_REVIEW_RESPONSE.md`
9. `docs/version_plans/6.0_A1_CLAUDE_HORIZONTAL_REVIEW_INPUT_PACKAGE.md`
10. `docs/version_plans/v_6_0_A1_后端v2与位置链路最小闭环_开发计划书_2026_05_12.md`
11. `docs/version_plans/6.0_A1_SKELETON_PRECONDITION_EXECUTION_PLAN.md`
12. `docs/version_plans/6.0_A1_ENVIRONMENT_SPLIT_PLAN.md`
13. `docs/version_plans/6.0_A1_LOCATION_CHAIN_RESTRUCTURE.md`
14. `docs/version_plans/6.0_A1_BACKUP_ROLLBACK_MONITORING_PLAN.md`
15. `docs/version_plans/6.0_A1_LARAVEL12_STAGING_DRY_RUN_PLAN.md`
16. `docs/version_plans/6.0_A1_ENV_CACHE_SESSION_CONFIG_UNIFICATION_PLAN.md`
17. `docs/version_plans/6.0_A1_AUTHENTICATED_READONLY_SMOKE_BATCH2_RERUN_REPORT.md`
18. `docs/version_plans/6.0_A1_READONLY_SMOKE_BATCH1_PRODUCTION_READONLY_REPORT.md`
19. `docs/version_plans/6.0_A1_BACKEND_V2_CONTRACT_MAP.md`
20. `docs/version_plans/6.0_A1_V1_CONTRACT_AUDIT.md`

## 6.0 Alpha 当前参考

- `docs/version_plans/ELITESYNC_6_0_ALPHA_MASTER_PLAN_2026_05_12.md`
- `docs/version_plans/v_6_0_A0_Alpha内测准备_商用化底座与路线冻结版_开发计划书_2026_05_12.md`
- `docs/version_plans/6.0_A1_HANDOFF_MASTER.md`
- `docs/version_plans/v_6_0_A1_后端v2与位置链路最小闭环_开发计划书_2026_05_12.md`
- `docs/version_plans/CODEX_6_0_A0_EXECUTION_REPORT.md`
- `docs/version_plans/CODEX_6_0_A0_CLAUDE_FEEDBACK_RESPONSE.md`
- `docs/version_plans/claude_reviews/6.0_A0/CLAUDE_6_0_A0_HORIZONTAL_REVIEW.md`
- `docs/reference/ELITESYNC_FEATURE_GAP_ANALYSIS_2026_05_12.md`
- `docs/reference/ELITESYNC_REVIEW_ACTION_MATRIX_2026_05_12.md`
- `docs/agents/CLAUDE_HORIZONTAL_REVIEW_GATE_RULES.md`

6.0-A1 当前入口提醒：`docs/version_plans/6.0_A1_HANDOFF_MASTER.md` 是当前 A1 默认主交接入口。Claude review report archive、Codex response、narrow readonly v2 skeleton planning 与 v2 runtime authorization package 已提交并 push，Claude verdict 为 `pass with observations`；R1 readonly v2 runtime slice 已 remote-published，commit `90436e2d17c611907dfe4322135c7e4ba0bbb23d feat: add readonly v2 runtime slice`。Post-push readonly verification 已通过：route-list 可见 `GET api/v2/app/health`、`GET api/v2/app/readiness`、`GET api/v2/contracts/location`，不存在 `api/v2/health` / `api/v2/readiness`；3 个新增 Feature Test 文件最小测试通过。当前仍不能标记 A1 final acceptance complete、production ready 或 A2 start；下一步应是 A1 后续验证 / 证据收口 / 顾问判断，或另一个明确授权的极窄 runtime slice 计划确认。

## 规则文件 / Agent Rules / Project Rules

- `docs/agents/PROJECT_RULE_DEVELOPMENT_PLAN_FORMAT_CURRENT.md`
  - 后续所有版本开发计划书格式规则；
  - 强制写入多 agent / sub-agent 协作计划；
  - 强制写入 Claude APP 实测横向对比报告作为 GPT 顾问验收前置门禁。

- `docs/agents/PROJECT_RULE_CLAUDE_SOUL_CECE_HORIZONTAL_REVIEW.md`
  - Claude 使用 Soul + 测测 / CECE 对 EliteSync 做横向评测的长期规则；
  - 规定设备、权限、停止规则、证据目录、Action Matrix、pass / conditional pass / fail 判定；
  - 后续每个版本进入 GPT 顾问验收前必须遵守。

- `docs/agents/CLAUDE_HORIZONTAL_REVIEW_GATE_RULES.md`：Claude 横向复评门禁长期规则。
- `docs/agents/CODEX_CYBER_SAFE_UI_RESEARCH_RULES.md`：竞品 UI research 安全规则。

## 历史参考 / 上一阶段闭环

- `docs/version_plans/elite_sync_整体开发计划书_5_6_plus_玄学能力二次产品化修订版_2026_05_11.md`
- `docs/version_plans/elite_sync_未来版本开发路线图_5_6_plus_玄学能力二次产品化_2026_05_11.md`
- `docs/version_plans/v_5_6_玄学能力二次产品化边界与校准版_开发计划书_2026_05_11.md`
- `docs/version_plans/v_5_7_Match关系解释层最小产品化版_开发计划书_2026_05_11.md`
- `docs/version_plans/v_5_8_Me个人解释层与表达建议版_开发计划书_2026_05_11.md`
- `docs/version_plans/v_5_9_Chat轻追问与低压开场版_开发计划书_2026_05_11.md`
- `docs/version_plans/v_5_10_解释层治理与用户控制版_开发计划书_2026_05_11.md`
- `docs/version_plans/5.6_HANDOFF_MASTER.md`
- `docs/version_plans/5.7_HANDOFF_MASTER.md`
- `docs/version_plans/5.8_HANDOFF_MASTER.md`
- `docs/version_plans/5.9_HANDOFF_MASTER.md`
- `docs/version_plans/5.10_HANDOFF_MASTER.md`

## 当前发布与版本

- `docs/CHANGELOG.md`
- `docs/devlogs/RELEASE_LOG.md`
- `docs/version_plans/0.05.05_UPDATE_BRIEF.md`
- `docs/version_plans/0.05.04_UPDATE_BRIEF.md`
- `docs/version_plans/0.04.09_UPDATE_BRIEF.md`

## 当前归档入口

- `docs/archive/legacy_2026-04/`
- `docs/archive/legacy_2026-04/version_plans/`
- `docs/archive/legacy_2026-04/reports/`
