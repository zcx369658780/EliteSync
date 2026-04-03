# Gemini UI Handoff for EliteSync

更新日期：2026-04-02

本文档用于把当前仓库中与玄学可视化、资料输入、版本计划、依赖许可和接口契约相关的信息一次性交接给 Gemini。目标是：
- Gemini 负责界面与信息架构建议、视觉草图、页面文案收口
- Codex 负责最终代码落地、接口接线、测试和回归
- 所有涉及数据库、真值、重算、备份和发布脚本的修改，默认仍由 Codex 执行

---

## 1. 当前任务背景

当前仓库已经完成了 2.6 / 2.6.1 / 2.6.2 的多轮修订，核心现状如下：

- 个人资料页已经能录入：昵称、性别、生日、出生时间、出生地、城市、婚恋目标。
- 出生地搜索已切换为百度 Web 服务 API，保存后会触发后端画像重算。
- 后端画像已经是服务端 canonical：
  - 八字：`lunar-php`
  - 紫微：服务端 canonical 画像
  - 西占：过渡实现，仍保留 legacy / canonical 说明字段
- 玄学可视化已经从“自绘主视觉”逐步切换到 `fl_chart` 运行时图表。

Gemini 这边最适合做的事情是：
- 重新设计页面信息架构
- 统一玄学可视化风格
- 让页面更像参考图，而不是继续堆卡片
- 输出可落地的视觉方案和页面草图

---

## 2. 当前已接入 / 可用库

### 2.1 Flutter runtime 依赖

| 库 | 当前状态 | 用途 | 许可证 | 备注 |
|---|---|---|---|---|
| `fl_chart` | 已接入 runtime | 八字五行雷达、总览就绪度、星盘位置影响、紫微轮盘 | MIT | 已写入 `LICENSE_DEPENDENCY_STATUS.md`，许可证快照在 `docs/licenses/astrology/fl_chart__LICENSE.txt` |
| `flutter_riverpod` | 已接入 runtime | 状态管理 | BSD-style / Riverpod 项目许可 | 现有架构核心依赖 |
| `go_router` | 已接入 runtime | 页面路由 | BSD-style | 当前页面导航核心 |
| `dio` | 已接入 runtime | 网络请求 | MIT | profile / geo / match 等 API 请求 |
| `shared_preferences` | 已接入 runtime | 本地缓存兜底 | BSD-style | 仅做 fallback，不是真值 |
| `flutter_secure_storage` | 已接入 runtime | 安全存储 | BSD-style | 会话 / token |

### 2.2 玄学 / 数据库相关依赖

| 依赖 | 状态 | 用途 | 许可证 | 备注 |
|---|---|---|---|---|
| `lunar-php` | runtime | 八字 canonical | MIT | 后端服务端真值 |
| `lunar-java` | reference | 玄学计算参考 | MIT | 主要用于比对 / 边界理解 |
| `lunar-python` | reference | 玄学计算参考 | MIT | 主要用于比对 / 边界理解 |
| `Tyme` / `tyme4kt` / `tyme4py` | reference | 中历 / 节气 / 边界参考 | MIT | 参考用，不作为前端 runtime 真值 |
| `sxtwl_cpp` | reference / 对拍 | 边界验证 | BSD-3-Clause | 可用于高精对拍 |
| `Astronomy Engine` | reference | 西占 / 天文参考 | MIT | 参考用 |
| `Swiss Ephemeris` / `pyswisseph` / `Kerykeion` | restricted | 西占高精参考 | AGPL / dual / commercial | 闭源商用要谨慎，默认受限 |
| `fl_chart` | runtime | 玄学可视化图表 | MIT | 当前最主要的 UI 图表库 |

### 2.3 百度地图 / 定位相关

| 组件 | 状态 | 用途 | 备注 |
|---|---|---|---|
| `Baidu LBS Android SDK 8.0.0 / build 4195` | runtime | Android 端地图 / 定位 SDK | 已同步到 `apps/android/app/libs` |
| 百度 Web 服务 API | runtime（后端） | 地点搜索 / 地理编码 | 后端 `/api/v1/geo/places` 通过 AK/SK + sn 调用 |

---

## 3. 当前关键接口契约

### 3.1 资料保存接口

#### `POST /api/v1/profile/basic`
用于保存个人基础资料，并触发后端画像重算。

