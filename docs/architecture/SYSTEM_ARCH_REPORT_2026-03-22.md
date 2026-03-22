# EliteSync 系统架构报告（2026-03-22）

## 1. 报告范围与目标
- 目标：提取当前程序的整体系统架构（客户端、服务端、接口、数据模型、核心页面流），并识别当前已知的逻辑问题与重构方向。
- 时间戳：2026-03-22（Asia/Shanghai）
- 范围：
  - Android 客户端：`apps/android/app/src/main/java/com/elitesync`
  - Laravel 服务端：`services/backend-laravel`
  - API 路由：`services/backend-laravel/routes/api.php`

## 2. 当前系统上下文
- 客户端：Android（Jetpack Compose）
- 服务端：Laravel + Sanctum Token
- 地图能力：百度 SDK（Suggestion/GeoCoder）+ HTTP 兜底
- 实时通信：WebSocket（当前以 `ChatSocketManager` + API 轮询为主）

## 3. 客户端架构（现状）
### 3.1 分层
- UI/Nav：`AppNavHost.kt`（路由、底部 tab、转场）
- 状态中心：`AppViewModel.kt`（单 ViewModel 聚合大量状态与业务）
- 数据访问：`AppRepository.kt`（Retrofit API + Baidu SDK/HTTP）
- 模型定义：`Models.kt`

### 3.2 关键页面路由
- 注册与入口：`register`
- onboarding：`onboarding/hub`, `onboarding/basic`, `onboarding/preferences`, `onboarding/questionnaire`
- 主页面：`main/recommend`, `main/match`, `main/messages`, `main/discover`, `main/me`, `main/me/settings`
- 扩展：`profile/insights`, `map/pick/current`, `map/pick/birth`, `chat`

### 3.3 关键状态（AppViewModel）
- 认证与用户：token / currentUserId / birthday / gender / city / relationshipGoal / realname
- 问卷与匹配：questions / questionnaireProgress / currentMatch
- 地理与画像：currentPlace / birthPlace / insightsBirthTime / insightsResult
- UI 设置：hapticEnabled / clickSoundEnabled / litePerformanceMode

## 4. 服务端架构（现状）
### 4.1 API 路由（v1）
- 认证：`/auth/register`, `/auth/login`, `/auth/refresh`
- 问卷：`/questionnaire/*`
- 资料：`/profile/basic`, `/profile/astro`
- 匹配：`/matches/*`（兼容 `/match/*`）
- 消息：`/messages`
- 管理与开发：`/admin/*`

### 4.2 数据模型（核心）
- `users`：含 `birthday`, `gender`, `city`, `relationship_goal`, `realname_verified` 及公开/私密画像字段
- `user_astro_profiles`：`birth_time/place/lat/lng`, `sun/moon/asc`, `bazi`, `da_yun`, `liu_nian`, `wu_xing`, `computed_at`
- 其他：问卷题库/答案、匹配记录、聊天消息

## 5. 前后端接口映射（客户端 ApiService -> Laravel Route）
- auth/register/login -> `/api/v1/auth/*`
- basicProfile/saveBasicProfile -> `/api/v1/profile/basic`
- astroProfile/saveAstroProfile -> `/api/v1/profile/astro`
- currentMatch/confirmMatch -> `/api/v1/matches/current|confirm`
- messages/send -> `/api/v1/messages`

## 6. 已识别架构问题（重点）
### 6.1 位置能力重复采集，用户观感差
- 入口页 `RegisterScreen`：为星空背景首次请求定位并缓存经纬度（SharedPreferences）。
- 基础资料页 `BasicProfileScreen`：再次请求定位用于城市填写。
- 发现页 `DiscoverScreen`：也具备位置相关入口与逻辑。
- 结果：同一用户在同一次会话内，位置数据被多次请求/多条链路维护，体验割裂。

### 6.2 状态中心过重（单 ViewModel 承担过多职责）
- `AppViewModel` 同时承载认证、问卷、匹配、消息、地图、画像计算、UI 开关。
- 风险：状态耦合高、回归成本高、难做模块级测试。

### 6.3 位置与资料字段缺乏单一事实源（Single Source of Truth）
- 位置有“星空展示坐标”“当前城市坐标”“出生地坐标”三类，但目前存储/同步策略分散。
- `city` 的来源逻辑与地图选点逻辑没有统一策略（优先级、刷新时机、TTL 不统一）。

### 6.4 表单跨页面回填能力仍依赖局部状态
- MapView 返回后表单保留已有改进，但未形成统一 FormSession 机制。
- 后续扩展页面时仍可能重复踩坑。

## 7. 架构优化目标（第一版）
- 目标A：建立统一“位置域服务”（Location Domain Service）
  - 启动后一次权限决策 + 一次定位采集
  - 会话内复用，必要时按 TTL 刷新
  - 提供 `currentCity/currentLatLng/skyLatLng` 的标准输出
- 目标B：按业务域拆分 ViewModel
  - `AuthVm` / `ProfileVm` / `MatchVm` / `ChatVm` / `AstroVm` / `LocationVm`
- 目标C：建立表单会话层（Form Session Store）
  - 各表单页面（基础资料/画像）统一持久化恢复策略
- 目标D：统一“公开 vs 私密”资料边界
  - 客户端与服务端字段权限映射文档化，避免误展示

## 8. 建议的重构切分（可执行）
1. 引入 `LocationCoordinator`（应用级单例 + Flow）
2. 将 Register/BasicProfile/Discover 的定位入口收敛为调用同一 Coordinator
3. 在 `ProfileVm` 中将 `city` 绑定为 Coordinator 解析结果（允许手工覆盖）
4. 新增 `FormDraftStore`（DataStore）保存正在编辑的表单草稿
5. 把 `AppViewModel` 中画像计算与缓存逻辑迁移至 `AstroVm`

## 9. 已确认可复用能力
- 后端 `/profile/basic` 与 `/profile/astro` 已具备保存接口与字段。
- 登录页已有经纬度本地缓存（`KEY_LAST_SKY_LAT/LNG`），可升级为统一位置缓存策略。
- 地图搜索/反解已有 SDK 与 HTTP 双通道兜底。

## 10. 下一步（待顾问架构师评审）
- 基于本报告，提交给 Android Studio Developer 顾问 Agent 输出：
  - 目标架构图（模块/边界/数据流）
  - 迁移计划（按周或按里程碑）
  - 风险清单与回滚策略
  - 优先级最高的 3 个改造点（先解决用户重复填写/重复定位）
