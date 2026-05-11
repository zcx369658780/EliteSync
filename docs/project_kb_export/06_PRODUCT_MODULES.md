# 产品模块

更新时间：2026-05-11

## 主模块

| 模块 | 当前状态 | 说明 |
|---|---|---|
| 首页 Home | 已完成 | 入口聚合、轻量联动、个人摘要和转化入口都已可用 |
| 发现 Discover | 5.x 主增强对象 | 复合入口层，包含分栏、搜索、同城、轻治理动作与内容分发结构 |
| 匹配 Match | 已完成 | 匹配解释、首聊草稿、转化入口稳定 |
| 消息 Chat | 5.x 主增强对象 | 首聊 / 回聊队列、关系摘要、AI 破冰、语音与通话联动 |
| 我的 Me / Profile | 5.x 主增强对象 | 资料展示、AI 助理、内容运营、功能中心、个人经营页 |
| 动态流 / Status | 已完成且作为复用主链 | 动态发布、读取、点赞、删除、举报、拉黑和轻量联动都已接入 |

## 专项模块

| 模块 | 当前状态 | 说明 |
|---|---|---|
| 星盘 / Astro | 已完成 | 服务端真值 + Flutter 本地绘制，边界冻结 |
| 非官方四维问卷 / Questionnaire | 已完成 | 版本化问卷、历史、复测、轻量联动已完成 |
| 图片 / 视频消息 / Media | 已完成 | 上传、附件绑定、预览、重试、摘要回读已完成 |
| 账号治理 / Moderation | 已完成 | 举报、拉黑、封禁、审核等治理链路已存在 |
| 版本中心 / Release | 已完成 | 版本号、检查更新、下载包、发布脚本绑定 |
| 语音通话 / RTC | 已完成 | LiveKit 真语音闭环、heartbeats、可观测性已收口 |
| 个人空间外观 / Layout | 基础能力可借鉴 | 可参考 Soul 的外观面板思路，但不要和真正设置中心混为一谈 |
| 玄学扩展 / Advanced Astro | 基建完成 | 3.x 已归档，保持 derived-only / display-only 口径 |

## 5.6+ 玄学解释层模块角色

- Astro：基建完成，进入解释层二次产品化参考对象；继续保持服务端真值和展示层分离。
- Match：5.7 关系解释层承接位，适合承接关系摘要、维度解释、建议 / 避免和轻追问占位。
- Me：5.8 个人解释层已承接，当前落点为 Profile presentation 的 `我的慢约会表达建议`，用于个人表达建议和资料展示建议，但不得改资料真值。
- Chat：5.9 低压开场和轻追问已承接，当前落点为 Chat room presentation 的 `低压开场建议`，点击只填本机可编辑草稿，不自动发送、不自动代聊、不写聊天消息。
- Settings：5.10 已承接解释层用户控制，当前落点为 Settings presentation 的 `解释与建议设置`，用于统一说明、说明型开关占位、免责声明和用户控制入口。

## 5.x 产品化重点

- Discover：分栏、搜索、同城、轻治理、低压私聊入口
- Chat：首聊 / 回聊 / 稍后再聊、关系摘要、AI 续话、关系节奏化语音入口
- Me：个人经营区、标签体系、AI 助理、AI 草稿助手、展示标识、外观层
- Settings：真设置中心与个人空间外观配置分层、权限前解释

## 对 GPT 友好的检索提示

- 找首页：看 `home_page.dart`
- 找聊天：看 `chat_room_page.dart`、`message_bubble.dart`、`message_attachment_shelf.dart`
- 找问卷：看 `questionnaire_page.dart`、`questionnaire_history_page.dart`、`questionnaire_result_page.dart`
- 找版本中心：看 `about_update_page.dart`
- 找星盘：看 `astro_overview_page.dart`、`astro_chart_settings_page.dart`
- 找匹配：看 `match_result_page.dart`
- 找发现：看 `discover_page.dart`、`search_page.dart`
- 找个人页：看 `me_page.dart`、`profile_page.dart`

## 模块使用原则

- 主模块只承载核心转化和进入路径
- 专项模块只承载对应能力，不要跨层混写
- 轻量联动优先，避免把单模块做成大而全工具页
