# 文档索引（当前有效）

更新时间：2026-05-19

## 当前主入口

- `docs/DEVELOPMENT_PLAN_CURRENT.md`：当前整体开发计划入口
- `docs/DOC_INDEX_CURRENT.md`：当前文档阅读顺序
- `docs/project_memory.md`：项目长期记忆
- `docs/project_rules/PROJECT_RULE_HANDOFF_SINGLE_FILE.md`：项目级长期规则；当前版本默认只保留一个 handoff entry，supporting evidence 不得变成并行入口
- `docs/project_rules/PROJECT_RULE_CROSS_LAYER_BLOCKERS.md`：项目级长期规则；跨前端 / 后端 / server / DB / release chain 不确定问题进入 evidence-first blocker handling
- `docs/project_rules/PROJECT_RULE_RUNTIME_ISSUE_BUNDLE.md`：项目级长期规则；runtime / program-development 默认使用 GitHub Issue Bundle，而不是一个巨型 issue
- `docs/project_rules/PROJECT_RULE_TEXT_FIRST_EVIDENCE_PACKS.md`：项目级长期规则；证据链默认以 repo text reports / indexes 为主，截图只做 critical-only
- `docs/project_rules/PROJECT_RULE_CLAUDE_HORIZONTAL_REVIEW_ARTIFACTS.md`：项目级长期规则；Claude 横向 / blind review 产物采用 text-first repo artifacts
- `docs/version_plans/README.md`：版本计划总索引
- `docs/version_plans/ELITESYNC_6_0_ALPHA_MASTER_PLAN_2026_05_12.md`：6.0 Alpha 内测准备线主计划
- `docs/version_plans/v_6_0_A0_Alpha内测准备_商用化底座与路线冻结版_开发计划书_2026_05_12.md`：6.0-A0 planning-only 路线冻结计划书
- `docs/version_plans/v_6_0_A1_后端v2与位置链路最小闭环_开发计划书_2026_05_12.md`：6.0-A1 顾问计划书；先看 Framework / Runtime Support Gate，不得直接进入 v2 skeleton runtime
- `docs/version_plans/6.0_A1_HANDOFF_MASTER.md`：6.0-A1 当前默认主交接入口；已同步 #60 closure decision `accepted_with_observations`；acceptance scope limited to R1 readonly v2 runtime slice + Option B deployed-code correction + server-localhost readonly verification + user-confirmed public IP readonly verification + docs sync posture；不代表 production verification passed、broad API smoke passed、Candidate C implementation、R2 runtime completion、full v2 skeleton completion、A2 runtime start、Flutter / Android / release-chain change 或 production ready
- `docs/version_plans/6.0_A1_POST_ACCEPTANCE_DOCS_SYNC_AND_A2_PLANNING_DECISION_REPORT.md`：Issue #61 post-A1 current docs sync / A2 planning decision report；同步 #60 `accepted_with_observations` 到 current/status/index/handoff docs；下一步建议 `GPT-TASK: 6.0-A2 planning package / authorization prepackage gate`；不代表 A2 runtime start、production verification、broad API smoke、Candidate C implementation、full v2 skeleton completion 或 release-chain readiness
- `docs/version_plans/6.0_A1_CLOSURE_REVIEW_ACCEPTANCE_REPORT.md`：Issue #60 closure review / acceptance report；decision `accepted_with_observations`；acceptance limited to current narrowed R1 readonly / Option B evidence chain；不代表 production readiness、production verification、broad API smoke、Candidate C implementation、full v2 skeleton completion 或 A2 start
- `docs/version_plans/6.0_A1_DOCS_SYNC_AND_A1_CLOSURE_PLANNING_REPORT.md`：Issue #59 docs sync / A1 closure planning report；current/status/index/handoff docs 已同步到 #54-#58 evidence chain；下一步建议 `GPT-TASK: 6.0-A1 closure review / acceptance gate`；不代表 A1 final acceptance、production verification、broad API smoke、Candidate C implementation、A2 start 或 full v2 skeleton complete
- `docs/version_plans/6.0_A1_GATE_REVIEW_AFTER_OPTION_B_PUBLIC_IP_PASS.md`：Issue #58 gate review after Option B public IP pass；结论 `ready_for_docs_sync_and_a1_closure_planning`；production verification、broad API smoke 与 A1 final acceptance 均保持 separate / unclaimed
- `docs/version_plans/6.0_A1_USER_CONFIRMED_PUBLIC_IP_READONLY_ENDPOINT_VERIFICATION_REPORT.md`：Issue #57 user-confirmed public IP readonly endpoint verification；`http://101.133.161.203` 下三个 R1 readonly endpoints 返回 HTTP 200 JSON；不代表 production verification、broad API smoke 或 A1 final acceptance
- `docs/version_plans/6.0_A1_PUBLIC_STAGING_READONLY_ENDPOINT_VERIFICATION_REPORT.md`：Issue #56 public staging readonly endpoint verification；因 staging target unclear 在 request 前 stopped / blocked；未执行 public staging endpoint request
- `docs/version_plans/6.0_A1_OPTION_B_LOCALHOST_VERIFICATION_RERUN_REPORT.md`：Issue #55 corrected Option B server-localhost verification rerun；`127.0.0.1:8088` 下三个 R1 readonly endpoints 返回 HTTP 200 JSON
- `docs/version_plans/6.0_A1_OPTION_B_DEPLOYMENT_SYNC_EXECUTION_REPORT.md`：Issue #54 Option B deployment / sync execution report；deployed-code staleness corrected for seven allowlisted R1 readonly v2 files；route inventory showed three expected `api/v2` routes
- `docs/version_plans/6.0_A1_IP_STAGING_OPTION_B_NARROW_SCAFFOLD_PREFLIGHT_REPORT.md`：IP Staging Option B narrow scaffold / preflight report；已创建 `.env.staging` from `.env.example` 与 disabled localhost-only Nginx staging draft；`nginx -t` pass 但只验证 current active config；未创建 sites-enabled symlink，未 reload / restart，未执行 endpoint verification，staging 尚未启用、不可访问
- `docs/version_plans/6.0_A1_IP_STAGING_AUTHORIZATION_CLAUDE_LIGHTWEIGHT_REVIEW.md`：IP staging authorization Claude lightweight review；Claude verdict `pass with observations`，blockers none，recommended next step `proceed to user final parameter confirmation`；该 review 本身未 SSH、未修改服务器、未创建 IP staging、未执行 staging verification
- `docs/version_plans/6.0_A1_IP_STAGING_IMPLEMENTATION_EXECUTION_AUTHORIZATION_PACKAGE.md`：IP staging implementation execution authorization package；只用于未来 implementation 执行授权审查；尚未修改服务器，尚未创建 IP staging，尚未执行 staging verification；Nginx backup 已完成，可作为 future rollback reference
- `docs/version_plans/6.0_A1_NGINX_CONFIG_BACKUP_EXECUTION_REPORT.md`：Nginx/config backup execution report；backup directory `/opt/backups/elitesync/nginx_config_backup_20260517_173755`；只复制 allowlisted Nginx config 文件；未输出 Nginx config 正文，未读取真实 `.env` / `.env.*`，未输出 secrets，未 reload / restart Nginx，未修改 active Nginx config / symlink / firewall / security group，未创建 staging，未执行 staging verification
- `docs/version_plans/6.0_A1_NGINX_CONFIG_BACKUP_READONLY_PREPACKAGE.md`：Nginx/config backup readonly prepackage；backup execution 前置授权审查包；执行结果以后续 Nginx/config backup execution report 为准
- `docs/version_plans/6.0_A1_SERVER_INVENTORY_READONLY_EXECUTION_REPORT.md`：Server inventory readonly execution report；本次 readonly SSH inventory 已完成并归档；未修改服务器，未读取真实 `.env` / `.env.*`，未输出 secrets，未创建 staging，未执行 staging verification
- `docs/version_plans/6.0_A1_SERVER_INVENTORY_READONLY_PREPACKAGE.md`：Server inventory readonly prepackage；只用于未来只读服务器盘点授权审查；尚未 SSH 登录服务器，尚未执行 server inventory，尚未读取真实 `.env` / `.env.*`，尚未修改服务器 / Nginx / 安全组 / DB / Redis / storage
- `docs/version_plans/6.0_A1_IP_BASED_CONTROLLED_STAGING_IMPLEMENTATION_PREPACKAGE.md`：IP-based controlled staging implementation prepackage；只用于未来 implementation 授权审查；尚未修改服务器 / Nginx / 安全组 / DB / Redis / storage，尚未创建 staging 环境，尚未执行 staging verification
- `docs/version_plans/6.0_A1_IP_BASED_CONTROLLED_STAGING_PLAN.md`：IP-based controlled staging plan；candidate plan only；由于当前无法完成 ICP 备案，`staging.slowdate.top` 短期不可行；尚未创建 staging environment，尚未执行 staging verification
- `docs/version_plans/6.0_A1_STAGING_BOUNDARY_BLOCKER_REPORT.md`：Staging boundary blocker report；记录 staging readonly metadata verification 未执行，因为没有确认独立 staging base URL；不是 staging verification failed / passed
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
4. `docs/project_rules/PROJECT_RULE_HANDOFF_SINGLE_FILE.md`
5. `docs/project_rules/PROJECT_RULE_CROSS_LAYER_BLOCKERS.md`
6. `docs/project_rules/PROJECT_RULE_RUNTIME_ISSUE_BUNDLE.md`
7. `docs/project_rules/PROJECT_RULE_TEXT_FIRST_EVIDENCE_PACKS.md`
8. `docs/project_rules/PROJECT_RULE_CLAUDE_HORIZONTAL_REVIEW_ARTIFACTS.md`
9. `docs/version_plans/6.0_A1_HANDOFF_MASTER.md`
10. `docs/version_plans/6.0_A1_POST_ACCEPTANCE_DOCS_SYNC_AND_A2_PLANNING_DECISION_REPORT.md`
11. `docs/version_plans/6.0_A1_CLOSURE_REVIEW_ACCEPTANCE_REPORT.md`
12. `docs/version_plans/6.0_A1_DOCS_SYNC_AND_A1_CLOSURE_PLANNING_REPORT.md`
13. `docs/version_plans/6.0_A1_GATE_REVIEW_AFTER_OPTION_B_PUBLIC_IP_PASS.md`
14. `docs/version_plans/6.0_A1_USER_CONFIRMED_PUBLIC_IP_READONLY_ENDPOINT_VERIFICATION_REPORT.md`
15. `docs/version_plans/6.0_A1_PUBLIC_STAGING_READONLY_ENDPOINT_VERIFICATION_REPORT.md`
16. `docs/version_plans/6.0_A1_OPTION_B_LOCALHOST_VERIFICATION_RERUN_REPORT.md`
17. `docs/version_plans/6.0_A1_OPTION_B_DEPLOYMENT_SYNC_EXECUTION_REPORT.md`
18. `docs/version_plans/6.0_A1_IP_STAGING_OPTION_B_NARROW_SCAFFOLD_PREFLIGHT_REPORT.md`
19. `docs/version_plans/6.0_A1_IP_STAGING_AUTHORIZATION_CLAUDE_LIGHTWEIGHT_REVIEW.md`
20. `docs/version_plans/6.0_A1_IP_STAGING_IMPLEMENTATION_EXECUTION_AUTHORIZATION_PACKAGE.md`
21. `docs/version_plans/6.0_A1_NGINX_CONFIG_BACKUP_EXECUTION_REPORT.md`
22. `docs/version_plans/6.0_A1_NGINX_CONFIG_BACKUP_READONLY_PREPACKAGE.md`
23. `docs/version_plans/6.0_A1_SERVER_INVENTORY_READONLY_EXECUTION_REPORT.md`
24. `docs/version_plans/6.0_A1_SERVER_INVENTORY_READONLY_PREPACKAGE.md`
25. `docs/version_plans/6.0_A1_IP_BASED_CONTROLLED_STAGING_IMPLEMENTATION_PREPACKAGE.md`
26. `docs/version_plans/6.0_A1_IP_BASED_CONTROLLED_STAGING_PLAN.md`
27. `docs/version_plans/6.0_A1_STAGING_BOUNDARY_BLOCKER_REPORT.md`
28. `docs/version_plans/6.0_A1_STAGING_READONLY_METADATA_VERIFICATION_AUTHORIZATION_PREPACKAGE.md`
29. `docs/version_plans/6.0_A1_CANDIDATE_C_CLAUDE_HORIZONTAL_REVIEW_REPORT.md`
30. `docs/version_plans/6.0_A1_CANDIDATE_C_CLAUDE_HORIZONTAL_REVIEW_PREPACKAGE.md`
31. `docs/version_plans/6.0_A1_CANDIDATE_C_LOCAL_REPO_ONLY_READONLY_AUDIT_REPORT.md`
32. `docs/version_plans/6.0_A1_STAGING_PRODUCTION_SPLIT_READONLY_VERIFICATION_PREPACKAGE.md`
33. `docs/version_plans/6.0_A1_R1_READONLY_RUNTIME_SLICE_STAGE_ACCEPTANCE.md`
34. `docs/version_plans/6.0_A1_R2_NARROW_READONLY_RUNTIME_SLICE_AUTHORIZATION_PREPACKAGE.md`
35. `docs/version_plans/6.0_A1_V2_RUNTIME_SLICE_AUTHORIZATION_PACKAGE.md`
36. `docs/version_plans/6.0_A1_V2_HEALTH_READINESS_LOCATION_CONTRACT_SKELETON_PLAN.md`
37. `docs/version_plans/6.0_A1_CLAUDE_HORIZONTAL_REVIEW_REPORT.md`
38. `docs/version_plans/6.0_A1_CLAUDE_REVIEW_RESPONSE.md`
39. `docs/version_plans/6.0_A1_CLAUDE_HORIZONTAL_REVIEW_INPUT_PACKAGE.md`
40. `docs/version_plans/v_6_0_A1_后端v2与位置链路最小闭环_开发计划书_2026_05_12.md`
41. `docs/version_plans/6.0_A1_SKELETON_PRECONDITION_EXECUTION_PLAN.md`
42. `docs/version_plans/6.0_A1_ENVIRONMENT_SPLIT_PLAN.md`
43. `docs/version_plans/6.0_A1_LOCATION_CHAIN_RESTRUCTURE.md`
44. `docs/version_plans/6.0_A1_BACKUP_ROLLBACK_MONITORING_PLAN.md`
45. `docs/version_plans/6.0_A1_LARAVEL12_STAGING_DRY_RUN_PLAN.md`
46. `docs/version_plans/6.0_A1_ENV_CACHE_SESSION_CONFIG_UNIFICATION_PLAN.md`
47. `docs/version_plans/6.0_A1_AUTHENTICATED_READONLY_SMOKE_BATCH2_RERUN_REPORT.md`
48. `docs/version_plans/6.0_A1_READONLY_SMOKE_BATCH1_PRODUCTION_READONLY_REPORT.md`
49. `docs/version_plans/6.0_A1_BACKEND_V2_CONTRACT_MAP.md`
50. `docs/version_plans/6.0_A1_V1_CONTRACT_AUDIT.md`

