# EliteSync 开发计划书格式与验收门禁规则

建议文件名：`PROJECT_RULE_DEVELOPMENT_PLAN_FORMAT_CURRENT.md`  
建议路径：`docs/agents/PROJECT_RULE_DEVELOPMENT_PLAN_FORMAT_CURRENT.md` 或 `docs/PROJECT_RULE_DEVELOPMENT_PLAN_FORMAT_CURRENT.md`  
更新时间：2026-05-12  
适用范围：EliteSync 6.0 Alpha 起所有版本开发计划书、Codex 执行计划、版本验收、交接文件  
规则定位：项目级长期规则文件

---

# 0. 一句话结论

从 6.0 Alpha 起，EliteSync 的每一份开发计划书都必须同时写清：

```text
版本目标 + 边界 + protected surfaces + 多 agent / sub-agent 协作方式 + Claude 横向实测门禁 + GPT 顾问最终验收条件
```

没有多 agent / sub-agent 协作计划的开发计划书，不应进入执行。  
没有 Claude APP 实测横向对比报告的版本，不得提交 GPT 项目顾问最终验收。

---

# 1. 本规则定位

本规则用于约束后续所有 EliteSync 版本开发计划书的写法。

每份版本开发计划书都必须能回答：

1. 这个版本为什么做；
2. 这个版本做什么；
3. 这个版本明确不做什么；
4. 哪些文件、接口、数据库、release chain、canonical truth 不得误改；
5. Codex 如何执行；
6. Claude / Gemini / 其他 sub-agent 在哪里参与；
7. 如何做实机证据；
8. Claude 如何使用 Soul + 测测 / CECE 做横向复评；
9. 复评通过后如何提交 GPT 顾问最终验收；
10. 失败、阻塞、回滚、交接如何处理。

本规则不是某一个具体版本计划，也不是 runtime 需求文档。

---

# 2. 文件命名规则

版本开发计划书命名必须遵循：

```text
v_<版本号>_<计划书标题>_开发计划书_<YYYY_MM_DD>.md
```

示例：

```text
v_6_0_A0_Alpha内测准备_商用化底座与路线冻结版_开发计划书_2026_05_12.md
v_6_0_A1_后端v2与位置链路最小闭环_开发计划书_2026_05_13.md
v_6_0_A3_搭子精准陪伴最小闭环_开发计划书_2026_05_18.md
```

命名要求：

- 版本号必须明确；
- 标题必须体现版本主目标；
- 日期必须使用下划线格式；
- 不使用“最终版”“新版”“临时版”等模糊名称；
- 不用同一个文件名覆盖不同版本；
- 不把整体路线图命名成具体开发计划书；
- planning-only 版本必须在标题或版本定位中写明。

---

# 3. 开发计划书必须包含的章节

每份版本开发计划书至少包含以下章节。

## 3.1 版本元信息

必须写明：

```text
版本号：
计划书文件名：
更新时间：
版本定位：planning-only / runtime / hybrid / hotfix / release-prep
当前基线：
上一版本：
当前主线：6.0 Alpha 内测准备线
是否涉及后端：是 / 否
是否涉及 DB / migration：是 / 否
是否涉及 release chain：是 / 否
是否必须 Claude 横向复评：是
```

## 3.2 当前背景与版本目标

必须说明：

- 本版本继承哪个主计划；
- 本版本解决哪个 P0 / P1 / P2 问题；
- 本版本与 6.0 Alpha 的关系；
- 本版本是否服务内测准备；
- 本版本完成后应达到什么可验证状态。

## 3.3 只读参考文件

必须列出执行前必须阅读的项目源文件。

6.0 Alpha 默认至少包括：

```text
docs/DEVELOPMENT_PLAN_CURRENT.md
docs/DOC_INDEX_CURRENT.md
docs/project_memory.md
docs/version_plans/ELITESYNC_6_0_ALPHA_MASTER_PLAN_2026_05_12.md
docs/reference/ELITESYNC_FEATURE_GAP_ANALYSIS_2026_05_12.md
docs/reference/ELITESYNC_REVIEW_ACTION_MATRIX_2026_05_12.md
docs/agents/CLAUDE_HORIZONTAL_REVIEW_GATE_RULES.md
docs/agents/CODEX_CYBER_SAFE_UI_RESEARCH_RULES.md
docs/version_plans/README.md
```

