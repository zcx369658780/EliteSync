# 项目长期记忆

## 算法与接口总文件

项目内保留一份持续维护的总文件，用于记录：

- 全部算法信息
- 全部数据条目接口
- 用户字段与数据类型
- 关键 API 入口
- 兼容层与废弃项
- 与顾问对接所需的版本基线材料

每次版本更新后，必须优先更新这份总文件，再生成下一版规划或对外简报。

## 维护原则

- 只保留一份“当前版本总基线”文件作为主入口。
- 新版本规划必须以这份总基线为准。
- 历史版本只保留必要的归档，不再作为主对接材料。
- 若算法或数据接口发生变化，先更新总文件，再更新索引和版本规划。
- 百度地图配置已拆分为两套，不要再共用同一个 AK：
  - Android SDK AK：仅用于 Android `local.properties`
  - Web 服务 AK / SK：仅用于后端 `.env` 的地点搜索与地理编码签名
- 百度地图 Android 安全码当前固定为 `BB:BB:BF:79:60:8A:22:F4:E4:DA:86:5E:38:07:CC:EC:03:98:EB:7C;com.elitesync`，仅用于百度控制台与应用包名 / SHA1 绑定记录。
- 当前 Android 侧百度地图包体使用 `BaiduLBS_Android_4195.zip` 对应的 `8.0.0` SDK 物料；后续如继续升级百度 SDK，必须同步更新 `LICENSE_DEPENDENCY_STATUS.md` 和相关配置说明。
- `flutter_svg` 已接入 Flutter 运行时，用于渲染 APP 本地根据服务端 `chart_data` 生成的星盘 SVG；依赖授权状态见 `LICENSE_DEPENDENCY_STATUS.md`。
- Kerykeion 仍作为后端星盘计算引擎使用，当前状态在 `LICENSE_DEPENDENCY_STATUS.md` 中标记为 `AGPL_PENDING_REVIEW`；若继续扩大到生产默认依赖，必须先完成商用影响复核与依赖链审计。
- 玄学详情页的展示偏好使用本地持久化 key `astro_chart_preferences_v1`，仅影响 Flutter 渲染，不得回写 canonical 画像数据；如新增显示项开关，优先扩展该本地偏好而不是改服务端真值。
- 发布烟测脚本允许在固定回归账号失效时自动注册一个非真实号段的临时 synthetic 账号自举 auth chain；fallback 注册应支持重试，成功后必须在 smoke log 中显式记录 fallback 账号，并在完成 auth chain 后尝试自删，且不得将其视为 canonical 用户数据或进入匹配主流程。
- 当前后续主线版本建议按 `2.6.4 -> 2.7 -> 2.8 -> 2.9` 推进，其中 `2.6.4` 定位为“稳定性与发布门禁收口版”：
  - 重点不是继续扩玄学功能，而是稳住 `profile/basic -> summary/chart -> 四大玄学页` 链路。
  - 必须显式保护的 surfaces 包括：数据库初始化 / migration / 登录态恢复 / 地点搜索 / `POST /api/v1/profile/basic` / `GET /api/v1/profile/astro/summary` / `GET /api/v1/profile/astro/chart` / 玄学四页路由。
  - `2.6.4` 的完成标准以可重复回归、可执行回滚、可验收门禁为主，不以页面数量或新功能为准。
  - `2.6.4` 还要求把 `ROLLBACK_PLAN.md`、`RELEASE_SMOKE_CHECKLIST.md`、`REGRESSION_CHECKLIST.md`、`POST_CHANGE_ACCEPTANCE.md` 作为默认发布门禁材料，后续所有高风险版本沿用。
