# Dating Matching System Design

Version: 1.0
File target: /mnt/data/dating_system_design_integrated.md  
Format: Integrated engineering design document  
Audience: Product / Algorithm / Backend / Data / Codex CLI implementation

---

## 1. 目标与设计原则

本系统面向约会软件的匹配、排序和持续优化场景，目标不是单纯最大化 Like 数，而是最大化**真实有效互动**，包括：

- Match rate
- Reply rate
- Conversation quality
- Long-term retention
- Exposure fairness

核心原则：

1. **互惠优先**：不是 A 喜欢 B 就够了，而是 A、B 双方都更可能互相喜欢。
2. **心理兼容 + 行为学习结合**：问卷提供冷启动和长期兼容信号，行为数据提供真实偏好信号。
3. **排序目标真实化**：优先优化回复、对话和关系推进，而不是廉价点击。
4. **公平曝光**：避免少数热门用户吸走几乎全部流量。
5. **逐步演进**：V1 先稳定上线，V2/V3 再引入更复杂模型。

---

## 2. 系统全景

匹配系统可拆成五层：

```text
用户资料层
↓
答题与心理画像层
↓
候选召回层
↓
互惠排序层
↓
反馈学习层
```

对应服务建议：

```text
User Service
Question Service
Matching Service
Ranking Service
Feedback / Training Service
```

---

## 3. 用户表示（User Representation）

每个用户由三类向量组成：

```text
UserVector =
ProfileVector + InterestVector + QuestionnaireVector
```

### 3.1 Profile Vector

用于描述基础属性和强约束：

- age
- gender
- location
- education
- occupation
- relationship goal
- smoking / drinking
- religion
- height（如产品需要）
- active time / last seen

### 3.2 Interest Vector

用于表示兴趣偏好：

- music
- movies
- travel
- sports
- reading
- gaming
- food
- pets
- outdoor / indoor tendency

### 3.3 Questionnaire Vector

用于表示价值观、长期关系偏好、相处方式：

- values
- family views
- communication style
- emotional needs
- social energy
- intimacy expectations
- future planning

建议 embedding 维度：

- MVP：32 ~ 64
- 推荐：128
- 大规模迭代：128 ~ 256

---

## 4. 题库系统（Questionnaire System）

答题题库是冷启动和长期兼容预测的核心，不建议只做 MBTI 类型玩法，而应采用类似 OkCupid 的结构化兼容问答。

### 4.1 单题结构

每道题建议包含：

```text
Question
UserAnswer
AcceptableAnswers
ImportanceWeight
Category
```

示例：

```text
Q: 你是否想要孩子？

Your Answer: Yes
Acceptable Answers: Yes / Maybe
Importance: 3
Category: Family
```

### 4.2 Importance 设计

```text
0 = 不重要
1 = 略重要
2 = 重要
3 = 非常重要
```

### 4.3 题库维度建议

建议至少覆盖 8 个维度：

| 维度 | 作用 |
|---|---|
| Values | 价值观与人生排序 |
| Relationship Goals | 对关系形态的预期 |
| Lifestyle | 日常作息与生活方式 |
| Social Energy | 社交能量与独处需求 |
| Communication | 冲突处理与表达风格 |
| Family | 婚姻、孩子、家庭观 |
| Intimacy | 亲密关系边界与期待 |
| Interests | 兴趣和陪伴方式 |

### 4.4 题量建议

- MVP：60 ~ 80 题
- 推荐正式版：120 ~ 200 题
- 运营扩展：200+，并支持动态加题

### 4.5 示例题目

#### Values

1. 你觉得事业和生活哪个更重要？
   - 事业优先
   - 尽量平衡
   - 生活优先

2. 金钱在生活中有多重要？
   - 非常重要
   - 比较重要
   - 一般
   - 不太重要

#### Relationship Goals

3. 你现在主要想找什么关系？
   - Casual dating
   - Long-term relationship
   - Marriage

