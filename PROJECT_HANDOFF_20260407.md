# EliteSync 项目交接文档（Claude / Gemini 协作版）

更新时间：2026-04-07

本文用于把当前项目进度、版本谱系、前后端结构、发布配置、云端地址和密钥位置整合成一份可直接交接给 Claude Code / Gemini / GPT 顾问的总入口文档。

> 说明：本文只记录“路径、配置名、地址、脚本入口”和当前工程状态，不记录任何真实密钥内容。

## 1. 当前项目状态

### 当前发布版本
- App 当前对外版本：`0.03.01`
- Android `versionCode`：`301`
- 版本口径与算法版本 `2.8` 已对齐

### 当前阶段结论
- `2.6.4`：稳定性与发布门禁收口版，已结项
- `2.7`：慢约会核心体验补完版，已通过验收并结项
- `2.8`：信任安全与运营后台补完版，已通过验收并结项
- `2.9`：下一阶段 Beta 上线准备，作为后续主线

### 当前工程主目标
1. 保持资料保存 -> 服务端画像 -> 前端展示的单向真源链路
2. 保持玄学、匹配、治理、运营后台之间的边界清晰
3. 保持发布 / 回滚 / smoke / regression / 验收可重复执行
4. 所有版本升级时，App 版本号、更新说明、服务端版本检查必须同步

---

## 2. 版本计划与文件位置

### 总入口
- `docs/version_plans/README.md`：版本计划总索引
- `docs/HANDOFF_MASTER_20260406.md`：上一版总交接（总计划 + 2.0 后计划整合）
- `docs/project_memory.md`：项目长期记忆
- `docs/DOC_INDEX_CURRENT.md`：当前有效文档索引

### 已归档的版本计划目录
版本计划已统一归档到 `docs/version_plans/`，不再使用 `bazi_example/` 作为活跃目录。

关键版本文件：
- `docs/version_plans/算法2.3版本开发规划_2026-03-29.md`
- `docs/version_plans/算法2.4版本开发规划_2026-03-30.md`
- `docs/version_plans/算法2.5版本开发规划_2026-03-30.md`
- `docs/version_plans/算法2.6版本开发规划_2026-03-31.md`
- `docs/version_plans/算法2.6.1修改方案草案_2026-04-01.md`
- `docs/version_plans/算法2.6.2版本修改指令_2026-04-01.md`
- `docs/version_plans/算法2.6.3开发规划与gemini监督方案.md`
- `docs/version_plans/算法2.6.3a开发规划与gemini监督方案.md`
- `docs/version_plans/elite_sync_2_6_4_版本执行清单_与_codex_gemini分工prompt_2026_04_06.md`
- `docs/version_plans/elite_sync_2_7_版本prd_执行清单_与多agent_prompt_2026_04_06.md`
- `docs/version_plans/elite_sync_2_8_版本开发计划_信任安全与运营后台版_2026_04_06.md`
- `docs/version_plans/elite_sync_后续整体开发方案_2026_04_06.md`

### 当前版本执行 / 验收文件
- `docs/version_plans/2.6.4_EXEC_PLAN.md`
- `docs/version_plans/2.6.4_RISK_REVIEW.md`
- `docs/version_plans/2.6.4_ACCEPTANCE_REPORT.md`
- `docs/version_plans/2.8_EXEC_PLAN.md`
- `docs/version_plans/2.8_RISK_REVIEW.md`
- `docs/version_plans/2.8_ACCEPTANCE_REPORT.md`

### 当前交接 / 报告
- `reports/elite_sync_2_7_handoff_20260406.md`
- `docs/HANDOFF_2_8_FINAL_20260406.md`
- `reports/elite_sync_2_7_handoff_20260406.md`（2.7 结项交接）
- `docs/HANDOFF_2_8_FINAL_20260406.md`（2.8 结项交接）
- `CHANGELOG_0.03.01.md`（当前发布版本更新说明）

