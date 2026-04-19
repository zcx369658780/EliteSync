# 数据与 API 面

更新时间：2026-04-19

## 核心表

### 资料与画像

- `users`
- `user_astro_profiles`

### 发布与版本

- `app_release_versions`

### 问卷

- `questionnaire_questions`
- `questionnaire_answers`
- `questionnaire_attempts`
- `mbti_attempts`（兼容层 / 历史数据）

### 匹配 / 消息 / 媒体

- `dating_matches`
- `chat_messages`
- `conversations`
- `conversation_members`
- `media_assets`
- `media_processing_jobs`
- `message_attachments`

### 治理 / 互动

- `moderation_reports`
- `user_blocks`
- `status_posts`
- `app_events`
- `user_relationship_events`
- `notifications`

## 核心接口

### 版本与健康

- `GET /api/v1/app/health`
- `GET /api/v1/app/version/check`

### 资料与星盘

- `POST /api/v1/profile/basic`
- `GET /api/v1/profile/basic`
- `GET /api/v1/profile/astro/summary`
- `GET /api/v1/profile/astro/chart`
- `POST /api/v1/profile/astro`

### 问卷

- `GET /api/v1/questionnaire/questions`
- `POST /api/v1/questionnaire/answers`
- `GET /api/v1/questionnaire/history`
- `GET /api/v1/profile/mbti/quiz`
- `POST /api/v1/profile/mbti/submit`
- `GET /api/v1/profile/mbti/result`

### 匹配与消息

- `GET /api/v1/match/current`
- `GET /api/v1/match/history`
- `GET /api/v1/match/{targetUserId}/explanation`
- `GET /api/v1/messages`
- `POST /api/v1/messages`
- `POST /api/v1/messages/read/{messageId}`

### 媒体

- `GET /api/v1/media`
- `POST /api/v1/media`
- `GET /api/v1/media/{assetId}`
- `GET /api/v1/media/{assetId}/content`

### 治理与首页

- `GET /api/v1/home/banner`
- `GET /api/v1/home/shortcuts`
- `GET /api/v1/home/feed`
- `GET /api/v1/discover/feed`
- `GET /api/v1/geo/places`
- `POST /api/v1/moderation/reports`
- `POST /api/v1/moderation/blocks`
- `DELETE /api/v1/moderation/blocks/{blockedUserId}`

## 保护面接口

- `POST /api/v1/profile/basic`
- `GET /api/v1/profile/astro/summary`
- `GET /api/v1/profile/astro/chart`
- `GET /api/v1/app/health`
- `GET /api/v1/app/version/check`
- `GET /api/v1/messages`
- `POST /api/v1/messages`
- `POST /api/v1/media`

## 媒体关键字段

- `media_assets.media_type`
- `media_assets.storage_provider`
- `media_assets.storage_key`
- `media_assets.mime_type`
- `media_assets.size_bytes`
- `media_assets.status`
- `media_assets.error_code`
- `media_assets.owner_user_id`
- `media_assets.public_url`

## 动态流关键字段

- `status_posts.cover_media_asset_id`
- `status_post_likes`
- `moderation_reports.target_status_post_id`

## 发版绑定

- `apps/android/app/build.gradle.kts` 是版本真值
- `apps/android/app/src/main/assets/changelog_v0.txt` 是宿主 changelog
- `apps/flutter_elitesync_module/assets/config/about_update_0_xx.json` 是版本中心历史
- `services/backend-laravel/config/app_update.php` 是后端版本检查默认值
- `scripts/release_android_update_aliyun.ps1` 是唯一推荐发版脚本
