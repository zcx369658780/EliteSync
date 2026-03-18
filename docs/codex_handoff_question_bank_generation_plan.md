# Codex 交接文档：婚恋 App 题库批量生成计划（面向 GPT / Codex CLI）

Version: 1.0  
Owner: ChatGPT handoff to Codex CLI  
Target: 在统一 schema 下，分批生成并维护 2000+ 道适合中国年轻人婚恋场景的双语题库  
Output format: Markdown handoff + JSON question bank files

---

## 1. 文档目标

本文件用于把当前已经确定的题库规范、文件拆分策略、生成规则和验收标准一次性交给 Codex CLI，避免在命令行中反复粘贴上下文造成遗漏或格式漂移。

本文件不是讨论稿，而是执行稿。Codex 接手后应按本文件直接开展题库生成、校验、拆分、去重与维护工作。

---

## 2. 当前已确定的基础信息

### 2.1 已有题库规范

此前已经确定了单题结构的核心 schema，后续所有题目都必须遵循同一结构，至少包含以下字段：

- `question_id`
- `category`
- `question_text`
- `answer_type`
- `options`
- `acceptable_answer_logic`
- `importance_mapping`
- `active`
- `version`

### 2.2 八大维度（固定枚举）

```json
[
  "values",
  "relationship_goals",
  "lifestyle",
  "social_energy",
  "communication",
  "family",
  "intimacy",
  "interests"
]
```

### 2.3 统一 importance 映射（固定）

```json
{
  "0": 0.0,
  "1": 0.33,
  "2": 0.66,
  "3": 1.0
}
```

语义约定：

| importance | 语义 | 算法权重 |
|---|---|---:|
| 0 | 不重要 | 0.00 |
| 1 | 略重要 | 0.33 |
| 2 | 重要 | 0.66 |
| 3 | 非常重要 | 1.00 |

### 2.4 已经产出过的首版样例题库

已有一份首版 MVP 样例 JSON 题库（dating_question_bank_v_1.json），用于确认方向和 schema 一致性。  
Codex 后续不要重写 schema，而应在该 schema 基础上扩充、拆分、去重、稳定枚举。

---

## 3. 目标产物（必须生成的四个文件）

Codex 最终需要生成以下四个 JSON 文件：

```text
question_bank_core_v1.json
question_bank_extended_v1.json
question_bank_research_v1.json
question_bank_taxonomy_v1.json
```

### 3.1 各文件职责

#### A. `question_bank_core_v1.json`

定位：核心匹配题库  
用途：直接进入用户主问卷与匹配算法特征计算  
建议题量：300–500 题

要求：
- 题意稳定
- 尽量高信噪比
- 尽量少歧义
- 适合直接进入 reciprocal / compatibility 计算
- 避免过度敏感

#### B. `question_bank_extended_v1.json`

定位：扩展画像题库  
用途：补充用户画像、解释标签、多样化排序信号  
建议题量：500–700 题

要求：
- 覆盖更多生活方式、表达方式、相处习惯
- 可以比 core 更细
- 仍需保持稳定 options
- 适合中后期产品扩题

#### C. `question_bank_research_v1.json`

定位：研究与实验题库  
用途：AB test、人群细分、婚恋观调研、内容运营研究  
建议题量：700–1000 题

要求：
- 允许覆盖更细分、更探索性的婚恋观问题
- 但仍需通过敏感性筛查
- 不要求全部进入主匹配模型
- 应保留更多研究标签与 topic 标记

#### D. `question_bank_taxonomy_v1.json`

定位：题库索引与分类字典  
用途：给工程、数据、运营和后续自动生成使用  
建议内容：不是普通问卷题，而是题库元数据

必须包含：
- category 定义
- subtopic 定义
- answer_type 枚举
- option_style 模板
- 敏感级别定义
- 使用场景定义
- 文件归属关系
- question_id 命名规范

---

## 4. 总体规模目标

目标总题量：`2000+`

推荐首轮规划：

| 文件 | 目标题量 |
|---|---:|
| question_bank_core_v1.json | 400 |
| question_bank_extended_v1.json | 600 |
| question_bank_research_v1.json | 900 |
| question_bank_taxonomy_v1.json | 元数据文件 |

