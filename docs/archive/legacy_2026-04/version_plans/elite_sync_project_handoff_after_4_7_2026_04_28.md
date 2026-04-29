# EliteSync 慢约会 APP — 4.7 后项目交接文件

建议文件名：`elite_sync_project_handoff_after_4_7_2026_04_28.md`
建议存放位置：`docs/version_plans/elite_sync_project_handoff_after_4_7_2026_04_28.md` 或项目源根目录文档区
适用场景：新 ChatGPT 项目对话、Codex 新 session、后续 4.8 / 5.0 前路线规划
当前交接状态：`4.7 pass with observations` 后冻结

---

## 0. 新会话启动词

在新对话中建议直接粘贴以下启动词：

```text
你现在继续担任 EliteSync 慢约会 APP 项目的长期开发顾问、架构审查者、版本规划助手和验收助手。

请先阅读项目源中的以下文件，尤其是本交接文件：
- docs/version_plans/elite_sync_project_handoff_after_4_7_2026_04_28.md
- docs/PROJECT_RULE_CROSS_LAYER_BLOCKERS.md
- docs/PROTECTED_UI_SURFACES.md
- docs/runbooks/ROLLBACK_AND_RECOVERY_POLICY.md
- docs/version_plans/4.7_UI_BASELINE_GUARD.md
- docs/version_plans/4.7_UI_BASELINE_EVIDENCE_INDEX.md
- docs/version_plans/4.7_REGRESSION_CHECKLIST.md
- docs/project_memory.md
- docs/DEVELOPMENT_PLAN_CURRENT.md

当前默认基线：
3.9、4.0、4.1、4.2、4.3、4.4、4.4S、4.5、4.6P、4.7 均视为已完成或已按 pass with observations 冻结。

当前最重要规则：
1. 本地只做前端开发、UI 联调、截图采集、文档整理。
2. 后端开发、数据库迁移、备份、恢复、写库排障统一在阿里云端执行。
3. 跨层 blocker 必须先写 blocker report，再请 Claude 做根因缩层，Codex 只做最小修复。
4. 现代 UI 已是 protected surface，不允许再被 repo 级回滚覆盖。
5. 禁止 repo 级恢复；恢复只能 path-level / file-level / smallest-scope，且恢复前必须 checkpoint。
6. 后续计划书必须继续包含保护面、任务边界、验收条件、Codex / Claude / Gemini 分工与 Prompt。

请在后续回答中默认遵守这些项目规则，不要把已归档版本重新当成待开发版本，也不要随意扩大版本范围。
```

---

## 1. 项目总体定位

EliteSync 是一款以 **慢约会、轻匹配、低压沟通、关系渐进** 为核心体验的恋爱社交 APP。

当前产品主线不是盲目扩功能，而是按照版本节奏逐步补齐：

1. 用户资料与画像真值链
2. 星盘 / 人格 / 匹配解释
3. 图片、视频、动态等表达能力
4. 通知、消息、语音通话等互动转化能力
5. 测试前稳定化、环境隔离、回滚保护和质量门禁

目前项目已经从“核心功能补齐阶段”进入 **5.0 前测试稳定化阶段**。

---

## 2. 当前最新版本状态

当前最新完成并建议冻结的版本是：

> **4.7 测试前稳定化与质量门禁版 — pass with observations**

4.7 的目标不是继续扩业务功能，而是处理一次重要流程事故：

- Codex 在跨层恢复时使用 repo 级回滚，把现代 UI 回退到了旧版 UI。
- 后续已恢复 UI，并把现代 UI 正式定义为 protected surfaces。
- 新增 rollback / recovery policy，禁止再次 repo 级回滚。
- 新增 UI baseline evidence、UI regression checklist、UI reversion fix note。
- 4.7 已按稳定化与门禁收口，不建议继续在 4.7 上补功能。

---

## 3. 已完成版本总览

## 3.1 3.x 阶段

### 3.9

定位：3.x 收尾与真值链保护阶段。
状态：已归档通过。
默认保护，不再回头重开。

---

## 3.2 4.0

定位：媒体 / 存储 / 队列 / 缓存 / worker 基础设施版。
状态：已完成，作为后续图片、视频、动态、聊天媒体链的基础。
保护面：media/storage/attachment pipeline，不得被后续版本重写破坏。

---

## 3.3 4.1

定位：非官方四维人格问卷模块。
状态：已完成。
注意：必须持续声明为“非官方人格问卷”，不得冒充官方 MBTI。

---

