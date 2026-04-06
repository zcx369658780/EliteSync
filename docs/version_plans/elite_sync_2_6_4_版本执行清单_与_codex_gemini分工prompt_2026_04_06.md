# EliteSync 2.6.4 版本执行清单 + Codex / Gemini 分工 Prompt

更新时间：2026-04-06
适用版本：`0.02.06` 后续稳定性收口版本（建议内部命名：`2.6.4`）
当前分支基线：`feat/pair-chart-explainability`
文档用途：作为 2.6.4 版本的直接执行蓝本，供 GPT / Codex / Gemini / 多 subagent 协作使用。

---

## 1. 2.6.4 的版本定位

### 1.1 一句话目标

**2.6.4 不是继续堆功能，而是把 2.6.3 / 2.6.3a 已有成果稳定下来，建立可重复的回归、验收、发布与回滚门禁。**

### 1.2 本版本只做三件事

1. 稳定关键链路
2. 固化高风险保护面
3. 建立发布前后的门禁与验收规范

### 1.3 本版本不做的事情

以下内容在 2.6.4 中原则上不作为重点开发目标：

- 不新增大型玄学模块
- 不大改数据库 schema
- 不重构登录体系
- 不全面铺开运营后台
- 不正式推进学信网 / 高校邮箱真实接入
- 不做大型聊天系统升级
- 不做商业化付费体系
- 不做复杂社交广场

### 1.4 完成标准

2.6.4 完成，不以“页面更多”为标准，而以以下结果为标准：

- 资料保存与画像重算链路稳定
- 玄学四个主要页面无阻塞级 bug
- `summary` / `chart` 分流稳定
- 回归清单可重复执行
- 回滚方案可实际操作
- 发布前后有明确观测指标

---

## 2. 2.6.4 范围定义

## 2.1 必做范围（P0）

### A. 资料链路稳定化

覆盖以下链路：

- 进入 `EditProfilePage`
- 修改昵称 / 性别 / 生日 / 出生时间 / 出生地 / 城市 / 婚恋目标
- 百度地点搜索返回候选
- 选择地点候选后保存
- `POST /api/v1/profile/basic`
- 保存成功后触发服务端画像重算
- 回读 `GET /api/v1/profile/astro/summary`
- 回读 `GET /api/v1/profile/astro/chart`
- 总览 / 八字 / 星盘 / 紫微 / 诊断页展示一致

### B. 高风险表面保护

本版本必须显式保护以下 protected surfaces：

#### 1）数据与状态
- 数据库初始化
- migration
- 登录态恢复
- 本地缓存与服务端同步
- 画像重算触发条件

#### 2）关键接口
- `POST /api/v1/profile/basic`
- `GET /api/v1/profile/astro/summary`
- `GET /api/v1/profile/astro/chart`
- `GET /api/v1/geo/places`
- 匹配解释页依赖接口
- 聊天入口路由依赖接口

#### 3）关键页面
- `ProfilePage`
- `EditProfilePage`
- `AstroOverviewPage`
- `AstroBaziPage`
- `AstroNatalChartPage`
- `AstroZiweiPage`
- `AstroProfilePage`

#### 4）关键能力
- 出生地搜索
- 真太阳时展示
- 玄学总览回读
- 星盘 SVG 独立加载
- 页面 loading / empty / error 态
- 设置页本地展示偏好

### C. 发布门禁建立

本版本必须沉淀：

- `PROTECTED_SURFACES.md`
- `REGRESSION_CHECKLIST.md`
- `POST_CHANGE_ACCEPTANCE.md`
- `ROLLBACK_PLAN.md`
- `RELEASE_SMOKE_CHECKLIST.md`

## 2.2 可做范围（P1）

以下可以做，但只能在 P0 完成后少量推进：

- 页面间距、字号、卡片边界统一
- skeleton / empty / error 态统一
- summary 与 chart 首屏等待逻辑细化
- 玄学技术字段文案小幅优化
- 设置页展示偏好与实际渲染行为对齐

