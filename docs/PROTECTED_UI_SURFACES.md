# UI Protected Surfaces

> 4.7 起，以下现代 UI 视为保护面。任何跨层恢复、构建修复、后端修复、RTC/LiveKit 修复、媒体修复、数据库恢复或发版回滚，都不得默认覆盖这些 surface。

## 1. 保护原则

- 当前现代 UI 是稳定基线，不得因为恢复可用性而整体回滚。
- 任何触碰保护面的改动，都必须按 UI 专项任务处理，不能顺手带过。
- 路径级恢复可以做，但必须先确认路径是否属于保护面。
- 如果目标路径属于保护面，必须先停止并取得用户明确批准。

## 2. 必须保护的 UI surfaces

1. Flutter 主导航 / bottom tab / tab layout
2. 首页 Home 现代布局
3. 发现 / 动态 / 状态流入口
4. 消息列表页
5. 聊天页 / 图片消息 / 视频消息 / 通话入口相关 UI
6. 通知中心页
7. 匹配页 / 匹配解释页
8. 我的 / 资料 / 设置 / 退出登录入口
9. 星盘 / 问卷 / 版本中心等已产品化页面
10. `starry background` / `modern card` / `modern spacing` / `modern visual arrangements` 等视觉基线

## 3. 保护面内常见文件范围

- `apps/flutter_elitesync_module/lib/app/router/**`
- `apps/flutter_elitesync_module/lib/app/**` 中与启动、导航、shell 相关的文件
- `apps/flutter_elitesync_module/lib/design_system/**`
- `apps/flutter_elitesync_module/lib/features/home/presentation/**`
- `apps/flutter_elitesync_module/lib/features/discover/presentation/**`
- `apps/flutter_elitesync_module/lib/features/status/presentation/**`
- `apps/flutter_elitesync_module/lib/features/chat/presentation/**`
- `apps/flutter_elitesync_module/lib/features/notification/presentation/**`
- `apps/flutter_elitesync_module/lib/features/match/presentation/**`
- `apps/flutter_elitesync_module/lib/features/profile/presentation/**`
- `apps/flutter_elitesync_module/lib/features/questionnaire/presentation/**`
- `apps/flutter_elitesync_module/lib/features/verification/presentation/**`
- `apps/flutter_elitesync_module/lib/features/rtc/presentation/**`

## 4. 禁止把这些 UI surface 当成可自动回滚对象

- 不能为了修 Gradle / JDK / AAR / backend / RTC / LiveKit / database，顺手覆盖当前 UI 现代化布局。
- 不能用旧 commit、旧 zip、旧 worktree、repo 级恢复去“顺带修 UI”。
- 不能把 debug / demo / scaffold / mock 文案带回用户面。

## 5. 与其他文档的关系

- 回滚与恢复政策：`docs/runbooks/ROLLBACK_AND_RECOVERY_POLICY.md`
- 4.7 UI 回退修复说明：`docs/version_plans/4.7_UI_REVERSION_FIX_NOTE.md`
- 4.7 UI 基线门禁：`docs/version_plans/4.7_UI_BASELINE_GUARD.md`
- 4.7 基线证据索引：`docs/version_plans/4.7_UI_BASELINE_EVIDENCE_INDEX.md`

## 6. 默认判定

- 只要改动会影响上面任一 surface，就默认视为高风险 UI 改动。
- 任何恢复操作只允许做到“最小文件集、最小路径集、最小影响面”。
