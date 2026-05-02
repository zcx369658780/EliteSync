# EliteSync 项目总交接稿（当前基线）

更新时间：2026-05-02

本文档是 EliteSync 当前阶段的总交接主入口，用于统一说明：
- 当前做到哪里了
- 各方向的进度
- 当前算法与数据真值
- 当前接口与调用链
- 后续版本应如何接续

## 1. 当前基线

- 对外发布版本：`0.04.09 / 40900`
- 当前已完成并验收版本：`5.1`
- 当前有效文档索引：`docs/DOC_INDEX_CURRENT.md`
- 当前版本计划索引：`docs/version_plans/README.md`
- 当前运行手册索引：`docs/runbooks/README.md`
- `3.8` 已推进到 stage 5 回归与归档完成：参数联动区域、校准报告、已知偏差、Beta 回归清单、验收报告、最终交接稿、截图证据索引与截图验收说明已经落盘，Gemini CLI 已对截图验收说明给出 `pass`
- `3.9` 已正式归档收口：高级时法框架首版、细粒度解释层、截图证据索引、验收摘要与多 Agent 审查链已经完成，顾问口径为 `pass with observations`
- `4.0` 已正式归档通过：领域骨架、对象存储主路径最小闭环、媒体状态机、队列/缓存闭环、附件状态骨架与最小可观测性已完成
- `4.1` 已正式归档通过：非官方四维人格问卷、历史记录、复测、主页/匹配轻量联动与 walkthrough 证据链已完成
- `4.2` 图片消息正式接入版已正式通过：图片选择、上传、附件绑定、图片消息发送、图片气泡展示、预览与最小 telemetry 已完成，walkthrough 证据包、验收摘要与 closeout 文档已补齐
- `4.3` 动态流基础版已正式归档：动态主链、轻互动、治理挂点、首页 / 作者页轻量联动已落地，walkthrough 证据包、验收摘要、handoff 与 closeout 已冻结
- `4.4` 视频消息版已正式归档：聊天中的单视频消息最小闭环、成功态 walkthrough 证据包、验收摘要、handoff 与 closeout 已完成，会话列表摘要已稳定回读为 `视频消息`，归档口径为 `pass with observations`，不要再回头扩写成视频动态、RTC、通话或媒体平台化版本
- `4.4S` 媒体链稳定性修正版已完成：`public_url` 规范化、图片 / 视频内容端点与读取兜底已修复，历史媒体资源已恢复可读，作为 4.4 的稳定性收尾已纳入当前发布版本
- 历史材料：统一归档到 `docs/archive/legacy_2026-04/`
- 当前 5.1 主交接入口：`docs/version_plans/5.1_HANDOFF_MASTER.md`
- 当前 5.1 状态：`pass with observations`
- 下一阶段承接方向：`5.2`，不重复建设 5.1 已通过能力，优先承接观察项小单与个人经营页 / 表达层增强。

## 2. 项目主线概览

EliteSync 当前主线已经从“能跑”进入“正式化收口 + 版本化治理”阶段，核心方向如下：

1. 账号体系与治理
   - test / synthetic / normal 分层清晰
   - Admin 客观治理视图可查批次、版本、可见性、指标排除
2. 资料与画像
   - 保存资料后由服务端重算 canonical 真值
   - 前端优先消费保存响应，再刷新详情
3. 玄学链路
   - 星盘、八字、紫微等均以服务端真值为准
   - Flutter 端本地绘制星盘 SVG，不再把绘制当成服务端输出
4. 匹配与转化
   - 匹配解释、首聊草稿、会话入口已完成转化增强
5. 设置与版本中心
   - 设置中心、盘面设置、版本中心已产品化
6. 发布与回归
   - health / version check / smoke / regression / rollback 已纳入固定门禁

## 3. 各方向进度

### 3.1 账号与治理

已完成：
- 用户分层：`normal / test / synthetic`
- synthetic 批次生成、重建、清理、停用
- Admin 用户列表的批次审计信息
- synthetic 默认排除指标口径 `exclude_from_metrics = true`

当前状态：
- 可以支撑 Beta / smoke / regression / 运营抽检
- 合成账号与测试账号口径已明确可重叠，不是互斥分组

### 3.2 资料与画像

已完成：
- `POST /api/v1/profile/basic` 保存后会返回重算后的 `astro_profile`
- Flutter 编辑页优先消费保存响应，再做缓存刷新
- 资料页、画像页、星盘页的“真值优先”口径已统一

当前状态：
- 资料编辑 -> 服务端重算 -> 页面刷新链路已闭环
- 资料与玄学显示层已经从“猜测状态”转成“消费 canonical 快照”

### 3.3 星盘 / 八字 / 紫微

已完成：
- 服务端星盘链路只负责计算与保存，不再负责 SVG 绘制
- Flutter 本地根据 `chart_data` 绘制星盘
- 星盘设置页支持本地元素开关、预设、恢复默认
- 星盘阅读性提示、版本口径、说明卡已补齐

当前状态：
- 当前主实现使用 `kerykeion==5.12.7`
- `astro_chart_preferences_v1` 只影响 Flutter 本地展示
- 星盘 canonical 算法仍然冻结，不做高风险大改

### 3.4 匹配与转化

已完成：
- 匹配解释与分项结构增强
- 匹配结果到首聊的草稿转化
- 会话入口与破冰建议可点击
- 旧功能未被误伤的回归门禁已保留

