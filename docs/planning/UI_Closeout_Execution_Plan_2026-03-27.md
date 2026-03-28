# EliteSync UI修改方案（新UI统一性收尾）

日期：2026-03-27  
依据：
- `UI_example/开发命令.md`
- `UI_example/新_UI_统一性收尾清单_按页面优先级.md`
- 当前工程状态（版本 `0.02.01`）

执行状态（更新于 2026-03-27 夜间）：
- Round 1~Round 6 核心事项已全部落地。
- 详细完成度见：`docs/planning/UI_Closeout_Status_2026-03-27.md`

## 1. 目标与边界

### 1.1 本轮目标
在不推翻现有 Flutter 架构的前提下，完成 Beta 前 UI 统一性收尾：
1. 全局组件一致性收口
2. Match 与 Messages 两个高频核心页产品化精修
3. Home/Discover/Profile/Settings 体验统一
4. 动效与搜索态统一

### 1.2 约束
1. 不重构目录结构，不重做 Design System 主体。
2. 所有样式改动必须通过 design_system 组件/tokens 落地。
3. 不做“算法调试面板”式 UI 回退。
4. 仅做小步迭代：每轮一个任务包，逐轮验收。

---

## 2. 当前完成度判断（基于开发命令轨道）

1. T01-T18 + Route Guard 主体已完成。
2. Flutter 主渲染链路稳定，Android 宿主已合并。
3. 当前问题集中在“统一性与产品感收尾”，不是“缺页面”。

---

## 3. 执行顺序（6轮）

## Round 1（P0）全局组件统一收口
目标：先解决“看起来不是一套系统”的问题。

### 改动范围
1. `design_system/components/fields`：统一搜索框变体（focus/filled/loading/clear/filter/refresh）
2. `design_system/components/tags`：统一 chip/tab 状态与动画
3. `design_system/components/buttons`：统一主次按钮、ghost、danger 变体
4. `design_system/components/cards`：统一 Hero/Content/ListItem/Settings 四类容器
5. `design_system/components/states`：统一 skeleton/empty/error/retry
6. `design_system/components/feedback`（新增）：统一 toast/snackbar/inline notice
7. `design_system/components/controls`（新增）：统一 switch 样式与状态

### 验收
1. Home/Discover/Messages/Search 组件同源。
2. Settings/Privacy 开关只使用单一 DS switch。
3. 错误/空态文案和按钮风格统一。

---

## Round 2（P0）Match 页面产品化精修
目标：从“结果展示页”升级为“关系揭晓页”。

### 改动范围
1. `features/match/presentation/pages/match_result_page.dart`
2. `features/match/presentation/pages/match_detail_page.dart`
3. `features/match/presentation/widgets/*`

### 关键改动
1. 首屏 Hero 重构：
- 本周匹配状态
- 关系结论主文案
- 分数下沉（非主标题）
- 2~3 个关系亮点标签
- 主 CTA：愿意认识
2. Detail 分层重写：
- 为什么值得认识
- 相处舒服点
- 风险/留意点
- 开场建议
3. 权重/分数保留但下沉，不压主叙事。

### 验收
1. 3秒内能理解“为什么值得认识”。
2. 首屏不出现算法面板感。

---

## Round 3（P0）Messages 结构重构
目标：从“通知列表感”改为“聊天入口感”。

### 改动范围
1. `features/chat/presentation/pages/conversation_list_page.dart`
2. `features/chat/presentation/widgets/conversation_list_item.dart`
3. 相关筛选与搜索组件调用

### 关键改动
1. 头部三层结构：
- 搜索+操作
- 会话摘要
- 全部/未读/已读 tab
2. 会话 item 信息层级：
- 左：头像/标识
- 中：昵称+摘要
- 右：时间+未读
3. 空态产品化（去匹配/破冰建议 CTA）。

### 验收
1. 第一眼像 IM 会话页。
2. 会话项信息主次稳定。

---

## Round 4（P1）Home + Discover 精修
目标：强化“首页 vs 发现”差异，提升品牌识别。

### 改动范围
1. `features/home/presentation/pages/home_page.dart`
2. `features/home/presentation/widgets/*`
3. `features/discover/presentation/pages/discover_page.dart`
4. `features/discover/presentation/widgets/*`

### 关键改动
1. Home 首屏增加品牌 Hero（匹配状态/今日提醒/问卷进度）。
2. 内容卡增加统一标签体系（关系研究/沟通技巧/匹配提升等）。
3. Discover 场景化（活动/同城/话题）与 CTA 明确化。

### 验收
1. Home 与 Discover 定位差异清晰。
2. 首页首屏有视觉锚点而非纯列表流。

---

## Round 5（P1）Profile + Settings 收尾
目标：增强资料页稳定性和设置页系统感。

### 改动范围
1. `features/profile/presentation/pages/profile_page.dart`
2. `features/profile/presentation/pages/settings_page.dart`
3. `features/profile/presentation/widgets/*`

### 关键改动
1. Profile 顶部减噪，mock 数据真实化，结果卡状态标签统一。
2. Settings 分割线减弱，item 组件统一。
3. 危险操作（退出登录等）使用 DS destructive 变体与统一确认弹窗。

### 验收
1. Profile 不因长昵称等异常值破版。
2. Settings 不再“系统设置+自定义控件”混搭。

---

## Round 6（P2）搜索态与动效统一
目标：统一行为，不追求重动画。

### 改动范围
1. 路由过渡配置（router/shell）
2. Home/Discover/Messages 搜索展开与历史行为
3. CTA loading 与反馈节奏

### 关键改动
1. 统一 push/pop/tab 切换时长与曲线。
2. 搜索态一致：placeholder、清空、取消、历史空态、无结果态。
3. toast/snackbar 出现位置与时长统一。

### 验收
1. 三个搜索页面学习成本一致。
2. 页面切换不出现“不同团队写的感觉”。

---

## 4. 每轮交付格式（执行要求）

每轮必须输出：
1. 本轮目标
2. 修改文件清单
3. 关键改动说明
4. 验收点（你可直接手测）
5. 下一轮建议

---

## 5. 风险与回退策略

1. 风险：一次改动过大导致 UI 回归点难定位。
2. 控制：严格按轮次提交，单轮仅改一个任务包。
3. 回退：每轮可独立回退，不影响主链路。

---

## 6. 建议本周执行节奏

1. Day 1：Round 1 + Round 2
2. Day 2：Round 3 + Round 4
3. Day 3：Round 5 + Round 6 + 全局验收

完成标准：
- 满足顾问文档第 11 节（视觉一致性、产品感、信息层级、可用性）后，再进行下一次对外版本发布。
