# EliteSync 整体开发计划书入口

更新时间：2026-05-15

## 当前主线

当前主线：6.0 Alpha 内测准备线

当前主计划：`docs/version_plans/ELITESYNC_6_0_ALPHA_MASTER_PLAN_2026_05_12.md`

当前 A0 计划书：`docs/version_plans/v_6_0_A0_Alpha内测准备_商用化底座与路线冻结版_开发计划书_2026_05_12.md`

当前 A1 顾问计划书：`docs/version_plans/v_6_0_A1_后端v2与位置链路最小闭环_开发计划书_2026_05_12.md`

当前 A1 默认主交接入口：`docs/version_plans/6.0_A1_HANDOFF_MASTER.md`

当前最新 pushed HEAD：`3b26d7faf7387ff183194512396705f4308203d7`

当前下一步：6.0-A1 documentation / precondition stage 已通过 Claude review，verdict 为 `pass with observations`。Narrow readonly v2 skeleton planning 已 push / planning-only；v2 runtime authorization package 已 push / supporting evidence。A1 runtime 仍未完成，v2 skeleton runtime 仍 forbidden。下一步候选为用户授权判断“是否执行真正的极窄只读 v2 health / readiness / location contract runtime slice”；不建议直接进入完整 v2 skeleton runtime。

## 当前判断

- 5.6-5.10 已完成第一轮“玄学能力二次产品化与校准线”闭环，GPT 顾问验收口径为 `pass with observations`。
- 当前不继续直接制定 5.11，也不直接进入 5.11 runtime。
- 6.0 Alpha 进入内测准备线：商用级底座重构 + Date Drop 式高质量低频匹配 + 搭子精准陪伴 + 基础社交功能补齐 + 玄学解释产品化 + UI/IA 内测打磨。
- 6.0-A0 是 planning-only 版本，只做路线冻结、边界定义、计划书与门禁固化，不做 runtime；A0 不是后端 v2、搭子、Date Drop 或 UI/IA 的 runtime 完成版本。
- 6.0-A1 handoff master 已提交并作为当前默认入口；Claude review report archive、Codex response、narrow readonly v2 skeleton planning 与 v2 runtime authorization package 已提交并 push，Claude verdict 为 `pass with observations`。这只代表 documentation-only / precondition-stage 通过 Claude review 与 supporting evidence 收口，不代表 A1 runtime pass，也不代表 GPT final acceptance complete，不代表 runtime authorized。Laravel 11 不作为 v2 商用级目标版本；v2 skeleton runtime、route-controller-DTO-resource 新增、composer update、Laravel upgrade、migration、production operation、API smoke 与 write smoke 仍禁止，除非用户后续对极窄 runtime slice 另行明确授权。

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
