# Dating Matching System Design Supplement for Codex

Version: 1.1  
Target file: dating_system_design_supplement_for_codex.md  
Audience: Product / Algorithm / Backend / Data / Codex CLI implementation

---

## 1. 文档目的

本补充文档用于把原始设计文档中偏“原则性”的部分，补齐为可直接实现、可直接入库、可直接给 Codex 使用的工程规范，重点补充以下 5 项：

1. 问卷字段规范（JSON schema + 示例）
2. 业务硬约束优先级表（召回过滤 / 排序降分）
3. 解释标签字典（中英文）
4. 冷启动参数默认值
5. 公平指标目标

建议将本文件作为原文档的附录 A 使用，或直接合并进主设计文档第 23 节之后。

---

## 2. 问卷字段规范（必须给到）

### 2.1 八大维度枚举

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

### 2.2 单题 JSON Schema（入库标准）

每道题必须固定包含以下字段：

```json
{
  "question_id": "Q_FAMILY_001",
  "category": "family",
  "question_text": {
    "zh": "你想要孩子吗？",
    "en": "Do you want children?"
  },
  "answer_type": "single_choice",
  "options": [
    {
      "option_id": "yes",
      "label": { "zh": "想要", "en": "Yes" },
      "score": 1
    },
    {
      "option_id": "maybe",
      "label": { "zh": "不确定", "en": "Maybe" },
      "score": 0.5
    },
    {
      "option_id": "no",
      "label": { "zh": "不想要", "en": "No" },
      "score": 0
    }
  ],
  "acceptable_answer_logic": "multi_select",
  "importance_mapping": {
    "0": 0.0,
    "1": 0.33,
    "2": 0.66,
    "3": 1.0
  },
  "active": true,
  "version": 1
}
```

### 2.3 字段定义

| 字段 | 类型 | 说明 |
|---|---|---|
| question_id | string | 全局唯一，推荐 `Q_{CATEGORY}_{NNN}` |
| category | enum | 必须是 8 大维度之一 |
| question_text | object | 中英文本，便于多语言前端复用 |
| answer_type | enum | `single_choice` / `multi_choice` |
| options | array | 可选项列表，必须稳定可枚举 |
| acceptable_answer_logic | enum | 用户设置“可接受答案”的选择方式，`single_select` 或 `multi_select` |
| importance_mapping | object | 重要度 0~3 到算法权重的映射 |
| active | boolean | 是否启用 |
| version | int | 题目版本号 |

### 2.4 用户答案 JSON Schema（入库标准）

每个用户对每道题的作答建议拆成一张独立表或一条文档记录：

```json
{
  "user_id": "U_123456",
  "question_id": "Q_FAMILY_001",
  "selected_answer": ["yes"],
  "acceptable_answers": ["yes", "maybe"],
  "importance": 3,
  "updated_at": "2026-03-15T10:00:00Z",
  "version": 1
}
```

### 2.5 字段约束

#### selected_answer

- 当题目 `answer_type = single_choice` 时：
  - 必须长度为 1 的数组
- 当题目 `answer_type = multi_choice` 时：
  - 可以长度 >= 1

统一用数组存储，便于工程实现一致。

#### acceptable_answers

- 当 `acceptable_answer_logic = single_select` 时：
  - 长度必须为 1
- 当 `acceptable_answer_logic = multi_select` 时：
  - 长度可以 >= 1
- 所有值都必须属于该题 `options.option_id`

#### importance

```json
[0, 1, 2, 3]
```

映射到模型权重建议固定为：

| importance | 语义 | 算法权重 |
|---|---|---|
| 0 | 不重要 | 0.00 |
| 1 | 略重要 | 0.33 |
| 2 | 重要 | 0.66 |
| 3 | 非常重要 | 1.00 |

说明：
- 存储层保留用户原始选择 `0~3`
- 特征层转换为连续权重 `0.00~1.00`
- 这样前端、埋点、模型都更稳定

### 2.6 兼容得分规则（可直接实现）

设题目 q 上：

- `A.selected_answer[q]` = A 的答案
- `A.acceptable_answers[q]` = A 可接受的对方答案
- `w(A,q)` = importance_mapping(A.importance[q])