主要字段：
- `nickname`
- `gender`
- `birthday`
- `birth_time`
- `birth_place`
- `birth_lat`
- `birth_lng`
- `city`
- `relationship_goal`

行为：
- 写入 `users`
- 更新 `users.private_birth_place/private_birth_lat/private_birth_lng`
- 触发后端重算八字 / 星盘 / 紫微
- 返回服务端最新资料回包

### 3.2 画像读取接口

#### `GET /api/v1/profile/astro`
返回当前 canonical 画像，用于总览页、八字页、星盘页、紫微页和诊断页。

常见字段：
- `birthday`
- `birth_time`
- `birth_place`
- `birth_lat`
- `birth_lng`
- `true_solar_time`
- `location_shift_minutes`
- `longitude_offset_minutes`
- `equation_of_time_minutes`
- `position_signature`
- `location_source`
- `accuracy`
- `confidence`
- `western_engine`
- `western_precision`
- `western_confidence`
- `western_rollout_enabled`
- `western_rollout_reason`
- `sun_sign`
- `moon_sign`
- `asc_sign`
- `bazi`
- `wu_xing`
- `da_yun`
- `liu_nian`
- `ziwei`（对象）

`ziwei` 常见子字段：
- `engine`
- `precision`
- `confidence`
- `life_palace`
- `body_palace`
- `summary`
- `major_themes`
- `palaces`

### 3.3 出生地搜索接口

#### `GET /api/v1/geo/places?q=...`
用于出生地搜索，当前只保留百度 Web 服务 API，不再使用本地静态城市兜底。

返回要点：
- 地点名称
- 地址
- 经纬度
- 候选排序已按精确命中做过处理

### 3.4 匹配与解释接口（若后续 UI 需要展示）

#### `GET /api/v1/matches/current`
#### `GET /api/v1/matches/explanation/{target}`
用于展示匹配结果、解释块、模块摘要。

主要字段：
- `match_reasons`
- `module_explanations`
- `explanation_blocks`
- `compatibility_sections`
- `engine_version`
- `confidence_tier`

### 3.5 登录 / 用户摘要接口

用于 ProfilePage / Header / 资料回显：
- 登录响应中的用户摘要
- `lastKnownProfile`
- `profileSummarySnapshot`
- `profileDetailSnapshot`

说明：
- 这些只做 fallback，不是 truth source
- 真值永远以服务端 `/profile/basic` 和 `/profile/astro` 为准

---

## 4. 当前 UI / 页面结构

### 4.1 ProfilePage

当前状态：
- 我的页总入口
- 个人基础资料中心
- 玄学入口中心
- 编辑资料入口
- 设置入口

当前建议：
- 继续收敛成“资料中枢 + 单一玄学入口中心”
- 避免重复入口和诊断入口过多

### 4.2 EditProfilePage

当前状态：
- 昵称 / 性别 / 生日 / 出生时间 / 出生地 / 城市 / 婚恋目标
- 出生地搜索已经接百度 Web API
- 保存资料会触发画像重算

当前建议：
- Gemini 优先做“表单层级 + 输入节奏 + 保存反馈”的视觉方案
- 不要在 UI 里加入第二套计算逻辑

### 4.3 AstroOverviewPage

当前状态：
- 画像状态中枢
- 最近一次更新
- 画像就绪雷达（`fl_chart`）
- 八字 / 星盘 / 紫微入口

当前建议：
- 让总览页更像“状态汇总入口”，而不是“诊断墙”
- Gemini 可以重点设计“总览卡 + 模块卡 + 就绪度图”

### 4.4 AstroBaziPage

当前状态：
- 五行雷达（`fl_chart`）
- 四柱矩阵
- 真太阳时 / 生日 / 出生地 / 位置修正
- 大运 / 流年 / 备注

当前建议：
- 更接近“八字盘面 + 四柱表格”风格
- 用少量高密度信息，避免继续堆长卡片

### 4.5 AstroNatalChartPage

当前状态：
- 本命盘轮盘（`fl_chart` PieChart）
- 位置影响柱状图（`fl_chart` BarChart）
- 出生地 / 经纬度 / 真太阳时 / 位置来源

当前建议：
- 轮盘是主视觉，字段是辅助
- Gemini 可重点设计圆盘层次、外圈标签、中心锚点