## 2.3 明确禁止范围

在 2.6.4 开发期间，以下事项默认禁止，除非另行单独立项：

- 修改数据库 schema
- 删除旧字段或旧兼容逻辑
- 把前端缓存升级为真源
- 改写匹配主流程
- 大改聊天房间模型
- 一边做 UI 改版一边改权限链路
- 未备份就改高风险代码

---

## 3. 2.6.4 任务拆解

## 3.1 模块一：资料保存与画像重算稳定化

### 目标

确保出生资料修改后，后端画像重算和前端展示一致，不出现“保存成功但页面未更新”“页面更新但字段不一致”“summary 与 chart 显示冲突”等问题。

### 任务清单

- 核对 `EditProfilePage` 所有可编辑字段与保存 payload 是否一致
- 核对出生地候选选择后的经纬度写入逻辑
- 核对保存成功后的页面刷新触发顺序
- 核对 `summary` 与 `chart` 拉取时机
- 核对重算中的 loading 态与超时提示
- 核对异常回退逻辑（服务端失败 / 弱网 / 空结果）
- 核对本地缓存是否只做兜底，不覆盖服务端真源

### 完成定义

- 同一用户多次修改出生资料后，前后页面字段一致
- summary 与 chart 不出现互相冲突
- 服务端失败时页面能给出可理解提示
- 不会出现“旧数据残留覆盖新数据”

---

## 3.2 模块二：四大页面稳定性收口

### 目标

确保四大页面在不同数据状态下可用：

- AstroOverviewPage
- AstroBaziPage
- AstroNatalChartPage
- AstroZiweiPage

### 任务清单

#### Overview
- 状态卡片展示顺序统一
- 最近一次更新时间字段稳定
- 五行能量条空值、异常值处理
- 入口跳转正确

#### Bazi
- 四柱矩阵布局稳定
- 五行能量图在空值时不崩
- 大运 / 流年区块在缺数据时降级显示
- 底部技术参数格式一致

#### Natal Chart
- `chart` 接口单独加载
- SVG 加载失败时不拖垮整页
- 轮盘 1:1 与黑底样式在不同屏宽下稳定
- 行星 / 宫位 / 相位摘要与 SVG 状态一致

#### Ziwei
- 4x4 宫盘网格稳定
- 命宫 / 身宫高亮正确
- 中宫与宫位摘要不重叠
- 技术字段在窄屏下不溢出

### 完成定义

- 四页在真机和模拟器上都无严重布局错乱
- loading / empty / error / success 四态完整
- 任一页面失败不拖垮整个 Astro 模块

---

## 3.3 模块三：发布门禁与回归体系

### 目标

把“靠记忆验收”改成“靠清单验收”。

### 任务清单

#### A. 固化文档
- 建立 `docs/PROTECTED_SURFACES.md`
- 建立 `docs/REGRESSION_CHECKLIST.md`
- 建立 `docs/POST_CHANGE_ACCEPTANCE.md`
- 建立 `docs/ROLLBACK_PLAN.md`
- 建立 `docs/RELEASE_SMOKE_CHECKLIST.md`

#### B. 固化操作
- 每次修改前先列 impact surfaces
- 每次修改后走 smoke checklist
- 每次发布前做备份确认
- 每次发布后记录观察指标
- 每次 hotfix 后补充 acceptance note

#### C. 固化验收输出
每次改动后必须输出：

- 保住了什么
- 可能影响了什么
- 还没验证什么
- 回滚到哪里
- 谁执行了验收
- 哪些页面有截图对比

### 完成定义

- 新人接手也能按清单执行回归
- 任何高风险改动都能找到对应保护面
- 任何发布都能说清楚“出了问题怎么回”

---

## 3.4 模块四：日志、观测与最小监控

### 目标

虽然 2.6.4 不做完整监控平台，但至少要让关键失败可见。