说明：
- taxonomy 不是普通问卷题，不参与 2000 题统计
- 问卷总量目标由 core + extended + research 共同达到
- 第一阶段可先达到 1900–2100 题，后续再做增补和去重回填

---

## 5. 单题 JSON 标准（固定 schema）

后续所有题目默认使用以下结构：

```json
{
  "question_id": "Q_VALUES_001",
  "category": "values",
  "subtopic": "commitment",
  "question_text": {
    "zh": "在亲密关系里，你更看重哪一点？",
    "en": "What matters most to you in a close relationship?"
  },
  "answer_type": "single_choice",
  "acceptable_answer_logic": "multi_select",
  "options": [
    {
      "option_id": "trust",
      "label": {"zh": "信任与忠诚", "en": "Trust and loyalty"},
      "score": 1.0
    },
    {
      "option_id": "growth",
      "label": {"zh": "共同成长", "en": "Growing together"},
      "score": 0.9
    }
  ],
  "importance_mapping": {
    "0": 0.0,
    "1": 0.33,
    "2": 0.66,
    "3": 1.0
  },
  "sensitivity_level": "low",
  "recommended_bank": "core",
  "tags": ["long_term", "compatibility", "values"],
  "active": true,
  "version": 1
}
```

### 5.1 字段约束

| 字段 | 类型 | 说明 |
|---|---|---|
| question_id | string | 全局唯一，推荐 `Q_{CATEGORY}_{NNN}` 或 `Q_{CATEGORY}_{SUBTOPIC}_{NNN}` |
| category | enum | 必须属于 8 大维度 |
| subtopic | string | 二级主题，用于题库索引和去重 |
| question_text | object | 中英文文案 |
| answer_type | enum | `single_choice` / `multi_choice` |
| acceptable_answer_logic | enum | `single_select` / `multi_select` |
| options | array | 稳定枚举，必须含 `option_id`、双语 `label`、`score` |
| importance_mapping | object | 固定默认值 |
| sensitivity_level | enum | `low` / `medium` / `high_blocked` |
| recommended_bank | enum | `core` / `extended` / `research` |
| tags | array | 便于搜索、建模、运营复用 |
| active | boolean | 是否启用 |
| version | int | 版本 |

### 5.2 强制要求

1. `question_text.zh` 与 `question_text.en` 都必须存在。  
2. `options` 中的每个选项都必须有稳定的 `option_id`，不能只靠文案。  
3. `importance_mapping` 必须回填默认值，不允许缺失。  
4. `recommended_bank` 必须与文件归属一致。  
5. `sensitivity_level = high_blocked` 的题不进入最终题库文件。  

---

## 6. question_bank_taxonomy_v1.json 的结构要求

该文件不存普通题干，而存题库字典与元信息。建议格式如下：

```json
{
  "schema_version": "1.0",
  "categories": [...],
  "subtopics": {
    "values": ["commitment", "trust", "life_priorities", "money_values"],
    "relationship_goals": ["goal_type", "pace", "exclusivity", "future_planning"],
    "lifestyle": ["schedule", "fitness", "travel_style", "drinking"],
    "social_energy": ["social_frequency", "alone_time", "gatherings", "partner_rhythm"],
    "communication": ["conflict", "texting", "affection_expression", "date_pacing"],
    "family": ["children", "marriage_view", "family_boundary", "parenting_style"],
    "intimacy": ["pace", "emotional_safety", "boundaries", "closeness_style"],
    "interests": ["weekend_style", "activities", "first_date", "overlap_expectation"]
  },
  "answer_types": ["single_choice", "multi_choice"],
  "acceptable_answer_logic": ["single_select", "multi_select"],
  "sensitivity_levels": ["low", "medium", "high_blocked"],
  "recommended_banks": ["core", "extended", "research"],
  "question_id_rule": "Q_{CATEGORY}_{NNN} or Q_{CATEGORY}_{SUBTOPIC}_{NNN}",
  "importance_mapping": {
    "0": 0.0,
    "1": 0.33,
    "2": 0.66,
    "3": 1.0
  }
}
```

---

## 7. 生成原则（必须执行）

Codex 在生成题库时，必须同时遵守以下六项生产规则。

