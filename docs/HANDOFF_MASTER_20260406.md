# EliteSync 当前总交接文档（总计划 + 2.0 之后计划整合版）

更新时间：2026-04-06

本文档用于把项目总开发计划、2.0 之后的玄学计划、当前接口结构、UI 拓扑、发布状态与长期约束整合到一份可交接、可续接、可检索的总入口文档。适用对象：
- 新接手的开发同学
- Gemini / Codex 协作交接
- 后续版本规划与验收对齐

本文只记录当前有效的计划谱系、当前进度、关键接口、页面拓扑和高风险面。更细的历史过程、验收报告和阶段日报请按文末索引进入对应文件。

当前状态补充：2.7 慢约会核心体验补完版已通过 Gemini 监督验收并正式结项，对应结项交接稿见 `reports/elite_sync_2_7_handoff_20260406.md`。
2.8 信任安全与运营后台补完版已通过 Gemini 监督验收并正式结项，对应最终交接稿见 `docs/HANDOFF_2_8_FINAL_20260406.md`。
当前后续主线版本已转入 `2.9`，定位为 Beta 上线准备，重点推进测试体系、性能与稳定性、安全与合规、灰度与运维。

---

## 1. 项目目标与当前阶段

EliteSync 当前已从“基础功能可用”推进到“玄学画像 / 解释层 / 可视化 / 稳定性收口”阶段。当前工作的重心不是再堆新功能，而是把现有链路稳定下来，形成：

1. 资料录入 -> 服务端画像 -> 前端展示 的单向真源链路
2. 匹配解释、玄学画像和视觉展示的可读性与可维护性
3. 版本发布、回归、备份、恢复的闭环
4. UI 结构统一、信息架构收口、避免多处真值

---

## 2. 计划谱系

### 2.1 总开发计划（基线计划）

当前仍然有效的总计划入口主要有三份：

- `docs/PROJECT_INTRO.md`
- `docs/DEVELOPMENT_PLAN.md`
- `docs/planning/Current_Development_Plan_2026-03-27.md`
- `docs/planning/Astro_Algorithm_Upgrade_Plan_2026-03-28.md`

这些文档决定了项目的大方向：

- APP 以“慢约会”为主线，保留注册 / 问卷 / 匹配 / 确认 / 聊天闭环
- 玄学画像作为匹配解释和可视化的重要补充
- 计算层与展示层分离，前端只做展示与输入，不做第二真源
- 发布、回归、备份、恢复必须可验收

### 2.2 2.0 版本之后的玄学主线

2.0 技术方案的核心原则已经被后续版本继承下来：

1. 底层计算标准化
   - 八字、节气、星盘、宫位、时区、位置修正等不再手写近似公式
2. 计算层与解释层分离
   - 开源库或服务端 canonical 负责计算
   - 我们自己负责展示、评分、文案、证据标签
3. 展示层与排序层分离
   - 用户看到的画像不等于系统排序主分
4. 先做稳定可测版本，再做深度版本
   - 先修正明显错误，再逐步升级玄学深度

### 2.3 2.0 之后的版本演进

#### 2.3
- 重点：解释层重构、置信门禁、灰度演练、回归工具链
- 产出：
  - 解释模板 / 解释块 / compatibility_sections
  - display_guard / confidence_tier / engine_mode
  - 灰度与回滚演练

#### 2.4
- 重点：西占路线决策、发布门禁、兼容层收束、监控补齐
- 关键结论：
  - 西占收口为 `western_lite`
  - Explanation 被纳入发布门禁
  - 历史兼容 / 废弃文档开始收束

#### 2.5
- 重点：关闭 MBTI / 性格测试活跃链路，紫微 canonical 化，测试账号回填，shadow compare，rollback drill
- 关键结论：
  - MBTI 前台口径统一为“性格测试 / 性格特征”
  - 紫微斗数接入 canonical 服务端画像
  - 回填 / shadow compare / rollback drill 形成尾包

#### 2.6
- 重点：数据库双备份、资料输入与玄学入口统一、画像重算幂等、运维与告警、为 2.7 预留结构
- 当前状态：
  - 数据库备份 / 恢复已经跑通
  - 资料输入与保存链路已贯通
  - 出生地搜索已切百度 Web API
  - 保存出生地 / 生日后触发画像重算

#### 2.6.1
- 重点：出生时间与出生地接入八字 / 紫微 / 西占的真太阳时链路
- 当前状态：
  - 出生地 -> 经度修正 -> 真太阳时 -> 画像重算链路已接通
  - 星盘 / 八字 / 紫微页面都能展示出生地、经纬度、真太阳时

#### 2.6.2
- 重点：库优先可视化、视觉收口、依赖合规整合
- 当前状态：
  - `fl_chart` 已接入运行时
  - 八字 / 总览 / 星盘 / 紫微逐步完成视觉重构
  - Kerykeion 已纳入依赖许可管理，相关合规文件已同步