## 3.4 4.2

定位：图片消息正式接入版。
状态：已完成并冻结主链。
保护面：图片上传、附件绑定、预览、失败重试、摘要回读。

---

## 3.5 4.3

定位：动态流基础版。
状态：已完成并验收。
核心完成内容：

- 文本动态
- 单图动态
- 动态流读取
- 点赞 / 举报 / 删除
- 作者页联动
- 轻治理挂点

后续不得把 4.3 重新扩成内容社区大版本。

---

## 3.6 4.4

定位：视频消息版。
状态：代码主链曾基本成立，但媒体播放链存在阻断，后续通过 4.4S 修复。

---

## 3.7 4.4S

定位：媒体链稳定性修正版。
状态：已完成并建议视为 4.4 的稳定收口。
核心修复：

- 图片 / 视频媒体读取链
- 对象存储访问链
- public_url / playback_url / thumbnail_url
- 播放器读取链
- 失败态解释与日志

4.4S 之后，媒体链不应再被未来版本随意重写。

---

## 3.8 4.5 / 4.5E

定位：通知与社交转化增强版。
状态：已完成并可归档。
核心完成内容：

- 通知中心
- 未读数
- 通知已读 / 全部已读
- 消息、状态、匹配等回流
- 社交转化入口

当前观察项：通知卡片仍可能有少量工程 slug 外露，特别是 RTC 类型通知。

---

## 3.9 4.6 / 4.6A / 4.6P

定位：RTC / 通话基础设施版，语音优先。
状态：4.6P 已完成真语音可听闭环，建议 `pass with observations` 收口。
重要过程：

- 前期多次卡在“状态机通但无声音”。
- Codex 长时间在前端 / Flutter / RTC 连接层排障。
- 最终在 Claude 协助下定位到阿里云端 UDP 端口未开放。
- 修复端口后，手机端与电脑模拟器已可真实通话。

4.6P 的关键经验：

> 跨层 blocker 不能让 Codex 单独在前端死磕，必须先 blocker report，再 Claude 根因缩层，再 Codex 最小修复。

当前观察项：

- 独立 live-call runtime state 截图可补，但不阻断 4.6P。
- 模拟器反向发言链可后续再复测。
- 通话页仍有少量工程态标签可后续降噪。

---

## 3.10 4.7

定位：测试前稳定化与质量门禁版。
状态：已完成，建议 `pass with observations` 冻结。
核心完成内容：

- UI protected surfaces 落地
- repo 级回滚禁止
- rollback / recovery policy 落地
- UI baseline evidence 补齐
- UI baseline regression checklist 固化
- UI reversion 事故说明归档
- 跨层恢复与 UI 保护边界制度化

4.7 不新增业务功能，它的意义是：

> 防止未来修 Gradle、后端、RTC、OSS、LiveKit、数据库等跨层问题时，再把现代 UI 覆盖回旧版。

当前观察项：

- 通知中心仍可见 `rtc_call_invite`、`rtc_call_ended`、`rtc_call_missed` 等工程 slug。
- 独立 live-call runtime state 截图仍可补。
- 后续任何跨层恢复必须严格执行 protected surfaces 与 rollback policy。

---

## 4. 当前最重要长期规则

## 4.1 本地 / 云端开发边界

这是最高优先级规则之一：

> 本地只做前端开发、UI 联调、截图采集、文档整理。
> 后端开发、数据库迁移、备份、恢复、写库排障统一在阿里云端执行。

原因：项目曾出现本地后端数据库文件覆盖远端数据库的风险。

因此，后续所有开发计划书都必须写入：

- 本地不得作为正式后端写库源。
- 本地 SQLite / 临时数据库不得上传覆盖生产数据。
- 写库、迁移、备份、恢复、云端配置都必须在阿里云端执行。
- Codex 执行前必须明确当前操作属于前端、本地构建、云端后端、还是数据库写操作。

---

## 4.2 跨层 blocker 处理规则

当出现以下问题时，默认是跨层 blocker：

- 前端显示成功，但真实效果失败
- 媒体上传成功但播放失败
- RTC 状态机通但没声音
- join-info 可用但 Room.connect / 音频不通
- Gradle / JDK / wrapper / Flutter AAR 构建异常
- OSS / public_url / Nginx / LiveKit / 端口 / UDP / TCP / 代理异常
- 后端日志与 UI 现象不一致

处理流程必须是：

