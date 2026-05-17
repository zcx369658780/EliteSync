# Version Plans

更新时间：2026-05-16

## Current Active Plan

- [ELITESYNC_6_0_ALPHA_MASTER_PLAN_2026_05_12.md](./ELITESYNC_6_0_ALPHA_MASTER_PLAN_2026_05_12.md)
- [v_6_0_A0_Alpha内测准备_商用化底座与路线冻结版_开发计划书_2026_05_12.md](./v_6_0_A0_Alpha内测准备_商用化底座与路线冻结版_开发计划书_2026_05_12.md)

## Current Active Route

6.0 Alpha 内测准备线

当前下一步：6.0-A1 默认主交接入口仍为 [6.0_A1_HANDOFF_MASTER.md](./6.0_A1_HANDOFF_MASTER.md)。Claude review report archive、Codex response、narrow readonly v2 skeleton planning、v2 runtime authorization package、R2 authorization prepackage、Candidate C staging / production split readonly verification prepackage、Candidate C local/repo-only readonly audit report、Candidate C Claude horizontal review prepackage、Candidate C Claude horizontal review report、Staging readonly metadata verification authorization prepackage、Staging boundary blocker report 与 IP-based controlled staging plan 已形成证据链，Claude verdict 为 `pass with observations`。R1 readonly v2 runtime slice 已 remote-published，commit `90436e2d17c611907dfe4322135c7e4ba0bbb23d feat: add readonly v2 runtime slice`；post-push readonly verification 已通过。Staging boundary blocker report 已准备为 [6.0_A1_STAGING_BOUNDARY_BLOCKER_REPORT.md](./6.0_A1_STAGING_BOUNDARY_BLOCKER_REPORT.md)。IP-based controlled staging plan 已准备为 [6.0_A1_IP_BASED_CONTROLLED_STAGING_PLAN.md](./6.0_A1_IP_BASED_CONTROLLED_STAGING_PLAN.md)。由于当前无法完成 ICP 备案，`staging.slowdate.top` 域名 staging 方案短期不可行；IP-based controlled staging 仍只是 candidate plan，尚未创建 staging environment，尚未执行 staging verification。`https://slowdate.top/` 是 Android release/default tracked config，`http://101.133.161.203/` 是 debug / legacy Aliyun direct URL，二者均不得在未获明确确认并建立独立边界时当作 staging。production verification 继续后置，Candidate C 尚未 implementation，A1 尚未 final acceptance。后续 Codex 导出目录默认固定为 `C:\Users\zcxve\Downloads\`。

## 6.0 Alpha Version Split

- 6.0-A0：商用化底座与路线冻结版，planning-only，计划书已落地；仍需 Claude 轻量横向复评与 GPT 顾问最终验收
- 6.0-A1：后端 v2 与位置链路最小闭环；当前默认主交接入口为 [6.0_A1_HANDOFF_MASTER.md](./6.0_A1_HANDOFF_MASTER.md)，其他 A1 文件均为 supporting evidence / 补充附件，不创建多个 handoff 入口。Claude input / report / response、narrow readonly v2 skeleton planning、v2 runtime authorization package、R2 authorization prepackage、Candidate C staging / production split readonly verification prepackage、Candidate C local/repo-only readonly audit report、Candidate C Claude horizontal review prepackage、Candidate C Claude horizontal review report、Staging readonly metadata verification authorization prepackage、Staging boundary blocker report 与 IP-based controlled staging plan 均为 supporting evidence，Claude verdict 为 `pass with observations`。R1 已新增极窄 readonly v2 runtime slice；R2 authorization prepackage、Candidate C prepackage、Candidate C local audit report、Candidate C Claude review prepackage 与 Candidate C Claude horizontal review result 已获 GPT 顾问验收。Staging readonly metadata verification 未执行，因为没有确认独立 staging base URL；这是 staging boundary blocker，不是 staging verification failed。IP-based controlled staging 仍只是 candidate plan，尚未创建 staging environment，尚未修改服务器 / Nginx / 安全组 / DB / Redis / storage。Candidate C 尚未 implementation，staging verification / production verification / API smoke 尚未执行、尚未通过，production verification 继续后置。当前仍禁止 Laravel upgrade、composer update、migration、production operation、API/write smoke、Flutter default base URL change、release chain 修改、staging verification、production verification，以及未经授权扩展完整 v2 skeleton 或进入 Candidate C implementation。

## 6.0-A1 Current Supporting Evidence

- [6.0_A1_CLAUDE_HORIZONTAL_REVIEW_INPUT_PACKAGE.md](./6.0_A1_CLAUDE_HORIZONTAL_REVIEW_INPUT_PACKAGE.md)：Claude review input package，supporting evidence。
- [6.0_A1_CLAUDE_HORIZONTAL_REVIEW_REPORT.md](./6.0_A1_CLAUDE_HORIZONTAL_REVIEW_REPORT.md)：Claude review report archive，verdict `pass with observations`，supporting evidence only。
- [6.0_A1_CLAUDE_REVIEW_RESPONSE.md](./6.0_A1_CLAUDE_REVIEW_RESPONSE.md)：Codex response to Claude review，supporting evidence only。
- [6.0_A1_V2_HEALTH_READINESS_LOCATION_CONTRACT_SKELETON_PLAN.md](./6.0_A1_V2_HEALTH_READINESS_LOCATION_CONTRACT_SKELETON_PLAN.md)：narrow readonly v2 skeleton planning，R1 实施前 planning-only / supporting evidence；对应 endpoints 已在 R1 commit `90436e2d` 中实现为 readonly runtime slice。
- [6.0_A1_V2_RUNTIME_SLICE_AUTHORIZATION_PACKAGE.md](./6.0_A1_V2_RUNTIME_SLICE_AUTHORIZATION_PACKAGE.md)：v2 runtime authorization package，R1 实施前 supporting evidence；对应 endpoints 已在 R1 commit `90436e2d` 中实现为 readonly runtime slice。
- [6.0_A1_R1_READONLY_RUNTIME_SLICE_STAGE_ACCEPTANCE.md](./6.0_A1_R1_READONLY_RUNTIME_SLICE_STAGE_ACCEPTANCE.md)：R1 readonly runtime slice stage acceptance package，supporting evidence only；不取代 `6.0_A1_HANDOFF_MASTER.md`，不代表 A1 final acceptance / production ready / full v2 skeleton / A2 start。
- [6.0_A1_R2_NARROW_READONLY_RUNTIME_SLICE_AUTHORIZATION_PREPACKAGE.md](./6.0_A1_R2_NARROW_READONLY_RUNTIME_SLICE_AUTHORIZATION_PREPACKAGE.md)：R2 authorization prepackage，已 remote-published as `e1627b8dd9f4ec6967f9c9940e13e6cb788895ff docs: add 6.0-A1 R2 authorization prepackage`；GPT 顾问已验收并建议下一步选择 staging / production split readonly verification package；supporting evidence only，不代表 R2 runtime complete、Candidate C authorized 或 Candidate C implemented。
- [6.0_A1_STAGING_PRODUCTION_SPLIT_READONLY_VERIFICATION_PREPACKAGE.md](./6.0_A1_STAGING_PRODUCTION_SPLIT_READONLY_VERIFICATION_PREPACKAGE.md)：Candidate C staging / production split readonly verification prepackage，已 remote-published as `3e49879c1264f031325264a75702e8afa9db6302 docs: add 6.0-A1 staging production verification prepackage`；GPT 顾问已验收；authorization / preparation document only，不代表 Candidate C 已获实施授权、已实施或已完成，不代表 staging verification passed、production verification passed 或 API smoke passed；后续 Codex 导出目录默认固定为 `C:\Users\zcxve\Downloads\`。
- [6.0_A1_CANDIDATE_C_LOCAL_REPO_ONLY_READONLY_AUDIT_REPORT.md](./6.0_A1_CANDIDATE_C_LOCAL_REPO_ONLY_READONLY_AUDIT_REPORT.md)：Candidate C local/repo-only readonly audit report，已 remote-published as `9f958508a2ca4a60a5f1e8104aece230edb5c495 docs: add 6.0-A1 candidate C local audit report`；GPT 顾问已验收；local/repo-only readonly audit report only，不代表 Candidate C implementation，不代表 Candidate C 已获实施授权、已实施或已完成，不代表 staging verification passed、production verification passed 或 API smoke passed；后续 Candidate C Claude horizontal review 已完成，下一步以 review report 为准。
- [6.0_A1_CANDIDATE_C_CLAUDE_HORIZONTAL_REVIEW_PREPACKAGE.md](./6.0_A1_CANDIDATE_C_CLAUDE_HORIZONTAL_REVIEW_PREPACKAGE.md)：Candidate C Claude horizontal review prepackage，已 remote-published as `2944ab310a6e189bcc420007c9423a6043a23d38 docs: add 6.0-A1 candidate C Claude review prepackage`；GPT 顾问已验收；prepackage only，后续事实以 Candidate C Claude horizontal review report 为准。
- [6.0_A1_CANDIDATE_C_CLAUDE_HORIZONTAL_REVIEW_REPORT.md](./6.0_A1_CANDIDATE_C_CLAUDE_HORIZONTAL_REVIEW_REPORT.md)：Candidate C Claude horizontal review report；Claude verdict `pass with observations`；GPT 顾问已验收该 review result；允许进入 future staging readonly metadata verification authorization prompt 的准备讨论，但 staging request 仍需用户另行明确授权，production verification 继续后置；不代表 Candidate C implementation / authorized / completed，不代表 staging verification passed、production verification passed、API smoke passed、A1 final acceptance、production ready、full v2 skeleton 或 A2 start。
- [6.0_A1_STAGING_READONLY_METADATA_VERIFICATION_AUTHORIZATION_PREPACKAGE.md](./6.0_A1_STAGING_READONLY_METADATA_VERIFICATION_AUTHORIZATION_PREPACKAGE.md)：Staging readonly metadata verification authorization prepackage；只用于未来授权审查；尚未请求 staging，尚未执行 staging verification；staging execution 仍需用户另行明确授权，production verification 继续后置；不代表 staging verification passed、production verification passed、API smoke passed、Candidate C implementation / completed、A1 final acceptance、production ready、full v2 skeleton 或 A2 start。
- [6.0_A1_STAGING_BOUNDARY_BLOCKER_REPORT.md](./6.0_A1_STAGING_BOUNDARY_BLOCKER_REPORT.md)：Staging boundary blocker report；记录 `<STAGING_BASE_URL>` placeholder 导致 verification 在任何网络请求前停止；当前 blocker 是 no confirmed staging base URL；不得把 `https://slowdate.top/` 或 `http://101.133.161.203/` 当作 staging；不是 staging verification result，不代表 staging verification failed / passed。
- [6.0_A1_IP_BASED_CONTROLLED_STAGING_PLAN.md](./6.0_A1_IP_BASED_CONTROLLED_STAGING_PLAN.md)：IP-based controlled staging plan；candidate plan only；由于当前无法完成 ICP 备案，`staging.slowdate.top` 短期不可行；不代表 staging environment 已创建，不代表 staging verification 已执行或通过，不代表 production verification passed、Candidate C implementation 或 A1 final acceptance。
- R1 readonly v2 runtime slice：commit `90436e2d17c611907dfe4322135c7e4ba0bbb23d feat: add readonly v2 runtime slice`，remote-published。Post-push readonly verification passed：route-list 可见 `GET api/v2/app/health`、`GET api/v2/app/readiness`、`GET api/v2/contracts/location`；不存在错误旧路径 `api/v2/health` / `api/v2/readiness`；3 个新增 Feature Test 文件最小测试通过，无 failures，仅有 `PDO::MYSQL_ATTR_SSL_CA` deprecation notice。
- 6.0-A2：Date Drop 式匹配主链重构
- 6.0-A3：搭子精准陪伴最小闭环
- 6.0-A4：基础社交功能补齐
- 6.0-A5：玄学解释与 UI/IA 内测打磨

