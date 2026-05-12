# Claude 使用 Soul + 测测 / CECE 进行横向评测的开发计划书规则

建议文件名：`PROJECT_RULE_CLAUDE_SOUL_CECE_HORIZONTAL_REVIEW.md`  
建议路径：`docs/agents/PROJECT_RULE_CLAUDE_SOUL_CECE_HORIZONTAL_REVIEW.md`  
更新时间：2026-05-12  
适用范围：EliteSync 6.0 Alpha 起所有版本的 Claude 横向复评、竞品对照、APP 实测验收门禁  
规则定位：项目级长期规则文件

---

# 0. 一句话结论

从 6.0 Alpha 起，每个 EliteSync 版本完成后，必须由 Claude 对 EliteSync 当前版本进行 APP 实测，并使用 Soul + 测测 / CECE 作为横向参考，输出复评报告与 Action Matrix。只有 Claude 横向复评为 `pass` 或 `pass with observations`，该版本才能提交 GPT 项目顾问最终验收。

---

# 1. 本规则定位

本规则用于规范后续每个版本的 Claude 横向复评。

Claude 横向复评不是：

- 安全测试；
- 逆向分析；
- 抓包；
- 接口分析；
- 代码审计；
- 付费功能体验；
- 真人咨询体验；
- 竞品复制建议；
- 替代 GPT 顾问最终验收。

Claude 横向复评是：

- 用户视角 APP 实测；
- EliteSync 当前版本功能可见性检查；
- Soul / 测测 / CECE 的公开可见 UI 产品结构对照；
- 功能差距识别；
- UI / IA 可理解性评估；
- 竞品可吸收 / 不吸收边界判断；
- GPT 顾问验收前置门禁。

---

# 2. 标准流程

每个版本必须按以下流程执行：

```text
Codex 完成实现与自测
-> Codex 生成证据包与版本报告
-> Codex 提交 Claude 横向复评输入包
-> Claude 实测 EliteSync 当前版本
-> Claude 使用 Soul + 测测 / CECE 做横向参考
-> Claude 输出复评报告与 Action Matrix
-> Codex 根据 Claude 反馈修正或解释不采纳原因
-> Claude 复评结论达到 pass / pass with observations
-> 提交 GPT 项目顾问最终验收
-> GPT 顾问通过后才允许进入提交 / push / 下一版本
```

不得省略 Claude 横向复评。

不得用 Codex 自测报告替代 Claude 横向复评。

不得用文档阅读替代 APP 实测。

---

# 3. 适用版本类型

## 3.1 必须完整复评的版本

以下版本必须完整执行 EliteSync + Soul + 测测 / CECE 横向复评：

- Match / 匹配；
- Chat / 消息；
- Discover / 发现；
- Profile / Me / 个人经营；
- Astro / 八字 / 紫微 / 合盘 / 玄学解释；
- Buddy / 搭子；
- Settings / 隐私 / 解释与建议；
- UI / IA 重构；
- onboarding / 注册 / 资料填写；
- 内测反馈入口；
- 任何用户可见主流程改动。

## 3.2 可做轻量复评的版本

以下版本仍需 Claude 复评，但可采用轻量模式：

- planning-only；
- 文档规则同步；
- 版本索引同步；
- 非用户可见技术方案；
- 后端设计文档。

轻量复评仍必须输出结论，说明为什么不需要完整 Soul / CECE 实机对照。

## 3.3 不可豁免的情况

只要版本最终要提交 GPT 顾问验收，就不得完全跳过 Claude 复评。

如本版确实无法实测，必须写成 blocker，而不是直接提交验收。

---

# 4. 三个 App 的角色分工

## 4.1 EliteSync

EliteSync 是被评测对象。

Claude 需要判断：

- 本版本功能是否真的可见；
- 用户能否自然找到入口；
- 首屏是否自解释；
- 页面是否有明显工程术语；
- 功能是否符合 6.0 Alpha 主线；
- 是否破坏 Date Drop 式低频高质量匹配定位；
- 是否误把搭子做成泛同城约玩；
- 是否存在隐私、位置、安全、误操作风险；
- 是否存在文档自报有功能、实机不可见的问题。

## 4.2 Soul

Soul 是社交表达参考。

主要用于横向评估：

- 自我介绍 CTA；
- 交友意图表达；
- Discover / 广场 / 轻状态；
- Chat 关系推进；
- 破冰提示；
- 冷场恢复；
- 个人经营；
- 设置 / 外观 / 权限分层；
- 用户如何被引导表达“我是谁、我想找什么”。

