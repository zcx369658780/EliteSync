# EliteSync 整体开发计划书入口

更新时间：2026-05-12

## 当前主线

当前主线：6.0 Alpha 内测准备线

当前主计划：`docs/version_plans/ELITESYNC_6_0_ALPHA_MASTER_PLAN_2026_05_12.md`

当前 A0 计划书：`docs/version_plans/v_6_0_A0_Alpha内测准备_商用化底座与路线冻结版_开发计划书_2026_05_12.md`

当前下一步：完成 6.0-A0 planning-only 的 Claude 轻量横向复评与 GPT 顾问最终验收；通过前不得进入 6.0-A1 runtime。

## 当前判断

- 5.6-5.10 已完成第一轮“玄学能力二次产品化与校准线”闭环，GPT 顾问验收口径为 `pass with observations`。
- 当前不继续直接制定 5.11，也不直接进入 5.11 runtime。
- 6.0 Alpha 进入内测准备线：商用级底座重构 + Date Drop 式高质量低频匹配 + 搭子精准陪伴 + 基础社交功能补齐 + 玄学解释产品化 + UI/IA 内测打磨。
- 6.0-A0 是 planning-only 版本，只做路线冻结、边界定义、计划书与门禁固化，不做 runtime；A0 不是后端 v2、搭子、Date Drop 或 UI/IA 的 runtime 完成版本。

## 6.0 Alpha 优先级

- P0：后端 v2 与位置链路重构，采用 contract-first 与 parallel migration，不无计划推倒重写。
- P1：Date Drop 式匹配主链重构，Date Drop 是 EliteSync 匹配机制母版。
- P1：搭子精准陪伴，覆盖学习搭子、电影搭子、吃饭搭子、健身搭子等共同兴趣陪伴。
- P2：基础社交功能补齐，Soul 作为社交表达参考。
- P3：玄学解释产品化，测测 / CECE 作为玄学解释层参考。
- P4：UI/IA 内测打磨，清理工程术语、拆分长页、降低信息噪声。

## 强制验收门禁

- 每个版本完成后，必须先经 Claude 调用 Soul + 测测 / CECE 做横向复评。
- Claude 复评为 `pass` 或 `pass with observations` 后，才允许提交 GPT 顾问最终验收。
- `conditional pass` 必须补证据或小修后再提交。
- `fail` 必须返工。
- 没有 Claude 横向复评，不允许进入 GPT 顾问最终验收。
- 没有 GPT 顾问最终验收，不允许进入下一版本。

## 历史参考

- `docs/version_plans/elite_sync_整体开发计划书_5_6_plus_玄学能力二次产品化修订版_2026_05_11.md`
- `docs/version_plans/elite_sync_未来版本开发路线图_5_6_plus_玄学能力二次产品化_2026_05_11.md`
- `docs/version_plans/5.6_HANDOFF_MASTER.md`
- `docs/version_plans/5.7_HANDOFF_MASTER.md`
- `docs/version_plans/5.8_HANDOFF_MASTER.md`
- `docs/version_plans/5.9_HANDOFF_MASTER.md`
- `docs/version_plans/5.10_HANDOFF_MASTER.md`

本文件只保留为当前计划入口，不作为计划正文。
