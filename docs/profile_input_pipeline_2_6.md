# profile_input_pipeline_2_6

更新日期：2026-04-01

本文档是 2.6 阶段的整合验收材料，汇总以下内容，供顾问确认可视化修改方案：

- `ProfilePage / EditAstroProfilePage` 的页面结构草图
- `profile_input_pipeline_2_6.md` 的输入管道说明
- 玄学总览页、八字 / 星盘 / 紫微详情页的接口契约
- 备份脚本与发布脚本接线说明
- `.codex/LONG_TERM_MEMORY.md` 中新增的备份规则段落

说明：
- 当前代码里对应的编辑页类名是 `EditProfilePage`，本文将其视作需求里的 `EditAstroProfilePage`。
- 当前实现保持“服务端真源”原则：前端只负责输入、展示、缓存兜底和刷新触发，不在客户端做 canonical 玄学计算。
- 当前页面已经具备可视化基础，但和顾问提供的参考图相比，视觉主结构仍需要继续收口。

---

## 1. 页面结构草图

### 1.1 `ProfilePage`

当前定位：
- 我的页总入口
- 个人基础资料中心
- 玄学入口中心
- 资料更新状态中心

当前结构草图：

```text
ProfilePage
├─ Header（昵称 / 城市 / 认证态）
├─ 基础资料卡
│  ├─ 生日
│  ├─ 出生时间
│  ├─ 出生地
│  └─ 婚恋目标
├─ 玄学入口卡
│  ├─ 玄学总览
│  ├─ 八字详情
│  ├─ 星盘详情
│  ├─ 紫微详情
│  └─ 星盘画像（诊断）
├─ 资料完整度 / 标签
├─ 编辑资料入口
└─ 设置入口
```

当前状态判断：
- 已经能正确跳转到各玄学页
- 入口重复区域已收敛一轮，但仍需继续看是否要进一步压缩成更单一入口

### 1.2 `EditProfilePage`（即需求中的 `EditAstroProfilePage`）

当前定位：
- 个人资料录入中心
- 玄学计算输入中心
- 出生地搜索和候选选择中心

当前结构草图：

```text
EditProfilePage
├─ 昵称
├─ 性别
├─ 生日
├─ 出生时间
├─ 出生地搜索框
│  ├─ 百度地点搜索
│  ├─ 候选列表（名称 / 地址 / 经纬度）
│  └─ 选中后回填输入框
├─ 城市
├─ 婚恋目标
└─ 保存资料
   ├─ 保存基础资料
   ├─ 触发画像重算
   └─ invalidate / refresh 服务端数据
```

当前状态判断：
- 保存生日、出生时间、出生地后，服务端会重算画像
- 出生地搜索已切到百度 Web API
- 仍需继续收口输入 / 回显 / 刷新的视觉一致性

### 1.3 玄学总览页

当前定位：
- `AstroOverviewPage`
- 汇总八字、星盘、紫微与最近一次服务端更新

当前结构草图：

```text
AstroOverviewPage
├─ 最后一次更新
│  ├─ 更新时间
│  ├─ 出生时间
│  ├─ 真太阳时
│  ├─ 出生地
│  └─ 位置修正
├─ 模块概览
│  ├─ 八字
│  ├─ 西洋星盘
│  └─ 紫微斗数
├─ 视觉锚点
│  ├─ 八字五行条目
│  ├─ 紫微宫位数量
│  └─ 西占字段完整度
└─ 诊断页入口
```

### 1.4 八字详情页

当前定位：
- `AstroBaziPage`
- 当前版本已改成“四柱矩阵 + 辅助信息”的主视觉

当前结构草图：

```text
AstroBaziPage
├─ 标题 / 导航 chips
├─ 八字总览
│  ├─ 四柱摘要
│  └─ 真太阳时 / 精度 / 置信
├─ 四柱矩阵
│  ├─ 年柱
│  ├─ 月柱
│  ├─ 日柱
│  └─ 时柱
├─ 生日 / 出生时间 / 出生地 / 真太阳时
├─ 五行条形
├─ 大运 / 流年
└─ 备注
```

### 1.5 星盘详情页

当前定位：
- `AstroNatalChartPage`
- 当前版本已加入圆盘主视觉雏形

当前结构草图：

```text
AstroNatalChartPage
├─ 标题 / 导航 chips
├─ 本命盘圆盘
│  ├─ 太阳 / 月亮 / 上升标记
│  └─ 中心锚点
├─ 星盘摘要
├─ 关键字段
│  ├─ 出生时间
│  ├─ 真太阳时
│  ├─ 出生地
│  ├─ 经纬度
│  ├─ 位置修正
│  ├─ 经度偏移
│  ├─ 均时差
│  └─ 位置来源
├─ 位置影响
├─ 视觉标签
└─ 备注
```

### 1.6 紫微详情页

当前定位：
- `AstroZiweiPage`
- 当前版本已改成 12 宫盘网格

当前结构草图：

