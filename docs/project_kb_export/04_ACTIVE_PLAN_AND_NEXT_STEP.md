# 当前计划与下一步

更新时间：2026-05-11

## 当前最建议继续推进的方向

- 当前已经不是 4.x 的基础能力补全阶段。
- 当前主线已从 `4.9` 稳定门禁和 `5.x` 高价值主链功能覆盖进入 `5.6+` 玄学能力二次产品化与校准线。
- `5.0`、`5.1`、`5.2`、`5.3`、`5.4` 与 `5.5` 已作为历史链路收口，不重写。
- 如果继续按当前产品线推进，优先级应为：
  1. 验收 `docs/version_plans/5.7_HANDOFF_MASTER.md`
  2. 验收 `docs/version_plans/5.7_REGRESSION_CHECKLIST.md`
  3. 验收 `docs/version_plans/5.7_UI_BASELINE_EVIDENCE_INDEX.md`
  4. 验收通过前不要自动进入 5.8 runtime

## 为什么这样排

- `4.9` 已经把 UI protected surfaces、rollback / recovery policy、release gate、health、数据库安全、媒体 / 队列 / Worker 可观测性、RTC / LiveKit 可观测性固化为门禁基线。
- 继续沿纯稳定化方向推进，边际收益会快速下降。
- 5.x 更应该解决的是：
  - 发现页如何覆盖分栏 / 搜索 / 同城 / 轻治理 / 低压私聊入口
  - 聊天页如何承担首聊 / 回聊 / 稍后再聊 / 关系推进
  - 个人页如何从资料页升级成经营中枢与表达层
  - AI 如何嵌入慢约会主线
  - 云端治理如何在后期服务收口与稳定化

## 5.x 的默认推进原则

- 5.x 不是重做主链，而是先覆盖高价值主链再做优化和治理。
- 5.x 不是重写 RTC，而是把语音通话作为关系推进节点继续复用。
- 5.x 不是做重商业化平台，而是补齐测试期最容易暴露的高价值功能缺口。

## 5.2 收口说明

- `5.2` 已正式收口，状态为 `pass with observations`。
- 5.2 已完成个人经营中枢与表达层覆盖，后续不再作为当前主线继续展开。
- 5.2 的 observations 仅作为后续 5.3 及更后续版本的补证据或小项承接，不回头重开主链。

## 5.4 收口说明

- `5.4` 已正式收口，状态为 `pass with observations`。
- 5.4 已完成测试运营准备与云端治理增强：只读运营准备入口、观测入口、Smoke / Regression Matrix、5.4 Runbook Library、synthetic / smoke 账号治理提示、备份 / 恢复 / migration readiness 与保护面证据。
- 5.4 observations 只作为真实环境核验项承接：Cloud DB read-only audit、backup existence、restore drill、migration-level checks、queue / logs、RTC success evidence 仍需真实环境证据，不回头重开 5.4 主链。

## 不能跳过的前置条件

- 不能跳过 `profile/basic`、`profile/astro/summary`、`profile/astro/chart` 真值链
- 不能跳过 `media_assets` / `message_attachments` / `chat_messages` 的稳定性
- 不能跳过版本检查和发版脚本一致性
- 不能跳过截图证据、回归清单和 closeout 文档
- 不能跳过云端后端与本地前端的环境边界
- 不能把 5.x 的高价值主链功能覆盖优先重新写成 4.x 的基础设施补课

## 当前建议

- 继续做新版本前，先确认 5.7 handoff、回归清单与 UI 证据索引已通过顾问验收。
- 下一步只做 5.7 顾问验收，不直接做 5.8 runtime。
- 任何后续解释层能力都必须保持 `derived-only / display-only / explanation layer`，不得反写真值链、匹配算法、API / DB / release contract。
