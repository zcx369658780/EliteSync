# 文档索引（当前有效）

更新时间：2026-05-16

## 当前主入口

- `docs/DEVELOPMENT_PLAN_CURRENT.md`：当前整体开发计划入口
- `docs/DOC_INDEX_CURRENT.md`：当前文档阅读顺序
- `docs/project_memory.md`：项目长期记忆
- `docs/version_plans/README.md`：版本计划总索引
- `docs/version_plans/ELITESYNC_6_0_ALPHA_MASTER_PLAN_2026_05_12.md`：6.0 Alpha 内测准备线主计划
- `docs/version_plans/v_6_0_A0_Alpha内测准备_商用化底座与路线冻结版_开发计划书_2026_05_12.md`：6.0-A0 planning-only 路线冻结计划书
- `docs/version_plans/v_6_0_A1_后端v2与位置链路最小闭环_开发计划书_2026_05_12.md`：6.0-A1 顾问计划书；先看 Framework / Runtime Support Gate，不得直接进入 v2 skeleton runtime
- `docs/version_plans/6.0_A1_HANDOFF_MASTER.md`：6.0-A1 当前默认主交接入口；已同步 R1 readonly v2 runtime slice remote-published / verification pass、R2 authorization prepackage remote-published、Candidate C staging / production split readonly verification prepackage remote-published、Candidate C local/repo-only readonly audit report remote-published、Candidate C Claude horizontal review prepackage remote-published 与 Candidate C Claude horizontal review report；不代表 A1 final acceptance complete 或 production ready
- `docs/version_plans/6.0_A1_STAGING_READONLY_METADATA_VERIFICATION_AUTHORIZATION_PREPACKAGE.md`：Staging readonly metadata verification authorization prepackage；只用于未来授权审查；尚未请求 staging，尚未执行 staging verification；staging execution 仍需用户另行明确授权；production verification 继续后置
- `docs/version_plans/6.0_A1_CANDIDATE_C_CLAUDE_HORIZONTAL_REVIEW_REPORT.md`：Candidate C Claude horizontal review report；Claude verdict `pass with observations`；GPT 顾问已验收该 review result；允许进入 future staging readonly metadata verification authorization prompt 的准备讨论，但 staging request 仍需用户另行明确授权，production verification 继续后置；不代表 Candidate C implementation / authorized / completed，不代表 staging / production verification passed 或 API smoke passed
- `docs/version_plans/6.0_A1_CANDIDATE_C_CLAUDE_HORIZONTAL_REVIEW_PREPACKAGE.md`：Candidate C Claude horizontal review prepackage；已 remote-published as `2944ab310a6e189bcc420007c9423a6043a23d38 docs: add 6.0-A1 candidate C Claude review prepackage`；GPT 顾问已验收；prepackage only，后续事实以 Candidate C Claude horizontal review report 为准
- `docs/version_plans/6.0_A1_CANDIDATE_C_LOCAL_REPO_ONLY_READONLY_AUDIT_REPORT.md`：Candidate C local/repo-only readonly audit report；已 remote-published as `9f958508a2ca4a60a5f1e8104aece230edb5c495 docs: add 6.0-A1 candidate C local audit report`；GPT 顾问已验收；不代表 Candidate C implementation，不代表 staging / production verification passed 或 API smoke passed；后续 Candidate C Claude horizontal review 已完成，下一步以 review report 为准
- `docs/version_plans/6.0_A1_STAGING_PRODUCTION_SPLIT_READONLY_VERIFICATION_PREPACKAGE.md`：Candidate C staging / production split readonly verification prepackage；GPT 顾问已验收；authorization / preparation document only，不代表 Candidate C 已获实施授权、已实施或已完成，不代表 staging / production verification passed
- `docs/version_plans/6.0_A1_R2_NARROW_READONLY_RUNTIME_SLICE_AUTHORIZATION_PREPACKAGE.md`：R2 authorization prepackage；GPT 顾问已验收并建议下一步选择 staging / production split readonly verification package；supporting evidence only，不代表 Candidate C 已获实施授权或 R2 runtime complete
- `docs/version_plans/6.0_A1_R1_READONLY_RUNTIME_SLICE_STAGE_ACCEPTANCE.md`：R1 readonly runtime slice 阶段性验收证据包；supporting evidence only，不取代 `6.0_A1_HANDOFF_MASTER.md`
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
5. `docs/version_plans/6.0_A1_STAGING_READONLY_METADATA_VERIFICATION_AUTHORIZATION_PREPACKAGE.md`
6. `docs/version_plans/6.0_A1_CANDIDATE_C_CLAUDE_HORIZONTAL_REVIEW_REPORT.md`
7. `docs/version_plans/6.0_A1_CANDIDATE_C_CLAUDE_HORIZONTAL_REVIEW_PREPACKAGE.md`
8. `docs/version_plans/6.0_A1_CANDIDATE_C_LOCAL_REPO_ONLY_READONLY_AUDIT_REPORT.md`
9. `docs/version_plans/6.0_A1_STAGING_PRODUCTION_SPLIT_READONLY_VERIFICATION_PREPACKAGE.md`
10. `docs/version_plans/6.0_A1_R1_READONLY_RUNTIME_SLICE_STAGE_ACCEPTANCE.md`
11. `docs/version_plans/6.0_A1_R2_NARROW_READONLY_RUNTIME_SLICE_AUTHORIZATION_PREPACKAGE.md`
12. `docs/version_plans/6.0_A1_V2_RUNTIME_SLICE_AUTHORIZATION_PACKAGE.md`
13. `docs/version_plans/6.0_A1_V2_HEALTH_READINESS_LOCATION_CONTRACT_SKELETON_PLAN.md`
14. `docs/version_plans/6.0_A1_CLAUDE_HORIZONTAL_REVIEW_REPORT.md`
15. `docs/version_plans/6.0_A1_CLAUDE_REVIEW_RESPONSE.md`
16. `docs/version_plans/6.0_A1_CLAUDE_HORIZONTAL_REVIEW_INPUT_PACKAGE.md`
17. `docs/version_plans/v_6_0_A1_后端v2与位置链路最小闭环_开发计划书_2026_05_12.md`
18. `docs/version_plans/6.0_A1_SKELETON_PRECONDITION_EXECUTION_PLAN.md`
19. `docs/version_plans/6.0_A1_ENVIRONMENT_SPLIT_PLAN.md`
20. `docs/version_plans/6.0_A1_LOCATION_CHAIN_RESTRUCTURE.md`
21. `docs/version_plans/6.0_A1_BACKUP_ROLLBACK_MONITORING_PLAN.md`
22. `docs/version_plans/6.0_A1_LARAVEL12_STAGING_DRY_RUN_PLAN.md`
23. `docs/version_plans/6.0_A1_ENV_CACHE_SESSION_CONFIG_UNIFICATION_PLAN.md`
24. `docs/version_plans/6.0_A1_AUTHENTICATED_READONLY_SMOKE_BATCH2_RERUN_REPORT.md`
25. `docs/version_plans/6.0_A1_READONLY_SMOKE_BATCH1_PRODUCTION_READONLY_REPORT.md`
26. `docs/version_plans/6.0_A1_BACKEND_V2_CONTRACT_MAP.md`
27. `docs/version_plans/6.0_A1_V1_CONTRACT_AUDIT.md`