### 7.1 维度配额控制

不能让某几个维度题量过多，也不能让某些维度明显偏少。

#### core 题库建议配额

| category | 目标题量 |
|---|---:|
| values | 50 |
| relationship_goals | 50 |
| lifestyle | 50 |
| social_energy | 50 |
| communication | 50 |
| family | 50 |
| intimacy | 50 |
| interests | 50 |

总计：400

#### extended 题库建议配额

| category | 目标题量 |
|---|---:|
| values | 75 |
| relationship_goals | 75 |
| lifestyle | 75 |
| social_energy | 75 |
| communication | 75 |
| family | 75 |
| intimacy | 75 |
| interests | 75 |

总计：600

#### research 题库建议配额

| category | 目标题量 |
|---|---:|
| values | 110~115 |
| relationship_goals | 110~115 |
| lifestyle | 110~115 |
| social_energy | 110~115 |
| communication | 110~115 |
| family | 110~115 |
| intimacy | 110~115 |
| interests | 110~115 |

总计：约 900

### 7.2 题意去重

必须避免以下类型的重复：

1. **完全重复**：题干几乎一致，仅换近义词。  
2. **结构重复**：只是把“你更看重什么”换成“你最在意什么”。  
3. **选项重复**：题干不同，但本质上还是同一组判断维度。  
4. **跨文件重复**：core 和 extended 或 research 出现明显重题。  

#### 去重规则建议

- 同一 `subtopic` 内，不允许高相似题过密堆积
- 同一文件内，单一题意模板不应连续出现超过 3 次
- 与已有题文本相似度高于阈值时，必须改写或删除
- core 中出现过的高价值题，不要原样复制到 extended / research

### 7.3 敏感题筛查

面向中国年轻人婚恋场景时，题库需要真实，但不能粗暴或冒犯。

#### 直接阻断（high_blocked）的题

以下类型不得进入最终题库：

- 明确索要收入数字、资产数字、房产数量
- 过于露骨的性行为细节
- 医疗诊断、心理疾病标签化表达
- 违法内容、暴力倾向、极端歧视性内容
- 带强烈羞辱意味的外貌比较题
- 明确诱导用户披露身份证、住址、公司等隐私

#### 可保留但需谨慎表达（medium）的题

- 婚育观
- 原生家庭边界
- 金钱观
- 亲密节奏
- 伴侣分工
- 价值观冲突处理

这类题要做到：
- 语气温和
- 不预设正确答案
- 不带明显审判感
- 尽量提供中性选项

### 7.4 中英文字段统一

所有题必须双语。

要求：
- 中文优先贴近中国年轻人自然表达
- 英文不是逐字硬译，而是自然、简洁、可用于国际化前端
- 避免中英文语义不一致
- 英文文案不要比中文更尖锐或更模糊

### 7.5 option 枚举稳定化

每个 `option_id` 必须稳定、短小、可复用。

#### 推荐写法

```text
yes / maybe / no
slow / balanced / fast
trust / growth / fun / stability
alone_time / close_person / go_out
```

#### 不推荐写法

```text
option_1 / option_2 / option_3
ans_a / ans_b / ans_c
```

规则：
- option_id 使用英文 snake_case 或简短小写词组
- 同类题尽量复用同一组选项命名
- 不要同义不同 id 随机漂移

### 7.6 importance 默认值回填

所有题统一回填：

```json
{
  "0": 0.0,
  "1": 0.33,
  "2": 0.66,
  "3": 1.0
}
```

不要为单题定制 importance 映射，避免工程复杂化。

---

## 8. 题目设计的业务取向

本题库并不是纯学术社会调查，而是服务于婚恋 App 的真实业务。

因此题目要兼顾以下三点：

1. **可回答**：用户愿意答，不觉得像考试。  
2. **可匹配**：答案对长期相处、关系目标、沟通方式有区分度。  
3. **可扩展**：后续可进入算法、标签系统、AB test、运营活动。  

### 8.1 优先覆盖的主题

- 长期关系 vs 轻松约会
- 婚姻与孩子观念
- 沟通与冲突处理
- 社交与独处节奏
- 生活方式与日常习惯
- 关系推进速度
- 边界感与亲密表达
- 兴趣重叠与约会偏好
- 金钱观、责任感、成长观