### 任务清单

- 关键接口调用日志统一
- 资料保存失败日志结构化
- 地点搜索失败日志结构化
- chart 加载失败日志结构化
- 页面级 error 埋点最小化接入
- 版本号 / 分支 / 构建号可快速识别

### 最低观测项

- `profile_basic_save_success_rate`
- `geo_places_search_success_rate`
- `astro_summary_fetch_success_rate`
- `astro_chart_fetch_success_rate`
- `chart_svg_render_fail_count`
- `post_save_recompute_timeout_count`

### 完成定义

- 出现失败时能知道大概发生在哪一层
- 能区分是接口失败、渲染失败还是状态同步失败

---

## 4. 2.6.4 验收清单（可直接执行）

## 4.1 冒烟验收

### 登录与入口
- 能进入 App
- 登录态恢复正常
- `ProfilePage` 可进入
- 设置页可进入

### 编辑资料
- 编辑昵称后保存成功
- 编辑生日后保存成功
- 编辑出生时间后保存成功
- 搜索出生地能返回候选
- 选择候选地点后保存成功
- 返回个人页信息正确

### 画像回读
- 总览页可打开
- 八字页可打开
- 星盘页可打开
- 紫微页可打开
- 诊断页可打开

### 页面状态
- loading 态不空白过久
- 空数据不崩
- 错误态可恢复
- 返回上一页不会状态错乱

---

## 4.2 高风险专项验收

### 资料修改后的一致性
- 修改出生地后，总览、八字、星盘、紫微中的出生地一致
- 修改出生时间后，真太阳时相关字段一致
- 修改生日后，summary 与 chart 对应字段一致

### chart 独立性
- chart 拉取失败时，summary 页仍可看
- 星盘页失败时，不影响八字与紫微

### 缓存与真源
- 清缓存后重新进入，服务端数据仍正确
- 多次保存后不会被旧缓存覆盖

### 发布安全
- 发布前备份完成
- 回滚步骤可执行
- hotfix 后 smoke 再次通过

---

## 4.3 验收输出模板

```md
# 2.6.4 验收报告

## 本次改动范围
-

## 保住了什么
-

## 可能影响了什么
-

## 未验证项
-

## 发现的问题
-

## 是否允许进入 release
- yes / no

## 回滚点
-
```

---

## 5. 2.6.4 发布前检查清单

```md
# Release Smoke Checklist

- [ ] 当前分支与目标版本号一致
- [ ] 高风险改动已做备份
- [ ] `POST /api/v1/profile/basic` 已验证
- [ ] `GET /api/v1/profile/astro/summary` 已验证
- [ ] `GET /api/v1/profile/astro/chart` 已验证
- [ ] `GET /api/v1/geo/places` 已验证
- [ ] Overview / Bazi / Natal / Ziwei 页面已验证
- [ ] 登录态恢复已验证
- [ ] 设置页展示偏好已验证
- [ ] 回滚步骤已更新
- [ ] 验收报告已填写
- [ ] 发布后观测指标已准备
```

---

## 6. 2.6.4 建议目录输出

建议在仓库内补齐以下文档：

```text
docs/
  PROTECTED_SURFACES.md
  REGRESSION_CHECKLIST.md
  POST_CHANGE_ACCEPTANCE.md
  ROLLBACK_PLAN.md
  RELEASE_SMOKE_CHECKLIST.md
  versions/
    2.6.4_EXEC_PLAN.md
    2.6.4_RISK_REVIEW.md
    2.6.4_ACCEPTANCE_REPORT.md
```

---

## 7. Codex 执行 Prompt（主实现）

下面这段可直接发给 Codex。

