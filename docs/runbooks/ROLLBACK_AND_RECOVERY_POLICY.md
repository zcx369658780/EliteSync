# Rollback and Recovery Policy

> 适用于 4.7 及以后所有跨层 blocker 修复。原则：先 checkpoint，再最小范围恢复；优先路径级恢复，禁止 repo 级回滚把 UI 一起带回旧基线。

## 1. 目标

- 防止在修 Gradle、后端、RTC、LiveKit、媒体、数据库、配置时误伤 UI 基线。
- 防止恢复操作把 modern UI 回退到旧版本。
- 保证每次恢复都能解释、可追踪、可回滚。

## 2. 绝对禁止的操作

未经用户明确批准，禁止执行：

- `git reset --hard <old_commit>`
- `git checkout <old_commit> .`
- `git restore --source=<old_commit> .`
- `git clean -fdx`
- 使用旧 zip / 旧 worktree / 旧 baseline 整仓覆盖当前项目
- 为了修构建或后端 blocker 而恢复整个 repo

## 3. 必须先做的安全检查

在任何高风险恢复前，先执行并保存：

1. `git status --short`
2. `git branch --show-current`
3. `git rev-parse HEAD`
4. `git diff --stat`
5. `git diff --name-only`

并且至少执行一种 checkpoint：

- 新建安全分支：`git switch -c safety/pre-recovery-<date>-<topic>`
- 或创建 checkpoint commit：`git commit -m "safety: checkpoint before <topic> recovery"`
- 或创建 stash：`git stash push -u -m "safety: checkpoint before <topic> recovery"`

没有 checkpoint，不得做跨层恢复。

## 4. 允许的恢复方式

只允许以下路径级、文件级、最小范围恢复：

- `git restore --source=<commit> -- <specific_file_or_directory>`
- 只恢复明确验证过的最小文件集
- 恢复后必须 diff-check 变化是否仅限目标路径

## 5. UI protected surfaces

如果恢复目标属于 `docs/PROTECTED_UI_SURFACES.md` 中定义的保护面，必须先停止并向用户确认。

## 6. 分层恢复原则

恢复必须分层，不得混层：

1. 构建层：Gradle / JDK / Android plugin / wrapper / Flutter AAR
2. 后端层：auth / profile / APP_KEY / DB / Laravel
3. RTC 层：LiveKit / Nginx / UDP / join-info / Room.connect
4. 媒体层：OSS / public_url / ExoPlayer / image/video
5. UI 层：页面布局、入口、视觉、导航

原则：

- 修构建只动构建文件
- 修后端只动后端文件和云端配置
- 修 RTC 只动 RTC 相关后端、配置、连接层和最小 Flutter 连接代码
- 修 UI 必须有 UI 专项任务
- 不允许用整仓回滚同时修多个层

## 7. 恢复后必须做的事

- 复查目标路径的 diff
- 复查 UI Baseline Regression
- 复查关键接口 / smoke / 入口是否恢复
- 记录恢复原因、影响面、回滚点

## 8. 发生 blocker 时的默认顺序

1. 写 blocker report
2. 让 Claude 做定点分析
3. 只做最小修复
4. 验证通过后再考虑下一层问题

## 9. 具体到 4.7 的规则

- 4.7 的现代 UI 基线是 protected surface
- 4.7 的跨层恢复必须先 checkpoint
- 任何恢复前都不能默认使用 repo-level 恢复命令
