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
- 当前实际 Git HEAD 以 `git rev-parse HEAD` / `git log` 实时结果为准。

## 当前下一步

R2 prepackage 后的下一步应保持在 A1 内：

- prepare staging / production split readonly verification package authorization/preparation document；
- 或由用户再次明确授权后再下达 Candidate C prepackage prompt；
- Laravel 12 staging dry-run pre-evidence package；
- Claude horizontal review before A1 final gate。

Candidate C 尚未获实施授权，本阶段不得进入 Candidate C implementation。

不得把 R1 或 R2 prepackage 直接扩展为 R2 runtime implementation / endpoint expansion / A2 / Date Drop / Flutter integration / production release。

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
