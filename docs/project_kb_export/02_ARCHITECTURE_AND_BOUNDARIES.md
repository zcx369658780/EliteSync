# 架构与边界

更新时间：2026-05-11

## 真值链路

- `profile/basic` 的保存结果是资料真值入口。
- `user_astro_profiles` 是星盘 / 画像核心真值表。
- `chat_messages` 是消息主链真值表。
- `app_release_versions` 是发布真值表。
- `questionnaire_attempts`、`questionnaire_answers`、`questionnaire_questions` 是问卷真值表。
- `rtc_calls` / `rtc_sessions` / heartbeat 相关记录是 RTC 真实状态链。

## 资料 / 画像 / 星盘 / 匹配边界

- 资料：前端可以缓存，服务端真值优先。
- 画像：保存后必须由服务端重算，不能让前端缓存覆盖。
- 星盘：服务端负责计算，Flutter 负责绘制与展示。
- 匹配：解释层可以展示分项与证据，但不能把派生结果写成 canonical truth。

## 4.0~4.4S 基础能力边界

- 4.0 建立的是媒体基础设施，不是完整媒体平台。
- 4.1 是非官方四维人格问卷，不是官方 MBTI。
- 4.2 图片消息是聊天主链扩展，不是独立媒体平台。
- 4.3 动态流是轻内容分发，不是重社区平台。
- 4.4 / 4.4S 视频消息与媒体链是消息主链扩展，不是短视频平台。

## 4.6P 真语音边界

- 4.6P 解决的是 1v1 真语音闭环。
- RTC 只承担关系推进和真实联通，不承担多人直播 / 群聊 / 重娱乐扩展。
- `Room.connect()`、join-info、heartbeat、播放链与路由都属于 RTC 保护面。

## 4.7~4.9 稳定化边界

- 4.7 把现代 UI 定义为 protected surfaces。
- 4.8 作为 Alpha smoke 与真实路径复验，不能回滚到旧 UI 或旧入口形态。
- 4.9 把通知降噪、可观测性、数据库正式演练、release gate 收口为门禁基线。
- 这三版之后，任何恢复都必须分层、路径级、最小范围。

## 5.x 增量边界

- 5.x 只做高价值主链功能覆盖优先，不重写已归档主链。
- 5.x 可补：
  - 发现页分栏 / 搜索 / 同城 / 轻治理 / 低压私聊入口
  - 聊天首聊 / 回聊 / 稍后再聊 / 关系摘要 / AI 续话 / 关系节奏化语音入口
  - 个人经营中枢 / AI 助理 / AI 草稿助手 / 标签表达 / 外观层
- 5.x 不做：
  - 重商业化商城
  - 微服务大拆分
  - 多人 RTC
  - 重娱乐化玩法平台

## 5.6+ 玄学解释层边界

- 玄学解释、合盘解释、AI 追问只能作为 `derived-only / display-only / explanation layer`。
- 不反写 `profile/basic`、`profile/astro/summary`、`profile/astro/chart`、`user_astro_profiles`。
- 不改 Match algorithm contract，不把解释层结果作为匹配算法输入。
- 不改 API / DB / release chain；5.6 是 planning / boundary / calibration 版本，不做 runtime implementation。
- 5.8 Me / Profile 个人解释层只允许读取现有 Profile summary 做 presentation 派生展示，不得接入 edit profile save chain、profile providers 写链、astro providers 或真实 AI。
- 不引入真人玄学咨询市场、付费报告商店、上传截图主路径、娱乐化测试主路径、强出生资料收集、测试结果反写画像、大规模社区讨论或测测术语体系复制。

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
- `GET /api/v1/questionnaire/history`
- `POST /api/v1/questionnaire/answers`
- `POST /api/v1/rtc/calls`
- `GET /api/v1/rtc/calls/{callId}/livekit`
- `POST /api/v1/rtc/calls/{callId}/heartbeat`

## 5.6 版本 / 发布链保护面

- `GET /api/v1/app/version/check`
- `apps/android/**`
- `apps/android/app/build.gradle.kts`
- `apps/android/app/src/main/assets/changelog_v0.txt`
- `services/backend-laravel/config/app_update.php`
- `routes/**`
- `config/**`
- `scripts/release_android_update_aliyun.ps1`
- `app_release_versions`

5.6 不修改 version check 路由、不修改默认 app update 配置、不修改 Android build 配置、不更新 APK，也不改变 release metadata。

## 不能被误改的口径

- canonical truth 只能由服务端写入
- cache 只能兜底，不能替代真值
- 版本检查必须与宿主 APK 绑定
- 版本中心展示的主版本必须和宿主 APK 一致
- 图片 URL 的 `public_url` 不能写回 localhost
- UI protected surfaces 不能被“顺手恢复旧 commit”覆盖
- 任何跨层 blocker 必须先写 blocker report，再做最小修复