不吸收：

- 强 Feed；
- 关注制社交；
- 快速私聊泛滥；
- 匿名文化；
- 礼物商城；
- 币 / 会员 / 重商业化；
- 强运营活动；
- 黑箱吸引力焦虑；
- 过度娱乐化关系推进。

## 4.3 测测 / CECE

测测 / CECE 是玄学解释层参考。

主要用于横向评估：

- 入口矩阵；
- 档案上下文；
- 字段级引导；
- 摘要句；
- 维度解释；
- 详情分层；
- 建议 / 避免；
- 生活化 CTA；
- 如何把专业玄学信息转为用户可理解解释。

不吸收：

- 真人玄学咨询；
- 付费报告；
- 上传截图主路径；
- 娱乐化测试主路径；
- 强出生资料收集；
- 测试结果反写画像；
- 伪短信 / 消息模拟；
- 大规模社区讨论；
- 复制测测术语体系；
- 从竞品 UI 推断后端 contract、算法、接口或数据库。

---

# 5. Claude 设备与权限规则

## 5.1 EliteSync

Claude 体验 EliteSync 时可使用：

```text
模拟器 + 手机真机双端
```

允许：

- 登录；
- 退出；
- 修改测试资料；
- 发测试消息；
- 双端互动；
- 进入 Home / Discover / Match / Chat / Profile / Astro / Buddy / Settings；
- 测试图片 / 视频 / 语音 / 通话；
- 截图；
- XML / UI hierarchy；
- 体验记录；
- 报告生成。

禁止：

- 删除账号；
- 操作非测试账号的重要真实数据；
- 清库；
- 迁移数据库；
- 发布 APK；
- 修改源码；
- 修改服务器；
- git add / commit / push。

## 5.2 Soul

Claude 体验 Soul 时默认使用：

```text
模拟器端
```

允许：

- 普通用户可见 UI 浏览；
- 截图；
- XML / UI hierarchy；
- 少量、受控、非骚扰的写入行为；
- 体验报告。

写入行为上限：

```text
关注：不超过 3 次
点赞：不超过 5 次
私信：不超过 3 条
```

每条私信必须是中性、礼貌、非骚扰文本。

禁止：

- 付费；
- 开会员；
- 充值；
- 下单；
- 进入支付链；
- 删除账号；
- 修改绑定手机号；
- 实名认证；
- 人脸识别；
- 上传隐私照片；
- 授权通讯录；
- 批量关注；
- 批量点赞；
- 批量私信；
- 发送骚扰、暧昧、诱导、商业、冒犯性内容；
- 抓包、接口分析、逆向、绕过限制。

## 5.3 测测 / CECE

Claude 体验测测 / CECE 时默认使用：

```text
手机真机端
```

允许：

- 普通用户可见 UI 浏览；
- 截图；
- XML / UI hierarchy；
- 少量、受控、非骚扰的写入行为；
- 体验报告。

写入行为上限：

```text
关注：不超过 3 次
点赞：不超过 5 次
发信息：不超过 3 条
```

如需填写出生资料，只能使用虚构测试资料，并在报告中注明。

禁止：

- 付费；
- 开会员；
- 充值；
- 购买报告；
- 真人咨询成交；
- 上传截图 / 图片 / 隐私资料；
- 填写真实身份证、真实联系方式等敏感信息；
- 删除账号；
- 修改绑定手机号；
- 实名认证；
- 人脸识别；
- 抓包、接口分析、逆向、绕过限制。

---

# 6. 文件读写与证据目录规则

Claude 的横向复评证据统一保存在：

```text
D:\EliteSync\test\
```

建议目录：

```text
D:\EliteSync\test\
├─ EliteSync\
│  ├─ screenshots\
│  ├─ xml\
│  ├─ notes\
│  └─ videos\
├─ Soul\
│  ├─ screenshots\
│  ├─ xml\
│  ├─ notes\
│  └─ videos\
├─ CECE\
│  ├─ screenshots\
│  ├─ xml\
│  ├─ notes\
│  └─ videos\
└─ reports\
```

Claude 不得写入：

```text
D:\EliteSync\apps\
D:\EliteSync\services\
D:\EliteSync\docs\
D:\EliteSync\.git\
D:\EliteSync\.codex\
D:\EliteSync\.claude\
```

