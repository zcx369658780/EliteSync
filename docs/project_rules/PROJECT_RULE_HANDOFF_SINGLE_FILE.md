# EliteSync Project Rule: Handoff Single File

## 0. One-line conclusion

Each active version must have one default handoff entry, and all supporting evidence must point to that entry instead of creating parallel handoff entrances.

## 1. Purpose

This rule prevents handoff sprawl, conflicting entry points, and stale GPT Project Source uploads. It keeps the repo-local handoff chain readable for GPT advisor, Codex, Claude, Gemini, and the user.

## 2. Canonical handoff hierarchy

Current convention:

```text
docs/HANDOFF_MASTER_CURRENT.md                       repo-level current pointer only
docs/version_plans/<VERSION>_HANDOFF_MASTER.md       version-level main handoff
docs/version_plans/*                                 version-specific supporting evidence
docs/archive/*                                       historical material only
```

For current A1:

```text
docs/HANDOFF_MASTER_CURRENT.md -> docs/version_plans/6.0_A1_HANDOFF_MASTER.md
```

Future references to this rule should use:

```text
docs/project_rules/PROJECT_RULE_HANDOFF_SINGLE_FILE.md
```

## 3. Rules

- Do not create multiple competing current handoff files.
- Do not use root-level temporary handoff files as default current entry.
- Do not replace `docs/HANDOFF_MASTER_CURRENT.md` with a long version handoff.
- Do not claim a supporting evidence package is the current main handoff.
- If a handoff update is needed, update the version handoff and then update the pointer only in a separate explicit sync task.
- Historical handoff files should be archived or referenced, not promoted.

## 4. Current allowed handoff update pattern

1. Prepare version-specific evidence or report.
2. Commit/push it as supporting evidence.
3. Only in a separate explicit sync issue, update `docs/HANDOFF_MASTER_CURRENT.md`, `DOC_INDEX_CURRENT.md`, and relevant current docs.
4. GPT advisor reviews via GitHub.

## 5. Forbidden overclaims

A handoff file must not imply:

- final acceptance complete unless accepted by GPT advisor
- production ready unless explicitly accepted
- staging enabled / verified unless reload and endpoint verification have both been separately authorized and completed
- A2 start unless authorized

## 6. Current A1 note

- current active version: 6.0-A1
- current stage: Option B / SSH Tunnel staging preparation
- Option B symlink execution remains paused
- no reload / endpoint verification / staging request is authorized by this rule file