#### 单选题

```text
Agreement(A<-B,q) = 1, if B.selected_answer[0] in A.acceptable_answers
                    0, otherwise
```

#### 多选题

建议采用 Jaccard-over-acceptable 版本，避免过于严格：

```text
Agreement(A<-B,q) = |B.selected_answer ∩ A.acceptable_answers| / |B.selected_answer|
```

若要更严格，也可改为：

```text
Agreement(A<-B,q) = 1, if B.selected_answer ⊆ A.acceptable_answers
                    0, otherwise
```

MVP 推荐第一种，容错更好。

#### 单向题目得分

```text
Score_q(A<-B) = Agreement(A<-B,q) * w(A,q)
```

#### 双向题目得分

```text
BiScore_q(A,B) = Score_q(A<-B) + Score_q(B<-A)
```

#### 总体问卷兼容

```text
QuestionCompatibility(A,B) = Σ BiScore_q(A,B) / Σ MaxBiScore_q(A,B)
```

最终归一化到 `[0,1]`。

### 2.7 建议数据库表结构

#### questionnaire_questions

| 字段 | 类型 | 说明 |
|---|---|---|
| question_id | varchar PK | 题目 ID |
| category | varchar | 8 大维度 |
| question_text_zh | text | 中文题干 |
| question_text_en | text | 英文题干 |
| answer_type | varchar | `single_choice` / `multi_choice` |
| acceptable_answer_logic | varchar | `single_select` / `multi_select` |
| options_json | jsonb | 选项配置 |
| version | int | 版本 |
| active | boolean | 是否启用 |
| created_at | timestamptz | 创建时间 |
| updated_at | timestamptz | 更新时间 |

#### user_question_answers

| 字段 | 类型 | 说明 |
|---|---|---|
| user_id | varchar PK(partial) | 用户 ID |
| question_id | varchar PK(partial) | 题目 ID |
| selected_answer_json | jsonb | 用户答案数组 |
| acceptable_answers_json | jsonb | 可接受答案数组 |
| importance | smallint | 0~3 |
| version | int | 题目版本 |
| updated_at | timestamptz | 更新时间 |

推荐唯一键：

```text
(user_id, question_id)
```

### 2.8 五道标准示例题（可直接扩展）