```md
你现在是 EliteSync 项目的主实现 agent，当前目标是完成 2.6.4 稳定性收口版，而不是继续扩功能。

# 项目背景
当前版本基线为 0.02.06，项目已经完成主业务闭环与玄学画像主链路：注册/登录、问卷、每周匹配、匹配解释、双向确认、聊天、首页内容流、资料编辑、画像 summary/chart 分流、总览/八字/星盘/紫微/诊断页均已可用。
当前阶段的核心任务是：
1. 稳定资料录入 -> 服务端画像 -> 前端展示链路
2. 建立 protected surfaces
3. 固化 regression / smoke / acceptance / rollback 文档

# 版本目标
请完成 2.6.4 的实现与收口，严格遵循：
- 不新增大型功能
- 不大改数据库 schema
- 不把前端缓存变成真源
- 不误伤定位、地图、权限、数据库初始化、登录态恢复
- 以稳定性、验收、回滚能力为第一优先级

# 必须保护的 surfaces
1. 数据与状态：数据库初始化、migration、登录态恢复、本地缓存与服务端同步、画像重算触发条件
2. 接口：
   - POST /api/v1/profile/basic
   - GET /api/v1/profile/astro/summary
   - GET /api/v1/profile/astro/chart
   - GET /api/v1/geo/places
3. 页面：
   - ProfilePage
   - EditProfilePage
   - AstroOverviewPage
   - AstroBaziPage
   - AstroNatalChartPage
   - AstroZiweiPage
   - AstroProfilePage

# 具体任务
A. 稳定 EditProfilePage 保存链路：
- 核对表单字段与 payload 映射
- 核对出生地选择后的经纬度写入
- 核对保存后重算触发与刷新顺序
- 处理弱网、失败、空数据、超时场景

B. 稳定 summary/chart 分流：
- 确保 chart 独立失败不影响 summary 页面
- 确保星盘页失败不拖垮八字/紫微/总览
- 核对新旧数据刷新时机，避免旧缓存覆盖新结果

C. 收口四大页面：
- loading / empty / error / success 四态补齐
- 布局溢出、黑屏、卡死、重叠、空指针问题修复
- 设置页展示偏好与实际渲染行为对齐

D. 文档输出：
- docs/PROTECTED_SURFACES.md
- docs/REGRESSION_CHECKLIST.md
- docs/POST_CHANGE_ACCEPTANCE.md
- docs/ROLLBACK_PLAN.md
- docs/RELEASE_SMOKE_CHECKLIST.md

# 工作方式要求
1. 先输出 impact analysis，再改代码。
2. 每次改动前先列出可能误伤的 surfaces。
3. 每完成一个模块，就补一段 acceptance note。
4. 所有高风险改动必须说明回滚点。
5. 不要大面积无关重构。
6. 优先做最小可验证修改。

# 输出格式要求
请按以下顺序输出：
1. 本次准备修改的范围
2. 风险点
3. 计划改动文件
4. 具体实现
5. 回归检查结果
6. 仍未验证的点
7. 回滚建议

# 成功标准
只有当以下条件成立时，才算完成：
- 资料保存后画像回读一致
- summary/chart 分流稳定
- 四大页面无阻塞级 bug
- regression / smoke / acceptance / rollback 文档已补齐
- 能清楚说明保住了什么、影响了什么、没验证什么
```

---

## 8. Gemini 监督 Prompt（UI/回归/遗漏检查）

下面这段可直接发给 Gemini。

