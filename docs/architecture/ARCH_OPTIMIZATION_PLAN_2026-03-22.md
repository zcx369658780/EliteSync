# EliteSync 架构优化方案（Android Studio Developer 顾问）

日期：2026-03-22
来源：顾问 Agent（Android Studio Developer）
基线输入：`docs/architecture/SYSTEM_ARCH_REPORT_2026-03-22.md`

## 1. 结论摘要
- 采用增量重构：先包级分层，后 Gradle 模块化。
- 先修体验：优先解决“重复定位/重复填写/表单丢失”。
- 服务端接口保持兼容：继续沿用 `/api/v1/profile/basic` 与 `/api/v1/profile/astro`。

## 2. 顾问识别的核心问题
1. `AppViewModel` 职责过重（认证/资料/问卷/匹配/消息/定位/星盘/UI设置）。
2. `RegisterScreen`、`BasicProfileScreen`、`DiscoverScreen` 各自实现定位，存在重复采集。
3. 表单回填未形成统一 Draft 机制，地图返回后易丢状态或被自动值覆盖。
4. 多页面共用全局 `status/error` 字符串，存在状态串味风险。

## 3. 目标架构（建议）

```text
app/
  AppContainer.kt
  EliteSyncApp.kt
core/
  network/
  location/
  store/
data/
  auth/
  profile/
  astro/
  place/
  match/
  chat/
domain/
  auth/
  profile/
  astro/
  location/
ui/
  navigation/
  session/
  auth/
  profile/basic/
  profile/astro/
  discover/
  match/
  chat/
```

### 模块边界
- Session：token/userId/onboarding/ui settings。
- Location：权限、定位、TTL、反解、`skyLatLng/currentPlace`。
- BasicProfile：昵称/性别/生日/城市/婚恋目标 + draft。
- Astro：出生时间/出生地/MBTI/星盘结果与缓存。
- Discover：同城搜索独立状态，不复用画像搜索状态。
- Match/Chat：与资料/地图完全解耦。

## 4. 关键数据流（建议）
1. 登录成功后并发：`loadBasicProfile + loadAstroProfile + loadQuestionnaireProgress + warmupLocationCache`。
2. 基础资料合并优先级：手工输入 > draft > 服务端 > 自动定位。
3. 定位统一走 `LocationCoordinator`，页面禁止直接调 `LocationServices`。
4. 星盘缓存签名需至少包含：`birthday + gender + birthTime + birthLat + birthLng`。
5. 本地缓存拆分：`LocationCacheStore`、`BasicProfileDraftStore`、`AstroDraftStore`。

## 5. 迁移计划

### P0（2~3天，先修用户观感）
- 新增 `ui/location/DeviceLocationProvider.kt`。
- 抽出 Register/BasicProfile/Discover 三处重复定位逻辑。
- 在 `AppViewModel` 先新增过渡态：`BasicProfileDraft`、`AstroDraft`、`cityManuallyEdited`。
- 修复星盘缓存判定，避免生日/性别变化后误用旧缓存。

验收标准：
- 首次会话仅一次定位授权。
- 注册后进入基础资料可直接回填城市。
- 地图返回不丢表单。
- 生日或性别变更后，星盘重新计算并可保存。

### P1（职责拆分）
- 新增 `SessionViewModel/BasicProfileViewModel/AstroViewModel/LocationViewModel`。
- `AppRepository` 拆为域仓库（Auth/Profile/Astro/Place）。
- `AppViewModel` 过渡为 façade 后逐步下线。

### P2（长期架构）
- 增加 DataStore（draft + location cache）。
- 建立 `domain/*UseCase.kt`。
- 条件允许再拆成 feature module。

## 6. 兼容性约束
- DTO 保持不变：`BasicProfileReq`、`AstroProfilePayload` 不改字段名与必填规则。
- 新增 `citySource/manualOverride/ttl` 仅客户端本地使用，不上送服务端。
- 旧路由持续保留一个版本周期。

## 7. 我们的执行建议（本仓库）
- 先做 P0：在当前分支实现最小改造，快速提升体验并降低回归风险。
- P0 完成后再进入 P1，避免一次性大改造成 UI 迭代停滞。