除非这些路径位于 `D:\EliteSync\test\` 下。

---

# 7. 证据命名规则

截图和 XML 应尽量成对保存，使用相同前缀。

格式：

```text
<App>_<version>_<phase>_<module>_<序号>_<说明>.png
<App>_<version>_<phase>_<module>_<序号>_<说明>.xml
```

示例：

```text
EliteSync_6_0_A3_blind_buddy_001_entry.png
EliteSync_6_0_A3_blind_buddy_001_entry.xml

Soul_6_0_A3_compare_buddy_like_001_discover.png
Soul_6_0_A3_compare_buddy_like_001_discover.xml

CECE_6_0_A5_compare_astro_001_matrix.png
CECE_6_0_A5_compare_astro_001_matrix.xml
```

每个关键页面至少保留：

- 一张截图；
- 一份 XML / UI hierarchy；
- 一段体验记录。

如果无法采集 XML，必须说明原因。

---

# 8. Claude 横向复评阶段

每次复评默认包含以下阶段。

## Stage 0：读取材料

Claude 必须先读取：

1. 本版本开发计划书；
2. Codex 执行报告；
3. 本版本测试报告；
4. UI / XML 证据；
5. 本版本 non-goals；
6. protected surfaces；
7. 6.0 Alpha 主计划；
8. Claude 横向复评门禁规则；
9. 竞品 UI research 安全规则。

## Stage 1：EliteSync 盲测

Claude 先不根据开发说明找功能，而是从普通用户视角体验 EliteSync。

检查：

- 是否知道从哪里开始；
- 是否能自然发现本版本功能；
- 首屏是否自解释；
- 页面是否过长；
- 是否出现工程术语；
- 是否有误操作风险；
- 是否能形成慢约会主线理解。

## Stage 2：EliteSync 带文档复测

Claude 阅读本版本说明后，再检查：

- 计划中写的目标是否实际可见；
- 功能是否符合计划；
- non-goals 是否被突破；
- protected surfaces 是否被误触；
- 证据是否支持 Codex 自报；
- 是否有“文档说有，实机看不到”的问题。

## Stage 3：Soul 横向对照

Claude 使用 Soul 对照本版本相关功能。

如果本版本涉及社交表达、Discover、Chat、Profile、Settings、搭子、状态、关系推进，则必须重点对照 Soul。

输出：

- Soul 的可吸收结构；
- Soul 的不可吸收部分；
- EliteSync 与 Soul 的差距；
- 是否应进入本版修复或后续版本。

## Stage 4：测测 / CECE 横向对照

Claude 使用测测 / CECE 对照本版本相关功能。

如果本版本涉及星盘、八字、紫微、合盘、档案、解释层、字段引导、摘要 / 详情分层，则必须重点对照测测 / CECE。

输出：

- CECE 的可吸收结构；
- CECE 的不可吸收部分；
- EliteSync 与 CECE 的差距；
- 是否应进入本版修复或后续版本。

## Stage 5：三方对比总结

Claude 对 EliteSync / Soul / CECE 进行总结：

- EliteSync 当前最弱的一环；
- 本版本是否解决了计划目标；
- 是否出现新问题；
- 哪些竞品启发应吸收；
- 哪些竞品路径不应吸收；
- 是否符合 Date Drop 式低频高质量匹配定位；
- 是否符合搭子精准陪伴边界；
- 是否适合提交 GPT 顾问验收。

## Stage 6：Action Matrix

必须生成 Action Matrix。

---

# 9. 不同版本的对照重点

## 9.1 Match / 匹配版本

重点检查：

- 等待期是否解释清楚；
- 揭晓页是否有价值；
- 为什么匹配是否可理解；
- 是否支持反馈；
- 是否符合低频高质量；
- 是否避免无限刷人。

Soul 参考：关系推进、破冰、表达入口。  
CECE 参考：合盘、关系解释、维度解释。

## 9.2 Buddy / 搭子版本

重点检查：

- 搭子类型是否清晰；
- 学习 / 电影 / 吃饭 / 健身搭子是否有明确差异；
- 是否有时间、地点、预算、边界；
- 是否有安全提示；
- 是否变成泛同城约玩；
- 是否服务慢约会主线。

Soul 参考：兴趣表达、状态发布、关系启动。  
CECE 参考：不作为主要参考，除非搭子解释借用了玄学适配。

## 9.3 Chat 版本

重点检查：

- 首聊是否低压；
- 建议是否可编辑；
- 是否自动发送；
- 是否暴露私密聊天；
- 冷场恢复是否自然；
- 是否能承接 Match / Buddy 上下文。

Soul 参考：Chat 关系节奏、破冰、状态提示。  
CECE 参考：关系建议 / 避免表达，但不得复制命运式话术。

## 9.4 Profile / Me 版本

重点检查：

- 用户是否知道如何经营自己；
- 资料是否像表单而不是主页；
- 标签是否可理解；
- 自我介绍是否有 CTA；
- 交友意图是否内容化；
- 是否避免资料完整度压力。

Soul 参考：个人经营、自我表达。  
CECE 参考：档案上下文、字段引导。

## 9.5 Astro / 玄学解释版本

重点检查：

- 是否仍是原材料堆叠；
- 是否有摘要句；
- 是否有维度卡；
- 是否有详情页；
- 是否解释对关系 / 表达 / 搭子有什么帮助；
- 是否避免命运断言。

Soul 参考：不作为主要参考。  
CECE 参考：入口矩阵、字段引导、摘要 / 详情分层。

## 9.6 Settings / 治理版本

重点检查：

- 设置入口是否可见；
- 用户是否知道哪些建议可开关；
- 隐私与解释层是否清楚；
- 是否能关闭；
- 是否出现工程配置感；
- 是否有版本、权限、安全说明。

Soul 参考：Settings / Appearance / Permission 分层。  
CECE 参考：解释服务边界，但不吸收商业化入口。

## 9.7 后端 / 底座版本

如果本版本用户不可见，Claude 可以做轻量复评：

- 检查计划是否明确不做 runtime；
- 检查是否存在未来用户体验风险；
- 检查位置 / 隐私 / 数据边界；
- 检查是否需要后续实机复评；
- 不强行做 Soul / CECE 深度对照。

---

# 10. Action Matrix 格式

Claude 必须输出：

```md
# Claude <VERSION> Horizontal Review Action Matrix

