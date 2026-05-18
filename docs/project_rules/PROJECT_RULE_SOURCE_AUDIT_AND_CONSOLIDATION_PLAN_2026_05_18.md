# EliteSync Project Rule Source Audit and Consolidation Plan

## 0. One-line conclusion

Repo-local docs should become the canonical shared rule source for GPT advisor and Codex, but this issue only audits and proposes consolidation; it does not delete, move, rename, or rewrite any existing rule files.

## 1. Current baseline

| Item | Value |
|---|---|
| branch | `feature/5.0-alpha-readiness-20260501` |
| HEAD | `c47738b5bb1dd9416b53807658b03909ddf759e5` |
| worktree state before report creation | clean |
| current active route | 6.0 Alpha 内测准备线 |
| current active version | 6.0-A1 |
| current active stage | Option B / SSH Tunnel staging preparation; symlink execution still paused |

Current workflow bridge commits:

- `6bda7e0e31862eade09f328881feb5ca3cb2d20e docs: add GPT-Codex repo source workflow bridge`
- `c47738b5bb1dd9416b53807658b03909ddf759e5 docs: add GitHub issue task queue workflow`

## 2. Rule-file inventory

Source command:

```powershell
git ls-files | Where-Object { $_ -match '(^|/)(AGENTS\.md|.*RULE.*\.md|.*GATE.*\.md|.*WORKFLOW.*\.md|.*CHECKLIST.*\.md|.*PROTECTED.*\.md|.*RUNBOOK.*\.md)$' }
```

### Root agent instructions

| Path | Apparent role | Classification | Recommendation |
|---|---|---|---|
| `AGENTS.md` | Root Codex / agent execution rules | current | canonical source |

### Current entry / handoff pointers

No `*RULE*`, `*GATE*`, `*WORKFLOW*`, `*CHECKLIST*`, `*PROTECTED*`, or `*RUNBOOK*` handoff pointer was matched by the audit command. Current handoff pointers still exist outside this filename pattern, especially `docs/HANDOFF_MASTER_CURRENT.md` and `docs/version_plans/6.0_A1_HANDOFF_MASTER.md`; they should remain canonical current-entry sources by policy, not by filename-match inclusion.

### Project-level rules

| Path | Apparent role | Classification | Recommendation |
|---|---|---|---|
| `docs/PROTECTED_SURFACES.md` | General protected surfaces | current / supporting | canonical or migrate into `docs/project_rules/` after follow-up review |
| `docs/PROTECTED_UI_SURFACES.md` | UI protected surfaces after rollback incident | current / supporting | canonical or migrate into `docs/project_rules/` after follow-up review |
| `docs/REGRESSION_CHECKLIST.md` | General regression checklist | current / supporting | supporting source; consider canonical checklist location decision |
| `docs/RELEASE_SMOKE_CHECKLIST.md` | Release smoke checklist | supporting | supporting source; keep until release workflow normalization |

### Agent rules

| Path | Apparent role | Classification | Recommendation |
|---|---|---|---|
| `docs/agents/CLAUDE_HORIZONTAL_REVIEW_GATE_RULES.md` | Claude review gate rules | current | canonical agent-specific source |
| `docs/agents/CODEX_CYBER_SAFE_UI_RESEARCH_RULES.md` | Codex UI research safety rules | current | canonical agent-specific source |
| `docs/agents/PROJECT_RULE_CLAUDE_SOUL_CECE_HORIZONTAL_REVIEW.md` | Claude Soul / Cece review rule | current | canonical agent-specific source |
| `docs/agents/PROJECT_RULE_DEVELOPMENT_PLAN_FORMAT_CURRENT.md` | Development plan format rule | current | canonical agent-specific or project-level rule; consider moving policy-only copy into `docs/project_rules/` later |

### Workflow docs

