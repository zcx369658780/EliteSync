# 2.4 演练证据索引

## 目的
记录 2.4 阶段所有灰度 / 回滚 / 门禁演练的证据，供顾问与项目负责人复核。

## 当前演练项
- 模块关闭演练
- profile 回退演练
- explanation 模板回退演练
- western policy 回退演练

## 证据字段
每份演练报告至少记录：
- 时间
- 操作人
- 环境
- 演练目标
- 操作步骤
- 日志摘要
- 结果
- 是否通过

## 当前索引
- `reports/drills/`：演练报告正文
- `reports/drills/gray_rollback_drill_2026-03-30.md`：灰度 / 回滚 / 门禁演练
- `reports/explanation_snapshot_diff/`：解释快照差异
- `docs/devlogs/RELEASE_GATE_LOG.md`：发布门禁日志
- `docs/devlogs/REGRESSION_BASELINE_LOG.md`：回归基线日志