## 6.0 Alpha Gate

- 每个版本完成后必须先经 Claude 调用 Soul + 测测 / CECE 做横向复评。
- 只有 `pass` 或 `pass with observations` 可以进入 GPT 顾问最终验收。
- `conditional pass` 必须补证据或小修。
- `fail` 必须返工。
- 无 Claude 横向复评，不得进入 GPT 顾问最终验收。
- 无 GPT 顾问最终验收，不得进入下一版本。
- 6.0 Alpha 起，所有版本开发计划书必须遵守：
  - `docs/agents/PROJECT_RULE_DEVELOPMENT_PLAN_FORMAT_CURRENT.md`
  - `docs/agents/PROJECT_RULE_CLAUDE_SOUL_CECE_HORIZONTAL_REVIEW.md`

## 6.0-A0 Review Materials

- [CODEX_6_0_A0_EXECUTION_REPORT.md](./CODEX_6_0_A0_EXECUTION_REPORT.md)
- [CODEX_6_0_A0_CLAUDE_FEEDBACK_RESPONSE.md](./CODEX_6_0_A0_CLAUDE_FEEDBACK_RESPONSE.md)
- [claude_reviews/6.0_A0/CLAUDE_6_0_A0_HORIZONTAL_REVIEW.md](./claude_reviews/6.0_A0/CLAUDE_6_0_A0_HORIZONTAL_REVIEW.md)
- [claude_reviews/6.0_A0/CLAUDE_6_0_A0_SOUL_COMPARISON.md](./claude_reviews/6.0_A0/CLAUDE_6_0_A0_SOUL_COMPARISON.md)
- [claude_reviews/6.0_A0/CLAUDE_6_0_A0_CECE_COMPARISON.md](./claude_reviews/6.0_A0/CLAUDE_6_0_A0_CECE_COMPARISON.md)
- [claude_reviews/6.0_A0/CLAUDE_6_0_A0_ACTION_MATRIX.md](./claude_reviews/6.0_A0/CLAUDE_6_0_A0_ACTION_MATRIX.md)