#### 2.6.3 / 2.6.3a
- 重点：盘面专业化、总览页收口、星盘 SVG 收口、紫微中宫与八字四柱视觉净化
- 当前状态：
  - 星盘页已切为 wheel-only / 1:1 / 黑底盘面
  - 紫微页已切为 4x4 宫盘，命宫 / 身宫高亮
  - 八字页已切为高密度四柱矩阵
  - 设置页已提供本地展示偏好

#### 2.6.4
- 重点：稳定性与发布门禁收口、资料链路稳定化、summary/chart 分流、回滚与烟测文档固化
- 当前状态：
  - `ROLLBACK_PLAN.md`、`RELEASE_SMOKE_CHECKLIST.md`、`REGRESSION_CHECKLIST.md`、`POST_CHANGE_ACCEPTANCE.md` 已纳入门禁体系
  - 2.6.4 执行计划、风险评审、验收报告模板已写入 `docs/version_plans/`
  - 当前任务重心从“继续堆功能”切换为“稳定现有链路并可重复验收”

---

## 3. 当前开发进度回顾

### 3.1 主业务链路

当前已稳定可用的主链路：

- 注册 / 登录
- 问卷作答
- 每周匹配
- 匹配解释
- 双向确认
- 聊天
- 首页内容流

### 3.2 资料与画像链路

当前已形成的资料链路：

```text
EditProfilePage
  -> 百度地点搜索
  -> 选择出生地候选
  -> POST /api/v1/profile/basic
  -> 触发后端重算
  -> GET /api/v1/profile/astro/summary
  -> GET /api/v1/profile/astro/chart (星盘页)
  -> 玄学总览 / 八字 / 星盘 / 紫微 / 诊断页
```

### 3.3 当前已完成的重点工作

- Flutter 主界面迁移已完成
- 我的页、编辑页、玄学总览、八字页、星盘页、紫微页已接通
- 玄学总览 / 八字 / 紫微 / 星盘的页面结构已经做过一轮收口
- 百度地点搜索已改成 Web API 真实搜索
- 保存出生地 / 生日后会触发画像重算
- `summary` / `chart` 已做拆分，星盘 SVG 不再拖住其它页面
- Kerykeion SVG 已接入星盘页
- 版本发布、备份与恢复演练已纳入长期文档

---

## 4. 当前架构与接口

### 4.1 Flutter 侧页面结构

#### `ProfilePage`
- 我的页入口
- 个人资料中枢
- 玄学入口中心
- 编辑资料入口
- 设置入口

#### `EditProfilePage`
- 昵称 / 性别 / 生日 / 出生时间 / 出生地 / 城市 / 婚恋目标
- 百度地点搜索
- 保存后触发画像重算

#### `AstroOverviewPage`
- 画像状态中枢
- 最近一次更新
- 模块概览入口
- 五行能量条
- 视觉门户入口

#### `AstroBaziPage`
- 四柱矩阵
- 五行能量
- 大运 / 流年
- 底部技术参数

#### `AstroNatalChartPage`
- 本命盘 SVG / 轮盘
- 行星 / 宫位 / 相位摘要
- 位置修正与技术参数
- 盘面设置入口

#### `AstroZiweiPage`
- 十二宫盘轮盘 / 宫盘网格
- 命宫 / 身宫高亮
- 宫位摘要
- 底部技术字段

#### `AstroProfilePage`
- 服务端画像诊断页
- 用于查看完整 canonical 数据和调试信息

### 4.2 后端接口分层

#### 资料保存
- `POST /api/v1/profile/basic`

作用：
- 保存个人基础资料
- 写入 `users`
- 更新出生地镜像字段
- 触发后端画像重算

#### 画像 summary
- `GET /api/v1/profile/astro/summary`

作用：
- 提供总览页、八字页、紫微页、诊断页的结构化画像
- 不携带星盘 SVG
- 避免 chart 链路拖慢 summary 链路

#### 画像 chart
- `GET /api/v1/profile/astro/chart`

作用：
- 仅为星盘页提供 Kerykeion / SVG 相关结果
- 包含 `natal_chart_svg`、`planets_data`、`houses_data`、`aspects_data`

#### 兼容总入口
- `GET /api/v1/profile/astro`

作用：
- 兼容旧入口
- 当前可按需要返回 summary / chart 的组合结果

#### 出生地搜索
- `GET /api/v1/geo/places`

作用：
- 百度 Web 服务地点搜索
- 返回候选名称、地址、经纬度

### 4.3 关键数据真源

#### `users`
基础资料、公共画像、镜像字段都在这里。

#### `user_astro_profiles`
canonical 画像主表。

原则：
- 前端缓存只做兜底
- 服务端数据是唯一真源

---

## 5. 关键长期约束

1. UI 重构不得默认碰数据库 schema / 迁移 / 初始化 / 定位权限链路。
2. 改按钮、入口、页面跳转时，必须核对旧行为是否保留。
3. 涉及数据库或关键状态变更，优先备份、恢复、回滚。
4. 出生地、坐标、八字、紫微、星盘必须以服务端真源为准。
5. 前端缓存只能兜底，不能成为新真源。
6. 任何高风险改动都要在验收里单独列出保住了什么、丢了什么、未验证什么。