```json
[
  {
    "question_id": "Q_RELATIONSHIP_GOALS_001",
    "category": "relationship_goals",
    "question_text": {
      "zh": "你现在主要想找什么关系？",
      "en": "What kind of relationship are you primarily looking for right now?"
    },
    "answer_type": "single_choice",
    "options": [
      {"option_id": "casual", "label": {"zh": "轻松约会", "en": "Casual dating"}, "score": 0},
      {"option_id": "long_term", "label": {"zh": "长期关系", "en": "Long-term relationship"}, "score": 0.7},
      {"option_id": "marriage", "label": {"zh": "以结婚为目标", "en": "Marriage"}, "score": 1}
    ],
    "acceptable_answer_logic": "multi_select",
    "importance_mapping": {"0": 0.0, "1": 0.33, "2": 0.66, "3": 1.0},
    "active": true,
    "version": 1
  },
  {
    "question_id": "Q_FAMILY_001",
    "category": "family",
    "question_text": {
      "zh": "你想要孩子吗？",
      "en": "Do you want children?"
    },
    "answer_type": "single_choice",
    "options": [
      {"option_id": "yes", "label": {"zh": "想要", "en": "Yes"}, "score": 1},
      {"option_id": "maybe", "label": {"zh": "不确定", "en": "Maybe"}, "score": 0.5},
      {"option_id": "no", "label": {"zh": "不想要", "en": "No"}, "score": 0}
    ],
    "acceptable_answer_logic": "multi_select",
    "importance_mapping": {"0": 0.0, "1": 0.33, "2": 0.66, "3": 1.0},
    "active": true,
    "version": 1
  },
  {
    "question_id": "Q_LIFESTYLE_001",
    "category": "lifestyle",
    "question_text": {
      "zh": "你的作息更接近哪种？",
      "en": "Which schedule describes you better?"
    },
    "answer_type": "single_choice",
    "options": [
      {"option_id": "early", "label": {"zh": "早睡早起", "en": "Early bird"}, "score": 1},
      {"option_id": "flexible", "label": {"zh": "比较灵活", "en": "Flexible"}, "score": 0.5},
      {"option_id": "night", "label": {"zh": "夜猫子", "en": "Night owl"}, "score": 0}
    ],
    "acceptable_answer_logic": "multi_select",
    "importance_mapping": {"0": 0.0, "1": 0.33, "2": 0.66, "3": 1.0},
    "active": true,
    "version": 1
  },
  {
    "question_id": "Q_COMMUNICATION_001",
    "category": "communication",
    "question_text": {
      "zh": "冲突出现时你更倾向？",
      "en": "How do you usually handle conflict?"
    },
    "answer_type": "single_choice",
    "options": [
      {"option_id": "discuss_now", "label": {"zh": "当下沟通", "en": "Discuss immediately"}, "score": 1},
      {"option_id": "cool_then_talk", "label": {"zh": "先冷静再沟通", "en": "Cool down first"}, "score": 0.6},
      {"option_id": "avoid", "label": {"zh": "尽量避免冲突", "en": "Avoid conflict"}, "score": 0}
    ],
    "acceptable_answer_logic": "multi_select",
    "importance_mapping": {"0": 0.0, "1": 0.33, "2": 0.66, "3": 1.0},
    "active": true,
    "version": 1
  },
  {
    "question_id": "Q_INTERESTS_001",
    "category": "interests",
    "question_text": {
      "zh": "理想周末更像哪种？",
      "en": "What does your ideal weekend look like?"
    },
    "answer_type": "multi_choice",
    "options": [
      {"option_id": "outdoor", "label": {"zh": "户外活动", "en": "Outdoor activities"}, "score": 1},
      {"option_id": "social", "label": {"zh": "聚会社交", "en": "Social gatherings"}, "score": 1},
      {"option_id": "home", "label": {"zh": "宅家放松", "en": "Relax at home"}, "score": 1},
      {"option_id": "travel", "label": {"zh": "短途旅行", "en": "Short trips"}, "score": 1}
    ],
    "acceptable_answer_logic": "multi_select",
    "importance_mapping": {"0": 0.0, "1": 0.33, "2": 0.66, "3": 1.0},
    "active": true,
    "version": 1
  }
]
```

---

## 3. 业务硬约束优先级表

目标：明确哪些条件在召回层必须过滤，哪些进入排序层做降分，避免算法和后端在不同层重复或冲突实现。

### 3.1 优先级定义

| 优先级 | 类型 | 处理方式 |
|---|---|---|
| P0 | 安全/合规硬过滤 | 必须过滤，不得下发到排序层 |
| P1 | 核心双边硬约束 | 必须过滤，不得进入候选池 |
| P2 | 强偏好软约束 | 不过滤，但重度降分 |
| P3 | 一般偏好软约束 | 不过滤，轻中度降分 |
| P4 | 解释性特征 | 仅加分或出标签，不单独触发过滤 |

### 3.2 召回层硬约束表

| 约束项 | 优先级 | 建议处理 | 说明 |
|---|---|---|---|
| block / report / safety blacklist | P0 | 必须过滤 | 安全与合规优先 |
| account banned / under review / scam risk high | P0 | 必须过滤 | 风险账号不参与推荐 |
| gender preference 双边不满足 | P1 | 必须过滤 | A 接受 B 且 B 接受 A 才能召回 |
| age range 双边不满足 | P1 | 必须过滤 | 任一方超出对方硬年龄范围即过滤 |
| distance max 双边都超出 | P1 | 必须过滤 | 若双方都设置硬距离限制，取交集 |
| city-only / same-city hard setting 不满足 | P1 | 必须过滤 | 城市强约束产品必须召回层处理 |
| relationship goal 完全冲突 | P1 | 必须过滤 | 如一方只接受 marriage，另一方只接受 casual |
| inactive too long | P1 | 必须过滤 | 建议 30 天未活跃过滤 |
| duplicate / already matched / already passed recently | P1 | 必须过滤 | 避免浪费曝光 |
| children willingness severe conflict | P2 | 重度降分 | 除非产品定义为“硬条件” |
| smoking / drinking severe conflict | P2 | 重度降分 | 保留少量探索空间 |
| religion mismatch | P2 | 重度降分 | 除非用户将其设为硬条件 |
| education mismatch | P3 | 中度降分 | 不建议做硬过滤 |
| height preference mismatch | P3 | 中度降分 | 不建议做召回硬过滤 |
| introvert/extrovert mismatch | P3 | 轻度降分 | 更适合排序层处理 |
| low profile completeness | P3 | 中度降分 | 不是兼容问题，但影响体验 |
| interest overlap low | P4 | 轻度降分或不加分 | 适合排序层特征 |

