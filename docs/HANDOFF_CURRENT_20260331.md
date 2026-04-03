# EliteSync 当前交接总览

更新时间：2026-03-31

本文档用于新阶段交接，汇总当前算法、数据接口、APP 功能和页面拓扑。  
保留顾问下发的开发计划文件，本文只做“当前可运行状态”的总览。

## 1. 当前项目状态

- Android 客户端已迁移到 Flutter 模块化结构，保留少量历史兼容路径。
- 后端为 Laravel 11，云端运行在阿里云 `101.133.161.203`。
- 当前主链路可用：
  - 注册 / 登录
  - 基础资料录入
  - 星盘 / 八字 / 紫微画像
  - 匹配
  - 匹配解释
  - 聊天
  - 首页内容流
- 当前版本发布策略已启用版本检查与下载页。

## 2. 算法总览

### 2.1 匹配总结构

匹配由三层组成：

1. 硬性过滤
2. 核心评分
3. 软惩罚与公平调整

#### 硬性过滤

- 同城匹配：`city` 必须一致
- 性别过滤：按当前业务规则做异性互补匹配
- 婚恋目标冲突过滤：`relationship_goal` 不兼容则直接过滤
- 重复曝光控制：已配对组合按周/批次过滤

#### 核心评分

当前评分来源：

- 性格测试/MBTI 兼容因子
- 八字因子
- 属相因子
- 星座因子
- 星盘因子
- 紫微因子

解释层仍保留分项分数、权重、置信度与降级原因。

#### 软惩罚与调整

- 年龄差调整
- 同城加成
- 性格字母级微调
- 曝光公平性调整
- 数据不完整时的保守估计

### 2.2 八字

- 角色：长期结果层
- 主来源：`user_astro_profiles.bazi`
- 兜底：`users.private_bazi`
- 生成：服务端 canonical
- 说明重点：
  - 五行互补
  - 长期节律协调
  - 结果层稳定性
  - 缺少出生信息时降级输出

### 2.3 属相

- 角色：桥接层
- 来源：由年柱地支派生
- 不再按公历年份硬算
- 说明重点：
  - 六合 / 三合 / 冲 / 刑 / 害
  - 属相关系只做桥接，不单独决定最终结果

### 2.4 星座

- 角色：过程层
- 来源：太阳星座
- 说明重点：
  - 元素互补
  - 互动节奏
  - 推进顺滑度

### 2.5 星盘

- 角色：过程层
- 当前形态：`western_lite`
- 不承诺生产级高精 canonical 结果
- 说明重点：
  - 情绪回应
  - 推进节奏
  - 上升 / 月亮 / 太阳等过程信号
  - 数据不足时明确降级

### 2.6 紫微斗数

- 角色：持久命盘画像模块
- 来源：服务端 canonical 生成
- 前端只展示，不做 canonical 计算
- 说明重点：
  - 命宫 / 身宫
  - 主题倾向
  - 置信度与精度
  - 可回填测试账号

### 2.7 性格测试 / MBTI

- 前台已统一为“性格测试 / 性格特征”
- 后端兼容键保留 `mbti`
- 当前只作为轻量因子，不再作为核心排序模块
- 解释层中保留历史兼容，但不作为活跃主因子

## 3. 解释层统一契约

匹配解释统一使用以下结构：

- `match_reasons`
- `explanation_blocks`
- `compatibility_sections`
- `module_explanations`

常见字段：

- `key`
- `label`
- `layer`
- `score`
- `weight`
- `confidence`
- `confidence_tier`
- `confidence_reason`
- `engine_mode`
- `display_guard`
- `degraded`
- `degrade_reason`
- `highlights[]`
- `risks[]`

### 3.1 layer 含义

- `result`：结果层
- `bridge`：桥接层
- `process`：过程层

### 3.2 display_guard

用于控制展示强度的门禁字段：

- `allow_high_confidence_badge`
- `allow_strong_evidence_badge`
- `allow_precise_wording`

## 4. 数据接口总览

### 4.1 用户主表 `users`

`users` 是登录和基础资料的入口表，同时保存公共画像与保密镜像。

#### 关键字段

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | `bigint unsigned` | 主键 |
| `name` | `string|null` | 昵称 |
| `phone` | `string(32)` | 手机号，唯一 |
| `password` | `string` | 哈希密码 |
| `birthday` | `date|null` | 生日 |
| `zodiac_animal` | `string(8)|null` | 生肖 |
| `gender` | `string|null` | 性别 |
| `city` | `string|null` | 城市 |
| `relationship_goal` | `string|null` | 婚恋目标 |
| `verify_status` | `string|null` | 认证状态 |
| `realname_verified` | `boolean` | 实名通过 |
| `disabled` | `boolean` | 是否禁用 |
| `is_synthetic` | `boolean` | 是否测试账号 |
| `synthetic_batch` | `string|null` | 测试批次 |
| `public_zodiac_sign` | `string|null` | 太阳星座 |
| `public_mbti` | `string|null` | 性格测试结果 |
| `public_personality` | `json|null` | 公共性格画像 |
| `private_bazi` | `string|null` | 八字镜像 |
| `private_natal_chart` | `json|null` | 星盘镜像 |
| `private_ziwei` | `json|null` | 紫微镜像 |
| `private_birth_place` | `string|null` | 出生地镜像 |
| `private_birth_lat` | `decimal|null` | 出生地纬度 |
| `private_birth_lng` | `decimal|null` | 出生地经度 |
| `created_at` | `timestamp` | 创建时间 |
| `updated_at` | `timestamp` | 更新时间 |