如涉及跨层阻塞、云端、RTC、媒体、SDK、构建链，还必须引用：

```text
docs/PROJECT_RULE_CROSS_LAYER_BLOCKERS.md
```

如涉及交接文件收敛，还必须引用：

```text
docs/PROJECT_RULE_HANDOFF_SINGLE_FILE.md
```

## 3.4 范围与非目标

必须明确写出：

### 本版本做什么

- 功能范围；
- 页面范围；
- 数据范围；
- 测试范围；
- 文档范围；
- 证据范围。

### 本版本不做什么

必须写成明确的 non-goals。

例如：

- 不改 release chain；
- 不改 DB schema；
- 不改后端；
- 不接真实 AI；
- 不接付费；
- 不接真人咨询；
- 不上传截图主路径；
- 不把搭子做成泛同城约玩；
- 不照抄 Soul / 测测 / CECE。

## 3.5 Protected surfaces

必须显式列出不得误改的保护面。

常见保护面包括：

```text
profile/basic
profile/astro/summary
profile/astro/chart
user_astro_profiles
dating_matches
chat_messages
media_assets
rtc_calls / rtc_sessions
app_release_versions
API contract
DB schema
migration
release chain
```

若本版本确实要触碰其中任何一项，必须单独写出：

- 为什么必须触碰；
- 由谁批准；
- 修改前备份方式；
- 回滚路径；
- 测试证据；
- 是否需要云端确认。

## 3.6 产品与 UX 要求

必须说明：

- 用户从哪里进入；
- 用户第一眼应理解什么；
- 页面必须显示什么；
- 哪些文案必须避开工程术语；
- 是否需要空态 / loading / error / disabled / fallback；
- 是否需要解释“这个功能为什么有用”；
- 是否服务 Date Drop 式低频高质量匹配；
- 是否影响搭子主线；
- 是否影响玄学解释层。

## 3.7 技术实现范围

必须列出预计涉及文件或目录。

格式建议：

```text
预计修改：
- path/to/file_a.dart：原因
- path/to/file_b.php：原因

预计新增：
- path/to/new_file.dart：原因

明确不触碰：
- path/to/protected_file：原因
```

如果计划阶段还不能确定具体文件，也必须写：

```text
先做只读审计，审计完成后再列出文件清单；不得直接大范围搜索替换。
```

## 3.8 多 agent / sub-agent 协作计划

从 6.0 Alpha 起，每份开发计划书都必须包含本节。

### 3.8.1 默认协作原则

开发过程中必须主动使用多 agent / sub-agent 模式提高效率，而不是让 Codex 长时间单线作战。

Codex 的角色：

- 主执行者；
- 代码修改者；
- 本地测试者；
- 证据整理者；
- 文档同步者。

Claude 的角色：

- 架构与跨层问题分析；
- 产品体验复评；
- Soul + 测测 / CECE 横向对照；
- blocker 定点分析；
- 判断是否可提交 GPT 顾问验收。

Gemini 或其他视觉型 sub-agent 的角色：

- UI 截图审查；
- 信息密度审查；
- 视觉一致性审查；
- 用户视角 walkthrough 辅助。

### 3.8.2 必须主动触发 sub-agent 的场景

出现以下任一情况，开发计划书必须预先写入 sub-agent 参与方式：

- 后端 v2、API contract、DB、migration；
- 地图 / 定位 / 第三方 SDK；
- RTC / 语音 / 视频 / 媒体；
- WebSocket / 通知 / 推送 / 版本检查；
- 跨端双设备联动；
- App 实机可见性与文档自报不一致；
- 功能涉及 Soul / 测测 / CECE 的竞品对照；
- UI / IA 信息密度和用户理解是核心目标；
- Codex 连续两轮没有突破 blocker；
- 日志、截图、页面表现互相矛盾。

### 3.8.3 计划书中的固定写法

每份计划书必须包含类似条款：

```text
本版本采用 Codex 主执行 + Claude 横向复评 + 必要时 Gemini/视觉 sub-agent 辅助的多 agent 模式。
Codex 不得在出现跨层 blocker 或竞品体验判断时长期单独裁决。
Claude 复评通过前，不得提交 GPT 顾问最终验收。
```

## 3.9 执行阶段划分

开发计划书必须把执行拆成阶段。

