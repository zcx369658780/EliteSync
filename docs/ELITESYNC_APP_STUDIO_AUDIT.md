# EliteSync App Studio 审核说明

日期：2026-05-05

## 1. 审核目标

本文件用于给 GPT 顾问审核当前在仓库内落地的 `EliteSync App Studio` 目录结构与第一批技能设计。

目标不是立刻扩展为大而全的技能库，而是先验证：

- 是否符合 EliteSync 的单主题、低噪音、可迭代原则
- 是否与当前 5.x 开发工作流兼容
- 是否只落地第一批高频技能
- 是否把后续能力保留为规划而非提前建空壳

---

## 2. 已落地内容

### 2.1 本地插件

- `plugins/elitesync-app-studio/.codex-plugin/plugin.json`
- `plugins/elitesync-app-studio/README.md`
- `.agents/plugins/marketplace.json`

### 2.2 第一批已创建技能

1. `plugins/elitesync-app-studio/skills/elitesync-version-start/SKILL.md`
2. `plugins/elitesync-app-studio/skills/elitesync-runtime-slice/SKILL.md`
3. `plugins/elitesync-app-studio/skills/elitesync-evidence-closeout/SKILL.md`
4. `plugins/elitesync-app-studio/skills/elitesync-dirty-worktree/SKILL.md`
5. `plugins/elitesync-app-studio/skills/elitesync-cross-layer-blocker/SKILL.md`

### 2.3 明确仅保留为规划、未创建目录的后续能力

- `elitesync-current-entry-sync`
- `elitesync-historical-archive`
- `elitesync-release-readiness`

---

## 3. 设计判断

### 3.1 方向判断

当前实现方向是正确的，原因如下：

- 以 repo-local plugin 作为载体，符合 Codex 官方的本地插件组织方式
- 第一批只放 5 个高频 skill，没有一开始就把技能目录做满
- `release-readiness` 被明确保留为预留能力，没有提前落地
- `README.md` 作为 Studio 总说明页，降低了每个 skill 里重复写长规则的噪音

### 3.2 与 EliteSync 现有工作流的匹配点

这套 Studio 和仓库当前的成熟流程是对齐的：

- `elitesync-version-start` 对齐“新版本开发启动流程”
- `elitesync-runtime-slice` 对齐“单版本单切片实现”
- `elitesync-evidence-closeout` 对齐“截图 / XML / handoff 收口”
- `elitesync-dirty-worktree` 对齐“单主题提交、分桶、清仓”
- `elitesync-cross-layer-blocker` 对齐“跨层 blocker 先报告再缩层”的项目规则

---

## 4. 当前风险点

### 4.1 风险 1：技能说明重复

如果后续把所有项目规则都写进每个 `SKILL.md`，会造成：

- 重复维护
- 口径漂移
- 文档噪音增加

建议：

- 保持 `README.md` 作为总说明
- 每个 `SKILL.md` 只保留触发条件、停止条件、必须做/禁止做

### 4.2 风险 2：后续技能过早扩张

如果第二批、第三批技能过早物理创建，容易让目录看起来完整，但实际维护成本上升。

建议：

- 先让第一批真实跑通
- 再逐步增加 `current-entry-sync`、`historical-archive`
- `release-readiness` 继续保留为规划，不提前落地

### 4.3 风险 3：与当前版本文档入口混淆

这个 Studio 是工作流工具，不是版本交接本身。

建议明确区分：

- `docs/DEVELOPMENT_PLAN_CURRENT.md` 等当前入口文档
- `docs/ELITESYNC_APP_STUDIO_AUDIT.md` 这类工作流说明文件

---

## 5. 建议 GPT 顾问重点审核的点

1. 第一批 5 个 skill 是否已经足够覆盖 EliteSync 当前最常用的工作流。
2. `elitesync-cross-layer-blocker` 是否应该作为第一批必需 skill。
3. `README.md` 是否足以承载总说明，避免每个 skill 反复写长规则。
4. `current-entry-sync` 是否适合第二批优先落地。
5. `historical-archive` 是否应该和 `current-entry-sync` 一起作为第二批。
6. `release-readiness` 是否应继续只保留为预留能力。

---

## 6. 当前结论

当前版本的 `EliteSync App Studio` 可以视为：

- 方向正确
- 结构轻量
- 适合继续审查
- 还不需要立刻扩成完整平台

最重要的是：

> 第一批 5 个 skill 已经覆盖了 EliteSync 现在最常发生、最值得沉淀的工作流。

---

## 7. 交给顾问的简短结论

建议顾问审核结论聚焦为：

- 第一批 5 个 skill 可以作为最小可用工作流骨架
- `release-readiness` 不要提前建目录
- 第二批目录先保留在规划中
- 这个 Studio 更适合 repo-local、轻量、渐进式扩展