- 版本开发计划统一归档到 `docs/version_plans/`，不再把 `bazi_example/` 作为活跃计划目录；后续新增/修订的版本计划与执行清单，应优先写入 `docs/version_plans/` 并同步更新 `docs/DOC_INDEX_CURRENT.md`。
- `2.7` 版本已完成主流程骨架与慢约会仪式感收口，并通过 Gemini 监督验收；其最终交接与截图已整理为 `reports/elite_sync_2_7_handoff_20260406.md`。2.8 起建议转入“信任安全与运营后台”主线，继续围绕数据安全、运营效率和真实用户规模接入做规划。
- `2.8` 版本定位为“信任安全与运营后台补完版”，核心是举报 / 拉黑 / 封禁 / 申诉闭环、认证架构占位与人工审核链路、运营后台 MVP、内容审核最小闭环、以及最小事件埋点与核心指标看板；默认不大改前台匹配体验主流程、不重构聊天底层、不大改数据库核心 schema。
- `2.8` 起，前台安全出口以 `moderation_reports` / `user_blocks` 为主：举报、拉黑、申诉、工单处理都应走这套最小治理表；用户总体治理状态使用 `users.moderation_status` / `users.moderation_note`，`disabled` 仅作为强制停用兼容字段。
- `2.8` 的聊天安全拦截规则：如果双方存在 `user_blocks` 记录，则 `MessageController` 必须直接返回 `chat blocked by moderation`，不再继续走匹配可聊校验。
- `2.8` 的后台可先复用现有 `admin.phone` 保护网关扩展 `admin/reports`、`admin/users`、`admin/verify-queue`，不必一开始重建独立 RBAC；前台则优先在聊天页提供举报 / 拉黑入口，先把安全出口接通。
- `2.8` 已正式通过 Gemini 监督验收并结项；后续主线建议转入 `2.9`（Beta 上线准备），重点推进测试体系、性能与稳定性、安全与合规、灰度与运维。
- `2.9` 的正式开发计划已落地到 `docs/version_plans/elite_sync_2_9_正式开发计划书.md`，当前阶段先执行阶段 1：冻结边界、补齐回归清单、固化保护面。
- `2.9` 阶段 2 的真实链路联调记录已开始落盘到 `docs/version_plans/2.9_STAGE2_REAL_CHAIN_LOG.md`；当前已确认资料保存链路、匹配主链路可达，消息链路路由存在但模拟器上仍待补测稳定跳转。
- `2.9` 阶段在真实设备 / 模拟器验收 Flutter 页面时，必须优先构建并安装 `apps/android` 的 host APK（`com.elitesync`），不要把 `apps/flutter_elitesync_module` 的独立构建产物误当作最终运行时包；如果出现“源码已改但设备仍显示旧 UI”，先排查是否装错产物或旧包未卸载。
- `2.9` 阶段为减轻首进压力，`AppShell` 的 warmup 应尽量只预热当前初始路由对应的 provider，避免一次性 warm 多个顶层 provider 把启动负担放大；`performanceLiteMode` 仍然是首选回退开关。
- `2.9` 阶段的首页内容加载必须优先保证“可见性”，如果 banner / shortcuts / feed 在真实环境连续超时，应在数据源层短超时兜底并回落到 mock/快照，避免把首页拖成长白屏；不能把长时间等待当成可接受的 Beta 体验。
- `2.9` 阶段的匹配链路也要短超时兜底：`/api/v1/matches/current`、`/api/v1/match/current`、`/api/v1/matches/{id}/explanation`、`/api/v1/match/{id}/explanation` 这类首进/解释请求不应在慢网下长期阻塞门户页；必要时要快速退回到本地可见状态。
- `2.9` 阶段的资料页与地点搜索同样要短超时兜底：`/api/v1/profile/basic`、`/api/v1/geo/places` 不应在慢网下长期挂起；编辑资料与出生地搜索要尽快给出可见反馈或本地兜底结果，避免用户误以为页面死掉。
- `2.9` 阶段的消息链路也要短超时兜底：`/api/v1/match/current`、`/api/v1/match/history`、`/api/v1/messages` 在慢网下不应长期挂起；会话页优先给出快照或明确错误态，不要让消息入口长时间空等。
- 当前对外发布版本已对齐到 `0.03.02a`，版本号、版本检查默认值、更新说明与 APK 文件名必须同步按 `0.03.02a / 30201` 维护；`0.03.01` / `0.03.02` 仍保留为历史 compact 编码。
- 当前项目总交接文档已另存为根目录 `PROJECT_HANDOFF_20260407.md`，后续 Claude / Gemini / GPT 顾问交接优先引用该文件。
- `2.9` Beta 准备新增最小健康检查入口 `/api/v1/app/health` 与关于页服务状态卡，仅用于 Beta 可观测性，不得替代 smoke / regression / release gate，也不得成为第二真源。

