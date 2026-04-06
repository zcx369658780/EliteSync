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
- `flutter_svg` 已接入 Flutter 运行时，用于渲染 Kerykeion 返回的星盘 SVG 预览；依赖授权状态见 `LICENSE_DEPENDENCY_STATUS.md`。
- Kerykeion 已进入后端星盘服务集成评估链路，当前状态在 `LICENSE_DEPENDENCY_STATUS.md` 中标记为 `AGPL_PENDING_REVIEW`；若继续扩大到生产默认依赖，必须先完成商用影响复核与依赖链审计。
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



- 2.8 当前已落地最小运营后台 MVP：Flutter 侧新增隐藏的 dev 入口 `运营后台`，提供举报列表、举报详情、认证审核队列、用户列表的基础治理能力；详情页支持举报受理/调查/驳回/限制/封禁/恢复/关闭，治理入口保持与 canonical 匹配链路隔离。

- 2.8 运营后台已拆分为两条入口：
  - 运营后台：举报处理与用户治理
  - 认证审核：独立审核队列页，复用同一 moderation provider，但不再混在后台主页中
- 2.8 的 dev 验收支持通过 `ELITESYNC_INITIAL_ROUTE` 直达指定页面、通过 `ELITESYNC_ADMIN_MOCK=true` 注入后台 mock 数据，仅用于截图/验收，不影响生产 canonical 数据流。
- 2.8 的前台治理入口当前以两处为准：`ProfilePage` 的账号状态卡（实名/治理状态）和 `ChatRoomPage` 的右上角安全菜单（举报 / 拉黑）；这两处是 Gemini 监督验收中的 P0 可见入口。
- 2.8 已正式通过 Gemini 监督验收并结项；后续主线建议转入 `2.9`（Beta 上线准备），重点推进测试体系、性能与稳定性、安全与合规、灰度与运维。
