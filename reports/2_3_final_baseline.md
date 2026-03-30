# 2.3 最终基线报告（2026-03-30）

## 1. 基线目的

本报告用于冻结 2.3 阶段的最终可交付状态，作为 2.4 的唯一对照基线。后续所有 2.4 变更，均应与本报告描述的状态进行比较。

---

## 2. 2.3 最终状态概述

### 2.1 已完成的主体能力
- 显示保护层已接入：`engine_source`、`engine_mode`、`data_quality`、`precision_level`、`confidence`、`confidence_reason`、`display_guard`
- 解释层已模板化：`explanation_blocks` 已进入匹配输出链路
- 原始工程标签已收口：前端优先消费可读 `display_tags`
- 性格模块已前台改名为 `性格测试 / 性格特征`
- 问卷链路已改为选中即跳题，最后一题自动提交
- 匹配详情页已加入摘要兜底，不再出现纯灰空页
- 西占路线已形成 ADR 与过渡策略，具备执行分叉的基础
- 低样本调权守门、灰度计划、回滚 playbook 已建立

### 2.2 已完成的工程基础
- 许可证门禁与依赖审计已建立
- 回归样例与 snapshot diff 已建立
- 匹配解释接口已具备稳定结构
- 前后端字段契约已对齐到可用状态
- 文档索引已收束到 2.3 版本体系

---

## 3. 当前 2.3 的稳定口径

### 3.1 算法口径
- 八字为核心权重之一，强调结构互补、节律同步、风险点与建议。
- 属相作为低权重辅助模块。
- 星座作为轻量展示层，不与完整星盘混用。
- 星盘 / 合盘分层处理，不混为单一“合盘”结论。
- 性格模块作为辅助参考，不作为主排序来源。

### 3.2 展示口径
- 低置信、退化、legacy 路径必须降级展示。
- 不允许用户界面直接暴露 raw 工程 tag。
- explanation 统一采用结论 / 过程 / 风险 / 建议四层结构。
- 匹配详情页必须至少展示摘要卡，不得空白灰页。

### 3.3 路线口径
- 西占模块仍处于受控过渡态。
- 当前不将高精生产路线视为已完成闭环。
- 后续若要进入高精生产，需继续按 ADR 和许可证门禁推进。

---

## 4. 2.3 关键交付物清单

### 文档
- `docs/adr_western_canonical_route.md`
- `docs/confidence_badge_rules_2_3.md`
- `docs/explanation_template_spec_2_3.md`
- `docs/gray_release_plan_2_3.md`
- `docs/rollback_playbook_2_3.md`
- `docs/release_checklist_2_3.md`
- `docs/low_sample_tuning_policy_2_3.md`
- `docs/2_3_issue_registry.md`

### 配置/代码
- `config/display_guard.php`
- `config/western_policy.php`
- `app/Support/ExplanationMetaBuilder.php`
- `app/Support/EvidenceTagMapper.php`
- `app/Support/ExplanationComposer.php`

### 测试/样例/脚本
- 20 组 explanation 回归样例
- explanation snapshot diff 报告
- weight guardrail 检查结果
- 灰度/回滚文档与脚本
- 2.2 基线快照/对照报告

---

## 5. 2.3 风险与约束
- 西占 canonical 尚未彻底收口。
- 样本不足时禁止激进调权。
- 所有新增依赖必须通过许可证门禁。
- 历史文档与兼容字段仍需逐步收束，但不影响本基线有效性。

---

## 6. 对 2.4 的输入边界

2.4 的所有工作都应在以下边界内展开：
- 以 2.3 的最终状态为起点
- 不破坏现有稳定契约
- 不允许低置信高口径回退
- 不允许西占路线继续悬置
- 不允许 explanation 从发布门禁中脱钩

---

## 7. 结论

2.3 已完成主体落地，当前可作为 2.4 的正式基线。后续 2.4 不再重复构建主体能力，而是围绕西占执行路线、演练证据、发布门禁与兼容收束推进收尾。
