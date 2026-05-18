# GPT-Codex Repo Source Workflow

## 0. One-line conclusion

EliteSync will use repo-local docs and GitHub commits / PRs as the shared project source between GPT advisor and Codex, reducing manual copy-paste through the user.

## 1. Why change

- manual GPT -> user -> Codex -> user -> GPT transfer is too slow
- Codex cannot rely on ChatGPT Project Sources directly
- Codex can reliably read repo-local docs
- GPT advisor can review GitHub repo files, commits, PRs, diffs, and docs
- therefore repo-local docs become the shared project source

## 2. New workflow

1. GPT advisor defines task or authorization gate.
2. User passes minimal instruction or approves gate.
3. Codex reads AGENTS.md + docs current entries.
4. Codex executes allowed scope.
5. Codex commits / pushes or opens PR if authorized.
6. User gives GPT advisor only commit hash / PR link / branch.
7. GPT advisor reviews GitHub diff and docs directly.
8. GPT advisor returns approve / request changes / next gate.
9. User only intervenes for high-risk authorization.

## 3. What must remain user-confirmed

- SSH write operation
- sites-enabled symlink creation
- nginx -t
- reload / restart
- endpoint verification
- staging / production request
- DB / migration / restore
- release chain / APK / versionCode
- product roadmap / version start
- final acceptance / next version start

## 4. Commit / PR policy

- small documentation tasks may commit directly to current feature branch if explicitly authorized
- high-risk operations should produce authorization package first
- server operations should produce execution report only after user authorization
- larger feature/runtime tasks should prefer PR or isolated branch
- every commit / PR must include scope, files changed, not done, evidence, next gate

## 5. GitHub Issue task queue

- GitHub Issues are the preferred task queue after the bridge package.
- The user no longer needs to paste long task prompts between GPT advisor and Codex.
- GPT advisor can create issues with title prefix `GPT-TASK:` that define goal, scope, allowed files, validation, commit / PR policy, and final report format.
- Codex reads the issue number through GitHub CLI or a repo-approved helper script, then executes only the issue body scope that is also allowed by `AGENTS.md`.
- GPT advisor reviews the resulting commit / PR through GitHub afterwards.

## 6. Current docs policy

- AGENTS.md is stable root instruction
- docs/HANDOFF_MASTER_CURRENT.md is pointer only
- docs/version_plans/6.0_A1_HANDOFF_MASTER.md remains A1 main handoff
- docs/DOC_INDEX_CURRENT.md remains reading order
- docs/DEVELOPMENT_PLAN_CURRENT.md remains current plan entry
- docs/project_memory.md remains long-term memory
- current docs sync must be explicit; do not casually modify them

## 7. Example user message after migration

After this workflow is adopted, the user should only need messages like:

> Codex 已 push commit `<hash>`，请你通过 GitHub 审阅。

or:

> Codex 已开 PR `#<n>`，请你审查并给出是否通过。

## 8. Current transition status

- This bridge package is documentation-only.
- It does not modify runtime.
- It does not execute SSH / symlink / nginx -t / reload / endpoint verification.
- After this package is accepted and pushed, future GPT-Codex communication can switch to GitHub commit / PR based review.
- Current Option B symlink execution remains paused until separate authorization.

## 9. Runtime / program-development task policy

- Docs-only tasks can use one GitHub issue.
- Runtime/program-development tasks use a GitHub Issue Bundle rather than one giant issue.
- GitHub stores text reports and indexes: Codex self-review, Claude horizontal / blind review, Codex integrated acceptance, Action Matrix, and evidence index.
- Screenshots are critical-only / user-supplied on demand; GitHub should not become a bulk image warehouse.
- Claude horizontal / blind review artifacts are text-first and referenced in GPT final acceptance.
