# EliteSync 整体开发计划书入口

当前可编辑的主计划请看：
- `docs/version_plans/elite_sync_整体开发计划书_5_6_plus_玄学能力二次产品化修订版_2026_05_11.md`
- `docs/version_plans/elite_sync_未来版本开发路线图_5_6_plus_玄学能力二次产品化_2026_05_11.md`

历史参考：
- `docs/version_plans/elite_sync_整体开发计划书_5_x方向重排版_2026_05_01.md`
- `docs/version_plans/elite_sync_未来版本开发路线图草案_2026_05_01.md`

顾问参考稿：
- `docs/version_plans/elite_sync_5_6_plus_玄学能力二次产品化_路线图与计划书.md`

当前说明：
- 4.9 已作为测试前治理、限流、监控、发布链强化版收口，并作为 5.x 的稳定门禁基线。
- 5.0 已作为最小产品化覆盖集收口，状态为 `pass with observations`。
- 5.1 已作为关系转化与内容回流增强版收口，状态为 `pass with observations`；主交接入口为 `docs/version_plans/5.1_HANDOFF_MASTER.md`。
- 5.2 已作为个人经营页与表达层增强版收口，状态为 `pass with observations`；主交接入口为 `docs/version_plans/5.2_HANDOFF_MASTER.md`。
- 5.3 已作为功能覆盖收尾版收口，状态为 `pass with observations`；主交接入口为 `docs/version_plans/5.3_HANDOFF_MASTER.md`。
- 5.3 已完成 Discover / Chat / Me / Settings 的第二轮补齐与保护面回归证据，正式 evidence package 已收敛到 `docs/version_plans/5.3_UI_BASELINE_EVIDENCE_INDEX.md`。
- 5.3 observations 保留为后续小项：`稍后再聊`、`冷场恢复`、`AI 续话`、`个人空间外观` 仍保持轻量候选 / 预览语义，不作为后端持久化系统。
- 5.4 已作为测试运营准备与云端治理增强版收口，状态为 `pass with observations`；主交接入口为 `docs/version_plans/5.4_HANDOFF_MASTER.md`。
- 5.4 已完成只读运营准备入口、观测入口、Smoke / Regression Matrix、5.4 Runbook Library、synthetic / smoke 账号治理提示、备份 / 恢复 / migration readiness 与保护面证据补齐；正式 evidence package 已收敛到 `docs/version_plans/5.4_OBSERVABILITY_EVIDENCE_INDEX.md`。
- 5.4 observations 保留为后续真实环境核验项：Cloud DB read-only audit、backup existence、restore drill、migration-level checks、queue / logs、RTC success evidence 仍需真实环境证据，不写成已通过。
- 5.5 已完成并发布到阿里云；当前最新对外发布版本为 `0.05.05 / 50500`。`0.05.04 / 50400` 仅作为上一条发布基线 / 历史发布链保留。
- 5.x 当前主线已经切换为“高价值主链功能覆盖优先”：在运营资质申请成功前，先让 EliteSync 的高价值主链尽量与 Soul 对齐，遵循“先覆盖、再优化、再治理”的顺序。
- 5.0-5.5 已作为已完成历史链路保留，不重写。
- 5.6 起进入“玄学能力二次产品化与校准线”。Soul 继续作为社交主链参考，测测作为玄学解释层参考。
- 5.6 是 planning / boundary / calibration 版本，不做 runtime implementation。5.6 已通过顾问验收，口径为 `pass with observations`。
- 5.7 已完成 Match 关系解释层最小产品化 runtime slice，并已通过 GPT 顾问验收，口径为 `pass with observations`。
- 5.7 只在 Match result / detail 展示层新增 `为什么值得聊` 解释卡，继续保持 `derived-only / display-only / explanation layer`，不改 API / DB / backend / release chain，不写 chat / profile / astro，不接真实 AI。
- 5.8 已进入并完成 Me / Profile 个人解释层与表达建议 runtime slice。当前 5.8 主交接入口为 `docs/version_plans/5.8_HANDOFF_MASTER.md`，建议验收口径为 `pass with observations`。
- 5.8 只在 Profile presentation 层新增 `我的慢约会表达建议` 解释卡，继续保持 display-only，不改 API / DB / backend / release chain，不写 profile / astro canonical truth，不接真实 AI，不自动修改资料。
- 所有玄学解释、合盘解释、AI 追问都必须保持 `derived-only / display-only / explanation layer`，不得反写 `profile/basic`、`profile/astro/summary`、`profile/astro/chart`、`user_astro_profiles`。
- 5.6+ 不吸收测测的真人玄学咨询市场、付费报告商店、上传截图主路径、娱乐化测试主路径、强出生资料收集、测试结果反写画像、大规模社区讨论或测测术语体系复制。
- 当前版本顺序统一为：
  - `5.0` 最小产品化覆盖集
  - `5.1` 关系推进与内容转化补齐版
  - `5.2` 个人经营中枢与表达层覆盖版
  - `5.3` 功能覆盖收尾版
  - `5.4` 测试运营准备与云端治理增强版
  - `5.5` 真实小样本反馈吸收版
- 5.x 当前重点功能覆盖域为：
  - Discover：分栏、搜索、同城、轻治理、低压私聊入口
  - Chat：首聊 / 回聊 / 稍后再聊、关系摘要、AI 续话、关系节奏化语音入口
  - Me：个人经营区、标签体系、AI 助理、AI 草稿助手、展示标识、外观层
  - Settings / Appearance：真设置中心与外观层分离、权限前解释
- Soul Stage2 综合主报告已成为 5.x 新路线的默认竞品主参考入口：`docs/reference/SOUL_STAGE2_MASTER_CONSOLIDATED_REPORT.md`
- 本地环境默认只做前端开发、UI 联调与文档整理；后端开发、数据库迁移、备份、恢复和任何会写数据库的操作统一在阿里云端执行，避免本地更新误污染生产后端数据库。

本文件只保留为当前计划入口，不作为计划正文。  
旧的 3.x / 4.x 阶段计划仅作为历史参考保留。
