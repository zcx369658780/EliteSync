# 数据与 API 面

更新时间：2026-05-12

## 当前原则

- 6.0 Alpha 起，后端 v2 与位置链路重构是 P0。
- 后端 v2 必须采用 contract-first + parallel migration，不允许无计划推倒重写。
- A0 只做规划，不改 Laravel / DB / API runtime。

## 既有核心表

- `users`
- `user_astro_profiles`
- `dating_matches`
- `chat_messages`
- `conversations`
- `conversation_members`
- `media_assets`
- `message_attachments`
- `status_posts`
- `notifications`
- `rtc_calls`
- `rtc_sessions`
- `app_release_versions`

## 6.0 Alpha 新增关注域

- `buddy_requests`
- `buddy_matches`
- `buddy_feedback`
- `location_context`
- `place_preferences`
- `alpha_feedback`
- `match_feedback`
- `backend_v2_contract`

这些名称是 6.0 Alpha planning / contract 关注域，不代表当前已经存在数据库表或 API。

## 位置语义拆分

- 出生地：用于星盘、八字、紫微等资料真值链，必须服务端真值优先。
- 现居地：用于用户当前生活圈、匹配范围和内测分布判断。
- 约会地点：用于 Date Drop 式匹配后的低频高质量见面场景建议。
- 搭子地点：用于学习搭子、电影搭子、吃饭搭子、健身搭子等共同兴趣陪伴场景。

四类位置不得混写；任何 UI、API、缓存或数据模型规划都必须标明语义。

## 后端 v2 contract 关注点

- 用户资料真值 contract。
- 位置上下文 contract。
- Date Drop 式匹配 contract。
- 搭子请求 / 匹配 / 反馈 contract。
- alpha feedback 与 match feedback contract。
- 版本兼容与 parallel migration contract。

## 保护面接口

- `POST /api/v1/profile/basic`
- `GET /api/v1/profile/basic`
- `GET /api/v1/profile/astro/summary`
- `GET /api/v1/profile/astro/chart`
- `GET /api/v1/app/health`
- `GET /api/v1/app/version/check`
- `GET /api/v1/messages`
- `POST /api/v1/messages`
- `POST /api/v1/media`
- `POST /api/v1/rtc/calls`
- `GET /api/v1/rtc/calls/{callId}/livekit`
- `POST /api/v1/rtc/calls/{callId}/heartbeat`

## 发版绑定

- `apps/android/app/build.gradle.kts` 是版本真值。
- `apps/android/app/src/main/assets/changelog_v0.txt` 是宿主 changelog。
- `apps/flutter_elitesync_module/assets/config/about_update_0_xx.json` 是版本中心历史。
- `services/backend-laravel/config/app_update.php` 是后端版本检查默认值。
- `scripts/release_android_update_aliyun.ps1` 是唯一推荐发版脚本。
- 本次 6.0 Alpha 项目源同步不改 release chain。