1. 停止盲改
2. 产出 Markdown blocker report
3. 请 Claude 做根因缩层
4. Codex 只做最小修复
5. 用机器证据 + 用户面证据双重复验
6. 写 fix note / verification note / acceptance summary

严禁：

- Codex 连续多轮只在 Flutter/UI 层盲修
- 没有 blocker report 就继续试
- 用 UI 假成功掩盖后端 / 端口 / 网络问题
- 根因未定前大范围重构或换库

---

## 4.3 UI protected surfaces 规则

4.7 后，现代 UI 已正式成为 protected surface。

至少包括：

- 主导航 / bottom tab / tab layout
- 首页现代布局
- 发现 / 动态 / 状态流入口
- 消息列表页
- 聊天页 / 图片消息 / 视频消息 / 通话入口相关 UI
- 通知中心页
- 匹配页 / 匹配解释页
- 我的 / 资料 / 设置 / 退出登录入口
- 星盘 / 问卷 / 版本中心等产品化页面
- starry background / modern card / modern spacing / modern visual arrangements

任何构建、后端、RTC、OSS、LiveKit、数据库修复，都不得顺手覆盖这些 UI 文件。

如果必须恢复涉及 UI protected surfaces 的文件，必须先停止并请用户确认。

---

## 4.4 禁止 repo 级回滚

从 4.7 后开始，默认禁止：

- `git reset --hard <old_commit>`
- `git checkout <old_commit> .`
- `git restore --source=<old_commit> .`
- `git clean -fdx`
- 用旧 zip / 旧工作树覆盖当前项目
- 为了修构建或后端 blocker 恢复整仓代码

只允许：

- path-level restore
- file-level restore
- smallest-scope restore

执行任何高风险恢复前，必须先做：

```bash
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
git diff --name-only
```

并至少执行一种 checkpoint：

```bash
git switch -c safety/pre-recovery-<date>-<topic>
```

或：

```bash
git add -A
git commit -m "safety: checkpoint before <topic> recovery"
```

或：

```bash
git stash push -u -m "safety: checkpoint before <topic> recovery"
```

---

## 4.5 多 AI 协作规则

当前默认协作方式：

- Codex：主执行者、主程序员、主 reviewer、回归整理者、文档收口者
- Claude：架构咨询师、高风险边界审查官、跨层 blocker 根因缩层者
- Gemini：视觉 / 用户视角验收者、截图证据审查者

当前项目记忆中已不再默认依赖 Claude-mcp / Gemini-mcp。推荐使用 PowerShell 直连 CLI：

```powershell
claude -p "<prompt>" --output-format text --tools ""
gemini -p "<prompt>" --output-format text --approval-mode plan
```

如果历史本地配置仍保留 MCP，可等价使用；但后续计划书默认应写 CLI 直连，不再默认写 MCP 服务器。

---

## 5. 硬性保护接口与表

以下接口和表原则上不可乱改。

## 5.1 资料 / 星盘 / 问卷真值链

接口：

- `POST /api/v1/profile/basic`
- `GET /api/v1/profile/basic`
- `GET /api/v1/profile/astro/summary`
- `GET /api/v1/profile/astro/chart`
- `POST /api/v1/profile/astro`

表：

- `user_astro_profiles`
- `questionnaire_questions`
- `questionnaire_answers`
- `questionnaire_attempts`

原则：

- canonical truth 只能由服务端真值写入。
- cache 只能兜底，不能替代真值。
- 动态、消息、通话行为不能反向写入画像或匹配真值层。

---

## 5.2 消息与媒体主链

接口：

- `GET /api/v1/messages`
- `POST /api/v1/messages`
- `POST /api/v1/messages/read/{messageId}`
- `POST /api/v1/media`
- `GET /api/v1/media/{assetId}`

表：

- `chat_messages`
- `conversations`
- `conversation_members`
- `media_assets`
- `media_processing_jobs`
- `message_attachments`

原则：

- 不得为了动态、通知或 RTC 新造平行消息链。
- 不得让 `public_url` 写回 localhost。
- 不得靠前端硬编码资源路径掩盖后端媒体链问题。

---

## 5.3 动态与治理链

表：

- `status_posts`
- `status_post_likes`
- `moderation_reports`
- `user_blocks`
- `user_relationship_events`

原则：

- 动态是表达层，不是画像真值层。
- 点赞、举报、拉黑、删除不得污染匹配 canonical truth。
- 4.3 已冻结为动态流基础版，后续不得无边界扩成内容社区。

---

## 5.4 通知链

接口：