| ID | 来源 | App | 页面 | 问题 | 严重度 | 类型 | 证据路径 | 用户感受 | 建议 | 本版处理建议 | 是否进入后续版本 |
|---|---|---|---|---|---|---|---|---|---|---|---|
```

严重度：

```text
P0：阻断主流程
P1：严重困惑 / 明显误操作风险 / 破坏信任
P2：体验不顺 / 信息不清 / 入口不明显
P3：文案、布局、节奏优化
Observation：非阻断观察
```

类型：

```text
入口问题
文案问题
信息密度问题
信任问题
慢约会一致性问题
Date Drop 定位问题
搭子边界问题
解释层问题
互动节奏问题
商业化干扰
竞品差距
技术阻塞
隐私 / 安全问题
```

---

# 11. Claude 报告文件要求

每个版本至少输出：

```text
CLAUDE_<VERSION>_HORIZONTAL_REVIEW.md
CLAUDE_<VERSION>_SOUL_COMPARISON.md
CLAUDE_<VERSION>_CECE_COMPARISON.md
CLAUDE_<VERSION>_ACTION_MATRIX.md
```

如果某个对照不适用，也必须生成对应文件并说明：

```text
本版本不强依赖 Soul 对照，原因是……
本版本不强依赖 CECE 对照，原因是……
```

不得直接省略。

---

# 12. Claude 报告结构

建议结构：

```md
# Claude <VERSION> 横向复评报告

## 1. 任务范围

## 2. 输入材料

## 3. 设备与账号

## 4. 写入行为统计

| App | 关注 | 点赞 | 发消息 | 修改资料 | 付费 | 高风险操作 |
|---|---:|---:|---:|---:|---|---|

## 5. EliteSync 盲测结果

## 6. EliteSync 带文档复测结果

## 7. Soul 横向对照

## 8. CECE / 测测横向对照

## 9. 关键问题分级

### P0
### P1
### P2
### P3
### Observation

## 10. 可吸收项

## 11. 明确不吸收项

## 12. Codex 必须本版处理的问题

## 13. 可后移 observation

## 14. 结论

