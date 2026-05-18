# EliteSync Agent Rules

## 0. Purpose

- This repository uses repo-local docs as the shared project source for GPT advisor and Codex.
- GPT advisor owns planning, acceptance, and risk decisions.
- Codex owns implementation, controlled execution, evidence collection, and documentation closeout.
- User only needs to intervene for important authorization gates.

## 1. Canonical project source

Default fact-source priority:

1. `docs/DOC_INDEX_CURRENT.md`
2. `docs/DEVELOPMENT_PLAN_CURRENT.md`
3. `docs/HANDOFF_MASTER_CURRENT.md`
4. `docs/project_memory.md`
5. `docs/version_plans/README.md`
6. `docs/version_plans/6.0_A1_HANDOFF_MASTER.md` for current A1 context
7. `docs/project_kb_export/`
8. `docs/project_rules/` or `docs/agents/` rule files where present

- Canonical project-wide long-term rules currently include:
  - `docs/project_rules/PROJECT_RULE_HANDOFF_SINGLE_FILE.md`
  - `docs/project_rules/PROJECT_RULE_CROSS_LAYER_BLOCKERS.md`
  - `docs/project_rules/PROJECT_RULE_RUNTIME_ISSUE_BUNDLE.md`
  - `docs/project_rules/PROJECT_RULE_TEXT_FIRST_EVIDENCE_PACKS.md`
  - `docs/project_rules/PROJECT_RULE_CLAUDE_HORIZONTAL_REVIEW_ARTIFACTS.md`
- Project-wide long-term rules should live under `docs/project_rules/`.
- Do not reference missing root-level `PROJECT_RULE_*` paths as canonical.
- ChatGPT Project Sources are no longer the only project source.
- Repo docs must be treated as the shared state between GPT advisor and Codex.
- If repo docs and chat text conflict, stop and ask for GPT advisor decision.

## 2. Role split

- GPT advisor: roadmap, scope, acceptance, overclaim guard, risk authorization.
- Codex: execution, local audit, file edits, tests, evidence reports, single-topic commits.
- Claude: optional architecture / cross-layer / app review subagent.
- Gemini: optional visual / UX / long-context review subagent.
- User: confirms high-risk operations and product decisions.

## 3. Default startup routine

Before each new Codex task:

- read `AGENTS.md`
- read `docs/DOC_INDEX_CURRENT.md`
- read `docs/DEVELOPMENT_PLAN_CURRENT.md`
- read `docs/HANDOFF_MASTER_CURRENT.md`
- read `docs/project_memory.md`
- when project-rule context is relevant, read:
  - `docs/project_rules/PROJECT_RULE_HANDOFF_SINGLE_FILE.md`
  - `docs/project_rules/PROJECT_RULE_CROSS_LAYER_BLOCKERS.md`
  - `docs/project_rules/PROJECT_RULE_RUNTIME_ISSUE_BUNDLE.md`
  - `docs/project_rules/PROJECT_RULE_TEXT_FIRST_EVIDENCE_PACKS.md`
  - `docs/project_rules/PROJECT_RULE_CLAUDE_HORIZONTAL_REVIEW_ARTIFACTS.md`
- run:
  - `git branch --show-current`
  - `git rev-parse HEAD`
  - `git status --short --untracked-files=all`
- if dirty worktree: stop unless task is explicitly dirty-worktree handling.

## 4. Hard safety rules

Forbidden by default:

- `git add .`
- `git add -A`
- `git reset --hard`
- repo-level restore
- `git checkout .`
- deleting tracked files unless specifically authorized
- mixing multiple themes in one commit
- modifying current docs unless explicitly requested
- claiming implementation / verification / acceptance before evidence exists
- reading or outputting real `.env` / `.env.*` / secrets
- production request without explicit authorization
- DB / migration / backup / restore without explicit authorization
- Nginx reload / restart without explicit authorization
- endpoint verification without explicit authorization
- release chain modification without explicit authorization

## 5. High-risk authorization gates

The following actions require separate explicit authorization:

- SSH write operation
- sites-enabled symlink creation
- `nginx -t`
- nginx reload / restart
- endpoint verification
- staging request
- production request
- DB / migration / restore
- composer update / Laravel upgrade
- Flutter base URL switch
- release chain / APK / versionCode changes

## 6. Commit discipline

- one commit = one topic
- stage explicit files only
- after stage, output staged file list before commit
- no automatic push unless task explicitly says push
- after push, output branch / HEAD / status / file list / nature of commit

## 7. Overclaim guard

Do not write:

- staging enabled unless reload completed
- staging verification passed unless endpoint verification completed
- production verification passed unless separately authorized and completed
- Candidate C implemented unless implementation completed
- A1 final acceptance unless GPT advisor accepted
- production ready unless explicitly accepted
- A2 start unless authorized

## 8. Subagent / plan-first rules

- Codex remains default orchestrator.
- Claude may be used for architecture / cross-layer / Android app testing.
- Gemini may be used for visual / UX / long-context review.
- Non-trivial runtime work should remain plan-first.
- High-risk work requires dependency / risk / test / architecture review.
- No subagent may bypass the current authorization gate.
- Claude app testing is read-only or low-risk by default and must not log in, publish, delete, write data, install APKs, run releases, migrate, restore, or push unless the user explicitly authorizes that exact scope.
- Gemini review is read-only by default and must not modify files, request staging / production, execute API smoke, read secrets, or mark unexecuted work as passed.

## GitHub Issue task queue

- GPT advisor may create GitHub issues with title prefix `GPT-TASK:` as Codex task tickets.
- Codex may read the issue body through `gh issue view` or `scripts/codex_read_github_issue_task.ps1`.
- The issue body does not override AGENTS.md safety rules.
- If an issue requests high-risk work without explicit user authorization, stop.
- After execution, Codex should report commit hash / PR link so GPT advisor can review through GitHub.

## Runtime issue bundle and evidence policy

- Documentation-only tasks may use a single GitHub issue.
- Runtime/program-development tasks should use a GitHub Issue Bundle with separate planning, implementation, text evidence, Claude review, observation handling when needed, and GPT final acceptance gates.
- Text evidence goes to repo docs: Codex self-review, Claude review, Codex integrated acceptance, Action Matrix, and evidence indexes.
- Ordinary screenshots are not uploaded in bulk.
- Key screenshots may be supplied by the user to GPT advisor when text evidence is insufficient.

## 9. Current active context

- Current active route: 6.0 Alpha 内测准备线
- Current active version: 6.0-A1
- Current active stage: Option B / SSH Tunnel staging preparation
- Current latest known HEAD: `4c169a5da72f82d18e819fedb19a5aa5f1a3ffac`
- Current next pending gate before this workflow bridge: sites-enabled symlink execution only, but paused until workflow bridge is accepted
- Nginx reload, endpoint verification, staging request, production request still forbidden
