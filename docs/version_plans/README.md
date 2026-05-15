# Version Plans

更新时间：2026-05-15

## Current Active Plan

- [ELITESYNC_6_0_ALPHA_MASTER_PLAN_2026_05_12.md](./ELITESYNC_6_0_ALPHA_MASTER_PLAN_2026_05_12.md)
- [v_6_0_A0_Alpha内测准备_商用化底座与路线冻结版_开发计划书_2026_05_12.md](./v_6_0_A0_Alpha内测准备_商用化底座与路线冻结版_开发计划书_2026_05_12.md)

## Current Active Route

6.0 Alpha 内测准备线

当前下一步：6.0-A1 默认主交接入口仍为 [6.0_A1_HANDOFF_MASTER.md](./6.0_A1_HANDOFF_MASTER.md)。Claude review report archive、Codex response 与 narrow readonly v2 skeleton planning 已提交并 push，Claude verdict 为 `pass with observations`；A1 documentation / precondition stage 可记为 `pass with observations`。A1 runtime 仍未完成，v2 skeleton runtime 仍 forbidden；下一步最多是“是否授权真正极窄只读 v2 runtime slice”的用户判断，不是直接 runtime。

## 6.0 Alpha Version Split

- 6.0-A0：商用化底座与路线冻结版，planning-only，计划书已落地；仍需 Claude 轻量横向复评与 GPT 顾问最终验收
- 6.0-A1：后端 v2 与位置链路最小闭环；当前默认主交接入口为 [6.0_A1_HANDOFF_MASTER.md](./6.0_A1_HANDOFF_MASTER.md)，其他 A1 文件均为 supporting evidence / 补充附件，不创建多个 handoff 入口。Claude input / report / response 与 narrow readonly v2 skeleton planning 均为 supporting evidence，Claude verdict 为 `pass with observations`。当前仍禁止 v2 skeleton runtime、route / controller / DTO / Resource 新增、Laravel upgrade、composer update、migration、production operation、API smoke、write smoke。

## 6.0-A1 Current Supporting Evidence

- [6.0_A1_CLAUDE_HORIZONTAL_REVIEW_INPUT_PACKAGE.md](./6.0_A1_CLAUDE_HORIZONTAL_REVIEW_INPUT_PACKAGE.md)：Claude review input package，supporting evidence。
- [6.0_A1_CLAUDE_HORIZONTAL_REVIEW_REPORT.md](./6.0_A1_CLAUDE_HORIZONTAL_REVIEW_REPORT.md)：Claude review report archive，verdict `pass with observations`，supporting evidence only。
- [6.0_A1_CLAUDE_REVIEW_RESPONSE.md](./6.0_A1_CLAUDE_REVIEW_RESPONSE.md)：Codex response to Claude review，supporting evidence only。
- [6.0_A1_V2_HEALTH_READINESS_LOCATION_CONTRACT_SKELETON_PLAN.md](./6.0_A1_V2_HEALTH_READINESS_LOCATION_CONTRACT_SKELETON_PLAN.md)：narrow readonly v2 skeleton planning，planning-only / supporting evidence。Future proposal endpoints: `GET /api/v2/app/health`, `GET /api/v2/app/readiness`, `GET /api/v2/contracts/location`；这些 endpoint 仍不是 implemented。
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
