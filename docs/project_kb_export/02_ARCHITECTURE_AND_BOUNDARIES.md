# 架构与边界

更新时间：2026-04-19

## 真值链路

- `profile/basic` 的保存结果是资料真值入口。
- `user_astro_profiles` 是星盘 / 画像核心真值表。
- `chat_messages` 是消息主链真值表。
- `app_release_versions` 是发布真值表。
- `questionnaire_attempts`、`questionnaire_answers`、`questionnaire_questions` 是问卷真值表。

## 资料 / 画像 / 星盘 / 匹配边界

- 资料：前端可以缓存，服务端真值优先。
- 画像：保存后必须由服务端重算，不能让前端缓存覆盖。
- 星盘：服务端负责计算，Flutter 负责绘制与展示。
- 匹配：解释层可以展示分项与证据，但不能把派生结果写成 canonical truth。

## 4.0 媒体基础设施边界

- 4.0 建立的是媒体基础设施，不是完整媒体平台。
- 当前有效对象面：
  - `media_assets`
  - `media_processing_jobs`
  - `message_attachments`
- 当前有效能力：
  - 对象存储适配层
  - 上传状态机
  - 队列处理
  - 缓存回读
  - 结构化日志
- 明确不做：
  - 分片上传
  - 断点续传
  - 工业化签名 URL 协议
  - 视频转码平台化

## 4.1 人格模块边界

- 模块定位：`非官方四维人格问卷`
- 不能写成官方 MBTI
- `mbti_attempts` 保留兼容层语义，但对外主口径应是问卷 / 人格倾向
- 结果只能表示“当前倾向”，不能表示人格真值或专业诊断
- 联动只做轻量摘要卡，不改变匹配总分主线

## 4.2 图片消息边界

- 图片消息通过 `attachment_ids` 绑定到 `chat_messages`
- 图片消息是聊天主链的扩展，不是独立媒体平台
- 只保留：
  - 发送
  - 接收
  - 气泡展示
  - 预览
  - 失败重试
  - 会话摘要回读
- 明确不做：
  - 视频消息正式版
  - 动态流
  - 音视频通话
  - 大型相册/图库产品

## 保护面接口

- `POST /api/v1/profile/basic`
- `GET /api/v1/profile/astro/summary`
- `GET /api/v1/profile/astro/chart`
- `GET /api/v1/app/health`
- `GET /api/v1/app/version/check`
- `GET /api/v1/messages`
- `POST /api/v1/messages`
- `POST /api/v1/media`
- `GET /api/v1/questionnaire/history`
- `POST /api/v1/questionnaire/answers`

## 不能被误改的口径

- canonical truth 只能由服务端写入
- cache 只能兜底，不能替代真值
- 版本检查必须与宿主 APK 绑定
- 版本中心展示的主版本必须和宿主 APK 一致
- 图片 URL 的 `public_url` 不能写回 localhost