```md
你现在是 EliteSync 项目的监督与验收 agent，不负责大规模改代码，主要负责发现 UI、交互、状态同步、视觉一致性和遗漏问题。

# 当前版本任务
请围绕 EliteSync 2.6.4 稳定性收口版执行监督检查。这个版本的目标不是新增功能，而是保护已有链路，防止 UI 重构误伤关键功能。

# 重点关注对象
1. EditProfilePage
2. AstroOverviewPage
3. AstroBaziPage
4. AstroNatalChartPage
5. AstroZiweiPage
6. 设置页与展示偏好
7. summary/chart 分流后的页面行为

# 你要重点检查的问题
A. 页面一致性
- 字号、边距、卡片层级是否统一
- 深浅色或黑底场景是否有文字不可见
- 页面是否存在挤压、遮挡、重叠、溢出
- loading / empty / error / success 四态是否完整

B. 交互一致性
- 保存按钮是否可理解
- 保存后的反馈是否明确
- 失败提示是否友好
- 返回路径是否正确
- 页面刷新后是否展示旧数据

C. 状态同步
- 修改出生地后，Overview/Bazi/Natal/Ziwei 是否一致
- 修改出生时间后，技术字段是否一致
- chart 失败时 summary 是否仍能正常展示
- 切换页面后是否发生状态丢失或旧状态残留

D. 风险提示
- 哪些 UI 修改可能误伤定位、权限、保存链路、接口时序
- 哪些看似只是视觉调整，实际上会影响逻辑行为

# 你的输出要求
请不要只说“看起来不错”。请按以下结构输出：
1. 发现的明显问题
2. 可能的隐性风险
3. 视觉一致性问题
4. 交互不清晰问题
5. 建议优先修复项（按 P0/P1/P2 排序）
6. 你认为已经保住的关键点
7. 仍需人工真机验证的点

# 你的角色边界
- 你可以提出精确修正建议
- 你可以指出具体页面和具体状态问题
- 你不要推动大规模 UI 重构
- 你不要引入新的产品范围
- 你要优先帮助团队降低回归风险

# 成功标准
你的监督结论必须能帮助团队回答：
- 这次改动保住了没有？
- 有没有新的视觉或交互倒退？
- 哪些地方还不能放心发版？
```

---

## 9. GPT 协调 Prompt（总控/评审）

下面这段可作为发给 GPT 的总控提示词。

```md
你现在是 EliteSync 项目的总控架构评审 agent。项目当前正在推进 2.6.4 稳定性收口版。

你的职责不是直接写大量代码，而是：
1. 帮我拆解需求与版本范围
2. 审查 Codex 的修改是否超范围
3. 审查 Gemini 的风险提示是否成立
4. 帮我决定哪些问题必须修、哪些可以延后
5. 在每轮修改后输出一份简洁的 risk review 和 acceptance judgment

请你始终坚持以下原则：
- 2.6.4 只做稳定性与发布门禁收口
- 不默认扩大需求范围
- 不允许 UI 改动误伤数据库、定位、权限、登录态恢复、画像真源
- 不允许把前端缓存变成第二真源
- 高风险改动必须说明回滚点
- 每轮修改后必须输出“保住了什么 / 影响了什么 / 未验证什么”

当我贴出 Codex 修改结果或 Gemini 验收意见时，请你：
1. 判断是否超出 2.6.4 范围
2. 判断是否存在结构性风险
3. 判断当前是否允许进入 release
4. 给出下一步最小改动建议
```

---

## 10. 推荐的多 Agent 执行顺序

### Round 1：GPT
- 输出 2.6.4 范围确认
- 输出 protected surfaces
- 输出本轮只允许改动的文件范围

### Round 2：Codex
- 做 impact analysis
- 实施最小改动
- 输出 acceptance note

### Round 3：Gemini
- 对页面、交互、状态同步做验收
- 列出 UI 与流程回归点

### Round 4：GPT
- 汇总 Codex + Gemini 结果
- 判断是否需要 hotfix
- 判断是否允许进入 release

---

## 11. 最后建议

对于 2.6.4，你们最需要抵抗的诱惑是：

> “既然已经在改了，不如顺手再把更多东西做掉。”

这往往正是高风险版本失控的开始。

2.6.4 的正确姿势应该是：

- **少改，但每一改都可验证**
- **少扩张，但把门禁立住**
- **少追求新效果，多确保不回退**

只要 2.6.4 做稳，后面的 2.7 才能放心去补 Drop 仪式感、盲盒解锁、破冰问题这些真正决定产品气质的能力。

