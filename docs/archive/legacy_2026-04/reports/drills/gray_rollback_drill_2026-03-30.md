# 2.4 演练报告 - 灰度 / 回滚 / 门禁证据（2026-03-30）

## 1. 演练目的

验证 2.4 所需的灰度 / 回滚 / 门禁能力是否具备可复核证据。

## 2. 演练环境
- 仓库：`D:\EliteSync`
- 日期：2026-03-30
- 运行方式：本地 PowerShell + backend unit/feature tests

## 3. 演练项目

### 3.1 Explanation 回归演练
执行：
- `powershell -ExecutionPolicy Bypass -File .\scripts\run_23_stage1_checks.ps1 -SkipFlutterAnalyze`

结果：
- `Backend Explanation Regression`: PASS
- `MatchPayloadContractTest`: PASS
- `MatchApiTest`: PASS
- `Overall`: PASS

证据：
- 已写入 `reports/explanation_snapshot_diff/latest.md`
- 已写入 `reports/explanation_snapshot_diff/latest_diff.md`

### 3.2 Weight guardrail 演练
执行：
- `powershell -ExecutionPolicy Bypass -File .\scripts\check_weight_change_guard.ps1 -FromProfile baseline -ToProfile a1`

结果：
- `Overall`: PASS
- 通过说明：`MATCH_WEIGHT_ASTRO` 已调整到 10% 阈值内，`MATCH_WEIGHT_PERSONALITY` 也在阈值内。

结论：
- 当前 `a1` profile 可以作为可复核的受控变更 profile。
- guardrail 有效，且能拦截超阈值设置。

### 3.3 灰度 / 回滚现场证据
当前已具备：
- 灰度计划文档
- 回滚 playbook 文档
- stage1 checks / explanation regression 脚本
- weight guardrail 脚本
- 演练索引 `docs/drill_evidence_index_2_4.md`

本次报告已记录：
- 回归链路结果
- 权重守门结果
- 失败到通过的修正过程

## 4. 演练结论

### 通过项
- explanation 回归链路可运行
- 匹配契约可验证
- guardrail 能拦截超阈值 profile
- profile 修正后可以再次通过守门

### 待修项
- 后续仍建议补一轮更完整的模块关闭 / 回滚操作留痕，形成更强证据

## 5. 下一步动作
1. 继续补齐模块关闭、profile 回退、explanation 回退、western policy 回退的独立演练证据。
2. 如需进入更严格的 2.4 验收，可在此基础上补截图或日志摘录。

## 6. 结论

本次演练证明：
- explanation 门禁已可用
- weight guardrail 已可用
- 2.4 的灰度 / 回滚体系具备基础证据，并且已经能通过一次真实 profile 修正验证