```text
AstroZiweiPage
├─ 标题 / 导航 chips
├─ 紫微摘要
│  ├─ 命宫
│  ├─ 身宫
│  ├─ 精度
│  └─ 置信
├─ 关键字段
│  ├─ 生日
│  ├─ 出生时间
│  ├─ 真太阳时
│  ├─ 位置修正
│  └─ 引擎 / 精度
├─ 主题标签
├─ 十二宫盘
│  ├─ 12 宫网格
│  ├─ 命宫 / 身宫高亮
│  └─ 主星 / 辅星 / 强度
└─ 备注
```

### 1.7 诊断页

当前定位：
- `AstroProfilePage`
- 用于看完整服务端画像字段、精度、位置签名和调试信息

当前结构草图：

```text
AstroProfilePage
├─ 当前画像
│  ├─ 出生时间
│  ├─ 出生地点
│  ├─ 经纬度
│  ├─ 真太阳时
│  ├─ 位置修正
│  ├─ 位置签名
│  ├─ 八字精度 / 置信
│  ├─ 西占引擎 / 精度 / 置信
│  ├─ 星象
│  ├─ 五行
│  └─ 紫微摘要
└─ 数据来源说明
```

---

## 2. `profile_input_pipeline_2_6.md` 输入管道说明

### 2.1 设计目标

2.6 的输入管道目标不是重新发明一套计算，而是把“保存资料 -> 触发重算 -> 服务端回显 -> 前端可视化”这条链路做成稳定闭环。

### 2.2 输入来源

#### 个人基础资料输入
- 昵称
- 性别
- 生日
- 出生时间
- 出生地
- 城市
- 婚恋目标

#### 出生地输入方式
- 只保留百度 Web 服务 API 的地点搜索结果
- 候选结果必须包含名称、地址、经纬度
- 选中后直接回填到表单

### 2.3 输入流转

```text
EditProfilePage
  -> profileRepository.searchBirthPlaces()
  -> GET /api/v1/geo/places
  -> 百度 place/geocoding Web API
  -> 选中候选
  -> POST /api/v1/profile/basic
  -> 后端重算八字 / 星盘 / 紫微
  -> GET /api/v1/profile/astro
  -> AstroOverview / Bazi / Natal / Ziwei / AstroProfile
```

### 2.4 真源规则

- 服务端是唯一真源
- `profile/basic` 负责写基础资料
- `profile/astro` 负责读 canonical 画像
- 本地 `session / snapshot / provider` 只能兜底，不能决定真值

### 2.5 保存后的联动结果

保存任一关键输入后，应触发：
- 八字重算
- 紫微重算
- 星盘重算
- 服务端画像刷新
- 前端页面重新拉取并回显最新值

### 2.6 允许的降级

允许：
- 搜索失败时提示明确错误
- 服务端返回空画像时显示空态
- 本地快照作为短暂兜底

不允许：
- 本地缓存覆盖服务端最新值
- 地点搜索静默退化成假候选而不提示
- 保存成功但页面显示旧值

---

## 3. 接口契约

### 3.1 个人资料接口

#### `GET /api/v1/profile/basic`

用途：
- 加载个人基础资料
- 作为编辑页的初始回显来源

核心字段：
- `nickname`
- `gender`
- `birthday`
- `birth_time`
- `city`
- `target`
- `birth_place`
- `birth_lat`
- `birth_lng`

#### `POST /api/v1/profile/basic`

用途：
- 保存个人基础资料
- 触发后端画像重算

保存后应联动：
- `users.private_birth_place`
- `users.private_birth_lat`
- `users.private_birth_lng`
- `user_astro_profiles`
- `users.private_*` 镜像字段

### 3.2 玄学画像接口

#### `GET /api/v1/profile/astro`

用途：
- 读取服务端 canonical 画像
- 供总览页、八字页、星盘页、紫微页、诊断页共用

核心字段（八字）：
- `bazi`
- `true_solar_time`
- `accuracy`
- `confidence`
- `wu_xing`
- `da_yun`
- `liu_nian`

核心字段（地点/修正）：
- `birth_time`
- `birth_place`
- `birth_lat`
- `birth_lng`
- `location_shift_minutes`
- `longitude_offset_minutes`
- `equation_of_time_minutes`
- `position_signature`
- `location_source`

核心字段（西占）：
- `sun_sign`
- `moon_sign`
- `asc_sign`
- `western_engine`
- `western_precision`
- `western_confidence`
- `western_rollout_enabled`
- `western_rollout_reason`

核心字段（紫微）：
- `ziwei.engine`
- `ziwei.precision`
- `ziwei.confidence`
- `ziwei.life_palace`
- `ziwei.body_palace`
- `ziwei.summary`
- `ziwei.major_themes`
- `ziwei.palaces`

### 3.3 地点搜索接口

#### `GET /api/v1/geo/places`

用途：
- 把输入的出生地名称转换为可计算的候选地点

返回应包含：
- `label`
- `address`
- `city`
- `district`
- `lat`
- `lng`

要求：
- 只保留百度 Web API
- 不再使用本地城市兜底作为主要来源
- 搜索失败要明确报错，不静默伪装成功

### 3.4 页面与接口映射

