# EliteSync 整体开发计划书入口

更新时间：2026-05-16

## 当前主线

当前主线：6.0 Alpha 内测准备线

当前主计划：`docs/version_plans/ELITESYNC_6_0_ALPHA_MASTER_PLAN_2026_05_12.md`

当前 A0 计划书：`docs/version_plans/v_6_0_A0_Alpha内测准备_商用化底座与路线冻结版_开发计划书_2026_05_12.md`

当前 A1 顾问计划书：`docs/version_plans/v_6_0_A1_后端v2与位置链路最小闭环_开发计划书_2026_05_12.md`

当前 A1 默认主交接入口：`docs/version_plans/6.0_A1_HANDOFF_MASTER.md`

当前 Git HEAD：以 `git rev-parse HEAD` / `git log` 实时结果为准；本文档不再硬编码自身所在 commit 作为“当前最新 HEAD”。

近期关键提交链：

- R1 runtime commit：`90436e2d17c611907dfe4322135c7e4ba0bbb23d feat: add readonly v2 runtime slice`
- R1 documentation sync commit：`5fb233e20103eea90e6faa342ace3e58ee1367b1 docs: record 6.0-A1 R1 readonly verification`
- HEAD metadata correction commit：`ad3899b3d9365da3dd39d21e1a22d5d4076830d7 docs: clarify 6.0-A1 current head metadata`
- R1 stage acceptance package commit：`99cfd0ba47186bbacc03770b2679afe558a9a5f8 docs: add 6.0-A1 R1 stage acceptance package`
- R2 authorization prepackage commit：`e1627b8dd9f4ec6967f9c9940e13e6cb788895ff docs: add 6.0-A1 R2 authorization prepackage`
- Candidate C staging / production split readonly verification prepackage commit：`3e49879c1264f031325264a75702e8afa9db6302 docs: add 6.0-A1 staging production verification prepackage`
- Candidate C local/repo-only readonly audit report commit：`9f958508a2ca4a60a5f1e8104aece230edb5c495 docs: add 6.0-A1 candidate C local audit report`
- Candidate C Claude horizontal review prepackage commit：`2944ab310a6e189bcc420007c9423a6043a23d38 docs: add 6.0-A1 candidate C Claude review prepackage`
- Candidate C Claude horizontal review report：`docs/version_plans/6.0_A1_CANDIDATE_C_CLAUDE_HORIZONTAL_REVIEW_REPORT.md`，Claude verdict `pass with observations`，GPT 顾问已验收 review result
- Staging readonly metadata verification authorization prepackage：`docs/version_plans/6.0_A1_STAGING_READONLY_METADATA_VERIFICATION_AUTHORIZATION_PREPACKAGE.md`
- Staging boundary blocker report：`docs/version_plans/6.0_A1_STAGING_BOUNDARY_BLOCKER_REPORT.md`
- IP-based controlled staging plan：`docs/version_plans/6.0_A1_IP_BASED_CONTROLLED_STAGING_PLAN.md`
- IP-based controlled staging implementation prepackage：`docs/version_plans/6.0_A1_IP_BASED_CONTROLLED_STAGING_IMPLEMENTATION_PREPACKAGE.md`
- Server inventory readonly prepackage：`docs/version_plans/6.0_A1_SERVER_INVENTORY_READONLY_PREPACKAGE.md`
- Server inventory readonly execution report：`docs/version_plans/6.0_A1_SERVER_INVENTORY_READONLY_EXECUTION_REPORT.md`
- Nginx/config backup readonly prepackage：`docs/version_plans/6.0_A1_NGINX_CONFIG_BACKUP_READONLY_PREPACKAGE.md`
- Nginx/config backup execution report：`docs/version_plans/6.0_A1_NGINX_CONFIG_BACKUP_EXECUTION_REPORT.md`
- IP staging implementation execution authorization package：`docs/version_plans/6.0_A1_IP_STAGING_IMPLEMENTATION_EXECUTION_AUTHORIZATION_PACKAGE.md`
- IP staging authorization Claude lightweight review：`docs/version_plans/6.0_A1_IP_STAGING_AUTHORIZATION_CLAUDE_LIGHTWEIGHT_REVIEW.md`
- IP Staging Option B narrow scaffold / preflight report：`docs/version_plans/6.0_A1_IP_STAGING_OPTION_B_NARROW_SCAFFOLD_PREFLIGHT_REPORT.md`

