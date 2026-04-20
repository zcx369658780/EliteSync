# 产品模块

更新时间：2026-04-19

## 主模块

| 模块 | 当前状态 | 说明 |
|---|---|---|
| 首页 Home | 已完成 | 入口聚合、轻量联动、个人摘要和转化入口都已可用 |
| 发现 Discover | 基建完成 | feed / tab / search / cache 已有骨架，偏内容分发 |
| 匹配 Match | 已完成 | 匹配解释、首聊草稿、转化入口稳定 |
| 消息 Chat | 已完成 | 文本消息 + 图片 / 视频消息主链都已接入 |
| 我的 Me / Profile | 已完成 | 资料、设置、版本中心、人格摘要、星盘入口都已归位 |
| 动态流 / Status | 已完成 | 动态发布、读取、点赞、删除、举报、拉黑和轻量联动都已接入 |

## 专项模块

| 模块 | 当前状态 | 说明 |
|---|---|---|
| 星盘 / Astro | 已完成 | 服务端真值 + Flutter 本地绘制，边界冻结 |
| 非官方四维问卷 / Questionnaire | 已完成 | 版本化问卷、历史、复测、轻量联动已完成 |
| 图片 / 视频消息 / Media | 已完成 | 上传、附件绑定、预览、重试、摘要回读已完成 |
| 账号治理 / Moderation | 已完成 | 举报、拉黑、封禁、审核等治理链路已存在 |
| 版本中心 / Release | 已完成 | 版本号、检查更新、下载包、发布脚本绑定 |
| 玄学扩展 / Advanced Astro | 基建完成 | 3.x 已归档，保持 derived-only / display-only 口径 |

## 对 GPT 友好的检索提示

- 找首页：看 `home_page.dart`
- 找聊天：看 `chat_room_page.dart`、`message_bubble.dart`、`message_attachment_shelf.dart`
- 找问卷：看 `questionnaire_page.dart`、`questionnaire_history_page.dart`、`questionnaire_result_page.dart`
- 找版本中心：看 `about_update_page.dart`
- 找星盘：看 `astro_overview_page.dart`、`astro_chart_settings_page.dart`
- 找匹配：看 `match_result_page.dart`

## 模块使用原则

- 主模块只承载核心转化和进入路径
- 专项模块只承载对应能力，不要跨层混写
- 轻量联动优先，避免把单模块做成大而全工具页
