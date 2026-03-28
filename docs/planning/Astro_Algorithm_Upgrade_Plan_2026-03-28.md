# 玄学算法升级计划（2026-03-28）

## 目标
- 在不破坏现有接口契约的前提下，提升玄学模块（八字/属相/星座/星盘/合盘）的可解释性与稳定性。
- 保持前端零接口改造即可消费新解释字段。

## 已完成（Round 1）
1. 八字评分模型升级为可解释结构（V2）  
   - 从“目标距离拟合”改为：`base + complement + balance`  
   - 输出证据增强：`wu_xing_complement`、`wu_xing_balance_a/b/avg`
2. 属相解释增强  
   - 解释文案中加入当前组合与关系类型（如 `龙-马 / sanhe`）
3. 模块版本标记升级  
   - `matching.php` 中 `bazi`、`zodiac` 升级至 `p2`
4. 前端兜底解释文案优化  
   - “可在后续版本查看”改为“建议结合亮点/风险/证据标签判断”

## 已验证
- PHP 语法检查通过：
  - `AstroCompatibilityService.php`
  - `config/match_rules.php`
  - `config/matching.php`
- Flutter analyze 通过（无问题）
- 后端契约测试通过：
  - `MatchPayloadContractTest`

## 下一步（Round 2）
1. 合盘（pair_chart）细化
   - 将太阳/月亮/上升的过程层影响拆分为独立解释段
   - 增加“数据完整度”对置信度的更细粒度分段
2. 星盘（natal_chart）细化
   - 在现有简化模型上增加“情绪同步/表达同步/节奏同步”三段解释
3. 术语可读化
   - 将 `relation_type`、证据标签在后端生成时同步提供中文解释映射

## 发布策略
- Round 2 完成后进行一次集中回归（匹配详情页 + 匹配接口契约 + 端侧展示）
- 再决定是否发布 `0.02.03`