### 4.6 AstroZiweiPage

当前状态：
- 十二宫盘轮盘（`fl_chart` PieChart）
- 十二宫摘要网格
- 命宫 / 身宫 / 主题标签

当前建议：
- 视觉重点应是“12 宫主盘 + 命宫 / 身宫高亮”
- 宫位摘要可以保留在下方，但不要压过主盘面

### 4.7 AstroProfilePage

当前状态：
- 服务端画像诊断页
- 展示出生地、经纬度、真太阳时、位置签名、精度、置信、星象、五行、紫微摘要

当前建议：
- 该页适合作为“调试 / 详细字段页”，不应继续抢总览页职责

---

## 5. 当前项目中的计划文件位置

### 5.1 主要开发计划

路径：`bazi_example/`

建议优先参考：
- `顾问Agent玄学算法修改规划_2026-03-28.md`
- `算法2.3版本开发规划_2026-03-29.md`
- `算法2.4版本开发规划_2026-03-30.md`
- `算法2.5版本开发规划_2026-03-30.md`
- `算法2.6版本开发规划_2026-03-31.md`
- `算法2.6.1修改方案草案_2026-04-01.md`
- `算法2.6.1执行清单_2026-04-01.md`
- `算法2.6.2版本修改指令_2026-04-01.md`
- `算法2.6.2开源库建议_2026-04-01.md`
- `算法2.6今晚玄学可视化执行方案_2026-04-01.md`

### 5.2 交接 / 执行模板

路径：`docs/`

建议优先参考：
- `docs/HANDOFF_CURRENT_20260331.md`
- `docs/profile_input_pipeline_2_6.md`
- `docs/EXEC_PLAN_TEMPLATE.md`
- `docs/REGRESSION_CHECKLIST.md`
- `docs/PROTECTED_SURFACES.md`
- `docs/REQUIREMENT_RISK_REVIEW.md`
- `docs/POST_CHANGE_ACCEPTANCE.md`
- `docs/DOC_INDEX_CURRENT.md`

### 5.3 长期记忆 / 合规

建议优先参考：
- `docs/project_memory.md`
- `.codex/LONG_TERM_MEMORY.md`
- `LICENSE_DEPENDENCY_STATUS.md`

---

## 6. 当前开发原则

1. **服务端 canonical 优先**
- 八字 / 星盘 / 紫微 的真值全部来自服务端
- Flutter 只做展示、刷新、缓存兜底

2. **UI 优先使用库，不再自绘主视觉**
- 当前运行时图表已经切到 `fl_chart`
- 不要再新增手绘主盘面作为主视觉
- 如果后续要加新的可视化库，必须先更新 `LICENSE_DEPENDENCY_STATUS.md`

3. **高风险区域先保护**
- 数据库 / 迁移 / 定位 / 权限 / 路由 / 备份 / 发布脚本，不要被 UI 改动顺带重写

4. **前端缓存只做 fallback，不做真值**
- `sessionProvider` / `profileProvider` / `snapshot` 都不能替代服务端画像

5. **新的视觉方案先给 Gemini 出草图，再由 Codex 落地**
- Gemini 负责视觉结构和布局建议
- Codex 负责实现、接线、测试、许可证与回归

---

## 7. 当前适合交给 Gemini 的任务范围

建议优先让 Gemini 产出：
- 玄学总览页的视觉主结构草图
- 八字页的“四柱矩阵 + 五行图 + 辅助信息”布局方案
- 星盘页的“轮盘 + 外圈标签 + 中心锚点 + 辅助字段”布局方案
- 紫微页的“12 宫盘 + 命宫 / 身宫高亮 + 宫位摘要”布局方案
- `ProfilePage` / `EditProfilePage` 的入口与资料区域信息架构

不建议交给 Gemini 的内容：
- 真值计算逻辑
- 数据库迁移
- 后端发布脚本
- 备份 / 恢复 / 回滚脚本
- 路由和状态管理的最终接线

---

## 8. 给 Gemini 的一句话总结

**当前仓库已经把玄学数据链路、后端 canonical、备份与合规文档都打好了，接下来最适合交给 Gemini 的是 UI 的信息架构和视觉草图；最终实现与接线仍由 Codex 负责。**
