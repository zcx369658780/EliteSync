# 2.5 计划前待删除 compat / deprecated 清单（2026-03-30）

## 目的

为 2.5 的清理工作预留明确删除候选，避免 2.4 与 2.5 之间继续堆积历史噪音。

## compat（2.4 保留，2.5 视情况删除）

### Backend
- `public_mbti`：当前持久化兼容读取源，先保留。
- `mbti_attempts`：历史作答明细，仅作为追溯使用。
- 旧 questionnaire payload 兼容分支：为旧客户端保留，后续视活跃设备再删。
- `legacy` / `fallback` / `hybrid` 的兼容映射：用于旧报告与历史日志回读。

### Flutter
- `mbtiCenter` 路由名：内部导航兼容，前台文案已改为“性格测试”。
- `mbti` backend key：仅作为契约兼容，不再作为用户可见主语义。
- 问卷旧草稿兼容入口：仅为旧客户端容错保留。

### Docs / Reports
- 2.3 过程类文档中已被 2.4 基线覆盖的重复叙述
- 旧版 explanation 格式草稿（若不再被测试引用）
- 仅用于历史比对、无新增维护价值的旧周报/简报

## deprecated（应在 2.5 删除或彻底退役）

### User-facing copy
- 新增的 MBTI 强口径屏幕文案
- 任何把 MBTI 描述成主排序信号的文案
- 任何把西占描述成高精确定结论的文案

### Backend / Contract
- 无实际客户端依赖的旧路由别名
- 已被统一接口替代的旧 payload adapter
- 与当前 explanation schema 不匹配的旧格式输出路径

### Documentation
- 被 2.3 / 2.4 基线完全覆盖的旧过程报告
- 重复的调权建议、调试日志、过时的快照说明

## 删除顺序建议
1. 先确认活跃客户端是否已经不再依赖兼容项。
2. 再把对应字段或路由标记为 deprecated。
3. 最后在 2.5 里删代码、删适配、删重复文档。

## 删除前必须满足
- 有明确使用率或依赖证明
- 已经在 deprecation register 中出现至少一个周期
- 已完成替代路径验证

## 2.5 优先删除候选
- 旧版 MBTI 强口径用户文案
- 无新客户端依赖的 questionnaire legacy adapter
- 不再被测试引用的旧解释格式草稿
- 过时且被基线覆盖的过程型报告
