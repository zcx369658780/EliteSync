# EliteSync 当前开发交接

更新时间：2026-05-01

用途：给下一次 Codex / 顾问会话承接当前开发进度、版本基线、文档入口、验收口径、竞品拆解结论与外部工具调用记忆。

---

## 1. 当前结论

- 当前正式发布基线：`0.04.09 / 40900`
- `4.9` 已冻结为 `pass with observations`
- `5.0` 已冻结为 `pass with observations`
- `5.1` 已验收通过，状态：`pass with observations`
- 当前下一阶段承接方向：`5.2`，基于 5.1 observations 做小单承接与个人经营页 / 表达层增强
- 当前主线已经从“基础能力补全”切换到“产品化补强 + 关系推进 + 回流链增强 + 个人经营增强”

---

## 2. 当前版本进度

### 2.1 已归档阶段

- `4.9`：测试前治理、限流、监控、发布链强化版
  - 状态：`pass with observations`
  - 作为 `5.x` 稳定门禁基线
- `5.0`：Alpha 测试候选版 / 产品化补强最小集
  - 状态：`pass with observations`
  - 形成 Discover / Chat / Me 的最小产品化起点

### 2.2 最新已验收阶段

- `5.1`：关系转化与内容回流增强版
  - 重点：首聊 / 回聊 / 冷场恢复、匹配解释联动、动态到私聊转化、通知回流、语音联动
  - 当前状态：`pass with observations`
  - 主入口：`docs/version_plans/5.1_HANDOFF_MASTER.md`
  - 观察项：Match / Status / Notification 证据补齐、RTC success result 截图、真实通知 payload 跳转方向复核、`match_detail_page_test.dart` 补测

---

## 3. 当前开发路线图

### 3.1 总入口

- [`docs/DEVELOPMENT_PLAN_CURRENT.md`](docs/DEVELOPMENT_PLAN_CURRENT.md)

### 3.2 当前主计划

- [`docs/version_plans/elite_sync_整体开发计划书_5_x方向重排版_2026_05_01.md`](docs/version_plans/elite_sync_整体开发计划书_5_x方向重排版_2026_05_01.md)
- [`docs/version_plans/elite_sync_未来版本开发路线图草案_2026_05_01.md`](docs/version_plans/elite_sync_未来版本开发路线图草案_2026_05_01.md)

### 3.3 当前最新版本计划

- [`docs/version_plans/v_5_1_关系转化与内容回流增强版_开发计划书_2026_05_01.md`](docs/version_plans/v_5_1_关系转化与内容回流增强版_开发计划书_2026_05_01.md)

---

## 4. 当前主交接材料

### 4.1 5.0 主交接

- [`docs/version_plans/5.0_HANDOFF_MASTER.md`](docs/version_plans/5.0_HANDOFF_MASTER.md)
- 当前 5.0 结论：`pass with observations`
- 5.0 的主交接入口已经单文件化，后续交接默认只看这一份

### 4.2 5.0 验收与证据

- [`docs/version_plans/5.0_ACCEPTANCE_SUMMARY.md`](docs/version_plans/5.0_ACCEPTANCE_SUMMARY.md)
- [`docs/version_plans/5.0_UI_BASELINE_EVIDENCE_INDEX.md`](docs/version_plans/5.0_UI_BASELINE_EVIDENCE_INDEX.md)
- [`docs/version_plans/5.0_ME_UI_EVIDENCE_INDEX.md`](docs/version_plans/5.0_ME_UI_EVIDENCE_INDEX.md)
- [`docs/version_plans/5.0_CHAT_UI_EVIDENCE_INDEX.md`](docs/version_plans/5.0_CHAT_UI_EVIDENCE_INDEX.md)
- [`docs/version_plans/5.0_DISCOVER_UI_EVIDENCE_INDEX.md`](docs/version_plans/5.0_DISCOVER_UI_EVIDENCE_INDEX.md)

### 4.3 5.0 关键证据目录

- [`docs/version_plans/assets/5.0/current/`](docs/version_plans/assets/5.0/current/)

### 4.4 5.1 主交接与验收

- [`docs/version_plans/5.1_HANDOFF_MASTER.md`](docs/version_plans/5.1_HANDOFF_MASTER.md)
- [`docs/version_plans/5.1_ACCEPTANCE_SUMMARY.md`](docs/version_plans/5.1_ACCEPTANCE_SUMMARY.md)
- [`docs/version_plans/v_5_1_关系转化与内容回流增强版_开发计划书_2026_05_01.md`](docs/version_plans/v_5_1_关系转化与内容回流增强版_开发计划书_2026_05_01.md)

---

## 5. 项目文件细则

### 5.1 当前应优先看的文件