### 8.2 尽量避免的坏题特点

- 太像职场性格测试
- 太像心理诊断量表
- 过于说教
- 过于学术化
- 只能区分“好人/坏人”，没有真实偏好差异
- 用户一看就知道“系统想让我选哪个”

---

## 9. 文件拆分策略

Codex 不要一次在单个文件中粗暴写满 2000 题。应使用分层拆分策略。

### 9.1 生成顺序

建议按以下顺序执行：

```text
第 1 步：先写 question_bank_taxonomy_v1.json
第 2 步：写 question_bank_core_v1.json
第 3 步：写 question_bank_extended_v1.json
第 4 步：写 question_bank_research_v1.json
第 5 步：全局去重、全局校验、全局补齐
```

### 9.2 批次策略

建议每批生成 80–150 题，然后立即做校验，而不是一次吐完全部。

推荐批次：

- core：每批 80–100 题
- extended：每批 100–120 题
- research：每批 120–150 题

每批完成后必须执行：
- schema 校验
- category 配额统计
- subtopic 覆盖检查
- 题意去重
- 敏感题筛查
- 中英文字段缺失检查

---

## 10. 质量验收标准

### 10.1 结构验收

每道题都必须满足：
- 字段齐全
- 枚举合法
- options 非空
- 中英文字段齐全
- question_id 唯一
- importance_mapping 存在

### 10.2 内容验收

每道题都必须满足：
- 语义清晰
- 不过度敏感
- 不带强引导性
- 能区分真实偏好
- 中文自然
- 英文可用

### 10.3 文件级验收

每个文件都必须满足：
- 达到目标题量
- 8 大维度分布基本均衡
- 没有明显题意堆叠
- 同文件内重复率可控
- 与其他文件的高相似题比例可控

### 10.4 全局验收

最终题库集合必须满足：
- 总题量 2000+
- core / extended / research 分层清晰
- taxonomy 能解释整个题库结构
- 后续可用于自动扩题与运营标注

---

## 11. question_id 命名规则

推荐以下两种之一：

### 简化版

```text
Q_VALUES_001
Q_FAMILY_023
Q_COMMUNICATION_117
```

### 细分版

```text
Q_VALUES_COMMITMENT_001
Q_FAMILY_CHILDREN_014
Q_COMMUNICATION_CONFLICT_008
```

执行建议：
- core 用简化版即可
- extended / research 更建议细分版，便于去重与索引

---

## 12. subtopic 建议清单

以下为推荐的二级主题池，Codex 可按此扩展。

### values
- commitment
- trust
- loyalty
- growth
- money_values
- responsibility
- emotional_stability
- life_priorities
- ambition_balance
- independence_vs_partnership

### relationship_goals
- goal_type
- pace
- exclusivity
- future_planning
- seriousness
- marriage_orientation
- dating_frequency
- certainty_threshold

### lifestyle
- schedule
- fitness
- cleanliness
- drinking
- smoking_attitude
- travel_style
- spending_style
- weekend_routine
- food_habits
- daily_structure

### social_energy
- social_frequency
- alone_time
- gathering_preference
- partner_social_rhythm
- recharge_style
- small_group_vs_big_group
- extroversion_expression

### communication
- conflict
- texting
- emotional_support
- affection_expression
- misunderstanding_repair
- directness
- reassurance
- feedback_style
- date_planning_communication

### family
- children
- marriage_view
- family_boundary
- parenting_style
- eldercare_attitude
- family_closeness
- household_roles
- stability_expectation

### intimacy
- emotional_safety
- physical_pace
- closeness_style
- vulnerability
- boundaries
- reassurance_need
- affection_rhythm
- exclusivity_comfort

### interests
- weekend_style
- first_date
- activities
- culture_consumption
- fitness_fun
- travel_interest
- food_interest
- homebody_vs_explorer
- overlap_expectation

---

## 13. 推荐题型模板

Codex 可以围绕以下模板批量扩题，但必须注意去重。

### 模板 A：偏好主轴

```text
你更偏向哪种？
Which do you lean toward more?
```

### 模板 B：理想关系场景

```text
在理想关系里，你更希望……
In an ideal relationship, you would rather...
```

