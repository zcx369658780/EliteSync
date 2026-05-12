# 验收基线

更新时间：2026-05-12

## 顾问验收口径

- `conditional pass`：核心实现已成立，但缺少最终归档所需的证据链、收尾材料或回归收口。
- `pass with observations`：版本可正式归档，非阻断观察项保留在文档里，但不应阻止进入下一版本。
- `pass`：实现、验证、证据、交接都已闭环，且无需要顾问继续补强的阻断项。

## 6.0 Alpha 强制门禁

- 6.0 Alpha 起，Claude 横向复评是强制验收前置条件。
- 无 Claude 横向复评，不得提交 GPT 顾问最终验收。
- 无 GPT 顾问最终验收，不得进入下一版本。
- Claude 需基于 Soul + 测测 / CECE 做产品体验对照。
- 只有 Claude `pass` 或 `pass with observations` 可以进入 GPT 顾问最终验收。
- `conditional pass` 需补证据或小修。
- `fail` 必须返工。

## 6.0-A0 Planning-Only 验收口径

- 6.0-A0 是 planning-only 版本，不做 runtime。
- 验收标准是路线冻结、后端 v2 计划、位置链路拆分、Date Drop 式匹配主链方案、搭子功能方案、Claude 横向复评门禁和 A1-A5 拆分齐备。
- 不能因没有 runtime 截图、XML、UI hierarchy 或实现证据而降级。
- 不能用 A0 planning-only 验收推动 A1 runtime；A1 之前必须先完成并验收 A0 具体计划书。

## 什么算正式归档通过

- 主实现或 planning-only 交付完成。
- 回归测试或文档一致性检查通过。
- 保护面未受影响。
- 证据链足够支撑结论。
- closeout / handoff 文档齐备。
- Claude 横向复评通过。
- GPT 顾问最终验收通过。

## `pass with observations` 的使用原则

- 用于“主功能已经成立，但仍保留少量可优化项”的版本。
- 不能因为有 observation 就重开同一条主链。
- observation 必须是非阻断的，且要写清楚为什么不阻断。
