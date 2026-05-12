# 架构与边界

更新时间：2026-05-12

## 6.0 Alpha 架构原则

- 后端 v2 采用 contract-first + parallel migration。
- 不允许无计划推倒重写。
- 6.0-A0 只做 planning-only，不改 Flutter / Laravel / DB / API / release chain runtime。
- 每个 runtime 版本必须先冻结 protected surfaces，再做最小垂直切片。

## 后端 v2 边界

- 先定义 contract map，再规划迁移顺序。
- 旧 API 与新 contract 必须有兼容策略。
- 不把 A0 文档计划写成已完成实现。
- 不把本地测试库或临时数据当作正式后端真值。

## 位置链路重构

- 出生地：服务星盘、八字、紫微等资料真值链。
- 现居地：服务当前生活圈、匹配范围和内测分布。
- 约会地点：服务 Date Drop 式低频高质量见面建议。
- 搭子地点：服务学习搭子、电影搭子、吃饭搭子、健身搭子等共同兴趣陪伴。
- 四类位置不得混写，不得让前端缓存抢服务端真值。

## 搭子安全边界

- 搭子是 P1 精准陪伴主线，不是泛同城约玩。
- 搭子入口必须低压、清晰、安全。
- 不默认展示精确位置、隐私资料或高风险约见信息。
- 搭子匹配必须有反馈、举报、拉黑和退出路径规划。

## 玄学解释边界

- 玄学解释仍保持 `derived-only / display-only`。
- 不反写 `profile/basic`、`profile/astro/summary`、`profile/astro/chart`、`user_astro_profiles`。
- 不改 Match algorithm contract，不把解释层结果作为匹配算法真值输入。
- 不吸收真人咨询、付费报告、上传截图主路径、娱乐化测试主路径。

## Date Drop / Soul / 测测边界

- Date Drop 是匹配机制母版，只吸收低频高质量匹配、深度资料、开放题、反馈驱动。
- Soul 是社交表达参考，只吸收交友意图、自我介绍、关系节奏、低压破冰、个人经营。
- 测测 / CECE 是玄学解释层参考，只吸收入口矩阵、档案上下文、字段引导、摘要 / 详情分层。
- 不照抄竞品商业化链路、娱乐化玩法或服务市场。

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