### 当前应优先阅读的顺序
1. `PROJECT_HANDOFF_20260407.md`
2. `docs/HANDOFF_MASTER_20260406.md`
3. `docs/version_plans/README.md`
4. `docs/DOC_INDEX_CURRENT.md`
5. 对应版本的执行计划 / 验收报告
6. `docs/project_memory.md`

---

## 3. 当前代码结构与主链路

### Flutter 页面结构
- `ProfilePage`：我的页与资料中枢
- `EditProfilePage`：资料编辑、出生地搜索、画像重算触发
- `AstroOverviewPage`：玄学总览、中枢状态与视觉门户
- `AstroBaziPage`：八字四柱矩阵、五行能量、时间轴
- `AstroNatalChartPage`：星盘 SVG、本命盘摘要、盘面设置入口
- `AstroZiweiPage`：紫微斗数宫盘、命宫 / 身宫高亮、中宫锚点
- `AstroProfilePage`：服务端画像诊断页

### 匹配与治理页面
- `MatchPortalPage`：2.7 匹配门户、Drop / 揭晓 / 解锁 / 破冰
- `MatchResultPage`：匹配结果与反馈入口
- `MatchFeedbackPage`：本机反馈闭环
- `AdminModerationPage`：运营后台主页
- `AdminDashboardPage`：运营看板
- `AdminVerificationPage`：认证审核队列
- `AdminUsersPage`：用户列表治理页
- `AdminReportDetailPage`：举报详情页

### 关键后端接口
- `POST /api/v1/profile/basic`
- `GET /api/v1/profile/astro/summary`
- `GET /api/v1/profile/astro/chart`
- `GET /api/v1/app/version/check`
- `POST /api/v1/moderation/reports`
- `POST /api/v1/moderation/blocks`
- `POST /api/v1/moderation/appeals`
- `GET /api/v1/admin/reports`
- `GET /api/v1/admin/verify-queue`
- `GET /api/v1/admin/users`

### 当前数据真源规则
- 生日、出生时间、出生地、经纬度、八字、紫微、星盘等画像字段：以服务端 canonical 为准
- 前端缓存仅做兜底与展示偏好，不得抢真值
- 星盘 SVG 由服务端 Kerykeion 生成，Flutter 只负责渲染
- 主题 / 盘面设置使用本地持久化偏好，不回写 canonical 数据

---

## 4. 发布、回归与版本配置

### 当前版本号与更新配置
- App 版本：`0.03.01`
- VersionCode：`301`
- 后端版本检查配置：`services/backend-laravel/config/app_update.php`
- 更新说明文件：`CHANGELOG_0.03.01.md`
- Flutter about 更新历史：`apps/flutter_elitesync_module/assets/config/about_update_0_xx.json`

### Android 版本文件
- `apps/android/app/build.gradle.kts`
- `apps/android/app/src/main/assets/changelog_v0.txt`

### 发布与部署脚本
- `scripts/release_android_update_aliyun.ps1`
- `scripts/deploy_aliyun_backend.ps1`
- `scripts/publish_to_github.ps1`
- `scripts/smoke_backend_alpha.ps1`
- `scripts/release_gate_alpha.ps1`
- `scripts/regression_alpha_baseline.ps1`

### GitHub workflow
- `.github/workflows/regression-full-manual.yml`
- `.github/workflows/ci-baseline.yml`

### 回滚 / 烟测 / 验收
- `docs/ROLLBACK_PLAN.md`
- `docs/RELEASE_SMOKE_CHECKLIST.md`
- `docs/REGRESSION_CHECKLIST.md`
- `docs/POST_CHANGE_ACCEPTANCE.md`

---

## 5. 阿里云与 GitHub 的关键地址 / 配置

> 这里仅记录地址、路径和配置名，不记录任何真实密钥内容。

### 5.1 GitHub

#### 仓库地址
- Git remote：`git@github.com:zcx369658780/EliteSync.git`
- 对应本地远程名：`origin`