---

## 6. 当前版本与发布状态

- 当前发布版本：`0.02.09`
- 当前分支：`feat/pair-chart-explainability`
- 近期开的 release / hotfix 仍围绕 `0.02.09`
- 发布变更记录和 hotfix 主要集中在：
  - regression smoke 稳定化
  - 玄学 UI 收口
  - 星盘 / 八字 / 紫微 / 总览的专业化展示

---

## 7. 版本计划入口与阅读顺序

建议后续阅读顺序：

1. `docs/PROJECT_INTRO.md`
2. `docs/DEVELOPMENT_PLAN.md`
3. `docs/planning/Current_Development_Plan_2026-03-27.md`
4. `docs/planning/Astro_Algorithm_Upgrade_Plan_2026-03-28.md`
5. `docs/version_plans/算法2.3版本开发规划_2026-03-29.md`
6. `docs/version_plans/算法2.4版本开发规划_2026-03-30.md`
7. `docs/version_plans/算法2.5版本开发规划.md`
8. `docs/version_plans/算法2.6版本开发规划_2026-03-31.md`
9. `docs/version_plans/算法2.6.1修改方案草案_2026-04-01.md`
10. `docs/version_plans/算法2.6.2版本修改指令_2026-04-01.md`
11. `docs/version_plans/算法2.6.3开发规划与gemini监督方案.md`
12. `docs/version_plans/算法2.6.3a开发规划与gemini监督方案.md`
13. `docs/version_plans/2.6.4_EXEC_PLAN.md`
14. `docs/version_plans/2.6.4_RISK_REVIEW.md`
15. `docs/version_plans/2.6.4_ACCEPTANCE_REPORT.md`
16. `docs/version_plans/elite_sync_2_8_版本开发计划_信任安全与运营后台版_2026_04_06.md`
17. `docs/version_plans/2.8_EXEC_PLAN.md`
18. `docs/version_plans/2.8_RISK_REVIEW.md`
19. `docs/version_plans/2.8_ACCEPTANCE_REPORT.md`

---

## 8. 文档与运维规范

- `docs/EXEC_PLAN_TEMPLATE.md`：每次任务的计划模板
- `docs/REGRESSION_CHECKLIST.md`：修改后回归验收清单
- `docs/ROLLBACK_PLAN.md`：回滚计划
- `docs/RELEASE_SMOKE_CHECKLIST.md`：发布烟测清单
- `docs/PROTECTED_SURFACES.md`：高风险模块保护清单
- `docs/REQUIREMENT_RISK_REVIEW.md`：需求评审与风险拆解规范
- `docs/POST_CHANGE_ACCEPTANCE.md`：修改后验收评估规范
- `AGENTS.md`：仓库级多 subagent 安全开发工作流

---

## 9. 当前工作区状态（截至写入时）

- 主业务与玄学页面都已可用
- `summary` / `chart` 分流已生效
- 星盘 SVG 的展示已独立于 summary
- regression smoke 的登录 / MBTI 410 兼容问题已处理并推送热修
- 当前可继续推进的重点是：
  - 视觉细节收尾
  - 算法字段完善
  - 回归验证与发布收口

---

## 10. 交接截图索引

以下截图文件保留在仓库根目录，可直接用于和顾问/Gemini 对照当前状态：

### 10.1 主题与设置
- `settings_page.png` - module 侧设置页，包含 `外观 / 夜间模式`

### 10.2 匹配与解锁
- `match_portal_updated.png` - 匹配门户页，显示 `Drop 与揭晓`
- `unlock_page.png` - 解锁页，显示完整解释与破冰问题

### 10.3 匹配流程与首页
- `home_or_match.png` - 首页 / 匹配入口过渡态
- `post_mock_login.png` - mock 登录后的主界面状态
- `restart_screen.png` - 重启后登录/启动状态

### 10.4 玄学页面
- `match_portal.png` - 匹配门户旧版对照
- `match_result.png` - 匹配结果页
- `match_detail.png` - 匹配解释详情

### 10.5 其他历史交接截图
- `mainapp_home.png`
- `mainapp_match.png`
- `mainapp_current_after_run.png`
- `match_portal_current.png`
- `match_portal_mock.png`
- `match_portal_mock_2.png`
- `post_login.png`
- `current_screen.png`
- `_current_screen.png`

> 说明：上面保留的是当前根目录中仍可用的截图文件名；如果只做今天的 2.6.4 / 2.7 交接，优先使用 `settings_page.png`、`match_portal_updated.png`、`unlock_page.png`、`home_or_match.png`、`post_mock_login.png`、`restart_screen.png`。

---

## 11. 索引说明

本项目的长期文档索引请以 `docs/DOC_INDEX_CURRENT.md` 为准。





