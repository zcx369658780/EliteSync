# 项目长期记忆

## 当前主入口

- 当前有效文档索引：`docs/DOC_INDEX_CURRENT.md`
- 当前版本计划索引：`docs/version_plans/README.md`
- 当前运行手册索引：`docs/runbooks/README.md`
- 3.x 收口与后续计划交接稿：`docs/HANDOFF_3X_CLOSEOUT_20260417.md`
- 历史材料统一进入 `docs/archive/legacy_2026-04/`

## 交接材料规范

- 同一版本的交接材料必须收敛为一个主交接文件，优先命名为 `*_HANDOFF_MASTER.md`。
- 其他验收、收尾、截图、门禁、执行、说明类文档可以继续保留为索引或引用，但对外上传 / 交接时默认只发送主交接文件。
- 若主交接文件不存在，先补主交接文件，再逐步把零散交接内容迁入其中，避免单次上传超过数量上限。
- 版本交接优先采用“1 个主文件 + 若干索引文件”的结构，不再默认拆成大量独立交接稿。

## 会话压缩规范

- 当前活动对话只保留一份短摘要文件，优先命名为 `CODEX_CURRENT_SESSION_SUMMARY.md`。
- 详细历史内容应迁入 `docs/archive/legacy_YYYY_MM/` 下的历史记录文件，避免当前工作树与上下文继续膨胀。
- 当前会话续接时，只需要读取短摘要文件 + 当前主交接文件 + 当前活跃版本索引即可，不再默认重读所有历史长文档。

## 当前基线

- 对外发布版本：`0.04.09 / 40900`
- 当前稳定阶段：`4.9`、`5.0`、`5.1` 均已按 `pass with observations` 收口；`4.9` 仍作为 `5.x` 的稳定门禁基线，`5.1` 是当前最新已验收版本。
- 当前主计划入口：`docs/DEVELOPMENT_PLAN_CURRENT.md`
- 当前 5.x 主计划：`docs/version_plans/elite_sync_整体开发计划书_5_x方向重排版_2026_05_01.md`
- 当前 5.x 路线图草案：`docs/version_plans/elite_sync_未来版本开发路线图草案_2026_05_01.md`
- 当前 4.9 主交接文件：`docs/version_plans/4.9_HANDOFF_MASTER.md`
- 当前 4.9 关键验收材料除 `4.9_HANDOFF_MASTER.md` 外已归档到 `docs/archive/legacy_2026-04/version_plans/`
- 4.9 的核心收口已经完成：现代 UI baseline、rollback / recovery policy、数据库正式演练、release gate、health、RTC / LiveKit 可观测性、通知降噪都已固化为门禁基线
- 4.9 的保留 observations 主要是：手机侧通知中心独立页仍可继续复测、版本中心 / 下载 / version check 的版本链可在后续再做一次彻底统一、可观测性深度可在 5.0 前继续加厚
- 5.x 当前主线已经从“基础能力补全”转为“产品化补强”：重点围绕 Discover / Chat / Me 的产品结构增强、AI 辅助层、首聊 / 回聊、关系推进、同城 / 搜索 / 轻治理动作，以及云端治理便利性提升。
- 5.0B 已开始进入 Discover 发现页产品化最小增强阶段，当前已补齐 Discover 默认态、搜索聚焦态、同城内容态与对应 UI 证据索引，作为后续产品化补强的当前落点。
- 5.0B Discover 已补齐执行记录与验收摘要，当前口径是：Discover 具备复合入口层雏形，但仍不应被扩成重推荐平台或重社区；后续实现应继续保持分栏、搜索、同城、轻治理的 additive 承接。
- 5.0C 已开始进入 Chat 关系推进最小增强阶段，当前已补齐会话列表、首聊 / 恢复建议、语音通话入口、附件入口与返回路径证据，作为后续首聊 / 回聊 / 关系摘要 / AI 轻按钮承接的当前落点。
- 5.0D 已开始进入 Me 个人经营页最小增强阶段，当前已补齐顶级身份区、账号状态、基础资料、资料完整度与资料同步提示证据，作为后续标签表达、内容经营、AI 建议与轻语音表达承接的当前落点。
- 5.0E 已形成 5.0 的统一验收与单文件交接材料，当前主交接入口切换为 `5.0_HANDOFF_MASTER.md`，并配套 `5.0_UI_BASELINE_EVIDENCE_INDEX.md` 与 `5.0_ACCEPTANCE_SUMMARY.md` 作为交接证据和收口摘要；顾问当前验收口径已提升为 `pass with observations`，后续保留的观察项仅为少量产品化细节；Me follow-up 证据已独立核验，覆盖 AI 助理 / 展示建议入口、内容标签区、资料真值链路与玄学入口，Chat 的关系摘要层也已形成用户面证据。
- 5.1 已形成统一验收与单文件交接材料，当前主交接入口为 `docs/version_plans/5.1_HANDOFF_MASTER.md`，验收口径为 `pass with observations`。5.1 已完成首聊 / 回聊 / 冷场恢复队列、匹配解释到聊天草稿联动、状态 / 动态低压回流、通知中心回流产品化、语音节奏和 RTC 未接通后回聊建议。保留 observations：Chat / Match / Status / Notification 证据仍需补齐，RTC success result 正式截图仍待补，`conversation_id / peer_user_id` 真实通知 payload 跳转方向仍待核验，`match_detail_page_test.dart` 可后续补测；这些观察项可拆给 5.2 或后续证据补采集，不阻断 5.1 收口。
- 5.x 验收提交经验补充：验收不能只看文档自报，必须让截图文件名、截图内容和页面实际内容三者一致；若证据链出现错绑 / 错传，必须先修正证据文件再谈升档，避免把 Chat 页证据误当成 Me 页证据。
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