## 开发工作流长期记忆

- 任何非微小任务，默认必须先进入 plan-first 流程。
- plan-first 阶段必须并行启动四个只读 subagent：
  1. `dependency-mapper`
  2. `risk-reviewer`
  3. `test-planner`
  4. `architecture-guardian`
- 只有在上述评审完成后，主线程才能汇总计划并进入实现。
- 涉及数据库、地图定位、权限、迁移、配置、第三方 SDK、状态持久化的任务，必须先确认备份/回滚点与最小回归清单。
- `2.6.4` 起，玄学模块与资料录入模块的所有 UI/状态改动，默认先检查 `summary/chart` 是否被拖累，且必须在验收报告里单列“保住了什么 / 丢了什么 / 未验证什么”。
- 实施阶段默认只允许一个 `implementation-worker` 写入同一批改动。
- 修改完成后，必须并行启动：
  1. `acceptance-auditor`
  2. `regression-sentinel`
  3. `test-planner` 复核验收覆盖
  4. `architecture-guardian` 复核结构边界
- 任一验收 subagent 输出 `fail`，必须进入修复轮次，不能直接宣告完成。
- 需要创建 PR 时，必须先经过 Code Review，并获得用户明确同意后再发起 PR。

## 高风险模块永久保护

- 本地数据库 / 远端数据库 / 迁移 / 初始化
- 地图、定位、权限、坐标刷新、逆地理编码
- 路由跳转、按钮事件、状态管理、页面生命周期
- 配置文件、环境变量、第三方 SDK 接入点
- 自动备份、恢复、版本升级脚本


- `2.9` 的 Beta 运维文档与灰度收口（范围边界、烟测清单、发布清单、环境矩阵、运营 SOP、应急手册、回滚演练、日报模板、观测与告警）已统一落盘到 `docs/version_plans/`；当前 2.9 剩余工作主要围绕性能 / 观测 / 灰度 / 运维收口。
- `2.9` 阶段已完成弱网抽检（GSM/GPRS 限速），首页、消息页、匹配页均能明确出壳，相关截图保留为 `D:/EliteSync/2_9_weaknet_home.png`、`D:/EliteSync/2_9_weaknet_messages.png`、`D:/EliteSync/2_9_weaknet_match.png`；后续 Beta 回归默认把这类弱网首进验证列为固定项。
- `2.9` 阶段已完成一次灰度演练 dry run，脚本 `scripts/run_23_gray_rehearsal.ps1` 在 `BaseUrl=http://101.133.161.203` 且登录成功的前提下执行通过，生成报告 `reports/explanation_snapshot_diff/gray_rehearsal_2_3_latest.md`；后续灰度回归默认保留该脚本作为最小门禁证据之一。
- `2.9` 阶段已完成连续切页稳定性抽检（弱网下 3 轮首页 / 消息 / 匹配 / 首页），无白屏、无卡死，截图保留为 `D:/EliteSync/2_9_nav_cycle_final.png`；后续 Beta 回归默认把连续切页稳定性列为固定项。
- `2.9` 阶段已完成回滚 dry run，回滚点与回滚后最小验收路径已确认，记录保留为 `docs/version_plans/2.9_ROLLBACK_DRY_RUN_20260408.md`；后续 Beta 回归默认把回滚 dry run 当作固定门禁证据。
- `2.9` 阶段已完成 health / version/check 的大样本压力抽检（100 轮），两项接口均 0 失败、无明显慢请求；后续 Beta 回归默认把这类大样本压力抽检列为固定量化门槛。
- `2.9` 阶段已完成最终 Beta 收口摘要落盘到 `docs/version_plans/2.9_BETA_FINAL_SUMMARY.md`；当前剩余事项已收敛为真实 Beta 流量观测与运营实战，不再是代码或门禁缺口。
- `2.9` 阶段已完成最终验收报告落盘到 `docs/version_plans/2.9_GEMINI_FINAL_ACCEPTANCE.md`；当前可直接交给 Gemini 做最终验收归档。
- 2.0 及更早版本的早期开发计划已统一归档到 `docs/archive/legacy_2026-04/DEVELOPMENT_PLAN_2_0_AND_EARLIER_ARCHIVE.md`，根目录 `DEVELOPMENT_PLAN.md` 仅保留为兼容入口，不再作为活跃执行计划。