### 3.3 四类核心业务约束的明确结论

#### 1) 性别偏好

- 默认：`必须过滤`
- 实现：双边必须同时满足

```text
A accepts gender(B) AND B accepts gender(A)
```

#### 2) 年龄范围

- 默认：`必须过滤`
- 实现：双边硬年龄范围都满足
- 年龄差不作为附加过滤，只用用户配置年龄范围

#### 3) 距离

- 默认：`必须过滤`
- 但支持产品开关：
  - `strict_distance_filter = true`：严格过滤
  - `strict_distance_filter = false`：超出距离但保留少量探索候选，并在排序层大幅降分

MVP 建议：严格过滤。

#### 4) 关系目标冲突

建议细分：

| A 目标 | B 目标 | 处理 |
|---|---|---|
| casual | casual | 通过 |
| casual | long_term | 降分 |
| casual | marriage | 必须过滤 |
| long_term | long_term | 通过 |
| long_term | marriage | 通过或轻降分 |
| marriage | marriage | 通过 |
| marriage | casual | 必须过滤 |

规则总结：
- `casual ↔ marriage`：必须过滤
- `casual ↔ long_term`：降分
- `long_term ↔ marriage`：轻降分或不降分

### 3.4 排序层降分建议

建议对软约束冲突使用乘法衰减，而不是简单减常数：

```text
score_after_penalty = base_score * penalty_factor
```

推荐默认值：

| 软约束项 | 冲突级别 | penalty_factor |
|---|---|---|
| children willingness | 强冲突 | 0.60 |
| smoking | 强冲突 | 0.70 |
| drinking | 强冲突 | 0.75 |
| religion | 强冲突 | 0.70 |
| relationship goal partial mismatch | 中强冲突 | 0.70 |
| education mismatch | 中冲突 | 0.85 |
| lifestyle mismatch | 中冲突 | 0.85 |
| communication mismatch | 中冲突 | 0.88 |
| interest overlap low | 轻冲突 | 0.92 |

### 3.5 推荐实现顺序

```text
P0 安全过滤
→ P1 核心双边硬约束过滤
→ 多路召回合并
→ 排序模型打分
→ P2/P3 软约束乘法降分
→ 公平重排
→ Top-N 返回
```

---

## 4. 解释标签字典（中英文）

目标：把算法命中特征翻译成稳定、统一、可国际化的用户可读文案，避免工程侧临时发挥。

### 4.1 标签生成原则

1. 标签必须是“正向可展示”文案，不显示负面拒绝理由。  
2. 仅展示前 3 个 strongest positive signals。  
3. 不直接展示敏感推断，如收入、热度分位、被很多人喜欢。  
4. 优先显示双方匹配、生活方式、长期目标，而不是模型术语。  

### 4.2 explanation_tag JSON Schema

```json
{
  "tag_code": "shared_relationship_goal",
  "feature_group": "pair",
  "trigger_rule": "A.relationship_goal == B.relationship_goal",
  "display_priority": 10,
  "label": {
    "zh": "你们都想找长期稳定关系",
    "en": "You are both looking for a stable long-term relationship"
  }
}
```

### 4.3 解释标签字典

