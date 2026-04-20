# EliteSync 3.x 收口与下一阶段交接稿

更新时间：2026-04-17

本文档用于 3.x 版本线收口后的顾问讨论与后续计划重整。  
当前基线已完成 `0.03.09 / 30900` 发布，`3.9` 已正式归档，通过结论为 `pass with observations`。  
GitHub 分支已推送并合并，阿里云发布脚本已完成更新与 PostCheck。

## 1. 当前结论

- 当前产品进入 `3.x` 收口后半段，重点已从“扩功能”转为“固化边界、稳定发布、准备下一阶段计划”。
- `3.9` 已归档完成，核心交付包括：
  - 高级时法框架首版
  - 细粒度解释层
  - 截图证据索引
  - 验收摘要
  - 多 Agent 审查链
- 顾问结论为 `pass with observations`，即：
  - 通过归档
  - 保留非阻断观察项
  - 不要求打回重做
- 当前版本发布为 `0.03.09 / 30900`
- 线上下载地址：
  - `http://101.133.161.203/downloads/elitesync-0.03.09.apk`
- GitHub PR 已合并，当前 regression 仍在执行中，最终回归报告待补

## 2. 版本与交付状态

### 2.1 近期版本线

- `3.8`：完成第二次验收收口并正式归档
- `3.9`：完成正式归档收口，口径为 `pass with observations`
- `0.03.09`：完成发布同步、阿里云推送与 PostCheck

### 2.2 当前可用文档入口

- [docs/DOC_INDEX_CURRENT.md](./DOC_INDEX_CURRENT.md)
- [docs/HANDOFF_MASTER_CURRENT.md](./HANDOFF_MASTER_CURRENT.md)
- [docs/version_plans/README.md](./version_plans/README.md)
- [docs/CHANGELOG.md](./CHANGELOG.md)

### 2.3 当前发布记录要点

- Android app 版本号：`0.03.09`
- Android `versionCode`：`30900`
- Flutter 模块版本：`0.03.09+30900`
- 版本中心历史标题：`0.03.09 版本中心更新历史`
- 版本检查与下载地址均已验证正常
- 发布脚本：
  - `scripts/release_android_update_aliyun.ps1`

## 3. 3.x 已完成的主线工作

### 3.1 账号与治理

已完成：
- `normal / test / synthetic` 三层口径清晰
- synthetic 账号支持生成、重建、清理、停用
- Admin 侧具备批次、版本、可见性、排除指标等治理视图
- synthetic 默认排除指标：`exclude_from_metrics = true`

当前结论：
- 账号治理链路已足够支撑 Beta、smoke、regression 和运营抽检
- 合成账号与测试账号是可重叠口径，不应误解为互斥分组

### 3.2 资料与画像

已完成：
- `POST /api/v1/profile/basic` 保存后服务端会重算 `astro_profile`
- 前端优先消费保存响应，再做缓存刷新
- 资料页、画像页、星盘页的“真值优先”口径已统一

当前结论：
- 资料编辑 -> 服务端重算 -> 页面刷新 的链路已闭环
- 前端缓存只能兜底，不能抢 canonical 真值

### 3.3 星盘 / 八字 / 紫微

已完成：
- 星盘服务端只负责计算与保存，不再负责 SVG 绘制
- Flutter 根据 `chart_data` 本地绘制星盘
- 星盘设置页支持本地元素开关、预设、恢复默认
- `astro_chart_preferences_v1` 已明确为本地渲染偏好

当前结论：
- canonical 算法不再频繁改动，保持冻结式维护
- 展示侧优化应继续限定在 derived-only / display-only 层

### 3.4 匹配与转化

已完成：
- 匹配解释结构增强
- 匹配结果到首聊草稿的转化
- 会话入口与破冰建议可点击
- 旧功能路径保留了回归门禁

当前结论：
- 主链路稳定，适合作为 Beta / 稳定版基线
- 后续优化重点应放在解释性、转化率和降噪，而不是扩大模块数量

### 3.5 设置中心与版本中心

已完成：
- 设置中心结构产品化
- 盘面设置、隐私设置、性能偏好、Beta 运营准备说明都已归位
- 版本中心统一了当前版本、服务状态、更新历史、健康检查口径

当前结论：
- 设置与版本页已经从“开发工具页”转成“产品入口页”
- 服务状态定位为可观测性，不是业务真值

### 3.6 发布 / 运维 / 文档

已完成：
- 版本号、更新说明、APK 文件名收口到 `0.03.09 / 30900`
- `docs/` 的当前入口、规划、runbooks、reference、licenses、devlogs 已统一索引
- 历史材料迁移到 `docs/archive/legacy_2026-04/`

当前结论：
- 新版本规划可直接从 `docs/DOC_INDEX_CURRENT.md` 进入
- 文档体系已经具备长期维护骨架

## 4. 当前算法与数据真值链路

### 4.1 资料与画像 canonical 真值

主真值来源：
- `users`
- `user_astro_profiles`

