# EliteSync Project Rule: Claude Horizontal Review Artifacts

## 0. One-line conclusion

Claude horizontal review and visual/blind comparison must produce text-first artifacts in repo docs; key screenshots are referenced and only uploaded when necessary.

## 1. Purpose

6.0+ user-visible feature work must preserve Claude horizontal review quality without turning GitHub into a large image repository.

## 2. Standard Claude artifact set

Default artifact files for a version / feature:

```text
docs/version_plans/CLAUDE_<VERSION>_<FEATURE>_HORIZONTAL_REVIEW.md
docs/version_plans/CLAUDE_<VERSION>_<FEATURE>_SOUL_COMPARISON.md
docs/version_plans/CLAUDE_<VERSION>_<FEATURE>_CECE_COMPARISON.md
docs/version_plans/CLAUDE_<VERSION>_<FEATURE>_ACTION_MATRIX.md
```

If visual blind review is used:

```text
docs/version_plans/CLAUDE_<VERSION>_<FEATURE>_VISUAL_BLIND_REVIEW.md
```

## 3. Review scope

Claude may compare EliteSync against Soul and CECE / 测测 for product completeness, UI/IA clarity, explanation quality, and user-visible gaps.

Claude must not perform:

- security testing
- reverse engineering
- packet capture
- interface analysis
- permission bypass
- payment / consulting / real transaction flows
- private data extraction

## 4. Visual blind review policy

If needed:

1. Codex / Claude prepares A/B/C screenshot groups.
2. Claude evaluates without app identity where practical.
3. Report records blind conclusions.
4. Then reveal mapping: A/B/C = EliteSync / Soul / CECE or other.
5. Action Matrix states what EliteSync should adopt, avoid, or defer.

Ordinary screenshots should remain local or user-held unless they are critical.

## 5. Accepted verdicts

Use:

```text
pass
pass with observations
conditional pass
fail
```

Only `pass` or `pass with observations` can proceed to GPT final acceptance unless GPT advisor explicitly accepts a narrower exception.

## 6. Relationship to GPT final acceptance

Claude review is a gate, not the final authority. GPT advisor performs final acceptance after reviewing implementation reports, evidence, Claude reports, Action Matrix, and any user-provided key screenshots.