| Path | Apparent role | Classification | Recommendation |
|---|---|---|---|
| `docs/ELITESYNC_APP_STUDIO_WORKFLOW.md` | Repo-local App Studio workflow | current / supporting | supporting workflow source |
| `docs/workflows/GPT_CODEX_REPO_SOURCE_WORKFLOW.md` | GPT-Codex repo source bridge | current | canonical workflow source |
| `docs/workflows/GITHUB_ISSUE_TASK_QUEUE_WORKFLOW.md` | GitHub issue task queue bridge | current | canonical workflow source |

### Version-specific authorization packages / gates

| Path | Apparent role | Classification | Recommendation |
|---|---|---|---|
| `docs/version_plans/6.0_A1_FRAMEWORK_RUNTIME_SUPPORT_GATE.md` | A1 framework/runtime support gate | supporting evidence | keep under version plans |
| `docs/version_plans/6.0_A1_GATE_P1_BLOCKER_REMEDIATION_PLAN.md` | A1 Gate P1 blocker remediation plan | supporting evidence | keep under version plans |

### Project_kb_export rules

| Path | Apparent role | Classification | Recommendation |
|---|---|---|---|
| `docs/project_kb_export/08_UI_IA_RULES.md` | Exported UI/IA rules snapshot | supporting / snapshot | keep as exported knowledge snapshot; not canonical if an equivalent rule exists elsewhere |
| `docs/project_kb_export/09_CODEX_COLLAB_RULES.md` | Exported Codex collaboration rules snapshot | supporting / snapshot | keep as exported knowledge snapshot; canonical behavior should live in `AGENTS.md`, `docs/project_rules/`, or `docs/agents/` |

### Runbooks / checklists / protected surfaces

| Path | Apparent role | Classification | Recommendation |
|---|---|---|---|
| `docs/runbooks/ANDROID_DEBUG_BRIDGE_MCP_USAGE.md` | Android debug bridge MCP usage | current / supporting | canonical runbook |
| `docs/runbooks/ANDROID_RELEASE_REGRESSION_CHECKLIST.md` | Android release regression checklist | current / supporting | canonical runbook/checklist |
| `docs/runbooks/BACKEND_WINDOWS_RUNBOOK.md` | Backend Windows runbook | current / supporting | canonical runbook |
| `docs/runbooks/BACKUP_RESTORE_AND_MIGRATION_CHECK.md` | Backup/restore/migration check | current / supporting | canonical runbook/checklist |
| `docs/runbooks/CLOUD_BACKEND_OPERATION_BOUNDARY.md` | Cloud backend operation boundary | current / supporting | canonical runbook/boundary |
| `docs/runbooks/CLOUD_DEPLOY_RUNBOOK.md` | Cloud deploy runbook | current / supporting | canonical runbook |
| `docs/runbooks/CLOUD_READONLY_DB_ACCESS_AND_AUDIT.md` | Cloud readonly DB access/audit | current / supporting | canonical runbook |
| `docs/runbooks/DATABASE_BACKUP_RESTORE_DRILL.md` | Database backup restore drill | current / supporting | canonical runbook |
| `docs/runbooks/DEMO_RUNBOOK_2026Q1.md` | Demo runbook | supporting | keep unless superseded |
| `docs/runbooks/GITHUB_BRANCH_PROTECTION_SETUP.md` | GitHub branch protection setup | current / supporting | canonical runbook |
| `docs/runbooks/HTTPS_WSS_CUTOVER.md` | HTTPS/WSS cutover | supporting | keep as runbook |
| `docs/runbooks/MATCHING_ALGO_P1_RUNBOOK_20260324.md` | Matching algorithm runbook | supporting | keep as domain runbook |
| `docs/runbooks/MEDIA_PIPELINE_TROUBLESHOOTING.md` | Media troubleshooting | current / supporting | canonical runbook |
| `docs/runbooks/NOTIFICATION_TROUBLESHOOTING.md` | Notification troubleshooting | current / supporting | canonical runbook |
| `docs/runbooks/README.md` | Runbook index | current | canonical runbook index |
| `docs/runbooks/REGRESSION_CHECKLIST_2026Q1.md` | 2026Q1 regression checklist | supporting / historical-current | keep until consolidated |
| `docs/runbooks/RELEASE_GATE_RUNBOOK.md` | Release gate runbook | current / supporting | canonical runbook |
| `docs/runbooks/ROLLBACK_AND_RECOVERY_POLICY.md` | Rollback/recovery policy | current | canonical runbook/policy |
| `docs/runbooks/RTC_LIVEKIT_TROUBLESHOOTING.md` | RTC/LiveKit troubleshooting | supporting | keep as runbook |
| `docs/runbooks/SYNTHETIC_ACCOUNT_GOVERNANCE.md` | Synthetic account governance | current / supporting | canonical runbook |
| `docs/runbooks/TROUBLESHOOTING_LOCAL.md` | Local troubleshooting | current / supporting | canonical runbook |
| `docs/runbooks/smoke_accounts.md` | Smoke account notes | sensitive operational reference | keep as restricted runbook; avoid copying credentials into future reports |
| `docs/explanation_release_gate_2_4.md` | Historical explanation release gate | supporting / historical | archive candidate after confirming current equivalent |
| `docs/ziwei_release_checklist_2_5.md` | Historical Ziwei release checklist | supporting / historical | archive candidate after confirming current equivalent |