- `GET /api/v1/notifications`
- `POST /api/v1/notifications/read/{notificationId}`
- `POST /api/v1/notifications/read-all`

表：

- `notifications`
- `app_events`
- `user_relationship_events`

原则：

- 4.5 通知中心是站内通知与回流层，不是营销推送平台。
- 通知 slug 仍有降噪空间，但不得重写通知主链。

---

## 5.5 RTC / LiveKit 链

接口：

- `POST /api/v1/rtc/calls`
- `POST /api/v1/rtc/calls/{callId}/accept`
- `POST /api/v1/rtc/calls/{callId}/reject`
- `POST /api/v1/rtc/calls/{callId}/end`
- `POST /api/v1/rtc/calls/{callId}/heartbeat`
- `GET /api/v1/rtc/calls/{callId}`
- `GET /api/v1/rtc/calls/{callId}/livekit`

表：

- `rtc_sessions`
- `rtc_session_events`

云端配置：

- LiveKit 容器
- Nginx `/rtc/` 反向代理
- UDP / TCP 端口开放
- `LIVEKIT_*` 环境变量

原则：

- 4.6P 只冻结 1v1 语音优先 RTC 可听闭环。
- 不得扩成多人通话、直播、语聊房或完整在线状态平台。
- RTC 异常必须优先检查端口、代理、Nginx、LiveKit、join-info，而不是只改 Flutter UI。

---

## 5.6 发布与版本链

接口 / 文件：

- `GET /api/v1/app/health`
- `GET /api/v1/app/version/check`
- `app_release_versions`
- `apps/android/app/build.gradle.kts`
- `apps/android/app/src/main/assets/changelog_v0.txt`
- `apps/flutter_elitesync_module/assets/config/about_update_0_xx.json`
- `services/backend-laravel/config/app_update.php`
- `scripts/release_android_update_aliyun.ps1`

原则：

- 宿主版本号、后端版本检查、版本中心、下载包必须一致。
- 不允许用旧 APK 截图冒充新包。
- 后续 release gate 必须检查版本链。

---

## 6. 当前保留 observations

这些不是阻断项，但建议后续处理。

## 6.1 通知中心工程 slug 降噪

当前通知中心仍可能看到：

- `rtc_call_invite`
- `rtc_call_ended`
- `rtc_call_missed`
- 其他 message / status_like / match_success 等 type slug

建议后续用一个小版本或顺手收尾修：

- 用户面展示自然文案
- 工程 type 仅保留在 debug/log 中
- 不重写通知主链

## 6.2 通话 runtime state 截图补充

4.6P / 4.7 均把“独立 live-call runtime state 截图”列为可选增强证据。
它不是阻断项，但若 5.0 前要做完整 Alpha 包，建议补一张。

## 6.3 模拟器反向发言链复测

4.6P 已证明真机与模拟器能真实通话。
后续可补一次模拟器反向发言链复测，作为增强证据。

## 6.4 UI baseline 后续必须持续复查

后续每次跨层修复后，至少复查：

- 首页
- 消息页
- 聊天页
- 通知中心
- 匹配页
- 我的页
- 设置页
- 版本中心

确保没有退回旧 UI。

---

## 7. 后续版本建议

## 7.1 不建议继续拖长 4.7

4.7 已经完成稳定化与门禁目标，不建议继续让 Codex 在 4.7 上补功能。

4.7 后应冻结为：

> `pass with observations`

---

## 7.2 4.8 候选方向 A：5.0 前 Alpha Smoke 与真实测试准备版

推荐程度：高。

目标：

- 整合 4.0–4.7 主链，形成小规模真实测试前的完整 smoke。
- 不新增大功能。
- 补齐 release gate、环境 runbook、测试账号、截图 walkthrough。

建议内容：

- Alpha smoke matrix
- 双账号全链路 walkthrough
- 通知 slug 降噪
- live-call runtime state 补证据
- UI baseline regression 自动化或半自动化
- 版本中心 / 下载 / 更新检查最终一致性

---

## 7.3 4.8 候选方向 B：视频通话最小骨架版

推荐程度：中等，需谨慎。

原因：4.6 总纲早期提过“视频通话基础可用”，但实际 4.6P 以语音优先收口。
如果要严格补齐总纲，可单独做一个非常小的视频通话骨架版。

边界必须极窄：

- 只做 1v1
- 不做美颜、滤镜、多人、直播
- 不做大 UI 重构
- 只验证摄像头权限、入房、远端视频轨、挂断、失败态

