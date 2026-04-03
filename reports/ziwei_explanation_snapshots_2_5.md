# Ziwei Explanation Snapshots 2.5

日期：2026-03-30

## 说明

以下为基于当前紫微解释模板与评分逻辑整理的 5 组代表性快照，用于和顾问对接时确认展示口径。

---

### 样例 1：命宫一致 + 身宫一致

- `key`: `ziwei`
- `label`: `紫微斗数`
- `score`: `89`
- `reason_short`: `命宫主轴较接近，长期画像节奏更易同频`
- `reason_detail`: `命宫主轴较接近；身宫落点一致，日常行为节律较容易贴近；部分核心主题重合，关系推进存在共同抓手`
- `risk_detail`: `紫微斗数更适合长期画像，不建议把单次波动当成最终结论。`
- `evidence_tags`:
  - `ziwei_canonical`
  - `ziwei_long_term_profile`
  - `life_palace_aligned`
  - `body_palace_aligned`
  - `major_themes_partial_overlap`

### 样例 2：命宫相近 + 主题部分重合

- `key`: `ziwei`
- `label`: `紫微斗数`
- `score`: `80`
- `reason_short`: `命宫主题存在差异，可形成互补视角`
- `reason_detail`: `命宫主题存在差异，可形成互补视角；身宫落点不同，现实互动中更容易形成分工；部分核心主题重合，关系推进存在共同抓手`
- `risk_detail`: `紫微斗数更适合长期画像，不建议把单次波动当成最终结论。`

### 样例 3：关系/事业/财富主题重合度高

- `key`: `ziwei`
- `label`: `紫微斗数`
- `score`: `86`
- `reason_short`: `关系/事业/财富主题出现较多重合，长期目标更易对齐`
- `reason_detail`: `命宫主轴较接近，长期画像节奏更易同频；身宫落点一致，日常行为节律较容易贴近；关系/事业/财富主题出现较多重合，长期目标更易对齐`
- `risk_detail`: `紫微斗数更适合长期画像，不建议把单次波动当成最终结论。`

### 样例 4：缺少完整紫微命盘

- `key`: `ziwei`
- `label`: `紫微斗数`
- `score`: `58`
- `reason_short`: `紫微斗数数据不完整，当前仅作保守参考。`
- `reason_detail`: `缺少完整紫微命盘，系统只能按已知宫位做简化估算。`
- `risk_detail`: `建议补全出生时刻与地点后再判断紫微画像稳定性。`
- `evidence_tags`:
  - `ziwei_degraded_estimation`
  - `missing_ziwei`

### 样例 5：主题差异较大但可形成互补

- `key`: `ziwei`
- `label`: `紫微斗数`
- `score`: `73`
- `reason_short`: `命宫主题存在差异，可形成互补视角`
- `reason_detail`: `命宫主题存在差异，可形成互补视角；身宫落点不同，现实互动中更容易形成分工；双方性别角色配置互补，可降低关系解释成本`
- `risk_detail`: `核心主题差异较大，需要先确认关系目标与资源节奏`

## 对接要点

- 紫微是“长期画像模块”，不是即时占断。
- 展示上应优先突出 `命宫 / 身宫 / 主要主题`。
- 低置信度时保持保守口径，不输出强结论。