1. [`docs/DEVELOPMENT_PLAN_CURRENT.md`](docs/DEVELOPMENT_PLAN_CURRENT.md)
2. [`docs/project_memory.md`](docs/project_memory.md)
3. [`docs/DOC_INDEX_CURRENT.md`](docs/DOC_INDEX_CURRENT.md)
4. [`docs/version_plans/README.md`](docs/version_plans/README.md)
5. [`docs/version_plans/5.1_HANDOFF_MASTER.md`](docs/version_plans/5.1_HANDOFF_MASTER.md)
6. [`docs/version_plans/5.0_HANDOFF_MASTER.md`](docs/version_plans/5.0_HANDOFF_MASTER.md)

### 5.2 目录职责

- `docs/project_memory.md`
  - 项目长期记忆
  - 记录跨版本持续规则、验收口径、保护面、工具调用习惯
- `docs/DOC_INDEX_CURRENT.md`
  - 当前全局索引入口
  - 给新会话快速指到当前有效文档
- `docs/version_plans/README.md`
  - 当前版本计划入口索引
  - 以当前版本周期为准，不要把归档版当主入口
- `docs/version_plans/*HANDOFF_MASTER.md`
  - 版本主交接文件
  - 对外 / 对顾问默认优先看这一份
- `docs/version_plans/*ACCEPTANCE_SUMMARY.md`
  - 验收结论与观察项摘要
- `docs/version_plans/*UI_EVIDENCE_INDEX.md`
  - 截图与 UI 证据索引
- `docs/version_plans/*EXECUTION_NOTE.md`
  - 执行过程记录
- `docs/version_plans/*RELEASE_GATE_CHECKLIST.md`
  - 发布门禁与检查项
- `docs/archive/`
  - 历史归档材料
  - 过期版本不要再作为当前入口

### 5.3 当前必须遵守的文档规则

1. 交接材料默认收敛到单一 `*_HANDOFF_MASTER.md`
2. 验收不能只看文档自报，必须让截图文件名、截图内容、页面实际内容三者一致
3. 如果证据链错绑 / 错传，先修证据文件再谈升档
4. Cross-layer blocker 先写 blocker report，再请 Claude 做根因缩层
5. 不能默认 repo 级回滚；只能路径级 / 文件级 / 最小范围恢复

---

## 6. 当前项目状态摘要

### 6.1 4.9

- 已完成测试前治理
- 已完成限流、监控、发布链强化
- 已完成数据库正式演练
- 已冻结为 `pass with observations`

### 6.2 5.0

- Discover / Chat / Me 已形成最小产品化起点
- Chat 已具备首聊 / 回聊 / 关系摘要 / 语音联动的用户面证据
- Me 已具备 AI 助理 / 展示建议、内容标签、资料真值链路、玄学入口
- 5.0 已冻结为 `pass with observations`

### 6.3 5.1 当前结论

- 5.1 已完成首聊 / 回聊 / 冷场恢复队列增强
- 已完成匹配解释到聊天建议联动增强
- 已完成动态 / 状态到私聊的低压转化增强
- 已完成通知中心回流产品化增强
- 已完成语音联动节奏增强
- 当前验收口径：`pass with observations`

### 6.4 5.2 承接方向

- 不重复建设 5.1 已完成的关系推进、通知回流和语音节奏能力
- 承接适合继续做的小项：证据补采集、真实通知 payload 跳转方向复核、Match Detail 测试补强
- 更适合推进个人经营页与表达层增强

---

## 7. 竞品拆解结论

已使用 `soul-ui-scout` 完成 Soul 竞品拆解，当前得到的主要结论：

- `Discover` 是复合入口层，不是纯 Feed
- `Chat` 是首聊 / 回聊 / 关系推进 / AI 破冰 / 语音联动的组合系统
- `Me` 是个人经营中枢，不是单纯资料页
- `设置` 更像个人主页外观 / 空间装扮快捷面板，不是传统通用设置中心

这些结论已作为 5.x 产品化补强的参考输入，不直接照搬 Soul 的商业化入口。

---

## 8. GitHub 与阿里云 SSH / key 调用记忆

### 8.1 GitHub 侧

- GitHub 相关操作优先使用仓库内的 GitHub connector / PR 工具链
- PR、review、merge、comment 尽量走 connector，不手工在文档中暴露密钥
- GitHub key / token 只保留在外部环境或既有认证链路中，不写入仓库文件
- 如果后续要继续做 GitHub 操作，优先复用现有认证状态，不要在仓库内新增明文凭据

### 8.2 阿里云 / SSH 侧

- 远端 SSH 检查一律显式调用：
  - `C:\WINDOWS\System32\OpenSSH\ssh.exe`
- PowerShell 中使用 SSH 时，参数优先按数组或 `--%` 原样透传，避免解析错误
- 不要再用容易被 PowerShell 误解析的裸 `ssh -o ...` 写法
- 阿里云相关 key / host 认证不写入仓库；按既有系统配置或环境配置加载