- pass / pass with observations / conditional pass / fail
```

---

# 13. 通过标准

Claude 复评结论允许：

```text
pass
pass with observations
conditional pass
fail
```

## 13.1 pass

满足：

- 本版本目标可见；
- 主路径可完成；
- 无 P0 / 必修 P1；
- 竞品对照无重大方向冲突；
- 证据充足。

可提交 GPT 顾问验收。

## 13.2 pass with observations

满足：

- 本版本核心目标成立；
- 有 P2 / P3 / Observation；
- 不阻断主路径；
- Codex 已说明后续承接方式。

可提交 GPT 顾问验收，但必须带 observations。

## 13.3 conditional pass

出现：

- 证据不足；
- 某个入口未复测；
- 某个轻微 P1 可快速修；
- Codex 需要补充说明。

不得直接提交 GPT 顾问最终验收。必须先补证据或小修。

## 13.4 fail

出现任一情况：

- 主功能实机不可见；
- 本版本目标未实现；
- 发现 P0；
- 发现重大隐私 / 安全 / 位置风险；
- 明显照抄竞品；
- 破坏 Date Drop 式低频高质量匹配定位；
- 把搭子做成泛同城约玩；
- 进入付费 / 逆向 / 抓包 / 高风险路径；
- 文档自报与实机严重不一致。

不得提交 GPT 顾问最终验收。必须返工。

---

# 14. 写入行为记录规则

任何关注、点赞、发消息、修改资料、设置开关切换等状态改变行为，都必须记录：

1. 操作前截图；
2. 操作后截图；
3. 当前屏幕 XML；
4. 操作对象；
5. 操作文案；
6. 操作原因；
7. 是否可撤回；
8. 是否已经撤回；
9. 是否产生账号状态变化。

格式：

```md
## 写入行为记录

- App：
- 设备：
- 页面：
- 操作：
- 操作对象：
- 操作文案：
- 操作前截图：
- 操作后截图：
- XML：
- 是否可撤回：
- 是否已撤回：
- 风险判断：
```

---

# 15. 停止规则

Claude 遇到以下情况必须停止，不得继续点击：

1. 需要付费、充值、开会员、下单；
2. 需要实名认证、身份证、人脸识别；
3. 需要授权通讯录、相册、定位、麦克风、摄像头，且当前测试目标不需要；
4. 需要上传照片、截图、聊天记录或隐私资料；
5. 需要删除账号、修改手机号、绑定支付；
6. 页面提示继续会产生不可逆结果；
7. 不确定某按钮是否会产生支付 / 咨询 / 发布 / 大规模消息发送；
8. 操作对象是真实用户且行为可能构成骚扰；
9. App 要求访问本地私有文件；
10. 需要跳出普通用户 UI 体验范围。

停止后记录 blocker：

```md
## Blocker 记录

- App：
- 设备：
- 页面：
- 触发路径：
- 当前可见文案：
- 当前 CTA：
- 为什么停止：
- 如果继续需要什么前提：
- 截图：
- XML：
```

---

# 16. Codex 对 Claude 反馈的处理规则

Claude 复评完成后，Codex 必须输出处理说明：

```md
# Codex 对 Claude <VERSION> 横向复评的处理说明

## 1. Claude 结论

## 2. P0 / P1 问题

## 3. 已采纳并修复

## 4. 已采纳但后移

## 5. 未采纳问题与理由

## 6. 补充证据

## 7. 是否满足 GPT 顾问最终验收条件
```

Codex 不得简单写“Claude 已通过”。

必须逐项处理 Action Matrix。

---

# 17. GPT 顾问验收前置条件

提交 GPT 顾问前必须具备：

1. 本版本开发计划书；
2. Codex 执行报告；
3. 测试报告；
4. UI 截图证据；
5. XML / UI hierarchy；
6. Claude 横向复评报告；
7. Claude Soul 对照报告；
8. Claude CECE 对照报告；
9. Claude Action Matrix；
10. Codex 对 Claude 反馈处理说明；
11. 是否 pass / pass with observations 的明确结论。

缺少任一关键材料，不得提交 GPT 顾问最终验收。

---

# 18. 计划书中的固定引用条款

每份版本开发计划书中必须加入：

```text
本版本完成后必须执行 Claude 横向复评。Claude 需实测 EliteSync 当前版本，并使用 Soul + 测测 / CECE 做普通用户可见 UI 产品体验对照。Claude 不得进行逆向、抓包、接口分析、付费、咨询、上传、实名认证等高风险操作。Claude 必须输出复评报告与 Action Matrix。只有 Claude 结论为 pass 或 pass with observations，本版本才能提交 GPT 项目顾问最终验收。
```

---

# 19. 最短执行口径

```text
Claude 横向复评是 EliteSync 6.0 Alpha 起每个版本的强制验收前置门禁。它以 EliteSync APP 实测为主体，以 Soul + 测测 / CECE 为产品结构参考，只做普通用户可见 UI 对照，不做逆向或安全测试。无 Claude 复评，不得提交 GPT 顾问最终验收。
```