关键规则：
- `POST /api/v1/profile/basic` 保存后必须触发服务端重算
- 前端只消费最新保存响应或详情接口结果
- 前端缓存只能兜底，不能覆盖真值

### 4.2 星盘计算

当前路线：
- 服务端计算
- Flutter 本地绘制

当前实现依赖：
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
- `personality`
- `MBTI`
- `astro`
- `bazi`
- `zodiac`
- `constellation`
- `natal_chart`
- `ziwei`
- `pair_chart`

核心要求：
- 分项必须可解释
- 解释必须可回溯到证据标签
- 首聊 / 行为转化要能从解释页导流

### 4.4 版本比较与升级判断

版本判断规则：
- 语义版本格式：`major.minor.patch[suffix]`
- `0.03.09 -> 30900`
- 有后缀时按 suffix rank 比较

版本检查职责：
- 判断客户端是否低于线上最新版本
- 提供下载地址、changelog、sha256
- 在 DB 不可用时可 fallback 到 config

### 4.5 synthetic 与治理算法

当前规则：
- synthetic 默认排除指标
- batch 级别记录生成版本、seed、batch_id、可见性
- Admin 视图显示治理字段用于核对，不依赖口头说明

## 5. 数据库与持久化接口

### 5.1 核心业务表

- `users`
- `user_astro_profiles`
- `mbti_attempts`
- `app_release_versions`
- `moderation_reports`

### 5.2 `users` 与 `user_astro_profiles`

职责：
- `users` 保存账号与基础镜像字段
- `user_astro_profiles` 保存 canonical 星盘/八字/紫微快照

规则：
- `profile/basic` 保存后要触发重算
- 画像显示必须以服务端快照为准
- `users` 上的镜像字段仅作兼容或兜底

### 5.3 `app_release_versions`

字段要点：
- `platform`
- `channel`
- `version_name`
- `version_code`
- `min_supported_version_name`
- `download_url`
- `changelog`
- `sha256`
- `force_update`
- `is_active`
- `published_at`

用途：
- 作为版本检查接口的数据库真源
- 支持单平台/单渠道单活跃版本
- 兼容 config fallback

### 5.4 `mbti_attempts`

字段要点：
- `user_id`
- `version_code`
- `answers_json`
- `score_json`
- `confidence_json`
- `tie_break_log_json`
- `result_letters`
- `submitted_at`

用途：
- 记录 MBTI 结果与评分过程
- 保留版本化痕迹，便于后续对拍与回归

### 5.5 `moderation_reports`

用途：
- 举报 / 申诉 / 后台治理记录
- 支撑 Admin 侧审核与处理链路

## 6. 当前接口总表

### 6.1 资料与玄学

- `POST /api/v1/profile/basic`
- `GET /api/v1/profile/astro`
- `GET /api/v1/profile/astro/summary`
- `GET /api/v1/profile/astro/chart`
- `POST /api/v1/profile/astro`
- `POST /api/v1/profile/astro/render`

### 6.2 账号与认证