```json
[
  {
    "tag_code": "shared_relationship_goal",
    "feature_group": "pair",
    "trigger_rule": "same relationship goal OR marriage/long_term compatible",
    "display_priority": 10,
    "label": {
      "zh": "你们对关系目标很一致",
      "en": "You are aligned on relationship goals"
    }
  },
  {
    "tag_code": "both_long_term",
    "feature_group": "pair",
    "trigger_rule": "A.goal == 'long_term' AND B.goal == 'long_term'",
    "display_priority": 9,
    "label": {
      "zh": "你们都想找长期关系",
      "en": "You are both looking for a long-term relationship"
    }
  },
  {
    "tag_code": "both_marriage_minded",
    "feature_group": "pair",
    "trigger_rule": "A.goal == 'marriage' AND B.goal == 'marriage'",
    "display_priority": 9,
    "label": {
      "zh": "你们都以结婚为目标",
      "en": "You are both dating with marriage in mind"
    }
  },
  {
    "tag_code": "children_alignment",
    "feature_group": "questionnaire",
    "trigger_rule": "family.children strong agreement",
    "display_priority": 9,
    "label": {
      "zh": "你们对是否要孩子的想法接近",
      "en": "You have similar views on having children"
    }
  },
  {
    "tag_code": "values_alignment",
    "feature_group": "questionnaire",
    "trigger_rule": "values compatibility >= 0.8",
    "display_priority": 8,
    "label": {
      "zh": "你们的价值观比较契合",
      "en": "Your values seem highly compatible"
    }
  },
  {
    "tag_code": "communication_style_match",
    "feature_group": "questionnaire",
    "trigger_rule": "communication compatibility >= 0.75",
    "display_priority": 8,
    "label": {
      "zh": "你们的沟通方式比较合拍",
      "en": "Your communication styles match well"
    }
  },
  {
    "tag_code": "lifestyle_match",
    "feature_group": "questionnaire",
    "trigger_rule": "lifestyle compatibility >= 0.75",
    "display_priority": 8,
    "label": {
      "zh": "你们的生活方式比较接近",
      "en": "You have similar lifestyles"
    }
  },
  {
    "tag_code": "sleep_schedule_match",
    "feature_group": "questionnaire",
    "trigger_rule": "sleep habit aligned",
    "display_priority": 7,
    "label": {
      "zh": "你们的作息节奏接近",
      "en": "You keep a similar daily rhythm"
    }
  },
  {
    "tag_code": "social_energy_match",
    "feature_group": "questionnaire",
    "trigger_rule": "social_energy compatibility >= 0.75",
    "display_priority": 7,
    "label": {
      "zh": "你们相处时对社交和独处的需求更容易平衡",
      "en": "Your social energy feels well balanced"
    }
  },
  {
    "tag_code": "shared_weekend_style",
    "feature_group": "questionnaire",
    "trigger_rule": "weekend preference overlap >= 0.5",
    "display_priority": 6,
    "label": {
      "zh": "你们理想中的周末方式很像",
      "en": "You enjoy spending weekends in similar ways"
    }
  },
  {
    "tag_code": "interest_overlap_high",
    "feature_group": "pair",
    "trigger_rule": "interest overlap >= 0.6",
    "display_priority": 7,
    "label": {
      "zh": "你们有不少共同兴趣",
      "en": "You share quite a few common interests"
    }
  },
  {
    "tag_code": "mutual_outdoor_interest",
    "feature_group": "pair",
    "trigger_rule": "both like outdoor",
    "display_priority": 5,
    "label": {
      "zh": "你们都喜欢户外活动",
      "en": "You both enjoy outdoor activities"
    }
  },
  {
    "tag_code": "mutual_travel_interest",
    "feature_group": "pair",
    "trigger_rule": "both like travel",
    "display_priority": 5,
    "label": {
      "zh": "你们都喜欢旅行",
      "en": "You both enjoy traveling"
    }
  },
  {
    "tag_code": "close_distance",
    "feature_group": "pair",
    "trigger_rule": "distance_km <= 10",
    "display_priority": 6,
    "label": {
      "zh": "你们距离很近，更方便见面",
      "en": "You live close enough to meet up easily"
    }
  },
  {
    "tag_code": "same_city",
    "feature_group": "pair",
    "trigger_rule": "city same",
    "display_priority": 6,
    "label": {
      "zh": "你们在同一座城市",
      "en": "You are in the same city"
    }
  },
  {
    "tag_code": "active_recently",
    "feature_group": "user",
    "trigger_rule": "candidate active within 24h",
    "display_priority": 4,
    "label": {
      "zh": "对方最近很活跃",
      "en": "This person has been active recently"
    }
  },
  {
    "tag_code": "new_here",
    "feature_group": "user",
    "trigger_rule": "account_age_days <= 7",
    "display_priority": 3,
    "label": {
      "zh": "对方刚加入，值得抢先认识",
      "en": "They are new here and worth discovering early"
    }
  },
  {
    "tag_code": "profile_complete",
    "feature_group": "user",
    "trigger_rule": "profile completeness >= 0.9",
    "display_priority": 3,
    "label": {
      "zh": "对方资料完整，更容易快速了解",
      "en": "Their profile is complete, so it is easier to get to know them"
    }
  }
]
```