4. 你希望多久进入稳定关系？
   - 尽快
   - 几个月后
   - 随缘

#### Lifestyle

5. 你的作息更接近：
   - 早睡早起
   - 比较灵活
   - 夜猫子

6. 你喝酒的频率：
   - 从不
   - 偶尔
   - 每周
   - 经常

#### Social Energy

7. 你更喜欢怎样恢复精力？
   - 独处
   - 和朋友一起
   - 两者都可以

#### Communication

8. 冲突出现时你更倾向：
   - 当下沟通
   - 先冷静再沟通
   - 尽量避免冲突

#### Family

9. 你想要孩子吗？
   - Yes
   - Maybe
   - No

#### Intimacy

10. 亲密关系中的身体亲密对你有多重要？
   - 非常重要
   - 比较重要
   - 一般
   - 不太重要

#### Interests

11. 理想周末更像：
   - 户外活动
   - 聚会社交
   - 宅家放松

### 4.6 问卷兼容得分

定义 A 对 B 的单向兼容：

```text
Agreement(A<-B,q) =
1, if B.answer ∈ A.acceptable_answers
0, otherwise
```

单题得分：

```text
Score_q(A<-B) = Agreement(A<-B,q) * Importance(A,q)
```

双向兼容：

```text
BiScore_q(A,B) = Score_q(A<-B) + Score_q(B<-A)
```

总体问卷兼容：

```text
QuestionCompatibility(A,B) = Σ BiScore_q(A,B) / MaxPossibleScore
```

归一化到 0~1 区间。

---

## 5. 候选召回（Candidate Generation）

排序模型前，先从全量用户中召回可匹配候选，降低线上计算量。

### 5.1 硬过滤条件

- gender preference
- age preference
- distance / city
- relationship goal compatibility
- block / report exclusion
- account safety / quality filters
- recent activity threshold

### 5.2 召回策略

建议多路召回并合并：

1. **规则召回**：强约束过滤后的本地候选
2. **相似用户召回**：profile / interest 近邻
3. **问卷兼容召回**：question compatibility top-K
4. **协同行为召回**：历史 like / reply 类似群体
5. **探索召回**：随机少量注入，用于破除同质化

### 5.3 候选池规模建议

- 小规模产品：100 ~ 300
- 中等规模：300 ~ 1000
- 大规模：1000+ 后再精排

---

## 6. 互惠匹配核心（Reciprocal Recommendation）

普通推荐只预测“用户会不会喜欢内容”，约会场景必须预测“双方是否互相有兴趣”。

### 6.1 单向偏好预测

定义：

```text
P(A likes B)
P(B likes A)
```

### 6.2 互惠得分

```text
ReciprocalScore(A,B) = P(A likes B) * P(B likes A)
```

也可以采用 log-space 防止极小值问题：

```text
log ReciprocalScore = log P(A likes B) + log P(B likes A)
```

### 6.3 为什么有效

因为真实的约会成功路径通常是：

```text
曝光 → 感兴趣 → Like → Match → Reply → Conversation
```

如果只优化单边 Like，会推很多“看上去会被一方喜欢，但另一方几乎不回应”的对象，最终浪费曝光位。

---

## 7. 特征工程（Feature Engineering）

建议把特征分为 6 组。

### 7.1 User A 特征

- age / location / education
- relationship goal
- activity level
- like rate
- reply rate
- received like rate
- exposure count
- profile completeness

### 7.2 User B 特征

同上。

### 7.3 Pair 特征

- age gap
- distance
- city match
- education similarity
- lifestyle similarity
- relationship goal compatibility
- question compatibility
- mutual interest overlap
- photo / profile quality diff（如可用）

### 7.4 行为统计特征

- A 对某类用户的历史 like rate
- A 对某类用户的历史 reply rate
- B 被某类用户 like 的比例
- recent activity decay
- acceptance probability by segment