- `POST /api/v1/auth/login`
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/change-password`
- `DELETE /api/v1/auth/me`

### 6.3 匹配与消息

- `GET /api/v1/matches/current`
- `GET /api/v1/match/current`
- `GET /api/v1/matches/{id}/explanation`
- `GET /api/v1/match/{id}/explanation`
- `GET /api/v1/messages`
- `POST /api/v1/messages`

### 6.4 版本与可观测性

- `GET /api/v1/app/health`
- `GET /api/v1/app/version/check`
- `GET /api/v1/geo/places`

### 6.5 管理与治理

- `GET /api/v1/admin/users`
- `POST /api/v1/admin/users/{id}/disable`
- `GET /api/v1/admin/verify-queue`
- `GET /api/v1/admin/reports`
- `GET /api/v1/admin/reports/{reportId}`
- `POST /api/v1/admin/reports/{reportId}/action`

### 6.6 可信度与实验数据

- `POST /api/v1/telemetry/events`
- `POST /api/v1/telemetry/match-explanation-preview-opened`
- `POST /api/v1/telemetry/first-chat-entry`
- `POST /api/v1/telemetry/match-feedback-submitted`

## 7. UI 逻辑与页面职责

### 7.1 资料页 / 画像页 / 星盘页

原则：
- 保存后优先显示服务端重算结果
- 页面展示不反向改写 canonical truth
- 缓存只做兜底

### 7.2 星盘设置页

职责：
- 本地展示偏好调节
- 元素开关 / 预设 / 恢复默认
- 说明“仅影响本地显示，不影响命盘真值”

风险控制：
- 不触碰数据库 schema
- 不碰服务器真值链
- 不把本地偏好写回 canonical 字段

### 7.3 高级时法预览页 / 演示页

职责：
- 展示高级时法框架首版
- 展示细粒度解释层
- 展示样例矩阵与日志摘要

当前设计口径：
- `summary`
- `entry`
- `timing-association`

说明：
- 这些是展示层卡片，不是新算法真值
- 只承担读与解释，不承担写回

### 7.4 版本中心 / 关于页

职责：
- 展示当前版本
- 展示更新历史
- 展示服务状态与健康检查
- 展示下载/升级口径

版本中心三层口径：
- 当前产品版本
- 产品构建号
- Flutter 模块版本

### 7.5 匹配结果页 / 首聊入口

职责：
- 呈现解释标签
- 导流首聊草稿
- 保留反馈入口与 telemetry

原则：
- 解释不能脱离证据标签
- 首聊入口不能破坏原结果

### 7.6 管理与治理页

职责：
- 查看用户、举报、审核、批次信息
- 支撑治理与审计

原则：
- 显示治理字段，但不要把治理字段混入业务真值

## 8. 当前发布链路

### 8.1 本地改动入口

- `apps/android/app/build.gradle.kts`
- `apps/android/app/src/main/assets/changelog_v0.txt`
- `apps/flutter_elitesync_module/assets/config/about_update_0_xx.json`
- `docs/CHANGELOG.md`
- `docs/version_plans/0.03.09_UPDATE_BRIEF.md`

### 8.2 发布脚本

- `scripts/release_android_update_aliyun.ps1`

脚本职责：
- 更新本地版本号
- 追加 Android changelog
- 构建 debug APK
- 上传到阿里云
- 更新远端 `.env`
- Upsert `app_release_versions`
- 重启 `php-fpm` / `nginx`
- 清理历史 APK
- 执行 PostCheck

### 8.3 当前发布结果

- 版本：`0.03.09 / 30900`
- 下载地址可用
- 版本检查返回正常
- PostCheck：`PASS`

## 9. 当前保护面与不应轻易改动的边界

必须保持稳定：
- `POST /api/v1/profile/basic`
- `GET /api/v1/profile/astro/summary`
- `GET /api/v1/profile/astro/chart`
- `GET /api/v1/app/health`
- `GET /api/v1/app/version/check`
- `astro_chart_preferences_v1`
- `app_release_versions`
- `moderation_reports`
- `user_astro_profiles`
- synthetic 批次审计字段

不能随意改：
- 服务端 canonical 真值
- 地点搜索与地理编码链路
- 权限 / 路由 / 生命周期 / 状态缓存
- 第三方 SDK 接入与许可证状态
- 发布脚本的版本检查 / 下载地址 / SHA256 口径

## 10. 已知观察项

### 10.1 3.9 归档观察项

- 细粒度解释层的截图证据可以再增强
- 高级时法页仍有少量工程语义外露
- 回归材料可在后续版本继续加厚

### 10.2 版本与发布观察项

- 版本更新必须同步：
  - Android `versionName`
  - Android `versionCode`
  - changelog
  - about 页版本中心
  - 阿里云下载包
  - `app_release_versions`

### 10.3 UI / IA 观察项

- 顾问已接受当前 3.9 口径，但建议后续继续降噪
- 页面层次已清楚，但工程术语不宜继续增加

## 11. 下一阶段建议

如果要和顾问讨论后续开发计划，我建议把议题拆成三条线：

### 11.1 3.x 收尾线

- 明确 3.x 是不是最后一个重功能阶段
- 只保留稳定性、可观测性、文案降噪、归档补证
- 避免再引入新的大功能面

### 11.2 4.x 规划线

可考虑的方向：
- 更清晰的 UI / IA 收敛
- 更强的解释层可读性
- 更完整的回归与审计输出
- 对外发布与内部治理进一步分层

不建议的方向：
- 重新触碰 canonical truth 的大改
- 把展示层的扩展混成算法重构
- 在同一版本里同时做多条高风险链路

### 11.3 算法演进线

建议单独评审的内容：
- 星盘引擎升级
- 路线 / 高级能力的边界再分层
- pair_chart / timing / advanced-context 的版本化
- 证据标签和解释模板的版本演进

核心原则：
- 算法升级与展示优化要拆开谈
- 真值层和展示层不要混写
- 新算法应另起版本规划，不要硬塞进当前稳定基线

## 12. 建议的后续工作方式

1. 先把 3.x 现有收口材料作为基线，不再回头重写已归档内容。
2. 用这份文档和 `docs/HANDOFF_MASTER_CURRENT.md` 作为和顾问沟通的主入口。
3. 如果要开 4.x，先出计划书，再拆风险评审、范围矩阵和验证清单。
4. 新计划中继续沿用：
   - plan-first
   - 风险拆解
   - 回归门禁
   - 顾问验收

## 13. 交接索引

- [docs/HANDOFF_MASTER_CURRENT.md](./HANDOFF_MASTER_CURRENT.md)
- [docs/DOC_INDEX_CURRENT.md](./DOC_INDEX_CURRENT.md)
- [docs/version_plans/README.md](./version_plans/README.md)
- [docs/CHANGELOG.md](./CHANGELOG.md)
- [docs/version_plans/0.03.09_UPDATE_BRIEF.md](./version_plans/0.03.09_UPDATE_BRIEF.md)