## 远端 SSH 执行约定

- 远端命令必须优先使用显式 `C:\WINDOWS\System32\OpenSSH\ssh.exe`，不要依赖 PowerShell 别名或不透明包装。
- PowerShell 中调用 `ssh` 时，必须使用参数数组或显式 `--%` 原样透传，避免 `-o`、`-i` 等参数被 PowerShell 误解析。
- 推荐稳定模板：
  - 先把远端命令写成单独的 here-string
  - 再组装成 `$sshArgs = @('-o','BatchMode=yes','-o','StrictHostKeyChecking=no','-i',$KeyPath,'user@host',$remote)`
  - 最后调用 `& $env:WINDIR\System32\OpenSSH\ssh.exe @sshArgs`
- 以后凡是需要检查服务器端、抓日志、执行远端命令，默认都用这个模板，避免重复踩 PowerShell 参数解析坑。
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
- `4.5A` 通知与社交转化增强版已进入边界冻结与最小骨架阶段：通知中心、未读数、已读 / 全部已读、消息 / 动态 / 匹配 / 问卷历史 / 设置回流入口已建立，但不做厂商推送平台化、RTC、在线状态或消息 / 动态 / 匹配主链重构；`4.5E` 已补齐稳定的 live notification-center page screenshot，并完成归档收口
- `4.6` RTC / 通话基础设施版（语音优先）已进入 `4.6A` 边界冻结与依赖拆解阶段：当前只做 1v1 实时通话最小闭环的范围、风险、测试计划与可复用依赖整理，不做多人通话、直播、在线状态或推送平台化；本地环境继续只做前端开发、UI 联调与文档整理，后端写库统一在阿里云端执行
- `4.6B` 已完成 RTC 最小闭环实现：后端 RTC 会话域 / 事件域 / 状态机已落地，Flutter 通话入口页与通话页骨架已落地，通知中心已可回流到通话页；当前建议验收口径为 `pass with observations`
- `4.6C` 已补齐来电页与通话结果页壳层，通知中心可按 rtc_call 的 kind 分流到来电页 / 通话页 / 结果页；当前仍保持 1v1 语音优先骨架，不扩多人 / 直播 / 在线状态
- `4.6D` 已补齐通话前麦克风权限提示与异常恢复壳层：发起通话前会先校验权限，未授权时会引导到权限页或系统设置；依然只做 1v1 语音优先，不扩多人 / 直播 / 在线状态
- 2026-04-19 已恢复两条稳定烟测账号到生产后端：`17094346566` / `SmokeUser` 与 `13772423130` / `test1`。当前口令分别为 `1234567aa` 与 `zcx658023`；同时已把问卷题库、答题历史与当前周匹配记录恢复到可读状态，本次登录/匹配异常的直接原因是生产库状态缺失，而非 app 登录链本身损坏
- 2026-04-21 用户再次确认两条稳定烟测账号的当前口令：`17094346566` / `SmokeUser` 对应 `1234567aa`，`13772423130` / `test1` 对应 `zcx658023`；后续 smoke / regression / 联调优先复用这两个账号，不再沿用旧密码口径
- 版本号、检查更新和发版脚本必须绑定成同一条链：`apps/android/app/build.gradle.kts` 的 `versionName/versionCode` 是宿主真值，`/api/v1/app/version/check` 和 `scripts/release_android_update_aliyun.ps1` 必须与其同步；`PackageInfo` 读取到的 Flutter 模块版本只用于辅助展示，不得覆盖宿主版本。
- 发版时必须同步更新 `apps/android/app/src/main/assets/changelog_v0.txt`、`apps/flutter_elitesync_module/assets/config/about_update_0_xx.json`、`docs/CHANGELOG.md` 和 `docs/devlogs/RELEASE_LOG.md`，并在模拟器 / 真机上重新安装最新宿主包后再采集版本中心截图，避免旧包导致截图显示滞后。
- 禁止在正式运行时反馈 mock / 虚假信息 / 伪成功 / 伪错误状态；一旦发现任何会误导用户、掩盖真实错误或让退出/登录/消息/上传/恢复流程失真的 mock 反馈，必须优先清理并恢复真实链路。
- 不要把本地 SQLite / 临时数据库当成正式运行源；仓库中的 `*.db` / `*.sqlite` 只保留迁移、种子、备份和证据类文件，正式联调一律以远端服务端数据库为准。涉及任何数据库恢复、回填、重建或修复前，先确认不会覆盖生产数据。
- 任何数据库变更都必须先区分“本地开发库 / 远端生产库 / 备份快照”，默认不得在未确认的情况下修改远端数据库内容；如果需要恢复账号、题库或匹配，只能走显式恢复脚本或人工确认后的最小写入，不允许模糊覆盖。
- 本地环境默认只做前端开发、UI 联调与文档整理；后端开发、数据库迁移、备份、恢复和任何会写数据库的操作统一在阿里云端执行，避免本地更新误污染生产后端数据库。
- `4.6` 继续严守“本地前端-only、云端后端-only”的边界；RTC / 通话状态机、写库、迁移、备份、恢复和排障都必须优先在云端完成。
- `4.6F` 是 4.6 的 LiveKit 真语音接入子任务：保留现有 RTC 状态机，仅新增语音媒体层、join info 接口和 Flutter 连接壳层；不要把它扩成多人 / 直播 / 在线状态平台。当前真语音仍未闭合，通话可连但音频频谱仍在等待远端音轨，后续应把材料交给 GPT 顾问裁决，不要继续盲修主链。
- `4.6P` 已下发为音频播放链定向修正版：只盯“听到声音”这一 blocker，不再继续扩 UI 或重写 RTC 主链；当前已完成真语音可听闭环，建议按 `pass with observations` 收口，并保留模拟器反向发言链的最终复测作为观察项。
- `4.7` 已切换为测试前稳定化与质量门禁版：UI protected surfaces、rollback policy、baseline evidence 和 release gate 是硬门禁，任何构建 / 后端 / RTC / 媒体恢复都不得默认覆盖现代 UI。
- Android 模拟器 / 设备 UI 自动化优先使用 `Android-Debug-Bridge-MCP`（ADB native）；后续 Soul 拆解或类似竞品 UI 分析默认先复用这一 MCP，不与重叠的自动化方案同时并行安装，只有在该方案不稳定或不兼容时才评估 `mobile-next/mobile-mcp`。
- 阿里云端已拉起 LiveKit 自托管容器并写入 `LIVEKIT_*` 环境变量，`GET /api/v1/rtc/calls/{callId}/livekit` 已能返回可用 join-info；后续若继续，只能基于顾问裁决做最小收口，不要回头重写 RTC 状态机。
- RTC 断连收口采用“双方心跳 + 10 秒失联自动结束”机制：后端新增 `POST /api/v1/rtc/calls/{callId}/heartbeat`，并通过 `initiator_last_seen_at` / `peer_last_seen_at` 记录双方最后活跃时间；当 `connecting` / `in_call` 会话任一方失联超过 10 秒时，后端自动结束通话，避免 busy 残留。
- 2026-04-29 当前快照：发布基线已统一到 `0.04.09 / 40900`，4.9 测试前治理、限流、监控与发布链强化版已完成并按 `pass with observations` 收口；4.6P 真语音闭环、4.7 UI 保护面、4.8 Alpha smoke 与 4.9 release gate 的归档材料继续保留，CI 的 `AppVersionApiTest` 版本默认值已同步为 `0.04.09 / 40900`，根目录临时截图 / 视频样本只保留归档需要的正式证据，不再作为长期记忆输入。
- 2026-04-26 4.7 UI 回退事故后，仓库新增 `docs/PROTECTED_UI_SURFACES.md` 与 `docs/runbooks/ROLLBACK_AND_RECOVERY_POLICY.md`：恢复动作默认只能做路径级、文件级、最小范围；现代 UI（主导航、首页、消息页、聊天页、通知中心、匹配页、资料页、问卷页、版本中心、starry background / modern card / spacing）视为 protected surface，任何触碰都必须先 checkpoint 再恢复。
- 模拟器 / 设备联网排障时，不要通过修改 DNS 来“硬修”应用问题；优先做外部连通性检查、模拟器重启 / 冷启动 / 重建、以及系统网络恢复。DNS 只作为网络栈诊断对象，不作为常规修复手段或默认改动项。