当前状态：
- 主链路稳定，可作为 Beta 基线
- 当前重点是稳定性与解释性，而不是再扩大发现面

### 3.5 设置中心与版本中心

已完成：
- 设置中心结构产品化
- 盘面设置、隐私设置、性能偏好、Beta 运营准备说明都已归位
- 版本中心统一了当前版本、服务状态、更新历史、健康检查的口径

当前状态：
- 设置与版本页已不再是临时调试页
- 服务状态定位为可观测性，不是业务真值

### 3.6 发布 / 运维 / 文档

已完成：
- 版本号、更新说明、APK 文件名已收口到 `0.04.09 / 40900`
- `docs/` 当前入口、规划、runbooks、reference、licenses、devlogs 已统一索引
- 历史材料已迁移到 `docs/archive/legacy_2026-04/`

当前状态：
- 新版本规划可以直接从 `docs/DOC_INDEX_CURRENT.md` 进入
- 当前文档体系已经具备长期维护的骨架

## 4. 当前算法与真值链路

### 4.1 资料与画像 canonical 真值

主真值来源：
- `users`
- `user_astro_profiles`

关键规则：
- `POST /api/v1/profile/basic` 保存后必须触发服务端重算
- 前端只消费最新保存响应或详情接口结果
- 前端缓存只能兜底，不能抢真值

### 4.2 星盘计算

当前路线：
- 服务端计算
- Flutter 本地绘制

当前使用的 Python 依赖：
- `kerykeion==5.12.7`

当前数据形态：
- `chart_data`
- `planets`
- `houses`
- `aspects`

当前规则：
- 服务器不再生成最终 SVG 作为主路径
- 盘面元素开关只影响本地展示，不影响 canonical 真值

### 4.3 匹配算法

当前匹配体系以多模块评分为主，包含：
- personality
- MBTI
- astro
- bazi
- zodiac
- constellation
- natal_chart
- ziwei
- pair_chart

核心要求：
- 模块分项要可解释
- 匹配解释要能回溯证据标签
- 首聊 / 行为转化要能从解释页导流

### 4.4 synthetic 与治理算法

当前规则：
- synthetic 默认排除指标
- batch 级别记录生成版本、seed、batch_id、可见性
- Admin 视图显示治理字段用于核对，而不是靠口头说明

## 5. 当前接口总表

### 5.1 资料与玄学

- `POST /api/v1/profile/basic`
- `GET /api/v1/profile/astro`
- `GET /api/v1/profile/astro/summary`
- `GET /api/v1/profile/astro/chart`
- `POST /api/v1/profile/astro`
- `POST /api/v1/profile/astro/render`（历史 / 兼容链路，已不作为主绘制路径）

### 5.2 账号与认证

- `POST /api/v1/auth/login`
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/change-password`
- `DELETE /api/v1/auth/me`

### 5.3 匹配与消息

- `GET /api/v1/matches/current`
- `GET /api/v1/match/current`
- `GET /api/v1/matches/{id}/explanation`
- `GET /api/v1/match/{id}/explanation`
- `GET /api/v1/messages`
- `POST /api/v1/messages`

### 5.4 管理与治理

- `GET /api/v1/admin/users`
- `POST /api/v1/admin/users/{id}/disable`
- `GET /api/v1/admin/verify-queue`
- `GET /api/v1/admin/reports`

### 5.5 基础可观测性

- `GET /api/v1/app/health`
- `GET /api/v1/app/version/check`
- `GET /api/v1/geo/places`

## 6. 当前前端接口约定

- 星盘页面本地根据 `chart_data` 构图
- `astro_chart_preferences_v1` 只做本地渲染偏好
- 资料页、画像页、星盘页要优先读保存响应中的最新快照
- 登录超时排查先看 host APK 与 bootstrap 注入是否正确

## 7. 已知约束与保护面

必须保持稳定的面：
- `POST /api/v1/profile/basic`
- `GET /api/v1/profile/astro/summary`
- `GET /api/v1/profile/astro/chart`
- `GET /api/v1/app/health`
- `GET /api/v1/app/version/check`
- `astro_chart_preferences_v1`
- Admin 治理字段
- synthetic 批次审计字段

不能随意改的边界：
- 服务端 canonical 真值
- 地点搜索与地理编码链路
- 权限 / 路由 / 生命周期 / 状态缓存
- 第三方 SDK 接入与许可证状态

## 8. 后续高风险议题

顾问已明确指出：
- 星盘引擎升级需要多版本推进
- 当前截图对应的网页版能力与现有 Kerykeion 路线不完全等价

因此后续如果要复刻更高层的星盘引擎能力，应另起专门版本规划，不能直接塞进当前稳定基线。

## 9. 交接使用方式

建议后续对接顺序：
1. 先看本文件
2. 再看 `docs/DOC_INDEX_CURRENT.md`
3. 再看 `docs/version_plans/README.md`
4. 再看对应版本的 `ACCEPTANCE_REPORT` / `HANDOFF_FINAL`
5. 3.9 相关材料优先看 `docs/version_plans/elite_sync_3_9_版本开发计划书_2026_04_17.md` 及其归档材料
6. 3.x 收口与下一阶段讨论优先看 `docs/HANDOFF_3X_CLOSEOUT_20260417.md`

如果需要向顾问补充版本材料，本文件应作为总入口，不要把散落的历史规划当作当前主入口。

