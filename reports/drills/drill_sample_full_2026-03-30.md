# 2.4 最完整 drill 样本（灰度 / 回滚 / 门禁证据）

## 目的

给 2.4 提供一份可直接复核的完整演练样本，包含 explanation 回归、weight guardrail、profile 修正与最终通过结果。

## 环境
- 仓库：`D:\EliteSync`
- 日期：2026-03-30
- 执行环境：本地 PowerShell + Laravel backend tests

## 演练 1：Explanation 回归

### 执行命令
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run_23_stage1_checks.ps1 -SkipFlutterAnalyze
```

### 结果摘要
- `Backend Explanation Regression`: PASS
- `MatchPayloadContractTest`: PASS
- `MatchApiTest`: PASS
- `Overall`: PASS

### 产出
- `reports/explanation_snapshot_diff/latest.md`
- `reports/explanation_snapshot_diff/latest_diff.md`

### 复核要点
- explanation 结构保持四层：结论 / 过程 / 风险 / 建议
- payload contract 没有被破坏
- 匹配解释接口可以正常返回

## 演练 2：Weight Guardrail

### 初始执行命令
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check_weight_change_guard.ps1 -FromProfile baseline -ToProfile a1
```

### 初始结果
- `MATCH_WEIGHT_ASTRO`: FAIL（17.14%）
- `MATCH_WEIGHT_PERSONALITY`: FAIL（10.34%）
- `Overall`: FAIL (fail=2)

### 结论
- guardrail 正常工作
- 超出阈值的 profile 被正确拦截

## 演练 3：Profile 修正

### 修正动作
- 将 `a1` profile 调整回 10% 阈值内：
  - `MATCH_WEIGHT_PERSONALITY = 0.62`
  - `MATCH_WEIGHT_ASTRO = 0.315`

### 修正后命令
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check_weight_change_guard.ps1 -FromProfile baseline -ToProfile a1
```

### 修正后结果
- 所有字段通过
- `Overall: PASS`

### 复核要点
- guardrail 不是摆设，能先失败再通过
- profile 修正路径清晰、可追踪

## 演练 4：证据化留痕

### 已有证据
- `docs/drill_evidence_index_2_4.md`
- `reports/drills/gray_rollback_drill_2026-03-30.md`
- `reports/explanation_guardrail_report_2_4.md`

### 现场可复核内容
- 失败 -> 修正 -> 再通过 的完整过程
- 解释回归与权重守门均可重复执行

## 结论

这一轮 drill 样本证明：
- explanation 回归可用
- weight guardrail 可用
- profile 修正可使系统回到合规范围
- 2.4 的灰度 / 回滚 / 门禁链路已具备真实可复核证据