### Version-specific regression checklists

| Path | Apparent role | Classification | Recommendation |
|---|---|---|---|
| `docs/version_plans/5.2_REGRESSION_CHECKLIST.md` | 5.2 regression checklist | historical / supporting | keep under version plans |
| `docs/version_plans/5.3_REGRESSION_CHECKLIST.md` | 5.3 regression checklist | historical / supporting | keep under version plans |
| `docs/version_plans/5.4_REGRESSION_CHECKLIST.md` | 5.4 regression checklist | historical / supporting | keep under version plans |
| `docs/version_plans/5.5_REGRESSION_CHECKLIST.md` | 5.5 regression checklist | historical / supporting | keep under version plans |
| `docs/version_plans/5.7_REGRESSION_CHECKLIST.md` | 5.7 regression checklist | historical / supporting | keep under version plans |
| `docs/version_plans/5.8_REGRESSION_CHECKLIST.md` | 5.8 regression checklist | historical / supporting | keep under version plans |
| `docs/version_plans/5.9_REGRESSION_CHECKLIST.md` | 5.9 regression checklist | historical / supporting | keep under version plans |
| `docs/version_plans/5.10_REGRESSION_CHECKLIST.md` | 5.10 regression checklist | historical / supporting | keep under version plans |

### Historical / legacy entries