### 7.5 流量与曝光特征

- daily exposure count
- recent received likes
- popularity percentile
- freshness / newcomer bonus

### 7.6 风险与质量特征

- report risk
- spam score
- low-effort profile score
- ghosting propensity（后续可做）

---

## 8. 模型设计（Matching Model）

### 8.1 V1：可快速上线

建议先做：

```text
Logistic Regression / LightGBM
```

目标预测：

```text
P(A likes B)
```

输入：

```text
UserA features
UserB features
Pair features
Question compatibility
```

优点：

- 训练快
- 解释性较强
- 上线成本低
- 方便做特征迭代

### 8.2 V2：行为增强

将目标从 Like 升级为：

```text
P(reply | match)
```
或
```text
P(successful conversation)
```

这比 Like 更接近真实价值。

### 8.3 V3：深度互惠推荐

可以采用：

- Two-tower model
- Neural collaborative filtering
- Deep reciprocal recommender

思路：

```text
UserTower(A) -> embedding A
UserTower(B) -> embedding B
pair interaction -> score
```

并同时预测：

- A like B
- B like A
- match probability
- reply probability

---

## 9. 最终排序公式（Ranking Formula）

建议使用可解释加权方案作为第一版：

```text
FinalScore =
0.45 * ReciprocalScore
+ 0.25 * QuestionCompatibility
+ 0.15 * InterestSimilarity
+ 0.10 * ActivityScore
+ 0.05 * FreshnessBoost
```

也可以加入公平曝光调整后的形式：

```text
FinalScoreAdjusted = FinalScore / log(exposure_count_B + 2)
```

其中：

- `ReciprocalScore`：互惠偏好核心
- `QuestionCompatibility`：长期兼容与冷启动
- `InterestSimilarity`：话题与共同活动机会
- `ActivityScore`：近期活跃度，避免把流量浪费给不活跃用户
- `FreshnessBoost`：帮助新用户快速被探索

---

## 10. 曝光公平与热门用户虹吸控制

约会产品很容易出现：

```text
10% 热门用户拿走 70%~90% 的曝光和 Like
```

这会导致：

- 大多数用户没有体验
- 留存下降
- 平台两端供需失衡

### 10.1 常用控制方法

#### 方法 A：曝光惩罚

```text
ExposurePenalty(B) = 1 / log(exposure_count_B + 2)
```

#### 方法 B：分层配额

将用户按热度分桶，限制单桶曝光占比。

#### 方法 C：新用户冷启动扶持

为新用户添加短期 boost：

```text
NewUserBoost = min(1.2, 1 + alpha * freshness)
```

#### 方法 D：供需平衡

对供给紧缺侧适当增加曝光，使平台匹配成功率更稳定。

---

## 11. 冷启动策略（Cold Start）

新用户没有行为数据时，系统必须依赖资料与问卷。

### 11.1 新用户排序依据

- profile similarity
- questionnaire compatibility
- distance / location
- profile completeness
- freshness boost

### 11.2 冷启动期建议

- 强制引导完成基础资料
- 至少完成 20~30 道高信息量题目
- 首周增加探索流量
- 加快早期反馈采样速度

### 11.3 早期用户分层

可先按以下维度做 segment：

- relationship goal
- city tier
- age range
- lifestyle cluster

这样即使没有行为数据，也能用 segment priors 进行粗粒度推荐。

---

## 12. 反馈学习闭环（Feedback Loop）

推荐系统真正变强，依赖的是持续学习用户反馈，而不是静态问卷。

### 12.1 事件采集

必须记录：

- profile view
- skip / pass
- like
- super like（如有）
- match
- first message sent
- first reply
- reply latency
- conversation length
- exchanged contacts（如可观察）
- offline date confirmation（若产品设计允许）

### 12.2 标签设计

建议多级标签：

```text
label_like
label_match
label_reply
label_conversation_3_turns
label_conversation_10_turns
```