### 模板 C：冲突/困难处理

```text
当出现分歧时，你通常更希望……
When a disagreement happens, you usually prefer...
```

### 模板 D：边界与节奏

```text
你对关系推进速度更接近哪种感受？
Which pace of relationship progression feels more right to you?
```

### 模板 E：生活方式分叉

```text
你的日常习惯更接近哪种？
Which daily pattern describes you better?
```

### 模板 F：多选活动偏好

```text
哪些活动最容易让你投入？（可多选）
Which activities are most likely to engage you? (Multiple choice)
```

---

## 14. 推荐 option 风格模板

### 14.1 三档模板

```json
[
  {"option_id": "low", "label": {"zh": "较低", "en": "Lower"}, "score": 0.3},
  {"option_id": "balanced", "label": {"zh": "适中", "en": "Balanced"}, "score": 0.7},
  {"option_id": "high", "label": {"zh": "较高", "en": "Higher"}, "score": 1.0}
]
```

### 14.2 节奏模板

```json
[
  {"option_id": "slow", "label": {"zh": "慢一点", "en": "Slower"}, "score": 1.0},
  {"option_id": "balanced", "label": {"zh": "自然推进", "en": "Balanced"}, "score": 1.0},
  {"option_id": "fast", "label": {"zh": "快一点", "en": "Faster"}, "score": 0.6}
]
```

### 14.3 亲近度模板

```json
[
  {"option_id": "very_close", "label": {"zh": "非常亲近", "en": "Very close"}, "score": 1.0},
  {"option_id": "balanced", "label": {"zh": "亲近但有边界", "en": "Close with boundaries"}, "score": 1.0},
  {"option_id": "independent", "label": {"zh": "相对独立", "en": "More independent"}, "score": 0.7}
]
```

---

## 15. 推荐给 Codex CLI 的执行方式

### 15.1 第一阶段：先建立 taxonomy

Codex 首先创建并写入：

```text
question_bank_taxonomy_v1.json
```

内容包括：
- categories
- subtopics
- answer_type 枚举
- acceptable_answer_logic 枚举
- sensitivity_level 枚举
- recommended_bank 枚举
- importance_mapping
- question_id_rule
- option_style_templates

### 15.2 第二阶段：生成 core

目标：400 题  
特点：高质量、低歧义、可直接入主问卷

### 15.3 第三阶段：生成 extended

目标：600 题  
特点：扩展画像、补充特征、保留中度探索题

### 15.4 第四阶段：生成 research

目标：900 题  
特点：研究与实验导向，但仍必须通过敏感性筛查

### 15.5 第五阶段：全局校验

全量执行：
- id 唯一性检查
- category 配额检查
- subtopic 覆盖检查
- 中英文字段缺失检查
- 敏感题过滤
- 跨文件重复检查
- 统计题量与输出总结

---

## 16. 可直接交给 Codex 的工作指令模板

以下提示词可以直接交给 Codex CLI。

### 16.1 初始化任务

```text
请在当前项目目录中生成一个婚恋 App 双语题库生产流程，目标是产出以下四个文件：
1. question_bank_core_v1.json
2. question_bank_extended_v1.json
3. question_bank_research_v1.json
4. question_bank_taxonomy_v1.json

要求：
- 所有题目遵循统一 JSON schema
- 8 大维度固定：values, relationship_goals, lifestyle, social_energy, communication, family, intimacy, interests
- importance_mapping 固定为 {"0":0.0,"1":0.33,"2":0.66,"3":1.0}
- 每题必须双语（zh/en）
- 每题必须包含 question_id, category, subtopic, question_text, answer_type, options, acceptable_answer_logic, importance_mapping, sensitivity_level, recommended_bank, tags, active, version
- 先写 taxonomy，再分批生成 core / extended / research
- 目标总题量达到 2000+
- 生成过程中执行维度配额控制、题意去重、敏感题筛查、中英文字段统一、option 枚举稳定化、importance 默认值回填
```

### 16.2 生成 core 的提示词