当前下一步：6.0-A1 R1 readonly v2 runtime slice 已 remote-published，commit `90436e2d17c611907dfe4322135c7e4ba0bbb23d feat: add readonly v2 runtime slice`。Post-push readonly verification 已通过；R1 stage acceptance package 已 push，路径为 `docs/version_plans/6.0_A1_R1_READONLY_RUNTIME_SLICE_STAGE_ACCEPTANCE.md`，commit `99cfd0ba47186bbacc03770b2679afe558a9a5f8 docs: add 6.0-A1 R1 stage acceptance package`。R2 authorization prepackage、Candidate C staging / production split readonly verification prepackage、Candidate C local/repo-only readonly audit report、Candidate C Claude horizontal review prepackage 与 Candidate C Claude horizontal review report 均已 remote-published / archived。Staging readonly metadata verification authorization prepackage、Staging boundary blocker report、IP-based controlled staging plan、IP-based controlled staging implementation prepackage、Server inventory readonly prepackage、Server inventory readonly execution report、Nginx/config backup readonly prepackage、Nginx/config backup execution report、IP staging implementation execution authorization package、IP staging authorization Claude lightweight review 与 IP Staging Option B narrow scaffold / preflight report 均已准备。IP Staging Option B narrow scaffold / preflight 已完成：已创建 `.env.staging` from `.env.example`，已创建 disabled localhost-only Nginx staging draft，8088 当前未占用，`php8.4-fpm.sock` discovered and used，`nginx -t` pass 但仅验证 current active config。尚未创建 sites-enabled symlink，未 reload / restart Nginx，staging 尚未启用/不可访问，未执行 endpoint verification，未请求 production。Candidate C 尚未 implementation，A1 尚未 final acceptance。当前实际 Git HEAD 仍以 `git rev-parse HEAD` / `git log` 实时结果为准。下一步不是直接请求 staging、production verification、Candidate C implementation、R2 runtime implementation、endpoint expansion、完整 v2 skeleton runtime、A2、Date Drop、Flutter integration 或 production release；下一步建议 request sites-enabled symlink authorization。后续 Codex 导出目录默认固定为 `C:\Users\zcxve\Downloads\`。

## 当前判断

- 5.6-5.10 已完成第一轮“玄学能力二次产品化与校准线”闭环，GPT 顾问验收口径为 `pass with observations`。
- 当前不继续直接制定 5.11，也不直接进入 5.11 runtime。
- 6.0 Alpha 进入内测准备线：商用级底座重构 + Date Drop 式高质量低频匹配 + 搭子精准陪伴 + 基础社交功能补齐 + 玄学解释产品化 + UI/IA 内测打磨。
- 6.0-A0 是 planning-only 版本，只做路线冻结、边界定义、计划书与门禁固化，不做 runtime；A0 不是后端 v2、搭子、Date Drop 或 UI/IA 的 runtime 完成版本。
- 6.0-A1 handoff master 已提交并作为当前默认入口；Claude review report archive、Codex response、narrow readonly v2 skeleton planning、v2 runtime authorization package、R2 authorization prepackage、Candidate C staging / production split readonly verification prepackage、Candidate C local/repo-only readonly audit report、Candidate C Claude horizontal review prepackage、Candidate C Claude horizontal review report、Staging readonly metadata verification authorization prepackage、Staging boundary blocker report、IP-based controlled staging plan、IP-based controlled staging implementation prepackage、Server inventory readonly prepackage、Server inventory readonly execution report、Nginx/config backup readonly prepackage、Nginx/config backup execution report、IP staging implementation execution authorization package、IP staging authorization Claude lightweight review 与 IP Staging Option B narrow scaffold / preflight report 已形成证据链，Claude verdict 为 `pass with observations`。R1 readonly v2 runtime slice 已 remote-published、通过 post-push readonly verification，并已形成 stage acceptance package；R2 authorization prepackage、Candidate C prepackage、Candidate C local audit report、Candidate C Claude review prepackage 与 Candidate C Claude horizontal review result 均已获 GPT 顾问验收。IP Staging Option B narrow scaffold / preflight 已完成，但 staging 未启用、不可访问，未执行 endpoint verification。production verification 继续后置。Candidate C 尚未 implementation；staging verification / production verification / API smoke 尚未执行、尚未通过。以上不代表 A1 final acceptance complete、production ready、完整 v2 skeleton complete、R2 runtime complete 或 A2 start。production 默认继续 v1，Flutter 默认不切 v2，R1 仍只保持三个 readonly endpoints。Laravel 11 不作为 v2 商用级目标版本；composer update、Laravel upgrade、migration、production operation、API / write smoke、Flutter default base URL change、release chain 修改、Candidate C implementation、staging verification 与 production verification 仍禁止，除非用户后续另行明确授权。

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
