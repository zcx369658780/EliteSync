# Western Execution Decision 2.4

Date: 2026-03-30
Status: Accepted

## Decision

2.4 的西占路线正式执行为 **western_lite**。

## Why

- 当前版本未获得可用于闭源生产的商业授权确认。
- 2.3 已证明西占模块可以作为轻量展示与解释补充运行，但不适合继续维持“高精 canonical”口径。
- 继续悬置路线会导致 badge、权重、文案、对拍与回滚口径长期不一致。

## What western_lite means

- 保留西占模块的输入、解释与辅助判断能力。
- 不将其作为高精生产主引擎。
- 不发高强度“高精星盘”类措辞。
- 不允许凭轻量结果发放高置信 badge。
- 允许与八字、属相、性格模块共同参与解释，但权重和措辞受限。

## Runtime policy

- `WESTERN_POLICY_MODE=western_lite`
- `config/western_policy.php` 为运行时唯一策略源之一。
- `display_guard` 必须与该模式绑定。

## Consequences

- 产品表达与底层能力一致。
- 未来如拿到商业授权，可在不改 API 契约的前提下再升级到 `licensed_canonical`。
- 当前不会把西占模块从工程中移除，只是把它收敛为轻量、受控、低口径模块。

## Non-goals

- 不在 2.4 内推进 Swiss 商业授权接入落地。
- 不在 2.4 内恢复高精西占口径。
- 不在 2.4 内改变现有 API 契约。