推荐结构：

1. Phase 0：只读审计；
2. Phase 1：方案确认与文件清单；
3. Phase 2：最小实现；
4. Phase 3：测试与证据；
5. Phase 4：Claude 横向复评；
6. Phase 5：Codex 根据 Claude 反馈修正或解释不采纳；
7. Phase 6：GPT 顾问最终验收；
8. Phase 7：提交 / push / 交接。

planning-only 版本可不做 runtime，但仍需 Phase 4 Claude 规则检查或文档复评。

## 3.10 测试与证据要求

必须写明：

- 单元测试；
- widget / page test；
- integration / smoke test；
- Android 模拟器；
- 手机真机；
- 截图；
- XML / UI hierarchy；
- 日志；
- API / DB / backend 证据；
- 回归清单。

任何用户可见页面改动，都应至少有：

```text
截图 + XML/UI hierarchy + 进入路径 + 期望文案 + 实际文案
```

## 3.11 Claude 横向复评门禁

每份开发计划书必须写入：

```text
Codex 完成实现、自测、证据包和版本报告后，必须提交 Claude 横向复评。
Claude 需要基于 EliteSync 当前版本实测，并调用 Soul + 测测 / CECE 作为横向参考。
只有 Claude 结论为 pass 或 pass with observations，才能提交 GPT 顾问最终验收。
conditional pass 必须先补证据或小修。
fail 必须返工。
```

计划书不得写成“如有必要再请 Claude 复评”。

Claude 复评是 6.0 Alpha 起的强制门禁。

## 3.12 Codex 对 Claude 反馈的处理

计划书必须要求 Codex 在 Claude 复评后输出：

1. Claude 提出的问题清单；
2. 已采纳问题；
3. 未采纳问题；
4. 未采纳理由；
5. 本版必须修的问题；
6. 后续 observation；
7. 修正后的证据；
8. 是否达到提交 GPT 顾问验收条件。

## 3.13 GPT 顾问最终验收条件

必须写明：

- 无 Claude 横向复评，不得提交 GPT 顾问最终验收；
- 无 GPT 顾问最终验收，不得进入下一版本；
- GPT 顾问验收时必须看到 Codex 报告、测试证据、Claude 报告、Action Matrix、Codex 处理说明；
- GPT 顾问验收通过后，才允许提交 / push 或进入下一版本。

若用户明确要求先 commit 某个 planning/source sync，则也必须先确认该提交不是 runtime 交付，并在报告中标注性质。

---

# 4. 每份开发计划书推荐模板

以下模板可直接复制到新版本计划书中。

```md
# EliteSync <VERSION> <TITLE> 开发计划书

更新时间：YYYY-MM-DD  
计划书文件名：`v_<VERSION>_<TITLE>_开发计划书_<YYYY_MM_DD>.md`  
版本定位：planning-only / runtime / hybrid / hotfix / release-prep  
当前主线：6.0 Alpha 内测准备线  
当前基线：  
上一版本：  
是否涉及后端：  
是否涉及 DB / migration：  
是否涉及 release chain：  
Claude 横向复评：强制  
GPT 顾问最终验收：强制  

---

# 0. 一句话目标


---

# 1. 当前背景


---

# 2. 本版本目标


---

# 3. 本版本范围

## 3.1 做什么


## 3.2 不做什么


---

# 4. 只读参考文件


---

# 5. Protected surfaces


---

# 6. 产品与 UX 要求


---

# 7. 技术实现范围


---

# 8. 多 agent / sub-agent 协作计划

## 8.1 Codex 角色


## 8.2 Claude 角色


## 8.3 Gemini / 视觉 sub-agent 角色


## 8.4 必须触发 sub-agent 的条件


---

# 9. 执行阶段

## Phase 0：只读审计

## Phase 1：方案确认

## Phase 2：最小实现

## Phase 3：测试与证据

## Phase 4：Claude 横向复评

## Phase 5：根据 Claude 反馈修正 / 说明不采纳

## Phase 6：GPT 顾问最终验收

## Phase 7：提交 / push / 交接

---

# 10. 测试与证据要求


---

# 11. Claude 横向复评门禁


---

# 12. 验收标准


---

# 13. 交付文件


---

# 14. Codex 执行 Prompt


---

# 15. 停止条件


```

---

# 5. Codex 执行报告格式

