# EliteSync Current Handoff Entry

## 0. Current pointer

- 当前主线：6.0 Alpha 内测准备线
- 当前版本：6.0-A1
- 当前默认主交接文件：
  `docs/version_plans/6.0_A1_HANDOFF_MASTER.md`
- 当前最新授权包：
  `docs/version_plans/6.0_A1_OPTION_B_SYMLINK_AUTHORIZATION_PACKAGE.md`
- 当前最新 HEAD：
  `4c169a5da72f82d18e819fedb19a5aa5f1a3ffac`

## 1. Current stage summary

- R1 readonly v2 runtime slice 已 stage accepted。
- Candidate C / IP staging 已转向 Option B SSH tunnel only。
- Option B narrow scaffold / preflight 已归档。
- Option B symlink authorization package 已提交。
- 当前尚未创建 sites-enabled symlink。
- 当前尚未 nginx -t for enabled symlink。
- 当前尚未 reload / restart Nginx。
- 当前尚未 endpoint verification。
- 当前 staging 仍不可视为 enabled / reachable / verified。

## 2. Next pending gate

下一步待决策：

- future sites-enabled symlink execution only
- 只允许 symlink + nginx -t
- 不允许 reload
- 不允许 endpoint verification
- 不允许 staging / production request

## 3. Repo-source workflow transition

- This file is the repo-local bridge so Codex and GPT advisor can use GitHub/repo docs instead of manual copy-paste.
- Future GPT advisor review should prefer GitHub commit / PR / repo docs over pasted terminal transcripts.
- User should only need to provide commit hash / PR link and confirm high-risk authorizations.
- Project-wide long-term rules now use canonical `docs/project_rules/` paths:
  - `docs/project_rules/PROJECT_RULE_HANDOFF_SINGLE_FILE.md`
  - `docs/project_rules/PROJECT_RULE_CROSS_LAYER_BLOCKERS.md`

## 4. Do not overclaim

- Not staging enabled
- Not staging reachable
- Not staging verification passed
- Not production verification passed
- Not Candidate C completed
- Not A1 final acceptance
- Not production ready
- Not A2 start

## 5. Historical note

- Previous content in this file was a 2026-05-11 historical recovery handoff.
- It is superseded by the current 6.0-A1 pointer above.
- For old 5.x recovery facts, consult git history or archived handoff materials.
- Do not use the old 5.6+ route as current active route.
