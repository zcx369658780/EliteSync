# 男女合盘功能落地说明（2026-03-25）

## 顾问结论（Android Studio Developer）
- 建议新增 `pair_chart` 模块，作为“关系过程层”解释信号。
- 不引入重依赖，复用现有星座/星盘/八字中间能力。
- 支持降级估算（FULL / PARTIAL / SUN_ONLY），并向前端暴露置信度与降级原因。

## 本次实现
1. 后端匹配算法新增 `pair_chart` 子模块：
   - 组成：太阳-月亮互容、上升互动、情绪节奏、长期稳定桥接（八字）
   - 输出：score/verdict/reason_short/reason_detail/risk_detail/evidence_tags/confidence/degraded
2. 玄学权重调整（可配置）：
   - 八字 45%
   - 属相 25%
   - 星座 8%
   - 星盘 7%
   - 男女合盘 15%
3. 模块契约输出：
   - `match_reasons.modules` 新增 `pair_chart`
4. 前端展示增强：
   - 证据标签变量名转中文可读
   - 惩罚/修正因子转中文可读并标注加成/惩罚

## 注意
- `pair_chart` 目前不新增数据库列，仅走 match_reasons 模块输出。
- 需要每次算法更新后重跑 `app:dev:run-matching --release-drop` 才能看到最新匹配解释。