- 3.1 的最终交接截图已从根目录移至 docs/archive/legacy_2026-04/3.1_evidence/，后续仅通过主交接文件与归档目录引用。
- `3.2` 的默认执行顺序固定为：测试账号体系底座 -> 账号可观测与管理 -> 玄学 correctness 修复 -> 匹配与首聊转化 -> 广场轻分层 -> 回归与验收归档。
- `astro_chart_preferences_v1` 现在同时承载两类本地展示偏好：下方摘要显示与盘面元素显示；盘面元素已经细分到星座分区线 / 星座文字 / 宫位线 / 宫位编号 / 相位连线 / 行星连线 / 行星点位 / 行星文字 / 盘心标题 / 盘心时间 / 盘心地点 等本地 SVG 开关，且不得回写后端 canonical 真值。
- 星盘设置页已提供“恢复默认”按钮，用于一键恢复推荐展示状态，便于验收与回归时对齐标准构图；该操作仍只影响本地偏好，不得改变后端真值。
- 星盘设置页已新增本地预设档位：`完整版 / 平衡版 / 极简版`，用于快速切换盘面观感；预设只影响 Flutter 本地 SVG 绘制与摘要显示，不得回写后端 canonical 真值。
- `3.2` 的核心保护面固定为：注册 / 登录、基础资料保存、出生地搜索、画像重算、匹配解释、每周匹配、首聊 / 会话、状态发布 / 广场、管理员控制面、synthetic batch 创建与清理，以及 3.1 已通过能力。
- `3.2a` 已作为 `0.03.02a / 30201` 对外发布版本完成收口，正式交接入口为 `docs/version_plans/3.2a_HANDOFF_FINAL_20260410.md`；星盘算法进一步拆分与测测级功能复刻已冻结，等待顾问就 `ASTRO_ALGORITHM_HANDOFF_20260410.md` 给出可行反馈后再推进。
- `3.2` 的测试账号体系必须严格分层为 `normal / test / synthetic`，其中 `synthetic` 默认 `exclude_from_metrics = true`，且支持 batch create / rebuild / cleanup / disable。
- `3.2` 阶段 1 已启动账号分层底座实现：`users` 已新增 `synthetic_batch_id / synthetic_seed / generation_version / account_status / visibility_scope / cleanup_token` 等批次审计字段，`app:dev:sync-account-tier` 和 `app:dev:synthetic-users` 已支持按批次生成 / 重建 / 清理，Admin 用户列表开始展示批次与生成元信息。
- `3.2` 阶段 1 的 Admin 用户列表已升级为客观治理视图：支持按 `account_type / synthetic_batch / account_status / visibility_scope / is_synthetic` 等字段筛选，并在列表卡片上展示 `Batch / Type / Version / Scope / Status / Match / Square / Metrics / Seed` 等审计元信息，用于核对账号分层、广场可见性与指标隔离。
- `3.2` 阶段的玄学页文字修正以“减少误导”为原则：八字页底部技术参数不再重复展示同一 `accuracy` 值，保留 `位置来源 / 引擎 / 置信` 三段，避免把同值重复标成不同概念。
- `3.2` 阶段的玄学术语对齐规则：星盘 / 紫微 / 八字 / 盘面设置页统一将 `precision` 类字段对外展示为“版本”或“可信度”，不要再把版本、模式、置信度混写成“精度”。
- `3.2` 阶段的广场轻分层已启动：首页状态广场预览与广场页统一展示作者层级 / 可见层级标签，区分公开层 / 广场层 / 私密层，后续继续补可见性治理与审核视图。
- `3.2` 阶段的匹配与首聊转化已补强：匹配结果页的行动建议已改成可点击开场草稿卡，点击后会把话题写进聊天草稿并跳到会话页；聊天页顶部破冰卡也已改成可点建议，用于开场与沉默后的恢复接话。
- `3.2` 已补出阶段性验收草稿 `docs/version_plans/3.2_ACCEPTANCE_REPORT.md`，当前口径为“核心底座已落地、Flutter acceptance smoke 已通过、仍待补最终截图验收”。
- `3.2` 当前已确认 `apps/android :app:assembleDebug` 通过、后端定向回归通过（`AdminApiTest` / `DevSyntheticUsersCommandTest` / `DevSyncAccountTierCommandTest`），Flutter acceptance smoke 已通过；`flutter analyze` 目前可运行但仍存在少量 lint/info，正式归档前建议补最终截图验收与必要的 lint 收口。
- `3.2` 已补充单文件阶段交接 `docs/version_plans/3.2_HANDOFF_STAGE_20260410.md`，后续如果要继续推进或交接，应优先引用这份摘要，而不是继续翻散落的执行文档。
- `3.2` 最终交接入口已收敛为 `docs/version_plans/3.2_HANDOFF_FINAL_20260410.md`，作为对顾问交付时的主入口；其余执行 / 验收 / 风险文档保留为附录和追溯材料。
- `3.2` 的关键截图证据已在 `emulator-5554` 重新补齐，根目录当前证据文件包括 `3_2_home.png`、`3_2_match_result.png`、`3_2_admin_users.png`、`3_2_status_square.png`，以及聊天页辅助证据 `_chat_room.png`。
- `3.2` 最终闭环已补足三处残余风险：匹配结果缓存保留 `matchId / partnerId`、Admin 封禁同步 `is_match_eligible / is_square_visible / exclude_from_metrics`、状态广场作者层级改为优先读 `is_synthetic` 真源；对应后端 / Flutter / acceptance tests 已回归通过。
- `3.2` 最终交接稿已收敛为 `docs/version_plans/3.2_HANDOFF_FINAL_20260410.md`，后续对 GPT 顾问或其他外部审阅的默认入口应优先引用该文件和 `3.2_ACCEPTANCE_REPORT.md`。
- `3.2` 终验补证包已落盘到 `docs/version_plans/3.2_TERMINAL_EVIDENCE_PACK_20260410.md`；其中默认 synthetic 池真实落地为 1000 条，独立临时 SQLite 里也验证过 10000 扩展路径能力。
- `3.2` Admin 统计口径明确为：`测试账号 = account_type == test`，`合成用户 = is_synthetic == true`，两者可以重叠，不要把卡片数量理解成互斥分组。
- `3.2` 出生地点链路优先以服务端 `GeoController` / `DevFillSyntheticAstroProfilesCommand` 为真源；若 Baidu live 复核临时不可用，以此前已验证的候选返回与代码链路作为补证材料。
- Android host 启动 Flutter 时必须把 `elitesync_api_base_url` / `elitesync_ws_base_url` 注入到 bootstrap extras，Flutter 端不要只依赖 `slowdate.top` 的隐式回退；以后排查 `Request Timed out`，优先确认 APK 是否为宿主包以及 bootstrap 是否已经注入正确基线地址。
- Gemini CLI 当前仓库级默认模型固定为 `gemini-2.5-flash`；若继续调用外部验收，优先按该默认值执行，避免在多配置来源之间漂移。
- Gemini 省 token 的实践：验收时优先传小尺寸截图，UI 识别不需要 4K 原图，控制在 `1024x1024` 以下更合适；只在需要时才扩大输入。
- Gemini 成本监控可按 response 的 `usage_metadata` 统计 `prompt_token_count` / `candidates_token_count` / `total_token_count`，再按当时价格计算预估费用；价格若变动，要同步更新这条记忆。