### 8.3 以后交接时的固定写法

- 如果需要提到 SSH 调用方式，只写“使用系统 OpenSSH 客户端 + 既有认证链路”
- 不要把具体密钥内容、私钥、口令写进交接文件

---

## 9. 下一次会话怎么继续

建议下一次新会话按这个顺序开始：

1. 先读本文件；
2. 再读 [`docs/DEVELOPMENT_PLAN_CURRENT.md`](docs/DEVELOPMENT_PLAN_CURRENT.md)；
3. 再看 [`docs/version_plans/5.1_HANDOFF_MASTER.md`](docs/version_plans/5.1_HANDOFF_MASTER.md)；
4. 再看 [`docs/version_plans/5.0_HANDOFF_MASTER.md`](docs/version_plans/5.0_HANDOFF_MASTER.md)；
5. 确认当前基线为 `0.04.09 / 40900`；
6. 按 5.2 承接方向拆小单，不回头重开 4.x / 5.1 已通过主链；
7. 任何跨层 blocker 先写 blocker report，再找 Claude 做根因缩层。

---

## 10. 程序算法 / 接口 / 变量规则

### 10.1 当前程序的核心算法口径

- **资料真值链**：资料以服务端为主真值，`POST /api/v1/profile/basic` 保存后返回的重算快照优先作为前端展示依据，前端缓存只做兜底。
- **版本真值链**：宿主 APK 的 `versionName/versionCode` 以 `apps/android/app/build.gradle.kts` 为准，`/api/v1/app/version/check` 和发版脚本必须与其同步。
- **消息主链**：消息发送、附件绑定、已读回写、媒体上传按 `chat_messages` / `message_attachments` / `media_assets` 的服务端链路走，不允许用本地缓存替代服务端结果。
- **RTC 真语音链**：`rtc_calls` / `rtc_sessions` / heartbeat 记录为 RTC 真状态；`GET /api/v1/rtc/calls/{callId}/livekit` 返回 join-info，`POST /api/v1/rtc/calls/{callId}/heartbeat` 负责保活与断连收口。
- **5.x 产品化链**：Discover / Chat / Me 的增强都必须是 additive 承接，目标是关系推进、内容回流、个人经营和轻治理，不回头重开 4.x 壳层。

### 10.2 当前程序常用接口

- `POST /api/v1/profile/basic`
- `GET /api/v1/profile/basic`
- `GET /api/v1/messages`
- `POST /api/v1/messages`
- `POST /api/v1/messages/read/{messageId}`
- `GET /api/v1/media`
- `POST /api/v1/media`
- `GET /api/v1/media/{assetId}`
- `GET /api/v1/media/{assetId}/content`
- `GET /api/v1/home/banner`
- `GET /api/v1/home/shortcuts`
- `GET /api/v1/home/feed`
- `GET /api/v1/discover/feed`
- `POST /api/v1/rtc/calls`
- `GET /api/v1/rtc/calls/{callId}/livekit`
- `POST /api/v1/rtc/calls/{callId}/heartbeat`
- `GET /api/v1/app/version/check`

### 10.3 变量与字段规则

- **服务端真值优先**：`birth_place`、经纬度、八字、紫微、星盘等画像字段以服务端保存结果为准，前端缓存只能兜底，不得覆盖真值。
- **展示字段只读**：`route_mode`、`metadata.route_context`、`field_roles.display_only` 这类字段只作为展示上下文，不得改写为业务真值。
- **版本字段统一**：发布链中所有版本口径必须对齐 `0.04.09 / 40900` 这一稳定基线，除非明确触发新的发版动作。
- **缓存用途限定**：`lastKnownProfile`、页面快照、UI 证据索引等仅用于回读和兜底，不得作为主数据源。
- **命名约定**：对外交接优先使用单一 `*_HANDOFF_MASTER.md`；截图文件名必须与页面实际内容一致，不允许错绑。

### 10.4 交接时必须记住的调用边界

- GitHub key、token 不写入仓库文件，只沿用既有认证链路；
- 阿里云 SSH 检查统一使用系统 OpenSSH 客户端；
- 任何跨层 blocker 先写 blocker report，再请 Claude 做根因缩层；
- 任何验收都要同时核对“文件名 / 文件内容 / 页面内容”三者一致。

---

## 11. 简短总结

当前项目状态可以概括为：

- 4.9 已收口；
- 5.0 已收口；
- 5.1 已验收通过，状态为 `pass with observations`；
- 5.2 将承接 5.1 observations 中适合继续做的小项；
- 文档和证据链必须保持一致；
- GitHub / 阿里云 SSH 调用方式要沿用既有记忆，不要把密钥写进仓库；
- 后续继续沿着 5.x 产品化补强主线推进。