#### GitHub 推送配置文件
- 本地配置文件：`C:\Users\zcxve\.codex\memories\secrets\elitesync_github_push.env`
- 该文件中常用字段：
  - `GITHUB_REPO_URL`
  - `GIT_BRANCH`
  - `GIT_USER_NAME`
  - `GIT_USER_EMAIL`
  - `GITHUB_TOKEN`
  - `HTTP_PROXY`
  - `HTTPS_PROXY`

#### GitHub 发布脚本
- `scripts/publish_to_github.ps1`
- 用途：设置 git user、设置 origin、提交并推送指定分支

#### GitHub 相关验收入口
- `docs/version_plans/2.8_ACCEPTANCE_REPORT.md`
- `docs/version_plans/2.6.4_ACCEPTANCE_REPORT.md`
- `reports/elite_sync_2_7_handoff_20260406.md`

### 5.2 阿里云

#### 服务器地址
- 主机：`101.133.161.203`
- SSH 用户：`root`
- 远程根目录：`/opt/elitesync`

#### SSH 密钥
- 本地私钥：`C:\Users\zcxve\.ssh\CodexKey.pem`
- 发布脚本默认读取路径：`$env:USERPROFILE\.ssh\CodexKey.pem`

#### 远端配置文件
- Laravel 环境文件：`/opt/elitesync/services/backend-laravel/.env`
- 版本检查配置：`/opt/elitesync/services/backend-laravel/config/app_update.php`
- 下载目录：`/opt/elitesync/services/backend-laravel/public/downloads/`

#### 阿里云发布脚本
- `scripts/release_android_update_aliyun.ps1`
- `scripts/deploy_aliyun_backend.ps1`

#### 阿里云相关环境变量
- `ANDROID_LATEST_VERSION_NAME`
- `ANDROID_LATEST_VERSION_CODE`
- `ANDROID_MIN_SUPPORTED_VERSION_NAME`
- `ANDROID_DOWNLOAD_URL`
- `ANDROID_CHANGELOG`
- `ANDROID_APK_SHA256`
- `ANDROID_FORCE_UPDATE`

#### 当前线上发布版本
- `0.03.01`
- `301`
- 下载地址：`http://101.133.161.203/downloads/elitesync-0.03.01.apk`

---

## 6. 安全与协作约束

1. 任何非微小改动都要先 plan-first。
2. 涉及数据库、路由、定位、权限、状态管理、发布脚本、版本脚本、第三方 SDK 的改动，先做风险拆解与回滚点确认。
3. 出生地、坐标、八字、紫微、星盘、画像等字段必须以服务端真源为准。
4. 版本号、APK 名称、更新说明、服务端版本检查必须同步。
5. GitHub / Aliyun 的密钥与 token 只保存在本地配置文件，不得写入仓库。
6. PR 前必须先做 Code Review，再进入发起流程。

---

## 7. 当前交接结论

当前项目已经完成：
- 2.6.4 稳定性与发布门禁收口
- 2.7 慢约会核心体验补完
- 2.8 信任安全与运营后台补完
- 发布版本已对齐到 `0.03.01`

下一阶段建议直接围绕：
- `2.9` Beta 上线准备
- 测试体系
- 性能与稳定性
- 安全与合规
- 灰度与运维

---

如需继续接手，请优先阅读：
1. `docs/HANDOFF_MASTER_20260406.md`
2. `docs/version_plans/README.md`
3. `docs/DOC_INDEX_CURRENT.md`
4. `docs/project_memory.md`
### 2.0 及更早版本总计划归档
- `docs/archive/legacy_2026-04/DEVELOPMENT_PLAN_2_0_AND_EARLIER_ARCHIVE.md`：2.0 及更早版本开发计划统一归档入口
- `DEVELOPMENT_PLAN.md`：兼容入口，仅指向归档，不再作为活跃计划
