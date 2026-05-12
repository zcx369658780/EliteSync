# Claude 横向复评门禁规则

更新时间：2026-05-12

## 适用范围

从 6.0 Alpha 起，每个版本完成后，必须先通过 Claude 横向复评，再提交 GPT 顾问最终验收。

## 标准流程

```text
Codex 完成实现与自测
-> Codex 生成证据包与版本报告
-> Claude 调用 Soul + 测测 / CECE 作为横向参考进行复评
-> Claude 输出竞品对照复评报告
-> Codex 根据 Claude 复评修正或解释不采纳原因
-> GPT 顾问最终验收
-> 通过后才允许 commit / push / 进入下一版本
```

## Claude 复评角色

Claude 的角色不是替代 GPT 顾问，而是：

- 独立产品体验复查员；
- Soul / 测测 / CECE 横向对照评估员；
- UI / IA 可理解性审查员；
- 功能完整性与用户路径审查员；
- 竞品吸收边界审查员。

## 每版必须检查

1. 本版本目标是否实际可见；
2. 用户是否能自然找到入口；
3. 页面是否能解释“为什么这个功能有用”；
4. 与 Soul 同类功能相比，是否缺少基础社交能力；
5. 与测测 / CECE 同类功能相比，是否缺少解释层、字段引导、摘要 / 详情分层；
6. 是否出现竞品不应吸收的商业化、娱乐化或服务化路径；
7. 是否暴露工程术语；
8. 是否破坏 Date Drop 式低频高质量匹配定位；
9. 是否误把搭子做成泛同城约玩；
10. 是否有用户安全、隐私、位置展示风险。

## 输出文件

每个版本必须输出：

```text
CLAUDE_<VERSION>_HORIZONTAL_REVIEW.md
CLAUDE_<VERSION>_SOUL_COMPARISON.md
CLAUDE_<VERSION>_CECE_COMPARISON.md
CLAUDE_<VERSION>_ACTION_MATRIX.md
```

如果版本与 Soul / 测测 / CECE 无强关系，也必须说明原因，但不能省略 Claude 复评。

## 通过标准

- `pass`：可提交 GPT 顾问验收；
- `pass with observations`：可提交 GPT 顾问验收，但必须带 observation；
- `conditional pass`：需 Codex 补证据或小修后再提交；
- `fail`：不得提交 GPT 顾问最终验收。

只有 `pass` 或 `pass with observations` 可以进入 GPT 顾问最终验收。

`conditional pass` 必须先补材料。

`fail` 必须返工。

## 禁止事项

- 不得在 Claude 横向复评缺失时提交 GPT 顾问最终验收。
- 不得用文档自报替代实机证据。
- 不得把 Soul / 测测 / CECE 功能照抄为 EliteSync 主路线。
- 不得做安全测试、逆向、抓包、接口分析、权限绕过、付费、咨询、上传、实名认证等高风险路径。