### 4.2 画像表 `user_astro_profiles`

用于保存 canonical 画像结果。

| 字段 | 类型 | 说明 |
|---|---|---|
| `user_id` | `bigint unsigned` | 用户主键 |
| `birth_time` | `datetime|null` | 出生时间 |
| `birth_place` | `string|null` | 出生地点 |
| `birth_lat` | `decimal|null` | 纬度 |
| `birth_lng` | `decimal|null` | 经度 |
| `sun_sign` | `string|null` | 太阳星座 |
| `moon_sign` | `string|null` | 月亮星座 |
| `asc_sign` | `string|null` | 上升星座 |
| `bazi` | `json|null` | 八字结果 |
| `true_solar_time` | `string|null` | 真太阳时 |
| `da_yun` | `json|null` | 大运 |
| `liu_nian` | `json|null` | 流年 |
| `wu_xing` | `json|null` | 五行分析 |
| `ziwei` | `json|null` | 紫微结果 |
| `notes` | `text|null` | 备注 |
| `computed_at` | `timestamp|null` | 计算时间 |

### 4.3 问卷表

- `questionnaire_questions`
- `questionnaire_answers`

作用：
- 保存题库
- 保存会话抽题
- 保存问卷作答与结果

### 4.4 匹配表

- `dating_matches`

作用：
- 保存匹配结果
- 保存解释结构
- 保存模块分数、权重、置信度、风险标签

### 4.5 版本表

- `app_release_versions`

作用：
- 版本检查
- 下载地址
- 最低支持版本
- 发布状态

### 4.6 MBTI / 性格测试表

- `mbti_attempts`

作用：
- 保存历史问卷尝试
- 兼容旧数据
- 当前不参与核心排序

## 5. APP 页面拓扑

### 5.1 顶层导航

底部五个主入口：

- 推荐
- 匹配
- 消息
- 发现
- 我的

### 5.2 主要页面

- `LoginPage`
- `RegisterPage`
- `HomePage`
- `DiscoverPage`
- `MatchResultPage`
- `MatchDetailPage`
- `MatchCountdownPage`
- `MatchIntentionPage`
- `ConversationListPage`
- `ChatRoomPage`
- `ProfilePage`
- `SettingsPage`
- `AboutUpdatePage`
- `ChangePasswordPage`
- `PrivacySettingsPage`
- `MbtiCenterPage`（当前为关闭/兼容页）
- `QuestionnairePage`
- `QuestionnaireResultPage`
- `VerificationSubmitPage`
- `VerificationStatusPage`
- `ContentDetailPage`

### 5.3 页面结构

#### 登录 / 注册

- 登录页
- 注册页
- 认证协议与隐私确认

#### 首页

- 轮播 / 头图
- 搜索栏
- 快捷入口
- 内容流

#### 匹配

- 匹配结果
- 匹配详情
- 匹配倒计时
- 互相确认

#### 消息

- 会话列表
- 聊天室
- 已读状态

#### 我的

- 基础资料
- 星盘 / 八字 / 紫微画像
- 设置
- 关于更新
- 修改密码
- 隐私设置

## 6. 关键接口

### 6.1 认证

- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/password`

### 6.2 问卷

- `GET /api/v1/questionnaire/questions`
- `POST /api/v1/questionnaire/answers`
- `GET /api/v1/questionnaire/profile`
- `GET /api/v1/questionnaire/progress`
- `POST /api/v1/questionnaire/reset`

### 6.3 资料

- `GET /api/v1/profile/basic`
- `POST /api/v1/profile/basic`
- `POST /api/v1/profile/city`
- `GET /api/v1/profile/astro`
- `POST /api/v1/profile/astro`
- `GET /api/v1/profile/mbti/quiz`
- `POST /api/v1/profile/mbti/submit`
- `GET /api/v1/profile/mbti/result`

### 6.4 匹配

- `GET /api/v1/matches/current`
- `POST /api/v1/matches/confirm`
- `GET /api/v1/matches/history`
- `GET /api/v1/matches/{targetUserId}/explanation`

### 6.5 消息

- `POST /api/v1/messages`
- `GET /api/v1/messages`
- `POST /api/v1/messages/read/{messageId}`
- `GET /api/v1/messages/ws/{userId}`

### 6.6 首页/发现

- `GET /api/v1/home/banner`
- `GET /api/v1/home/shortcuts`
- `GET /api/v1/home/feed`
- `GET /api/v1/discover/feed`
- `GET /api/v1/content/{contentId}`

### 6.7 版本

- `GET /api/v1/app/version/check`

## 7. 当前维护约束

- 服务端是唯一真源
- 客户端只做输入、展示、缓存、降级提示
- MBTI 不再参与核心排序
- 紫微斗数按持久命盘画像处理
- 历史兼容字段可保留，但不再扩写旧近似逻辑

## 8. 建议的后续交接方式

后续版本升级时，优先更新这份文档，再生成下一版规划：

1. 先更新算法与接口总览
2. 再更新版本规划
3. 最后更新发布/回滚/验收材料