```text
请生成 question_bank_core_v1.json，目标 400 题，8 个 category 平均分配，每类约 50 题。

要求：
- 定位为核心匹配题
- 适合中国年轻人婚恋语境
- 中文自然、英文自然
- 尽量低歧义、高区分度
- 避免过度敏感或冒犯性题目
- 不要重复题意
- options 使用稳定英文 option_id
- acceptable_answer_logic 只使用 single_select 或 multi_select
- answer_type 只使用 single_choice 或 multi_choice
- 每题写入 recommended_bank="core"
- 每题写入 sensitivity_level，high_blocked 不得出现在输出中
```

### 16.3 生成 extended 的提示词

```text
请生成 question_bank_extended_v1.json，目标 600 题，8 个 category 平均分配，每类约 75 题。

要求：
- 定位为扩展画像题
- 不要复制 core 中已有题目
- 可以细化生活方式、沟通方式、家庭边界、兴趣重叠等主题
- 保持双语、稳定 option_id、统一 importance_mapping
- 每题写入 recommended_bank="extended"
- 输出前先与 core 做高相似题检查
```

### 16.4 生成 research 的提示词

```text
请生成 question_bank_research_v1.json，目标 900 题，8 个 category 平均分配。

要求：
- 定位为研究与实验题库
- 可以比 core / extended 更细、更探索
- 但不得包含 high_blocked 敏感题
- 允许覆盖婚育观、责任观、边界感、金钱观、伴侣角色预期等更细分主题
- 仍需双语、统一 schema、稳定 option_id
- 每题写入 recommended_bank="research"
- 输出前先与 core 和 extended 做高相似题检查
```

### 16.5 全局校验提示词

```text
请对以下文件执行全局校验：
- question_bank_core_v1.json
- question_bank_extended_v1.json
- question_bank_research_v1.json
- question_bank_taxonomy_v1.json

检查项：
1. question_id 是否全局唯一
2. category 是否都属于 8 大维度
3. 中英文字段是否齐全
4. answer_type 和 acceptable_answer_logic 是否合法
5. importance_mapping 是否完整
6. options 是否都有 option_id 和双语 label
7. 是否存在 high_blocked 题目未被剔除
8. 是否存在明显跨文件重复题
9. 是否达到目标题量和维度配额
10. 输出一份 validation_summary.md，总结每个文件的题量、维度分布、重复处理情况和敏感题筛查情况
```

---

## 17. validation_summary.md 应包含的内容

建议最终额外输出：

```text
validation_summary.md
```

至少包含：
- 每个文件总题量
- 每个维度题量
- 每个 subtopic 覆盖数
- 去重前后数量变化
- 敏感题剔除数量
- 中英字段修复数量
- 发现的结构错误数量
- 最终可入库题量

---

## 18. 对 Codex 的执行风格要求

Codex 在处理该任务时，应遵循以下风格：

1. 不要一次性大段自由生成后再勉强拼接。  
2. 应优先保证 schema 正确和题意稳定。  
3. 应优先完成 taxonomy，再按批次扩题。  
4. 应把“去重、筛查、回填”看作生产流程的一部分，而不是事后补救。  
5. 对于过于敏感、不适合产品问卷的题目，应直接删除而不是硬改。  
6. 对于质量不够高的 research 题，也可以删除，不必强行凑数。  

---

## 19. 最终执行摘要

Codex 接手后的目标不是“随便生成很多题”，而是建立一套可持续扩张的婚恋题库生产体系。

最终目标如下：

```text
1. 生成 taxonomy 文件，固定题库结构
2. 生成 core 题库（约 400 题）
3. 生成 extended 题库（约 600 题）
4. 生成 research 题库（约 900 题）
5. 总题量达到 2000+
6. 所有题统一 schema、双语、稳定 option_id、固定 importance_mapping
7. 全流程执行维度配额控制、题意去重、敏感题筛查、中英统一、importance 回填
8. 输出 validation_summary.md 作为验收结果
```

---

## 20. 给你的补充说明

这份文档设计成“Codex 可直接执行”的交接稿，因此重点是：
- 规则明确
- 文件清晰
- 批次可控
- 质量口径统一

如果后续需要，还可以在本文件基础上继续追加：
- `dedupe_rules.md`
- `sensitive_filter_rules.md`
- `question_generation_templates.json`
- `question_bank_seed_examples.json`

这样 Codex 的自动化生产会更稳。

