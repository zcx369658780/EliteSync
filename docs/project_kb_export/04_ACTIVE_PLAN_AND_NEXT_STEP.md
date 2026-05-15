# 当前计划与下一步

更新时间：2026-05-15

## 当前最建议继续推进的方向

- 当前最建议方向改为 6.0 Alpha 内测准备线。
- 当前主计划：`docs/version_plans/ELITESYNC_6_0_ALPHA_MASTER_PLAN_2026_05_12.md`。
- 当前 A1 默认主交接入口：`docs/version_plans/6.0_A1_HANDOFF_MASTER.md`。
- R1 readonly v2 runtime slice 已 remote-published：`90436e2d17c611907dfe4322135c7e4ba0bbb23d feat: add readonly v2 runtime slice`。

## 当前下一步

R1 后的下一步应保持在 A1 内：

- 做 A1 后续 readonly verification / evidence closeout / Claude 或 GPT 顾问判断；或
- 在用户明确授权后，规划下一条极窄 runtime slice。

不得把 R1 直接扩展为 A2 / Date Drop / Flutter integration / production release。

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