## 6.0 Alpha 当前参考

- `docs/version_plans/ELITESYNC_6_0_ALPHA_MASTER_PLAN_2026_05_12.md`
- `docs/version_plans/v_6_0_A0_Alpha内测准备_商用化底座与路线冻结版_开发计划书_2026_05_12.md`
- `docs/version_plans/6.0_A1_HANDOFF_MASTER.md`
- `docs/version_plans/6.0_A1_STAGING_READONLY_METADATA_VERIFICATION_AUTHORIZATION_PREPACKAGE.md`
- `docs/version_plans/6.0_A1_CANDIDATE_C_CLAUDE_HORIZONTAL_REVIEW_REPORT.md`
- `docs/version_plans/6.0_A1_CANDIDATE_C_CLAUDE_HORIZONTAL_REVIEW_PREPACKAGE.md`
- `docs/version_plans/6.0_A1_CANDIDATE_C_LOCAL_REPO_ONLY_READONLY_AUDIT_REPORT.md`
- `docs/version_plans/6.0_A1_STAGING_PRODUCTION_SPLIT_READONLY_VERIFICATION_PREPACKAGE.md`
- `docs/version_plans/6.0_A1_R1_READONLY_RUNTIME_SLICE_STAGE_ACCEPTANCE.md`
- `docs/version_plans/6.0_A1_R2_NARROW_READONLY_RUNTIME_SLICE_AUTHORIZATION_PREPACKAGE.md`
- `docs/version_plans/v_6_0_A1_后端v2与位置链路最小闭环_开发计划书_2026_05_12.md`
- `docs/version_plans/CODEX_6_0_A0_EXECUTION_REPORT.md`
- `docs/version_plans/CODEX_6_0_A0_CLAUDE_FEEDBACK_RESPONSE.md`
- `docs/version_plans/claude_reviews/6.0_A0/CLAUDE_6_0_A0_HORIZONTAL_REVIEW.md`
- `docs/reference/ELITESYNC_FEATURE_GAP_ANALYSIS_2026_05_12.md`
- `docs/reference/ELITESYNC_REVIEW_ACTION_MATRIX_2026_05_12.md`
- `docs/agents/CLAUDE_HORIZONTAL_REVIEW_GATE_RULES.md`

6.0-A1 当前入口提醒：`docs/version_plans/6.0_A1_HANDOFF_MASTER.md` 是当前 A1 默认主交接入口。Claude review report archive、Codex response、narrow readonly v2 skeleton planning、v2 runtime authorization package、R2 authorization prepackage、Candidate C staging / production split readonly verification prepackage、Candidate C local/repo-only readonly audit report、Candidate C Claude horizontal review prepackage、Candidate C Claude horizontal review report 与 Staging readonly metadata verification authorization prepackage 已形成证据链，Claude verdict 为 `pass with observations`；R1 readonly v2 runtime slice 已 remote-published，commit `90436e2d17c611907dfe4322135c7e4ba0bbb23d feat: add readonly v2 runtime slice`。Post-push readonly verification 已通过：route-list 可见 `GET api/v2/app/health`、`GET api/v2/app/readiness`、`GET api/v2/contracts/location`，不存在 `api/v2/health` / `api/v2/readiness`；3 个新增 Feature Test 文件最小测试通过。Staging readonly metadata verification authorization prepackage 已准备为 `docs/version_plans/6.0_A1_STAGING_READONLY_METADATA_VERIFICATION_AUTHORIZATION_PREPACKAGE.md`；该文件只用于未来授权审查，尚未请求 staging，尚未执行 staging verification。staging execution 仍需用户另行明确授权，production verification 继续后置。当前仍不能标记 A1 final acceptance complete、production ready、R2 runtime complete、Candidate C implemented、Candidate C authorized、staging verification passed、production verification passed、API smoke passed、full v2 skeleton complete 或 A2 start。production 默认继续 v1，Flutter 默认不切 v2，R1 仍只保持三个 readonly endpoints。后续 Codex 导出目录默认固定为 `C:\Users\zcxve\Downloads\`。

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
