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