### 12.3 推荐训练目标建议

V1：

```text
maximize P(like)
```

V2：

```text
maximize P(reply | match)
```

V3：

```text
maximize expected conversation value
```

例如：

```text
ExpectedValue =
1.0 * match
+ 2.0 * reply
+ 3.0 * 3_turn_conversation
+ 5.0 * 10_turn_conversation
```

---

## 13. A/B 测试体系

算法没有实验就无法迭代。

### 13.1 主要指标

- Match rate
- Reply rate
- Conversation start rate
- 3-turn conversation rate
- 10-turn conversation rate

### 13.2 次级指标

- DAU / WAU
- D1 / D7 / D30 retention
- likes sent per user
- likes received per user
- profile completion rate
- first-day activation

### 13.3 风险指标

- report rate
- block rate
- ghosting rate
- popularity inequality
- female / male side satisfaction gap（按你们产品实际定义）

### 13.4 实验建议

首次实验优先比较：

1. 单边 Like 排序 vs 互惠排序
2. 有问卷兼容 vs 无问卷兼容
3. 有公平曝光 vs 无公平曝光
4. 优化 Like vs 优化 Reply

---

## 14. 工程架构设计

### 14.1 服务划分

#### User Service

负责：

- 用户资料
- 偏好设置
- 活跃状态
- 黑名单 / 安全状态

建议存储：

- PostgreSQL

#### Question Service

负责：

- 题库管理
- 用户答案
- acceptable answers
- importance weights
- 题目版本管理

建议存储：

- PostgreSQL

#### Matching Service

负责：

- 候选召回
- 多路召回合并
- 过滤逻辑
- embedding lookup

建议缓存：

- Redis

#### Ranking Service

负责：

- 特征拼装
- 调用模型
- 互惠得分计算
- 公平曝光重排
- 返回 Top-N

#### Feedback / Event Service

负责：

- 事件埋点
- 日志收集
- 下游训练样本生成

#### Training Pipeline

负责：

- 样本构建
- 特征计算
- 模型训练
- 模型评估
- 模型注册与发布

### 14.2 数据流

```text
User Action
↓
Event Logging
↓
Feature Store / Warehouse
↓
Daily Training Pipeline
↓
Model Registry
↓
Online Ranking Service
```

---

## 15. 实时链路与性能目标

推荐线上链路建议：

```text
request
→ candidate generation
→ feature fetch
→ model scoring
→ reciprocal combination
→ fairness rerank
→ return top 20
```

### 延迟目标

- 小规模：< 150 ms
- 推荐目标：< 100 ms
- 重点链路：P95 < 200 ms

### 实时缓存建议

缓存：

- user embeddings
- recent activity stats
- exposure counters
- candidate pools

使用：

- Redis
- Faiss / ANN（大规模近邻召回时）

---

## 16. 推荐技术栈

### Backend

- Python
- FastAPI
- PostgreSQL
- Redis

### ML / Ranking

- LightGBM
- PyTorch
- XGBoost（可替代）

### Data / Training

- Airflow
- Spark（数据量大时）
- Parquet / S3 / GCS

### Infra

- Docker
- Kubernetes
- AWS / GCP

### Retrieval / Vector

- Faiss
- pgvector（小规模也可）

---

## 17. 分阶段落地方案

### Phase 1：MVP 上线

能力：

- 资料过滤
- 基础问卷兼容
- 规则召回
- 简单互惠公式
- 曝光惩罚基础版

排序示例：

```text
score =
0.5 * reciprocal_rule_score
+ 0.3 * question_compatibility
+ 0.2 * interest_similarity
```

适合：

- 用户量小
- 数据稀缺
- 先要稳定落地

### Phase 2：行为增强版

能力：

- LightGBM 预测 P(A likes B)
- 双边偏好估计
- reply 目标训练
- 更完整的公平曝光

### Phase 3：深度学习版

能力：

