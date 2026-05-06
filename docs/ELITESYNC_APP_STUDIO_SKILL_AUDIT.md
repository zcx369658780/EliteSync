# EliteSync App Studio Skills 审核稿

日期：2026-05-05

本文档将当前已落地的 5 个 `SKILL.md` 正文合并在一起，便于 GPT 顾问一次性审核。

## 1. elitesync-version-start

```md
# elitesync-version-start

## Purpose

Start a new EliteSync version safely. This skill exists to force a read-only audit before any implementation begins.

## Trigger

- A new version plan is announced.
- A human says "start the version" or "begin implementation".

## Required workflow

1. Read `docs/DEVELOPMENT_PLAN_CURRENT.md`.
2. Read `docs/project_memory.md`.
3. Read the current handoff entry and the current acceptance status.
4. List the allowed scope, excluded scope, protection surfaces, and verification baseline.
5. Identify the first implementation slice and the files that may be touched.

## Stop condition

- Scope is locked.
- Protection surfaces are named.
- Non-goals are explicit.
- The next action is either implementation or a blocker report.

## Must not do

- Do not edit code.
- Do not stage or commit.
- Do not expand scope to other versions.
```

## 2. elitesync-runtime-slice

```md
# elitesync-runtime-slice

## Purpose

Implement the smallest safe runtime/UI slice for the current EliteSync version.

## Trigger

- A version slice has been approved for implementation.
- The target is Discover / Chat / Me / Settings or another UI/runtime slice.

## Required workflow

1. State the exact slice and the files in scope.
2. State what must not change.
3. Implement the smallest useful UI/runtime increment.
4. Run the minimum tests needed for that slice.
5. Hand off to evidence closeout if the slice is stable.

## Stop condition

- The smallest safe slice is implemented.
- The minimum tests pass.
- No protected surface has been broken.
- If the slice starts touching backend contracts, truth chains, release logic, or unclear boundaries, stop and switch to cross-layer-blocker.

## Must not do

- Do not touch backend contracts.
- Do not touch truth chains.
- Do not rewrite release logic.
- Do not widen the slice without approval.
```

## 3. elitesync-evidence-closeout

```md
# elitesync-evidence-closeout

## Purpose

Collect and close out the version evidence package.

## Trigger

- The implementation slice is done.
- Screenshots, XML, walkthroughs, or regression proof are needed.

## Required workflow

1. Collect evidence only from the current installed build/package and current UI state.
2. Verify filename, screenshot content, and page content match.
3. Update or create the single `*_HANDOFF_MASTER.md` for the version.
4. Keep evidence index and regression checklist as supporting files.

## Stop condition

- Handoff is single-entry.
- Evidence index is complete.
- Regression checklist is complete.
- Any observations are preserved but not inflated into blockers.

## Must not do

- Do not create parallel final summary files.
- Do not reuse old-version screenshots as if they were current evidence.
- Do not expand into new features.
```

## 4. elitesync-dirty-worktree

```md
# elitesync-dirty-worktree

## Purpose

Clean and organize a dirty EliteSync worktree one theme at a time.

## Trigger

- `git status --short` is non-empty.
- The repository needs to be prepared for a single-theme commit or archive action.

## Required workflow

1. Inspect `git status --short`, `git diff --stat`, and `git diff --name-only`.
2. Bucket all dirty files into A / B / C / D.
3. Pick only one theme for the next commit.
4. Stage only the confirmed files for that theme.
5. Before commit, output the staged file list, excluded files, and proposed commit message.
6. Wait for human confirmation before committing.

## Stop condition

- One theme is staged and confirmed.
- The remaining dirty work is clearly classified.

## Must not do

- Do not run `git add .`.
- Do not do repo-wide restore/reset/clean.
- Do not use git stash.
- Do not delete tracked files as a shortcut.
- Do not mix multiple themes into one commit.
```

## 5. elitesync-cross-layer-blocker

```md
# elitesync-cross-layer-blocker

## Purpose

Handle blockers that may cross UI, backend, truth chain, release chain, or environment boundaries.

## Trigger

- A bug resists local UI fixes.
- A change might affect backend contracts, truth chains, release metadata, or protected surfaces.

## Required workflow

1. Stop the blind fix.
2. Write a blocker report that names the symptom, suspected layer, affected surfaces, and smallest safe next step.
3. Identify the likely layer boundary.
4. Ask for the smallest safe scope cut.
5. Hand the high-risk root-cause analysis to the architecture reviewer if needed.

## Stop condition

- The boundary is named.
- The smallest safe fix is identified.
- The next action is no longer ambiguous.

## Must not do

- Do not keep patching the wrong layer.
- Do not broaden the scope in the hope of fixing it faster.
```

## 6. 审核重点

请重点审核以下方面：

1. 每个 skill 的触发条件是否足够清楚。
2. 每个 skill 的停止条件是否足够可执行。
3. 是否存在职责重叠。
4. 是否把不该重复的项目级规则写得过多。
5. `cross-layer-blocker` 是否应该保留在第一批。
6. 当前正文是否足够短、足够清晰、足够可维护。