## 星盘与资料链路

- 星盘计算与保存由服务端负责，绘制由 Flutter 本地完成
- 服务端只保存 / 返回 `chart_data` 等玄学真值，不再返回服务器绘制 SVG
- `astro_chart_preferences_v1` 仅影响本地展示，不得回写 canonical 真值
- `POST /api/v1/profile/basic` 保存后会返回重算后的 `astro_profile` 快照，前端应优先消费该快照

## 运行与接入

- Android 宿主启动 Flutter 时必须注入 `elitesync_api_base_url` 和 `elitesync_ws_base_url`
- Gemini CLI 默认模型改为 `gemini-3-flash-preview`，落点在 `~/.gemini/settings.json` 的 `model.name`
- 本机 Claude 已配置可调用 Deepseek V4；用户反馈其官方表现接近 Opus 4.6。后续涉及 Claude 的默认理解应按“本地 Claude 入口 + Deepseek V4 模型”处理，除非用户另行指定
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
- `4.6P` 执行时若需要 Claude 参与评审，默认按本机已配置的 Deepseek V4 入口理解，而不是旧的 Claude / Opus 口径。

## 维护原则

- 新版本规划先更新当前索引，再补版本计划与交接稿
- 历史版本只保留归档，不再作为当前执行基线
- 资料、出生地、坐标、八字、紫微、星盘等字段以服务端真源为准，前端缓存只做兜底
- 4.9 之后的交接材料默认只保留一个主交接文件（优先 `*_HANDOFF_MASTER.md`），对外上传 / 交接时默认只发主交接文件 + 必要索引，不再默认拆成大量独立交接稿
- 当前 Soul 拆解已完成首页、个人页、设置、聊天、发现模块的竞品分析；其中最值得 EliteSync 参考的方向是：
  - 发现页：推荐 / 同城 / 搜索 / 分享 / moderation 的复合入口层
  - 聊天页：首聊 / 回聊队列、关系摘要、AI 破冰、输入区轻集成
  - 个人页：资料展示 + AI 助理 + 内容经营 + 功能中心的综合中枢
  - 设置页：个人空间外观 / 主页背景 / 装扮面板与真实设置中心分层
  - 这些结论应作为 5.x 产品化补强的直接输入，而不是原样照搬 Soul 的商业化入口