## Historical Closeout

- 5.6-5.10：第一轮玄学解释层产品化闭环，`pass with observations`，不继续直接制定 5.11。
- 5.0-5.5：高价值主链功能覆盖与真实小样本反馈吸收历史链路。
- 4.9：测试前治理、限流、监控、发布链强化历史门禁基线。

## Historical 5.6-5.10 Files

- [elite_sync_整体开发计划书_5_6_plus_玄学能力二次产品化修订版_2026_05_11.md](./elite_sync_整体开发计划书_5_6_plus_玄学能力二次产品化修订版_2026_05_11.md)
- [elite_sync_未来版本开发路线图_5_6_plus_玄学能力二次产品化_2026_05_11.md](./elite_sync_未来版本开发路线图_5_6_plus_玄学能力二次产品化_2026_05_11.md)
- [v_5_6_玄学能力二次产品化边界与校准版_开发计划书_2026_05_11.md](./v_5_6_玄学能力二次产品化边界与校准版_开发计划书_2026_05_11.md)
- [v_5_7_Match关系解释层最小产品化版_开发计划书_2026_05_11.md](./v_5_7_Match关系解释层最小产品化版_开发计划书_2026_05_11.md)
- [v_5_8_Me个人解释层与表达建议版_开发计划书_2026_05_11.md](./v_5_8_Me个人解释层与表达建议版_开发计划书_2026_05_11.md)
- [v_5_9_Chat轻追问与低压开场版_开发计划书_2026_05_11.md](./v_5_9_Chat轻追问与低压开场版_开发计划书_2026_05_11.md)
- [v_5_10_解释层治理与用户控制版_开发计划书_2026_05_11.md](./v_5_10_解释层治理与用户控制版_开发计划书_2026_05_11.md)
- [5.6_HANDOFF_MASTER.md](./5.6_HANDOFF_MASTER.md)
- [5.7_HANDOFF_MASTER.md](./5.7_HANDOFF_MASTER.md)
- [5.8_HANDOFF_MASTER.md](./5.8_HANDOFF_MASTER.md)
- [5.9_HANDOFF_MASTER.md](./5.9_HANDOFF_MASTER.md)
- [5.10_HANDOFF_MASTER.md](./5.10_HANDOFF_MASTER.md)

## Archived Materials

All 4.9 and earlier version-plan documents have been archived to:

- [`docs/archive/legacy_2026-04/version_plans/`](../archive/legacy_2026-04/version_plans/)
