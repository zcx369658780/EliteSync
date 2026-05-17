# 当前计划与下一步

更新时间：2026-05-16

## 当前最建议继续推进的方向

- 当前最建议方向改为 6.0 Alpha 内测准备线。
- 当前主计划：`docs/version_plans/ELITESYNC_6_0_ALPHA_MASTER_PLAN_2026_05_12.md`。
- 当前 A1 默认主交接入口：`docs/version_plans/6.0_A1_HANDOFF_MASTER.md`。
- R1 readonly v2 runtime slice 已 remote-published：`90436e2d17c611907dfe4322135c7e4ba0bbb23d feat: add readonly v2 runtime slice`。
- R1 readonly runtime slice 已 stage accepted；stage acceptance package 已 push：`docs/version_plans/6.0_A1_R1_READONLY_RUNTIME_SLICE_STAGE_ACCEPTANCE.md`，commit `99cfd0ba47186bbacc03770b2679afe558a9a5f8 docs: add 6.0-A1 R1 stage acceptance package`。
- R2 authorization prepackage 已 remote-published：`docs/version_plans/6.0_A1_R2_NARROW_READONLY_RUNTIME_SLICE_AUTHORIZATION_PREPACKAGE.md`，commit `e1627b8dd9f4ec6967f9c9940e13e6cb788895ff docs: add 6.0-A1 R2 authorization prepackage`。
- GPT 顾问已验收 R2 prepackage；当前决策为 reject endpoint R2 for now，并建议下一步方向选择 staging / production split readonly verification package。
- 该决策只代表下一步建议方向，不代表 Candidate C 已获实施授权、已实施或已完成。
- Candidate C staging / production split readonly verification prepackage 已 remote-published：`docs/version_plans/6.0_A1_STAGING_PRODUCTION_SPLIT_READONLY_VERIFICATION_PREPACKAGE.md`，commit `3e49879c1264f031325264a75702e8afa9db6302 docs: add 6.0-A1 staging production verification prepackage`。
- GPT 顾问已验收 Candidate C prepackage；该文件只是 authorization / preparation document，不代表 Candidate C 已获实施授权、已实施或已完成，也不代表 staging verification passed、production verification passed 或 API smoke passed。
- Candidate C local/repo-only readonly audit report 已 remote-published：`docs/version_plans/6.0_A1_CANDIDATE_C_LOCAL_REPO_ONLY_READONLY_AUDIT_REPORT.md`，commit `9f958508a2ca4a60a5f1e8104aece230edb5c495 docs: add 6.0-A1 candidate C local audit report`。
- GPT 顾问已验收 Candidate C local audit report；该 report 是 local/repo-only readonly audit report，不代表 Candidate C implementation，不代表 Candidate C 已获实施授权、已实施或已完成，也不代表 staging verification passed、production verification passed 或 API smoke passed。
- 该 report 确认本轮未请求 staging / production，未执行 API / smoke / artisan / PHPUnit / composer / migration，未读取真实 `.env` / `.env.*`，未输出 secrets。
- Candidate C Claude horizontal review prepackage 已 remote-published：`docs/version_plans/6.0_A1_CANDIDATE_C_CLAUDE_HORIZONTAL_REVIEW_PREPACKAGE.md`，commit `2944ab310a6e189bcc420007c9423a6043a23d38 docs: add 6.0-A1 candidate C Claude review prepackage`。
- GPT 顾问已验收 Candidate C Claude review prepackage；该 prepackage 是 Claude horizontal review prepackage，后续事实以 Candidate C Claude horizontal review report 为准。
- Candidate C Claude horizontal review 已执行完成并归档：`docs/version_plans/6.0_A1_CANDIDATE_C_CLAUDE_HORIZONTAL_REVIEW_REPORT.md`。
- Claude verdict：`pass with observations`。
- GPT 顾问已验收该 Claude horizontal review result。
- 该结果允许进入 future staging readonly metadata verification authorization prompt 的准备讨论；staging request 仍需用户另行明确授权，production verification 继续后置。
- 该结果不代表 Candidate C implementation / authorized / completed，不代表 staging verification passed、production verification passed 或 API smoke passed，也不代表 A1 final acceptance、production ready、full v2 skeleton complete 或 A2 start。
- Staging readonly metadata verification authorization prepackage 已准备：`docs/version_plans/6.0_A1_STAGING_READONLY_METADATA_VERIFICATION_AUTHORIZATION_PREPACKAGE.md`。
- 该文件只用于未来授权审查；尚未请求 staging，尚未执行 staging verification；staging execution 仍需用户另行明确授权。
- Staging boundary blocker report 已准备：`docs/version_plans/6.0_A1_STAGING_BOUNDARY_BLOCKER_REPORT.md`。
- Staging readonly metadata verification attempt stopped before network request because staging base URL was placeholder only。
- No separate staging base URL is currently confirmed in tracked docs/config。
- `https://slowdate.top/` 是 Android release/default tracked config，不得在未获明确确认时当作 staging。
- `http://101.133.161.203/` 是 debug / legacy Aliyun direct backend URL，不得在未获明确确认时当作 staging。
- IP-based controlled staging plan 已准备：`docs/version_plans/6.0_A1_IP_BASED_CONTROLLED_STAGING_PLAN.md`。
- 由于当前无法完成 ICP 备案，`staging.slowdate.top` 域名 staging 方案短期不可行。
- 该 plan 是 candidate plan only；尚未创建 staging environment，尚未执行 staging verification，尚未修改服务器 / Nginx / 安全组 / DB / Redis / storage。
- IP-based controlled staging implementation prepackage 已准备：`docs/version_plans/6.0_A1_IP_BASED_CONTROLLED_STAGING_IMPLEMENTATION_PREPACKAGE.md`。
- 该 prepackage 只用于未来 implementation 授权审查；尚未修改服务器 / Nginx / 安全组 / DB / Redis / storage，尚未创建 staging 环境，尚未执行 staging verification。
- Server inventory readonly prepackage 已准备：`docs/version_plans/6.0_A1_SERVER_INVENTORY_READONLY_PREPACKAGE.md`。
- 该 prepackage 只用于未来只读服务器盘点授权审查；尚未 SSH 登录服务器，尚未执行 server inventory，尚未读取真实 `.env` / `.env.*`，尚未修改服务器 / Nginx / 安全组 / DB / Redis / storage。
- Server inventory readonly execution report 已准备：`docs/version_plans/6.0_A1_SERVER_INVENTORY_READONLY_EXECUTION_REPORT.md`。
- server inventory readonly execution 已完成并归档；未修改服务器，未读取真实 `.env` / `.env.*`，未输出 secrets，未创建 staging，未执行 staging verification。
- 发现 `8081` 已占用，不能直接复用；未发现 `.env.staging`；未发现 active Nginx staging port。
- Nginx/config backup readonly prepackage 已准备：`docs/version_plans/6.0_A1_NGINX_CONFIG_BACKUP_READONLY_PREPACKAGE.md`。
- 该 prepackage 只用于未来 backup execution 授权审查；尚未 SSH 登录服务器，尚未创建 backup，尚未读取完整 Nginx 配置正文，尚未读取真实 `.env` / `.env.*`，尚未修改服务器 / Nginx / 安全组 / DB / Redis / storage，尚未创建 staging，尚未执行 staging verification。
- 后续 Codex 导出目录默认固定为：`C:\Users\zcxve\Downloads\`。
- 当前实际 Git HEAD 以 `git rev-parse HEAD` / `git log` 实时结果为准。

## 当前下一步

Nginx/config backup readonly prepackage 后的下一步应保持在 A1 内：

- 由 GPT 顾问和用户判断是否允许未来执行 Nginx/config backup execution；
- 即使进入 backup execution，也仍必须另行明确授权，且不得修改 active Nginx config，不得 reload / restart Nginx，不得修改服务器 / 安全组 / DB / Redis / storage；
- 不得读取真实 `.env` / `.env.*` 或输出 secrets；
- staging request 仍需用户另行明确授权；
- 不得改用 `slowdate.top`、`staging.slowdate.top` 或 `101.133.161.203` 根路径绕过 blocker。

该建议不代表 backup completed，不代表 Nginx config reviewed in full，不代表 `.env` backed up to Git，不代表 staging environment 已创建，不代表 staging verification failed / passed、production verification passed 或 API smoke passed。Candidate C 尚未 implementation，staging verification / production verification / API smoke 尚未执行、尚未通过；本阶段不得进入 Candidate C implementation、staging verification 或 production verification。

不得把 R1、R2 prepackage 或 Candidate C prepackage 直接扩展为 R2 runtime implementation / endpoint expansion / A2 / Date Drop / Flutter integration / production release。

## R1 已验证范围

- `GET api/v2/app/health`
- `GET api/v2/app/readiness`
- `GET api/v2/contracts/location`
- `php artisan route:list --path=api/v2` 已确认以上 3 个 endpoint 可见，且不存在错误旧路径 `api/v2/health` / `api/v2/readiness`。
- 7 个 R1 PHP 文件 `php -l` 全部通过。
- 3 个新增 Feature Test 文件最小测试通过，无 failures，仅有 `PDO::MYSQL_ATTR_SSL_CA` deprecation notice。
- forbidden grep 无匹配。

## 不能跳过的前置条件

- 不能跳过后端 v2 与位置链路 P0。
- 不能把搭子做成泛同城约玩。
- 不能把 Soul / 测测 / CECE 功能照抄。
- 不能跳过 Claude 横向复评。
- 不能在 Claude 未通过前提交 GPT 顾问最终验收。
- 不能在 GPT 顾问未最终验收前进入下一版本。
- 不能把 R1 写成 6.0-A1 final acceptance complete、production ready 或 A2 start。
- 不能把 R2 prepackage 写成 R2 runtime complete。
- 不能把 Candidate C 写成已获实施授权、已实施或已完成。
- 不能把 staging / production split readonly verification 写成已通过。
- 不能把 API smoke 写成已通过。
- 不能把 Nginx/config backup readonly prepackage 写成 backup completed、Nginx config reviewed in full 或 `.env` backed up to Git。
- Candidate C Claude horizontal review 可以写成已执行完成，verdict 为 `pass with observations`，且 GPT 顾问已验收；但不能把它写成 staging / production verification passed、API smoke passed、Candidate C implementation authorization、A1 final acceptance complete、production ready、full v2 skeleton complete 或 A2 start。
- production 默认继续 v1；Flutter 默认不切 v2；R1 仍只保持三个 readonly endpoints。