### 4.4 返回给前端的建议格式

```json
{
  "candidate_id": "U_98765",
  "final_score": 0.8421,
  "explanation_tags": [
    {
      "tag_code": "both_long_term",
      "label": {"zh": "你们都想找长期关系", "en": "You are both looking for a long-term relationship"}
    },
    {
      "tag_code": "communication_style_match",
      "label": {"zh": "你们的沟通方式比较合拍", "en": "Your communication styles match well"}
    },
    {
      "tag_code": "close_distance",
      "label": {"zh": "你们距离很近，更方便见面", "en": "You live close enough to meet up easily"}
    }
  ]
}
```

### 4.5 标签选择规则

```text
1. 根据 trigger_rule 生成候选标签
2. 按 display_priority 排序
3. 去掉同类重复标签（如 same_city 与 close_distance 只保留更强一个）
4. 最多返回 3 个
```

---

## 5. 冷启动参数默认值

目标：在没有足够行为数据时，给 Matching / Ranking / Traffic 分配一个明确默认值，避免线上策略漂移。

### 5.1 冷启动用户定义

建议分两层：

| 阶段 | 判定 |
|---|---|
| New User | 注册 <= 7 天 |
| Cold User | 累计曝光 < 100 或累计 like/match/reply 样本不足 |

推荐实现：

```text
is_new_user = account_age_days <= 7
is_cold_user = account_age_days <= 14 OR historical_positive_events < 20
```

### 5.2 FreshnessBoost 默认值

推荐采用指数衰减：

```text
FreshnessBoost(days_since_signup) = exp(-days_since_signup / tau)
```

推荐默认参数：

| 参数 | 默认值 | 说明 |
|---|---:|---|
| tau | 7 天 | 新鲜度衰减时间常数 |
| max_boost_weight_in_final_score | 0.05 | 与主文档保持一致 |
| full_new_user_window | 3 天 | 前 3 天给予最明显扶持 |
| effective_boost_window | 14 天 | 14 天后衰减接近尾声 |

结论：
- 默认选 `7 天`，不是 `14 天`
- 因为约会产品对“新鲜感”和快速首轮曝光更敏感
- 14 天容易让新用户扶持过长，挤压存量用户

### 5.3 FreshnessBoost 分段近似（方便工程实现）

若线上不方便算指数函数，可用分段表：

| 注册天数 | freshness_multiplier |
|---|---:|
| 0~3 天 | 1.20 |
| 4~7 天 | 1.10 |
| 8~14 天 | 1.05 |
| >14 天 | 1.00 |

### 5.4 新用户探索流量比例

推荐默认值：

| 参数 | 默认值 | 说明 |
|---|---:|---|
| new_user_exploration_quota | 10% | 首页/推荐流中保底给新用户的探索流量 |
| global_random_exploration_quota | 5% | 所有用户统一随机探索位 |
| candidate_pool_new_user_injection_ratio | 15% | 候选池中额外注入新用户比例 |

结论：
- 默认建议 `10%`
- 不建议一开始就超过 `15%`
- 过高会伤害整体互惠匹配效率