| 页面 | 读取接口 | 写入接口 | 说明 |
|---|---|---|---|
| `ProfilePage` | `GET /api/v1/profile/basic` + `GET /api/v1/profile/astro` | 无 | 展示入口与摘要 |
| `EditProfilePage` | `GET /api/v1/profile/basic` + `GET /api/v1/geo/places` | `POST /api/v1/profile/basic` | 资料录入与触发重算 |
| `AstroOverviewPage` | `GET /api/v1/profile/astro` | 无 | 模块总览 |
| `AstroBaziPage` | `GET /api/v1/profile/astro` | 无 | 八字主视觉与辅助信息 |
| `AstroNatalChartPage` | `GET /api/v1/profile/astro` | 无 | 星盘主视觉与位置修正 |
| `AstroZiweiPage` | `GET /api/v1/profile/astro` | 无 | 紫微宫盘主视觉 |
| `AstroProfilePage` | `GET /api/v1/profile/astro` | 无 | 诊断与调试信息 |

---

## 4. 备份脚本与发布脚本接线说明

### 4.1 当前已落地脚本

- `scripts/db_backup_aliyun_mysql.ps1`
- `scripts/db_restore_aliyun_mysql.ps1`
- `scripts/deploy_aliyun_backend.ps1`

### 4.2 当前接线

当前实际生产接线是：

```text
deploy_aliyun_backend.ps1
  -> 调用 db_backup_aliyun_mysql.ps1
  -> 上传后端代码
  -> 恢复 .env
  -> 远端执行 composer / migrate / cache / restart
```

### 4.3 发布前约束

- 默认必须先备份，再发布
- `-SkipBackup` 只能作为明确的人工例外，不应成为默认流程
- 恢复脚本只恢复到独立测试库，不应把“恢复演练成功”误写成“线上原地回滚成功”

### 4.4 与 2.6 规划的对应关系

2.6 规划里提到的 `release_with_backup.sh`：
- 当前仓库里**不是**真实已落地的生产脚本名
- 当前等价实现由 `deploy_aliyun_backend.ps1` 承担
- 后续若补 shell 包装层，也应保持同样顺序：备份 -> 发布 -> 缓存重建 -> 重启

### 4.5 恢复与回滚建议

必须保留：
- 备份产物目录
- 最近一次恢复演练记录
- 数据库恢复手册
- 发布脚本日志

---

## 5. `.codex/LONG_TERM_MEMORY.md` 中的备份规则段落

当前长期记忆里与 2.6 备份相关的规则已经固定为以下方向：

1. 每次版本更新前必须先跑备份。
2. 备份必须至少保留本地 + 云端两份。
3. 备份失败不得静默跳过。
4. 必须记录恢复脚本位置。
5. 必须记录最近一次恢复演练位置。
6. 自动备份、恢复、版本升级脚本都属于高风险面，必须纳入 plan-first / 验收流程。

这部分规则已经同步写入：
- `D:\EliteSync\.codex\LONG_TERM_MEMORY.md`
- `D:\EliteSync\AGENTS.md`
- `D:\EliteSync\docs\project_memory.md`

---

## 6. 参考图对齐说明

顾问给出的参考图文件位于：
- `docs/archive/legacy_2026-04/version_plans/assets/legacy_misc/八字示意图.jpg`
- `docs/archive/legacy_2026-04/version_plans/assets/legacy_misc/星盘示意图.jpg`
- `docs/archive/legacy_2026-04/version_plans/assets/legacy_misc/紫薇示意图.jpg`

当前实现的判断：
- 字段已经对上
- 入口已经对上
- 服务端真源已经对上
- 但视觉密度和主视觉结构还需要继续收口

### 当前需继续优化的方向

#### 八字
- 进一步提升四柱矩阵的密度
- 让主结果区更像参考图的“表格主面板”

#### 星盘
- 继续强化圆盘主视觉
- 减少列表感，增加盘面感

#### 紫微
- 进一步逼近 12 宫盘的布局密度
- 命宫 / 身宫高亮要更明确

---

## 7. 验收口径

以下条件满足后，可认为本轮整合材料可交顾问复核：

1. `ProfilePage` 和 `EditProfilePage` 的页面结构与输入链路清楚。
2. 三个详情页都明确只读服务端 canonical 画像。
3. 出生时间 / 出生地 / 经纬度 / 真太阳时的接口契约清楚。
4. 备份脚本与发布脚本接线清楚。
5. 长期记忆中的备份规则清楚、可执行。

---

## 8. 结论

这份材料的目标不是宣布 2.6 可视化已经最终完成，而是把当前实现、接口合同、备份接线和长期规则整合成一个顾问可复核的统一入口，便于后续敲定最终可视化方案。



## 2.6.2 Library-first visualization status

- Runtime charts now use `fl_chart` instead of hand-drawn placeholders.
- Eight-character, overview, natal chart, and Ziwei pages all consume library widgets.
- The current adoption scope is limited to visual components only; server-canonical data flow is unchanged.
- License snapshot for `fl_chart` is stored in `docs/licenses/astrology/fl_chart__LICENSE.txt`.
- `LICENSE_DEPENDENCY_STATUS.md` has been updated to mark `fl_chart` as `OPEN_OK` runtime dependency.
