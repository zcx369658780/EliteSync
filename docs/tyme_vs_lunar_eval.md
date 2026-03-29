# Tyme vs Lunar Eval

- Date: 2026-03-29
- Scope: 中历底座选型（用于八字 canonical 服务化）

## Current Context
- Existing production path uses Lunar-family outputs already (Android侧 + Laravel存储链路)。
- Algo 2.2要求服务端 canonical 化，且避免继续扩写客户端近似算法。

## Compared Candidates
- Lunar: `lunar-java`, `lunar-python`, `lunar-php`
- Tyme: `tyme4kt`, `tyme4py`

## Evaluation Dimensions
1. API 可读性与稳定性
2. Android/Kotlin 接入成本
3. Laravel 过渡成本
4. 边界一致性（节气、干支、年柱）
5. 迁移风险

## Findings

### 1) API & Model
- Lunar 系列：成熟、文档和社区样例多，历史兼容性更强。
- Tyme 系列：设计更现代，长期可维护性潜力更高。

### 2) 接入成本
- 现阶段后端主栈是 Laravel。
- Lunar 有 `lunar-php`，可直接在现有服务端做过渡桥接；Tyme 暂无同等成熟 PHP 路线。
- Kotlin 侧 Tyme 体验较好，但 2.2 路线下 Android 不承担 canonical，因此优势暂不直接转化。

### 3) 一致性与迁移
- 若立刻切 Tyme，会引入“旧数据口径 vs 新引擎口径”迁移成本。
- 先用 Lunar 完成服务端 canonical，再做 Tyme A/B 对拍，风险更可控。

## Decision (Phase 2 conclusion)
- **短中期（当前版本）**：继续 Lunar 路线作为 canonical 主线（优先 `lunar-python` or `lunar-java`，Laravel 可用 `lunar-php` 过渡）。
- **中后期（Beta前）**：引入 Tyme 作为对拍与新模块候选，通过灰度开关评估切换成本。

## Migration Plan
1. P1: 服务端 canonical 先落地 Lunar（当前已完成脚手架）。
2. P2: 构建 Tyme 对拍任务（固定测试向量 + 边界日期集合）。
3. P3: 输出差异报告（节气、年柱、生肖、四柱字段一致率）。
4. P4: 仅当一致率与可维护性收益满足阈值，再考虑切换默认引擎。

## Risks
- 立即切 Tyme：数据口径漂移风险高。
- 长期不评估 Tyme：可能错过更现代的维护路径。

## Recommendation
- 采用“双轨”：
  - 生产 canonical 先稳（Lunar）
  - Tyme 并行评估，不中断现有业务链
