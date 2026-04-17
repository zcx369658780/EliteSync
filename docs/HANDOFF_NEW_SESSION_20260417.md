# EliteSync 新会话交接摘要

更新时间：2026-04-17

这份文档用于 Codex 新会话接手时快速恢复上下文。当前仓库状态已经完成 3.9 正式归档收口，并同步完成 0.03.09 版本发布。

## 1. 当前基线

- 对外发布版本：`0.03.09 / 30900`
- 当前已完成并归档版本：`3.4`
- `3.5`：已正式验收通过
- `3.6`：已正式归档
- `3.7`：已完成 stage 5 final archive
- `3.8`：已完成第二次验收收口，顾问已确认正式归档通过

## 2. 当前发布口径

- Android app 版本号：`0.03.09`
- Android `versionCode`：`30900`
- Flutter 模块版本：`0.03.09+30900`
- 关于页 / 版本中心历史标题：`0.03.09 版本中心更新历史`
- 版本中心已明确区分：
  - 当前产品版本
  - 产品构建号
  - Flutter 模块版本
  - 服务状态 / 服务可观测性

## 3. 当前主线状态

### 3.1 资料与画像

- 保存资料后由服务端重算 canonical 真值
- 前端优先消费保存响应，再刷新详情
- 资料与画像链路已收口

### 3.2 星盘 / 八字 / 紫微

- 服务端只负责计算和保存，不负责星盘 SVG 绘制
- Flutter 端本地绘制星盘 SVG
- 星盘设置页、参数联动、校准报告、已知偏差与高级预览页均已归档

### 3.3 路线 / 高级能力

- `route_mode` 维持为 `display-only`
- `pair / transit / return / comparison` 维持为 `advanced-context`
- 所有高级能力均保持 `derived-only / display-only`

### 3.4 发布与回归

- `health / version check / smoke / regression / rollback` 已纳入固定门禁
- 最新版本更新历史已写入：
  - `docs/CHANGELOG.md`
  - `apps/android/app/src/main/assets/changelog_v0.txt`
  - `apps/flutter_elitesync_module/assets/config/about_update_0_xx.json`

## 4. 当前关键文件

- `docs/DOC_INDEX_CURRENT.md`
- `docs/version_plans/README.md`
- `docs/HANDOFF_MASTER_CURRENT.md`
- `docs/DEVELOPMENT_PLAN_CURRENT.md`
- `docs/CHANGELOG.md`
- `docs/version_plans/0.03.09_UPDATE_BRIEF.md`
- `docs/version_plans/3.8_ACCEPTANCE_REPORT.md`
- `docs/version_plans/3.8_HANDOFF_FINAL_20260416.md`
- `docs/version_plans/3.8_SCREENSHOT_EVIDENCE_INDEX.md`
- `docs/version_plans/3.8_SCREENSHOT_VERIFICATION_NOTE.md`
- `docs/version_plans/3.8_MULTIAGENT_REVIEW_LOG.md`
- `docs/version_plans/3.8_SECOND_ACCEPTANCE_PACK.md`

## 5. 当前截图归档

3.8 的正式截图已经从根目录清理并迁移到 `docs/version_plans/`，当前保留的正式图片如下：

- `3_8_home.png`
- `3_8_profile_real.png`
- `3_8_profile_astro_real.png`
- `3_8_discover.png`
- `3_8_match.png`
- `3_8_messages_real.png`
- `3_8_settings_center.png`
- `3_8_version_center.png`
- `3_8_settings_page.png`
- `3_8_parameter_linkage.png`
- `3_8_calibration_report.png`
- `3_8_known_deviations.png`
- `3_8_advanced_preview_entry.png`
- `3_8_advanced_preview_samples.png`
- `3_8_advanced_preview_log.png`

## 6. 发布结果

- 0.03.09 已推送到阿里云
- 下载地址：`http://101.133.161.203/downloads/elitesync-0.03.09.apk`
- SHA256：`08B7EDD74CF3F86378ACBE657632E9BAC6AD776D02B97F1F18E01EBAFEEE2525`

## 7. 新会话建议

1. 继续以 `0.03.09 / 30900` 作为当前发布基线。
2. 如需继续版本推进，应先从 `docs/version_plans/README.md` 和 `docs/HANDOFF_MASTER_CURRENT.md` 读取当前口径。
3. 若要继续开发，请优先遵守 `AGENTS.md`：先做 plan-first，再进实现与验收。
4. 如再做发布，请沿用 `scripts/release_android_update_aliyun.ps1`。

## 8. 备注

- 当前无需回退 3.8 已完成的归档材料。
- 根目录已清理正式截图，后续请从 `docs/version_plans/` 读取截图证据。
- 若继续做新版本，注意不要重写 canonical truth，仅在 display-only / derived-only / advanced-context 层扩展。