## 6.0 Alpha 当前参考

- `docs/version_plans/ELITESYNC_6_0_ALPHA_MASTER_PLAN_2026_05_12.md`
- `docs/version_plans/v_6_0_A0_Alpha内测准备_商用化底座与路线冻结版_开发计划书_2026_05_12.md`
- `docs/version_plans/6.0_A1_HANDOFF_MASTER.md`
- `docs/version_plans/6.0_A1_IP_STAGING_OPTION_B_NARROW_SCAFFOLD_PREFLIGHT_REPORT.md`
- `docs/version_plans/6.0_A1_IP_STAGING_AUTHORIZATION_CLAUDE_LIGHTWEIGHT_REVIEW.md`
- `docs/version_plans/6.0_A1_IP_STAGING_IMPLEMENTATION_EXECUTION_AUTHORIZATION_PACKAGE.md`
- `docs/version_plans/6.0_A1_NGINX_CONFIG_BACKUP_EXECUTION_REPORT.md`
- `docs/version_plans/6.0_A1_NGINX_CONFIG_BACKUP_READONLY_PREPACKAGE.md`
- `docs/version_plans/6.0_A1_SERVER_INVENTORY_READONLY_EXECUTION_REPORT.md`
- `docs/version_plans/6.0_A1_SERVER_INVENTORY_READONLY_PREPACKAGE.md`
- `docs/version_plans/6.0_A1_IP_BASED_CONTROLLED_STAGING_IMPLEMENTATION_PREPACKAGE.md`
- `docs/version_plans/6.0_A1_IP_BASED_CONTROLLED_STAGING_PLAN.md`
- `docs/version_plans/6.0_A1_STAGING_BOUNDARY_BLOCKER_REPORT.md`
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

