# 项目长期记忆

## 当前主入口

- 当前有效文档索引：`docs/DOC_INDEX_CURRENT.md`
- 当前版本计划索引：`docs/version_plans/README.md`
- 当前运行手册索引：`docs/runbooks/README.md`
- 3.x 收口与后续计划交接稿：`docs/HANDOFF_3X_CLOSEOUT_20260417.md`
- 历史材料统一进入 `docs/archive/legacy_2026-04/`

## 当前基线

- 对外发布版本：`0.04.04 / 40400`
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
- `3.8` 已完成 stage 5 最终归档收口并通过顾问第二次验收：执行计划、风险评审、范围矩阵、缺口矩阵、校准报告、已知偏差、Beta 回归清单、验收报告、最终交接稿、截图证据索引、截图验收说明和第二次验收材料包都已落盘；参数联动区域已接入设置页并可直达高级解读页，正式截图已在 2026-04-17 刷新并统一到 `0.03.07 / 30700 / 0.03.07+30700` 口径；后续发布版本已升到 `0.04.02 / 40200`
- `3.9` 版本已正式归档收口；高级时法框架首版、细粒度解释层、截图证据索引、验收摘要与多 Agent 审查链均已落盘，Gemini 基于截图证据给出最终验收 `pass with observations`，3.9 已满足正式归档条件
- `3.9a` 收尾执行中，当前重点是高级时法页面的文案降噪、细粒度解释层证据补强与回归材料加厚；对应执行记录见 `docs/version_plans/3.9A_EXECUTION_NOTE.md`
- `3.9a` 验收材料已准备，建议验收口径为 `pass with observations`；摘要与核对清单分别见 `docs/version_plans/3.9A_ACCEPTANCE_SUMMARY.md` 和 `docs/version_plans/3.9A_ACCEPTANCE_CHECKLIST.md`
- `3.9B` 回归执行记录已补齐，当前回归材料已从保护面说明升级为执行记录，见 `docs/version_plans/3.9B_REGRESSION_EXECUTION.md`
- `3.9C` 当前只做边界说明收口，不改运行时契约；边界说明见 `docs/version_plans/3.9C_BOUNDARY_NOTE.md`
- `3.9C` 顾问短版已补齐，便于直接口头汇报与快速复查；见 `docs/version_plans/3.9C_BOUNDARY_BRIEF.md`
- `4.0` 基础能力基建版已启动；`4.0A` 领域边界与数据骨架已开始落地，执行记录见 `docs/version_plans/4.0A_EXECUTION_NOTE.md`
- `4.0B` 媒体基础线已形成：媒体配置、状态机与上传策略说明见 `docs/version_plans/4.0B_MEDIA_BASELINE.md`
- `4.0C` 队列与缓存最小闭环已落地：HTTP 触发 -> job -> 状态回写 -> cache 形成了可验证链路，见 `docs/version_plans/4.0C_PIPELINE_NOTE.md`
- `4.0D` Flutter 附件骨架已预留：聊天页加入附件底座说明卡与附件入口，见 `docs/version_plans/4.0D_ATTACHMENT_SKELETON.md`
- `4.0E` 可观测性与限流已补齐最小口径：新域 limiter、结构化日志与交付说明见 `docs/version_plans/4.0E_OBSERVABILITY_NOTE.md`
- `4.0` 总验收摘要已整理：完成 A/B/C/D/E 工作包，验证通过记录见 `docs/version_plans/4.0_ACCEPTANCE_SUMMARY.md`
- `4.0` 验收报告与多 Agent 审查日志已归档：见 `docs/version_plans/4.0_ACCEPTANCE_REPORT.md` 和 `docs/version_plans/4.0_MULTIAGENT_REVIEW_LOG.md`
- `4.0` 收尾补丁已把 `4.0B` 和 `4.0D` 补到原计划要求的最小完整闭环，补丁说明见 `docs/version_plans/4.0_PATCH_CLOSEOUT_NOTE.md`
- `4.0` 收尾补丁阶段没有新增 Claude / Gemini / 仓库 subagent 调用，验收以源码和测试自证为主
- `4.1` 非官方四维人格问卷版本已启动；`4.1A` 到 `4.1C` 已完成版本化问卷、结果闭环与历史/复测，`4.1D` 已把问卷摘要轻量接入首页与匹配页，并补了最小可观测性；执行记录见 `docs/version_plans/4.1D_EXECUTION_NOTE.md`
- `4.1` 收尾文档已补齐执行记录、验收摘要、交接说明、多 Agent 审查日志与截图证据索引；推荐验收口径为 `pass with observations`，相关材料见 `docs/version_plans/4.1_EXECUTION_NOTE.md`、`docs/version_plans/4.1_ACCEPTANCE_SUMMARY.md`、`docs/version_plans/4.1_HANDOFF_NOTE.md`、`docs/version_plans/4.1_MULTIAGENT_REVIEW_LOG.md`、`docs/version_plans/4.1_SCREENSHOT_EVIDENCE_INDEX.md` 和 `docs/version_plans/4.1_SCREENSHOT_VERIFICATION_NOTE.md`
- `4.1` 给 GPT 顾问的专用交接稿已经整理到 `docs/version_plans/4.1_GPT_ADVISOR_HANDOFF.md`；当前证据集已经从 compact pair 扩展为 full walkthrough，覆盖首页入口、问卷 q1/q2、提交后状态、结果路由、历史页、首页联动、匹配联动与 `0.04.02 / 40200` 版本中心页，旧的 `0.03.07` 版本中心截图已被替换
- `4.2` 图片消息正式接入版已正式通过；后端已经接入 `attachment_ids` 绑定消息与图片附件，Flutter 聊天页已支持选图、上传、发送、缩略预览与失败重试，walkthrough 证据包、验收摘要与 closeout 文档已补齐
- `4.2` 已进入正式归档收口阶段，后续如果继续只能从当前 additive 基线承接，不要回头改 4.2 主链
- `4.3` 动态流基础版已正式归档：`status_posts`、`status_post_likes`、`moderation_reports.target_status_post_id`、动态作者页和首页轻量联动已落地，walkthrough 证据包、验收摘要、handoff 与 closeout 已冻结，不要扩成视频 / 社区 / 推荐平台
- `4.4` 视频消息版已正式归档；归档口径为 `pass with observations`，walkthrough 成功态证据包、验收摘要、handoff、closeout 与多 Agent 审查日志均已补齐，会话列表摘要已稳定回读为 `视频消息`，禁止把它扩写成视频动态、RTC、通话或媒体平台化版本
- `4.4S` 媒体链稳定性修正版已完成：后端 `MediaAsset.public_url` 与 Flutter 媒体渲染层都已加上 URL 规范化兜底，旧数据里的 `localhost` / 相对路径会统一改写成当前可访问地址，目标是彻底修复图片 / 视频加载失败
- 2026-04-19 已恢复两条稳定烟测账号到生产后端：`17094346566` / `SmokeUser` 与 `13772423130` / `test1`。当前口令分别为 `1234567aa` 与 `zcx658023`；同时已把问卷题库、答题历史与当前周匹配记录恢复到可读状态，本次登录/匹配异常的直接原因是生产库状态缺失，而非 app 登录链本身损坏
- 版本号、检查更新和发版脚本必须绑定成同一条链：`apps/android/app/build.gradle.kts` 的 `versionName/versionCode` 是宿主真值，`/api/v1/app/version/check` 和 `scripts/release_android_update_aliyun.ps1` 必须与其同步；`PackageInfo` 读取到的 Flutter 模块版本只用于辅助展示，不得覆盖宿主版本。
- 发版时必须同步更新 `apps/android/app/src/main/assets/changelog_v0.txt`、`apps/flutter_elitesync_module/assets/config/about_update_0_xx.json`、`docs/CHANGELOG.md` 和 `docs/devlogs/RELEASE_LOG.md`，并在模拟器 / 真机上重新安装最新宿主包后再采集版本中心截图，避免旧包导致截图显示滞后。
- 禁止在正式运行时反馈 mock / 虚假信息 / 伪成功 / 伪错误状态；一旦发现任何会误导用户、掩盖真实错误或让退出/登录/消息/上传/恢复流程失真的 mock 反馈，必须优先清理并恢复真实链路。
- 不要把本地 SQLite / 临时数据库当成正式运行源；仓库中的 `*.db` / `*.sqlite` 只保留迁移、种子、备份和证据类文件，正式联调一律以远端服务端数据库为准。涉及任何数据库恢复、回填、重建或修复前，先确认不会覆盖生产数据。
- 任何数据库变更都必须先区分“本地开发库 / 远端生产库 / 备份快照”，默认不得在未确认的情况下修改远端数据库内容；如果需要恢复账号、题库或匹配，只能走显式恢复脚本或人工确认后的最小写入，不允许模糊覆盖。
- 本地环境默认只做前端开发、UI 联调与文档整理；后端开发、数据库迁移、备份、恢复和任何会写数据库的操作统一在阿里云端执行，避免本地更新误污染生产后端数据库。

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
- 若 Claude 因报错、预算、配额或不可用而无法执行其职责，或 Gemini 因额度不足、配额、不可用而无法执行其职责，应启用已授权的 subagent 代为承担相应的审查、验收或归档辅助职责，避免任务停摆。
- 对 4.0 及后续版本，同样适用上述 subagent 容错规则：Claude/Gemini 失效时，立即切换已授权 subagent 承担对应职责，不要让基础设施任务停摆。
- `4.4` 起必须优先冻结视频消息边界，复用既有媒体 / 消息主链，不得新造视频平行平台；当前 `4.4` 已正式归档且视频摘要语义已回读正确，后续只可在新版本计划书里继续扩展。

## 维护原则

- 新版本规划先更新当前索引，再补版本计划与交接稿
- 历史版本只保留归档，不再作为当前执行基线
- 资料、出生地、坐标、八字、紫微、星盘等字段以服务端真源为准，前端缓存只做兜底
