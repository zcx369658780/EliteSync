# 2.3 阶段性验收清单（Stage 1）

更新时间：2026-03-30
范围：2.3-0 ~ 2.3-2 主体落地 + 2.3-3/2.3-4/2.3-5 首版框架

## A. 后端契约与解释结构
- [x] `match_reasons.modules` 包含算法版本与解释字段
- [x] `match_reasons.module_explanations` 保持兼容
- [x] 新增 `match_reasons.explanation_blocks`
- [x] `explanation_blocks` 包含：
  - [x] `summary`
  - [x] `process`
  - [x] `risks`
  - [x] `advice`
  - [x] `core_evidence`
  - [x] `supporting_evidence`
  - [x] `confidence`
  - [x] `priority`
- [x] 新增元信息字段（模块级）：
  - [x] `engine_source`
  - [x] `engine_mode`
  - [x] `data_quality`
  - [x] `precision_level`
  - [x] `confidence_tier`
  - [x] `confidence_reason`
  - [x] `display_guard`
  - [x] `display_tags`

## B. 规则与策略
- [x] `display_guard` 配置已落地
- [x] `western_policy` 配置已落地
- [x] 西占 ADR 文档已落地
- [x] 低样本调权策略文档已落地
- [x] 权重变化守门脚本已落地

## C. 前端接入
- [x] Flutter 数据层接入 `explanation_blocks`
- [x] 匹配详情页展示四层解释卡（结论/过程/风险/建议）
- [x] 新旧收敛：有 `explanation_blocks` 时优先展示新块
- [x] 调试开关下可查看 engine/guard/reason 元信息
- [x] 调试面板折叠显示（默认简洁）

## D. 自动化验证
- [x] `ExplanationMetaBuilderTest`
- [x] `EvidenceTagMapperTest`
- [x] `ExplanationComposerTest`
- [x] `ExplanationFixturesTest`
- [x] `MatchPayloadContractTest`
- [x] `MatchApiTest`
- [x] `scripts/run_explanation_regression.ps1`
- [x] `flutter analyze lib/features/match`

## E. Stage 1 剩余工作（建议）
1. explanation 快照差异报告增强（输出字段级 diff，而不仅 PASS/FAIL）
2. 灰度演练脚本化（按 `gray_release_plan_2_3.md` 执行一轮模拟）
3. 前端“普通用户视图”再做一次文案降噪（减少调试语义误入）
4. 将 `display_guard` 结果用于前端 badge 可视样式（非调试态）

## 结论
当前可判定为：**2.3 Stage 1 已达到提测条件**（契约稳定、结构完整、可回归）。
建议下一阶段进入：**Stage 2（灰度演练 + 解释diff增强 + badge UI联动）**。
