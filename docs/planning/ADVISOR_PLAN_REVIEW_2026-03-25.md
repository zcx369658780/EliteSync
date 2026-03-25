# Advisor Plan Review (2026-03-25)

Source packet:
- `docs/planning/PLAN_REVIEW_PACKET_2026-03-25.md`

## Keep
1. Laravel 单运行时评分，Android 仅渲染。
2. 模块化契约字段保持稳定。
3. 现有 CI/Regression/发布流程继续保留。
4. Alpha 阶段以稳定性优先。
5. 解释结构（短结论+细节+风险+证据）继续沿用。

## Adjust Now (Alpha-safe)
1. 在匹配响应加入 `contract_version`（建议 `v1`）。
2. 增加独立的模块字段契约测试（严格类型和必填字段断言）。
3. 强化 synthetic 账号隔离（环境开关、查询守卫、管理端可视化、生产阻断）。
4. 尽快上线最小化“修改密码”流程（旧密码校验+新密码策略+可选会话失效）。
5. 增加 degraded 比例观测（模块降级率监控）。

## Defer to Beta
1. 深度八字规则矩阵与高精历法强化。
2. 高阶 MBTI 功能位调优与权重分组。
3. 高精星历/重 synastry 集成。
4. A/B 算法实验平台。
5. 多目标排序与探索策略扩展。

## 1-2 Week Checklist (Ordered)
1. 载荷契约加固：`contract_version`、`generated_at`、模块级 `algo_version`。
2. 回归门禁升级：严格 schema test + 固定样本快照测试。
3. synthetic 安全：命令与查询双重隔离 + 发布清单污染检查。
4. 安全基线：修改密码 API + Android 入口 + 审计事件。
5. 可观测性：模块分数/置信度/降级率日志和统计。
6. UI 一致性：分数色阶/结论映射统一、长文本截断规范。

## Risk Watchlist
1. 后端与 Android 契约漂移。
2. synthetic 数据误入生产匹配池。
3. 降级率升高但未被发现。
4. 发布脚本副作用影响非目标配置。
5. 低置信度结果文案过度肯定。
6. 密码能力缺失导致安全债务积累。
