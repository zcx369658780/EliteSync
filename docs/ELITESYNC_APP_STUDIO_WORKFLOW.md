# EliteSync App Studio Workflow

日期：2026-05-05

## 1. 目标

把 EliteSync 已经验证过的高频开发流程，固化为 repo-local 的 Codex skills 调用入口，减少临时长 prompt 和工作流漂移。

## 2. 当前已启用的第一批 skill

1. `elitesync-version-start`
2. `elitesync-runtime-slice`
3. `elitesync-evidence-closeout`
4. `elitesync-dirty-worktree`
5. `elitesync-cross-layer-blocker`

## 3. 默认调用顺序

### 3.1 新版本启动

- 先调用 `elitesync-version-start`
- 再做只读审计、范围锁定、保护面确认

### 3.2 版本实现

- 调用 `elitesync-runtime-slice`
- 只做当前版本最小实现切片
- 一旦触碰 backend contracts、truth chains、release logic 或边界不清，立即切换到 `elitesync-cross-layer-blocker`

### 3.3 证据与收口

- 调用 `elitesync-evidence-closeout`
- 只认当前 installed build/package 与当前 UI 状态
- 单文件主交接优先

### 3.4 脏工作区清理

- 调用 `elitesync-dirty-worktree`
- 按 A/B/C/D 分桶
- 单主题提交
- 先输出 staged 清单、排除项和 commit message，再等待确认

### 3.5 跨层 blocker

- 调用 `elitesync-cross-layer-blocker`
- 要求 blocker report 明确写出 symptom、suspected layer、affected surfaces、smallest safe next step

## 4. 暂缓的后续能力

- `elitesync-current-entry-sync`
- `elitesync-historical-archive`

## 5. 仅保留为预留能力

- `elitesync-release-readiness`

## 6. 使用原则

- 第一批只保留 5 个 skill 作为最小可用工作流骨架。
- 不提前物理创建第二批 / 第三批目录。
- 不把总说明重复抄进每个 skill。
- 后续如需扩展，再按版本节奏补充新 skill。