如果当前目标是尽快 5.0 前测试，更建议先做 Alpha Smoke，而不是马上视频通话。

---

## 7.4 4.9 候选方向：测试前治理、限流、监控、发布链强化

推荐程度：高。

目标：

- 压测
- 限流
- 监控
- 队列失败告警
- 媒体 / RTC / 通知失败可观测
- 云端 runbook 固化
- 数据备份与恢复演练

这是 5.0 前很重要的工程化任务。

---

## 7.5 5.0 候选定位

建议把 5.0 定位为：

> Alpha 测试准备版 / 小规模真实用户测试候选版

而不是继续大规模堆新功能。

5.0 前必须满足：

- 主链 smoke 完整
- UI baseline 稳定
- 远端数据库安全
- 版本链一致
- 媒体、通知、RTC 可复验
- 失败态不伪成功
- 跨层 blocker 有 runbook

---

## 8. 后续计划书固定要求

以后用户要求“下达版本开发计划书”时，必须默认包含：

1. 版本定位
2. 背景与承接基线
3. 当前已完成到哪里
4. 本轮做什么
5. 本轮不做什么
6. 工作包拆分
7. 每个工作包的任务边界和验收标准
8. 硬性保护面
9. 数据 / 接口 / 表边界
10. 跨层 blocker 处理条款
11. UI protected surfaces 条款
12. rollback / recovery policy 条款
13. Codex / Claude / Gemini 分工
14. 给 Codex 的详细 Prompt
15. 给 Claude 的详细 Prompt
16. 给 Gemini 的详细 Prompt
17. 回归清单
18. 截图 / 日志证据要求
19. 最终验收口径

命名格式继续参考：

```text
elite_sync_4_8_版本开发计划书_2026_04_28.md
elite_sync_4_9_版本开发计划书_2026_04_28.md
elite_sync_5_0_版本开发计划书_2026_04_28.md
```

---

## 9. 后续验收口径

继续使用三类结论：

## 9.1 pass

用于：

- 主链完成
- 回归完成
- 证据链完整
- handoff / closeout 完整
- 保护面未受影响

## 9.2 pass with observations

用于：

- 可正式归档
- 仍有非阻断观察项
- 观察项适合后续版本顺手优化，而不是重开旧版

4.6P 与 4.7 当前均属于此类。

## 9.3 conditional pass

用于：

- 核心实现已完成
- 但截图、日志、closeout、handoff 或关键证据链不足
- 当前不宜直接归档

如果某版本只是代码主链通，但缺 evidence，不得写成正式 pass。

---

## 10. 给新会话顾问的默认判断

如果没有新的项目源文件推翻当前基线，新会话顾问应默认：

1. 3.9 已收口
2. 4.0 媒体基础设施已收口
3. 4.1 非官方四维人格问卷已收口
4. 4.2 图片消息已收口
5. 4.3 动态流基础版已收口
6. 4.4 / 4.4S 视频消息与媒体链稳定性已收口
7. 4.5 通知与转化已收口
8. 4.6P 真语音可听闭环已收口
9. 4.7 测试前稳定化与质量门禁已收口
10. 下一步不应回头重开旧版本，而应规划 4.8 / 4.9 / 5.0 前路线

---

## 11. 4.8 最推荐方向简述

当前最推荐的下一版不是继续扩功能，而是：

> **4.8 Alpha Smoke 与测试前真实路径复验版**

建议目标：

- 双账号真实路径全链路 walkthrough
- 登录、资料、问卷、匹配、动态、消息、图片、视频、通知、语音通话、设置、版本中心全链路 smoke
- 通知 slug 降噪
- live-call runtime state 补证据
- UI baseline regression
- release gate 最终检查
- cloud runbook 与 blocker report 流程复核

本版仍然不建议做：

- 大推荐算法
- 多人 RTC
- 视频通话增强
- 新内容社区
- 付费 / 会员 / 运营后台

---

## 12. 最终交接结论

当前项目已完成 4.x 主要功能主干：

- 表达：动态
- 沟通：文本、图片、视频消息
- 召回：通知中心
- 实时：1v1 语音通话
- 稳定化：UI protected surfaces 与 rollback policy

后续重点应从“继续补功能”转为：

1. 稳定测试基线
2. 保护现代 UI
3. 防止跨层盲修
4. 云端后端与本地前端严格隔离
5. Alpha 测试前 smoke / release gate / runbook 完整化

下一位顾问应优先规划 4.8 / 4.9 / 5.0 前路线，而不是重开 4.7 或回滚旧版本。