每个版本完成后，Codex 必须输出：

```md
# Codex 执行报告：<VERSION>

## 1. 实际修改文件

## 2. 未修改保护面确认

## 3. 实现内容

## 4. 测试结果

## 5. UI / XML / 日志证据

## 6. 已知 observation

## 7. 是否已提交 Claude 横向复评

## 8. Claude 反馈处理情况

## 9. 是否满足 GPT 顾问验收条件

## 10. 建议下一步
```

如果 Claude 复评尚未完成，Codex 不得写“建议 GPT 顾问验收通过”。

---

# 6. Claude 复评前 Codex 必须提交的材料

Codex 提交给 Claude 前，至少准备：

1. 本版本开发计划书；
2. Codex 执行报告；
3. 本版本新增 / 修改功能的入口说明；
4. 截图证据；
5. XML / UI hierarchy 证据；
6. 测试命令与结果；
7. 已知 blocker；
8. 本版本 non-goals；
9. protected surfaces 说明；
10. 希望 Claude 重点复评的问题。

---

# 7. 不同版本类型的特殊要求

## 7.1 planning-only 版本

planning-only 版本不做 runtime，但仍必须：

- 明确路线；
- 明确边界；
- 明确下一阶段拆分；
- 明确多 agent 协作规则；
- 明确 Claude 门禁如何进入后续 runtime 版本；
- 同步项目源入口；
- 不得暗中修改代码。

## 7.2 runtime 版本

runtime 版本必须：

- 有实机证据；
- 有自动化测试；
- 有 UI / XML；
- 有 Claude 横向复评；
- 有 Codex 对 Claude 反馈的处理；
- 有 GPT 顾问验收结论。

## 7.3 后端 / DB / API 版本

后端 / DB / API 版本必须额外写明：

- 云端执行边界；
- 是否需要用户确认；
- 备份方式；
- 回滚方案；
- staging / production 分离；
- 压测和监控；
- 不得在本地替代云端真实写操作；
- 不得无计划推倒重写。

## 7.4 UI / IA 版本

UI / IA 版本必须额外写明：

- 页面进入路径；
- 首屏目标；
- 信息密度；
- 工程术语清理；
- 空态 / loading / error；
- 截图证据；
- 视觉 sub-agent 是否参与；
- Claude 用户视角复评。

## 7.5 竞品参考版本

只要版本参考 Soul / 测测 / CECE，必须写明：

- 吸收的是结构，不是照抄；
- 不做逆向、抓包、接口分析；
- 不进入付费、咨询、上传、实名、人脸识别；
- 不从 UI 推断后端 contract、算法或数据库；
- 不复制术语体系、商业化路径或娱乐化路径；
- Claude 只能做普通用户可见 UI 产品体验对照。

---

# 8. 版本提交与 push 规则

开发计划书必须写清：

1. 未经 GPT 顾问允许不得 commit / push；
2. 提交必须单主题；
3. 不得 `git add .`；
4. 不得把 `test/`、Claude 截图、XML、logs、临时 session 文件误提交；
5. planning/source sync 与 runtime commit 必须分离；
6. release chain commit 必须单独提交；
7. push 前如远端 ahead，默认不 force push，应先请示 rebase / merge 策略。

---

# 9. 开发计划书中的固定门禁文字

每份开发计划书都应包含以下固定文字：

```text
本版本采用多 agent / sub-agent 协作模式。Codex 为主执行者，但不得在跨层 blocker、竞品产品判断、实机体验判断上长期单独裁决。必要时必须调用 Claude / Gemini / 其他已授权 sub-agent 进行定点分析或视觉复核。

本版本完成后，Codex 必须先提交 Claude APP 实测横向对比复评。Claude 需基于 EliteSync 当前版本，并使用 Soul + 测测 / CECE 作为横向参考，输出复评报告和 Action Matrix。只有 Claude 结论为 pass 或 pass with observations，才能提交 GPT 项目顾问最终验收。无 Claude 复评，不得进入 GPT 顾问最终验收；无 GPT 顾问验收，不得进入下一版本。
```

---

# 10. 最短执行口径

```text
以后所有 EliteSync 开发计划书必须写入多 agent / sub-agent 协作计划，并把 Claude 使用 Soul + 测测 / CECE 的 APP 实测横向复评作为 GPT 顾问验收前置门禁。
```