- user embedding
- deep reciprocal recommender
- multi-task learning
- 实时 embedding 更新

---

## 18. 给 Codex 的实现建议

如果你要和 Codex CLI 协作实现，建议代码仓库拆分为：

```text
services/
  user-service/
  question-service/
  matching-service/
  ranking-service/
  event-service/

ml/
  feature_pipeline/
  training/
  evaluation/
  model_registry/

docs/
  dating_system_design.md
```

### 18.1 question-service 建议接口

```text
GET  /questions
POST /answers
GET  /users/{id}/answers
GET  /users/{id}/question-profile
```

### 18.2 matching-service 建议接口

```text
GET /candidates?user_id=xxx
POST /generate-candidates
```

### 18.3 ranking-service 建议接口

```text
POST /rank
body: {user_id, candidate_ids}
```

返回：

- candidate_id
- final_score
- explanation_tags

### 18.4 解释型输出建议

为前端提供匹配理由标签：

- 都想找长期关系
- 作息接近
- 对孩子态度一致
- 兴趣重合度高
- 沟通风格接近

这会显著提升用户对推荐的信任感。

---

## 19. 风险点与常见误区

### 19.1 误区：只做 MBTI

问题：

- 娱乐性强，预测力有限
- 信息维度太粗

建议：

- MBTI 可做展示层，不要做主排序核心

### 19.2 误区：只优化 Like

问题：

- 会推高颜值但低回复的人
- 真实互动效率低

建议：

- 尽快过渡到 reply / conversation 目标

### 19.3 误区：不做公平曝光

问题：

- 头部虹吸严重
- 长尾用户很快流失

### 19.4 误区：问卷题太空泛

问题：

- 结果好看但不实用

建议：

- 多设计“关系冲突点”题目，如孩子、婚姻、异地、消费、作息、饮酒、社交频率

---

## 20. 推荐的初版核心公式

如果你要一个现在就能实现的版本，我建议：

### 20.1 单边偏好估计

先用规则或轻模型估计：

```text
LikeScore(A,B) =
0.30 * profile_similarity
+ 0.20 * interest_similarity
+ 0.35 * question_compatibility(A<-B)
+ 0.15 * activity_score(B)
```

### 20.2 互惠分数

```text
Reciprocal(A,B) = LikeScore(A,B) * LikeScore(B,A)
```

### 20.3 最终得分

```text
Final(A,B) =
0.70 * Reciprocal(A,B)
+ 0.20 * BiQuestionCompatibility(A,B)
+ 0.10 * FreshnessBoost(B)
```

### 20.4 公平曝光重排

```text
FinalAdjusted(A,B) = Final(A,B) / log(exposure_count_B + 2)
```

这套公式足够支撑第一版上线。

---

## 21. 后续可扩展方向

后续可继续增强：

- graph-based recommendation
- two-tower retrieval
- reinforcement learning ranking
- conversation quality prediction
- long-term relationship success prediction
- anti-ghosting optimization
- dynamic questionnaire selection

---

## 22. 总结

这套 Dating Matching System 的关键不在于“神奇算法”，而在于三件事协同：

1. **高信息量问卷设计**：提供冷启动和长期兼容信号
2. **互惠推荐排序**：保证双边偏好成立
3. **行为反馈闭环**：逐步从问卷驱动过渡到真实行为驱动

建议你们的产品路线是：

```text
问卷兼容打底
+ 互惠排序上线
+ reply / conversation 作为优化目标
+ 公平曝光控制平台生态
```

这比只做“基于画像相似度的推荐”强很多，也更接近真正成熟的 dating app 系统思路。

---

## 23. 可继续补充的附录（下一版可加）

后续如果你需要，可以在这份文档后面继续追加：

- 200 题完整题库
- 100+ feature list
- SQL 表结构设计
- FastAPI 接口定义
- LightGBM 训练样本 schema
- A/B test dashboard 指标定义
- explanation tag 生成规则

