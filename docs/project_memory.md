# 项目长期记忆

## 当前主入口

- 当前有效文档索引：`docs/DOC_INDEX_CURRENT.md`
- 当前版本计划索引：`docs/version_plans/README.md`
- 当前运行手册索引：`docs/runbooks/README.md`
- 历史材料统一进入 `docs/archive/legacy_2026-04/`

## 当前基线

- 对外发布版本：`0.03.09 / 30900`
- 当前阶段结论：`3.5` 已正式验收通过并归档
- `3.6` 已进入计划执行阶段，stage 0、stage 1 与 stage 2 已完成
- `3.6` stage 3 也已完成：路线解释层已落地为轻量阅读卡，设置页补齐路线差异报告，本命盘详情页保留 compact 解释卡
- `3.6` stage 4 也已完成：多路线样例集与已知偏差归档已补齐，能力矩阵、差异报告、样例集三件套闭环
- `3.6` stage 5 也已完成：最终验收报告、最终交接稿、截图证据索引已补齐，可直接进入顾问归档链路
- `3.6` 的多 Agent 证据补充已单独落盘，Claude / Gemini 的阶段性审查结论可直接从 `3.6_MULTIAGENT_EVIDENCE_SUPPLEMENT.md` 读取
- 后续若继续迭代，应从 `3.6` 的稳定基线开始；`3.5` 仅作为已完成历史基线保留
- `3.6` 主线是古典 / 现代双路线版，新增 `route_mode` 与路线能力矩阵，但仍保持 canonical 真值只增不改
- `route_mode` 已作为 additive display context 落到 FastAPI / Laravel `/astro`、`/summary`、`/chart`、`/render` 返回体中，`metadata.route_context` 与 `field_roles.display_only` 已同步；旧缓存保持兼容，`chart_data` 未变
- 路线解释层与 parity report 都必须维持 derived-only / display-only，不得回写 canonical truth
- 多路线样例集和已知偏差文档必须与 capability matrix 保持一致，不得把 derived 差异写成算法 bug
- 3.6 的 stage 5 归档材料已经齐备，当前可作为后续 3.7 的稳定基线参考
- `3.7` 已进入 stage 0 拆解：执行计划、风险评审、范围矩阵和高级能力矩阵已落盘
- `3.7` 只纳入合盘 / 对比盘、行运和一项最小返照能力，所有高级能力都必须保持 derived-only / display-only / advanced-context 口径
- `3.7` stage 1 已完成架构边界收口：`route_mode` 继续作为 display-only，`pair_context` / `time_context` / `return_context` / `comparison_context` 归入 advanced context，`chart_data` 不改写
- 当前阶段的正式并行评审受 agent 线程上限限制，已先用本地代码检索与文档审查补齐 stage 1 边界结论，后续再补 Claude / Gemini 留痕
- `3.7` stage 2 已开始并落地后端 scaffold：FastAPI 新增 `/api/v1/profile/astro/pair`、`/transit`、`/return`，Laravel 也补了对应代理入口；高级能力仍保持 derived-only / display-only / advanced-context 口径
- `3.7` stage 3 已开始并落地 Flutter 侧高级预览卡与高级详情页：新增 `astro_advanced_profile_provider.dart`、`AstroAdvancedCapabilityCard` 与 `AstroAdvancedPreviewPage`，在玄学总览页展示合盘 / 行运 / 返照 scaffold 预览并提供高级入口
- `3.7` stage 4 已完成高级演示页与样例矩阵补证：`AstroAdvancedPreviewDemoPage`、路线能力矩阵、样例集和已知偏差已形成 stage 4 / stage 5 的交接基础
- `3.7` stage 5 已完成最终验收：`3.7_ACCEPTANCE_REPORT.md`、`3.7_HANDOFF_FINAL_20260412.md` 与 `3.7_SCREENSHOT_EVIDENCE_INDEX.md` 为当前交接材料
- `3.8` 已完成 stage 5 最终归档收口并通过顾问第二次验收：执行计划、风险评审、范围矩阵、缺口矩阵、校准报告、已知偏差、Beta 回归清单、验收报告、最终交接稿、截图证据索引、截图验收说明和第二次验收材料包都已落盘；参数联动区域已接入设置页并可直达高级解读页，正式截图已在 2026-04-17 刷新并统一到 `0.03.07 / 30700 / 0.03.07+30700` 口径；后续发布版本已升到 `0.03.09 / 30900`
- `3.9` 版本已正式归档收口；高级时法框架首版、细粒度解释层、截图证据索引、验收摘要与多 Agent 审查链均已落盘，Gemini 基于截图证据给出最终验收 `pass with observations`，3.9 已满足正式归档条件

## 星盘与资料链路

- 星盘计算与保存由服务端负责，绘制由 Flutter 本地完成
- 服务端只保存 / 返回 `chart_data` 等玄学真值，不再返回服务器绘制 SVG
- `astro_chart_preferences_v1` 仅影响本地展示，不得回写 canonical 真值
- `POST /api/v1/profile/basic` 保存后会返回重算后的 `astro_profile` 快照，前端应优先消费该快照

## 运行与接入

- Android 宿主启动 Flutter 时必须注入 `elitesync_api_base_url` 和 `elitesync_ws_base_url`
- Gemini CLI 默认模型改为 `gemini-3-flash-preview`，落点在 `~/.gemini/settings.json` 的 `model.name`
- 直接在 PowerShell 中调用 CLI 的默认方式是：
  - `claude -p "<prompt>" --output-format text --tools ""`
- `gemini -p "<prompt>" --output-format text --approval-mode plan`
- 如果需要结构化输出，可用：
  - `gemini -p "<prompt>" --output-format json --approval-mode plan`
- `claude` 默认命令应命中 `C:\Users\zcxve\.local\bin\claude.exe`
- `Get-Command claude` / `Get-Command gemini` 可用于确认当前直连入口
- 当前不再把 Claude-mcp / Codex-mcp 作为默认工作流入口
- Gemini 网页版仅用于临时浏览或探索，不作为 3.9 及后续版本的验收默认入口；验收与审查回到 PowerShell 直连 `gemini` CLI。

## 维护原则

- 新版本规划先更新当前索引，再补版本计划与交接稿
- 历史版本只保留归档，不再作为当前执行基线
- 资料、出生地、坐标、八字、紫微、星盘等字段以服务端真源为准，前端缓存只做兜底