### 5.5 新用户排序权重建议

当候选 B 为新用户时：

```text
FinalScore_new_adjusted = FinalScore * 1.10
```

但同时需要公平与质量保护：

- 资料完整度 < 60%：不吃满 boost
- 照片数 = 0：不给 freshness boost
- 风险分高：直接去掉 boost

### 5.6 冷启动阶段的默认权重

当用户行为数据稀少时，排序建议从行为驱动回退到画像驱动：

| 特征项 | 冷启动权重 | 常规权重 |
|---|---:|---:|
| ReciprocalScore(规则/轻模型) | 0.35 | 0.45 |
| QuestionCompatibility | 0.35 | 0.25 |
| InterestSimilarity | 0.15 | 0.15 |
| ActivityScore | 0.10 | 0.10 |
| FreshnessBoost | 0.05 | 0.05 |

即：
- 冷启动期提高问卷兼容权重
- 行为特征不足时，不要过度依赖稀疏行为统计

### 5.7 冷启动流量保护建议

| 场景 | 默认规则 |
|---|---|
| 新用户首日 | 保证至少 30 次有效曝光 |
| 新用户前 3 天 | 保证至少 100 次累计曝光 |
| 新用户 7 天内 | 若 match = 0，则额外补探索曝光 |
| 长尾普通用户 | 若 7 天曝光过低，也应进入轻扶持池 |

---

## 6. 公平指标目标

目标：给公平重排提供明确优化边界，没有目标值就无法调参。

### 6.1 为什么要设目标值

约会产品最常见问题不是平均效果差，而是：

```text
少数头部用户吃掉大量曝光，长尾几乎没有被看到的机会
```

因此公平目标不应该只写“尽量公平”，而要写成可监控的线上指标。

### 6.2 推荐公平指标体系

至少监控以下 6 个指标：

| 指标 | 定义 | 目标值 |
|---|---|---:|
| Top10% exposure share | 曝光量前 10% 用户占总曝光比例 | <= 35% |
| Top1% exposure share | 曝光量前 1% 用户占总曝光比例 | <= 8% |
| Gini of exposure | 用户曝光分布 Gini 系数 | <= 0.35 |
| P50/P90 exposure ratio | 中位数曝光 / P90 曝光 | >= 0.35 |
| Long-tail weekly visibility | 底部 50% 用户中，7 天内至少获得一次曝光的比例 | >= 85% |
| New user 3-day visibility | 新用户 3 天内至少获得一次有效曝光的比例 | >= 95% |

### 6.3 你提到的核心目标值建议

#### Top10% 用户曝光占比

建议默认目标：

```text
Top10% 用户曝光占比 <= 35%
```

解释：
- 35% 仍允许头部用户凭吸引力获得更多流量
- 但不会让系统进入“10% 吃掉 70%+”的极端虹吸
- 这个值适合做 V1/V2 公平重排目标

### 6.4 分层公平目标

建议分三层监控：

#### 1) 全站层

| 指标 | 目标 |
|---|---:|
| Top10% exposure share | <= 35% |
| Top1% exposure share | <= 8% |
| Exposure Gini | <= 0.35 |

#### 2) 性别 / 供需侧分层

按你们产品实际人群结构拆分，但建议每个核心人群都单独看：

| 指标 | 目标 |
|---|---:|
| 任一主要分群的 Top10% exposure share | <= 40% |
| 任一主要分群的 bottom 50% weekly visibility | >= 80% |
| 任一主要分群 median received likes / exposure 不得连续两周恶化 > 15% | guardrail |

#### 3) 新用户层

| 指标 | 目标 |
|---|---:|
| 新用户 24h 首次曝光覆盖率 | >= 90% |
| 新用户 3 天曝光覆盖率 | >= 95% |
| 新用户 7 天至少一次 match 的比例 | 作为跟踪指标，不设硬阈值 |

### 6.5 公平不应伤害太多效果的 guardrail

公平重排不是无限压头部，因此要加业务 guardrail：

| 指标 | 允许变化 |
|---|---:|
| Match rate | 不低于基线 -5% |
| Reply rate | 不低于基线 -3% |
| 3-turn conversation rate | 不低于基线 -3% |
| Report rate | 不高于基线 +5% |