| Path | Apparent role | Classification | Recommendation |
|---|---|---|---|
| `docs/archive/legacy_2026-03/FASTAPI_TO_LARAVEL_CUTOVER_CHECKLIST.md` | Historical cutover checklist | legacy | archive only |
| `docs/archive/legacy_2026-03/docs_pruned_2026-03-28/planning_snapshots/Flutter_API_Implemented_Checklist_2026-03-26.md` | Historical Flutter API checklist | legacy | archive only |
| `docs/archive/legacy_2026-03/docs_pruned_2026-03-28/planning_snapshots/Flutter_UI_Final_Acceptance_Checklist_2026-03-27.md` | Historical Flutter UI checklist | legacy | archive only |
| `docs/archive/legacy_2026-03/docs_pruned_2026-03-28/planning_snapshots/Flutter_UI_Merge_Ready_Checklist_2026-03-26.md` | Historical Flutter UI checklist | legacy | archive only |
| `docs/archive/legacy_2026-03/docs_pruned_2026-03-28/planning_snapshots/Flutter_UI_Merge_Regression_Checklist_2026-03-27.md` | Historical Flutter UI checklist | legacy | archive only |
| `docs/archive/legacy_2026-03/docs_pruned_2026-03-28/planning_snapshots/Flutter_UI_Smoke_Checklist_2026-03-26.md` | Historical Flutter UI checklist | legacy | archive only |
| `docs/archive/legacy_2026-04/reports/RELEASE_GATE_LOG.md` | Historical release gate log | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/2.9_BETA_REGRESSION_CHECKLIST.md` | Historical beta checklist | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/2.9_BETA_RELEASE_CHECKLIST.md` | Historical beta checklist | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/2.9_BETA_SMOKE_CHECKLIST.md` | Historical beta checklist | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/2.9_INCIDENT_RUNBOOK.md` | Historical incident runbook | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/2.9_PROTECTED_SURFACES.md` | Historical protected surfaces | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/3.0_PROTECTED_SURFACES.md` | Historical protected surfaces | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/3.1_BETA_REGRESSION_CHECKLIST.md` | Historical checklist | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/3.1_PROTECTED_SURFACES.md` | Historical protected surfaces | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/3.2_BETA_REGRESSION_CHECKLIST.md` | Historical checklist | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/3.2_PROTECTED_SURFACES.md` | Historical protected surfaces | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/3.3_BETA_REGRESSION_CHECKLIST.md` | Historical checklist | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/3.3_PROTECTED_SURFACES.md` | Historical protected surfaces | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/3.4_BETA_REGRESSION_CHECKLIST.md` | Historical checklist | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/3.4_PROTECTED_SURFACES.md` | Historical protected surfaces | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/3.5_BETA_REGRESSION_CHECKLIST.md` | Historical checklist | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/3.5_PROTECTED_SURFACES.md` | Historical protected surfaces | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/3.6_BETA_REGRESSION_CHECKLIST.md` | Historical checklist | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/3.8_BETA_REGRESSION_CHECKLIST.md` | Historical checklist | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/3.9A_ACCEPTANCE_CHECKLIST.md` | Historical checklist | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/4.6F_LIVEKIT_LIVE_TEST_RUNBOOK.md` | Historical runbook | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/4.7_REGRESSION_CHECKLIST.md` | Historical checklist | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/4.8_RELEASE_GATE_CHECKLIST.md` | Historical checklist | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/4.9_RELEASE_GATE_CHECKLIST.md` | Historical checklist | legacy | archive only |
| `docs/archive/legacy_2026-04/version_plans/4.9_RELEASE_GATE_VERIFICATION_NOTE.md` | Historical gate note | legacy | archive only |

## 3. Duplicate / conflicting path observations

Explicit path check:

| Path | Status |
|---|---|
| `docs/PROJECT_RULE_HANDOFF_SINGLE_FILE.md` | missing |
| `docs/PROJECT_RULE_CROSS_LAYER_BLOCKERS.md` | missing |
| `docs/agents/PROJECT_RULE_HANDOFF_SINGLE_FILE.md` | missing |
| `docs/agents/PROJECT_RULE_CROSS_LAYER_BLOCKERS.md` | missing |
| `docs/project_rules/PROJECT_RULE_HANDOFF_SINGLE_FILE.md` | missing |
| `docs/project_rules/PROJECT_RULE_CROSS_LAYER_BLOCKERS.md` | missing |

Current docs reference missing root-level paths in at least `docs/version_plans/6.0_A1_HANDOFF_MASTER.md`, which lists `docs/PROJECT_RULE_HANDOFF_SINGLE_FILE.md` and `docs/PROJECT_RULE_CROSS_LAYER_BLOCKERS.md` as carry-forward files with an observation that the paths were not found. This issue does not fix those references; it only records that the missing-path observation still applies.

No canonical `docs/project_rules/PROJECT_RULE_HANDOFF_SINGLE_FILE.md` or `docs/project_rules/PROJECT_RULE_CROSS_LAYER_BLOCKERS.md` exists yet, so a follow-up normalization issue should create or intentionally retire those concepts.

## 4. Proposed canonical rule locations

Recommended convention:

```text
AGENTS.md                                         root execution rules
docs/project_rules/PROJECT_RULE_*.md             project-wide long-term rules
docs/agents/*.md                                 agent-specific operational rules
docs/workflows/*.md                              workflow descriptions
docs/runbooks/*.md                               operational runbooks
docs/version_plans/*.md                          version-specific plans / evidence / authorization packages
docs/project_kb_export/*.md                      exported current knowledge base snapshots
```

This convention is safer than parallel rule files in multiple folders because:

- the root execution contract is always discoverable at `AGENTS.md`;
- long-term project rules have one canonical namespace under `docs/project_rules/`;
- agent-specific behavior stays in `docs/agents/` instead of mixing with project-wide policy;
- workflow process docs stay separate from safety rules;
- runbooks remain operational procedures, not planning gates;
- version-specific evidence remains immutable supporting context rather than global policy;
- exported project knowledge stays a snapshot, reducing risk that stale exports override current rules.

## 5. GPT Project Source cleanup recommendation

This is a recommendation only. It does not mean any GPT Project Source has been removed.

### Keep in GPT Project Source for now

- `AGENTS.md`
- `docs/HANDOFF_MASTER_CURRENT.md`
- `docs/DOC_INDEX_CURRENT.md`
- `docs/DEVELOPMENT_PLAN_CURRENT.md`
- `docs/version_plans/6.0_A1_HANDOFF_MASTER.md`
- `docs/workflows/GPT_CODEX_REPO_SOURCE_WORKFLOW.md`
- `docs/workflows/GITHUB_ISSUE_TASK_QUEUE_WORKFLOW.md`

### Replace by GitHub repo docs / no longer necessary as uploaded source

- Historical version-specific regression checklists once GPT advisor confirms GitHub browsing is reliable.
- Archived `docs/archive/legacy_*` runbooks/checklists.
- Duplicated exported snapshots when an equivalent canonical repo doc exists.

### Keep only as temporary bridge until next successful GitHub review cycle

- `docs/project_kb_export/08_UI_IA_RULES.md`
- `docs/project_kb_export/09_CODEX_COLLAB_RULES.md`
- Any manually uploaded copy of `docs/project_memory.md`, if GPT advisor can reliably read the repo copy.

### Archive / remove after confirming repo equivalent

- Any uploaded `PROJECT_RULE_HANDOFF_SINGLE_FILE` or `PROJECT_RULE_CROSS_LAYER_BLOCKERS` source that lacks a tracked repo equivalent.
- Old 5.x handoff uploads superseded by `docs/HANDOFF_MASTER_CURRENT.md` and `docs/version_plans/6.0_A1_HANDOFF_MASTER.md`.
- Any pasted terminal transcript that has an equivalent committed execution report.

## 6. Minimal next actions

1. GPT advisor reviews this audit report through GitHub.
2. If accepted, create a follow-up issue to add/normalize missing canonical rule files under `docs/project_rules/`.
3. Then update `DOC_INDEX_CURRENT.md` and `AGENTS.md` in a separate explicit sync task.
4. Then clean GPT Project Sources manually after user confirmation.
5. Only after repo-source cleanup, resume Option B symlink execution issue.

## 7. Forbidden overclaims

This report does not mean:

- project source cleanup completed
- GPT Project Sources cleaned
- rule files migrated
- rule conflicts resolved
- Option B symlink execution authorized
- staging enabled
- staging verified
- A1 final acceptance complete

## 8. Final recommendation

Proceed with canonical rule-file normalization before returning to Option B symlink execution. The immediate follow-up should create or explicitly retire the missing `PROJECT_RULE_HANDOFF_SINGLE_FILE` and `PROJECT_RULE_CROSS_LAYER_BLOCKERS` concepts under a single canonical `docs/project_rules/` namespace, then update indexes in a separate reviewed task.