6.0-A1 当前入口提醒：`docs/version_plans/6.0_A1_HANDOFF_MASTER.md` 是当前 A1 默认主交接入口。Issue #60 closure decision 为 `accepted_with_observations`，acceptance scope limited to R1 readonly v2 runtime slice + Option B deployed-code correction + server-localhost readonly verification + user-confirmed public IP readonly verification + docs sync posture。Issue #61 已用于 post-A1 current docs sync / 6.0-A2 planning decision。当前仍不能标记 production ready、production verification passed、broad API smoke passed、Candidate C implemented、R2 runtime complete、full v2 skeleton complete、A2 runtime start 或 release-chain readiness。production 默认继续 v1，Flutter 默认不切 v2，R1 仍只保持三个 readonly endpoints。下一步建议 `GPT-TASK: 6.0-A2 planning package / authorization prepackage gate`；A2 runtime implementation 必须等待后续显式 GPT advisor + user authorization gate。后续 Codex 导出目录默认固定为 `C:\Users\zcxve\Downloads\`。

## 规则文件 / Agent Rules / Project Rules

- `docs/project_rules/PROJECT_RULE_HANDOFF_SINGLE_FILE.md`
  - 项目级长期规则；
  - 当前 active version 必须只有一个默认 handoff entry；
  - supporting evidence 不得被提升为并行 current handoff。

- `docs/project_rules/PROJECT_RULE_CROSS_LAYER_BLOCKERS.md`
  - 项目级长期规则；
  - 前端 / 后端 / server / DB / release chain 跨层不确定问题进入 evidence-first blocker handling；
  - 不得在真实原因不明时盲目连续改 UI/runtime。

- `docs/project_rules/PROJECT_RULE_RUNTIME_ISSUE_BUNDLE.md`
  - 项目级长期规则；
  - runtime / program-development 默认拆成 GitHub Issue Bundle；
  - planning / implementation / evidence / Claude review / GPT final acceptance 不得混成一个巨型 issue。

- `docs/project_rules/PROJECT_RULE_TEXT_FIRST_EVIDENCE_PACKS.md`
  - 项目级长期规则；
  - GitHub 默认保存 text-first evidence chain；
  - ordinary screenshots 不批量入库，critical screenshots 才可按需引用或提交。

- `docs/project_rules/PROJECT_RULE_CLAUDE_HORIZONTAL_REVIEW_ARTIFACTS.md`
  - 项目级长期规则；
  - Claude horizontal / blind review 产物默认是 repo text artifacts；
  - key screenshots 只在必要时由用户提供给 GPT 顾问或作为 critical evidence。

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