结论：
- 公平重排上线时，不接受“公平变好但回复率明显塌掉”
- 建议把 reply rate 作为最核心 guardrail

### 6.6 公平重排分数建议

在原主分数后增加曝光惩罚：

```text
FairAdjustedScore(B) = FinalScore(B) / log(exposure_count_7d(B) + 2)
```

更稳的版本：

```text
FairAdjustedScore(B) = FinalScore(B) * fairness_multiplier(B)
```

其中：

| 7d 曝光分位 | fairness_multiplier |
|---|---:|
| top 1% | 0.70 |
| top 1%~10% | 0.82 |
| 10%~50% | 1.00 |
| 50%~90% | 1.05 |
| bottom 10% | 1.10 |

MVP 建议先用乘法分桶版本，更可控，也更容易 A/B。

### 6.7 实验验收建议

公平重排实验可以用以下标准做上线判断：

```text
1. Top10% exposure share 从 >45% 降到 <=35%
2. Bottom50% weekly visibility 提升至少 15%
3. Reply rate 降幅不超过 3%
4. Report rate 不上升
```

满足以上条件，可进入扩大流量阶段。

---

## 7. 推荐给 Codex 的直接落地指令

### 7.1 问卷服务接口补充

```text
GET    /questions
POST   /questions
PATCH  /questions/{question_id}
POST   /answers
GET    /users/{id}/answers
GET    /users/{id}/question-profile
```

### 7.2 排序服务返回字段补充

```json
{
  "candidate_id": "U_98765",
  "final_score": 0.8421,
  "base_score": 0.8011,
  "fairness_adjusted_score": 0.8421,
  "hard_filter_passed": true,
  "penalty_factors": {
    "children_conflict": 1.0,
    "drinking_conflict": 0.75
  },
  "explanation_tags": [
    "both_long_term",
    "communication_style_match",
    "close_distance"
  ]
}
```

### 7.3 配置中心默认参数（建议做成可热更新）

```json
{
  "strict_distance_filter": true,
  "inactive_days_threshold": 30,
  "freshness_tau_days": 7,
  "freshness_effective_window_days": 14,
  "new_user_exploration_quota": 0.10,
  "global_random_exploration_quota": 0.05,
  "candidate_pool_new_user_injection_ratio": 0.15,
  "top10_exposure_share_target": 0.35,
  "top1_exposure_share_target": 0.08,
  "exposure_gini_target": 0.35,
  "reply_rate_guardrail_drop_limit": 0.03,
  "match_rate_guardrail_drop_limit": 0.05
}
```

---

## 8. 最终结论（给你和 Codex 的简版）

### 必须马上补进系统的 5 件事

1. **问卷结构必须改成标准 JSON schema**：题目表 + 用户答案表都固定字段。  
2. **硬约束优先级必须明确**：性别、年龄、距离、强关系目标冲突，默认都在召回层过滤。  
3. **解释标签必须做成字典**：不要由前端或工程临时拼文案。  
4. **冷启动默认值建议直接定死**：`Freshness tau = 7天`，`新用户探索流量 = 10%`。  
5. **公平目标必须量化**：`Top10% 用户曝光占比 <= 35%` 作为默认目标。  

### 一组推荐默认值

```text
Freshness 衰减周期 tau = 7 天
Freshness 有效窗口 = 14 天
新用户探索流量比例 = 10%
候选池新用户注入比例 = 15%
Top10% 用户曝光占比 <= 35%
Top1% 用户曝光占比 <= 8%
Exposure Gini <= 0.35
Reply rate 作为公平实验核心 guardrail，降幅不超过 3%
```

---

## 9. 可直接追加到主文档的附录标题建议

若你们要把本补充直接并入主文档，建议新增：

```text
24. 问卷字段规范（JSON schema）
25. 业务硬约束优先级表
26. Explanation Tag 字典
27. 冷启动默认参数
28. 公平指标目标与验收标准
```

---

以上内容已经按“Codex 可以直接照着实现”的粒度写成，不再停留在原则层。

