# EliteSync App Studio

Repo-local workflow studio for EliteSync. This plugin keeps the high-frequency operating rules close to the repository and splits them into small Codex skills.

## First-batch skills

1. `elitesync-version-start`
   - Trigger: new version plan, before implementation
   - Stop: scope, protection surfaces, and non-goals are locked

2. `elitesync-runtime-slice`
   - Trigger: approved runtime/UI implementation slice
   - Stop: the smallest safe implementation + tests are complete

3. `elitesync-evidence-closeout`
   - Trigger: implementation is done and evidence must be collected
   - Stop: screenshots, XML, regression proof, and handoff package are complete

4. `elitesync-dirty-worktree`
   - Trigger: repository is dirty and must be cleaned or prepared for a single-theme commit
   - Stop: one clean theme is staged, confirmed, and committed

5. `elitesync-cross-layer-blocker`
   - Trigger: a bug or drift may cross UI/backend/truth/release boundaries
   - Stop: blocker report is written and the next smallest safe action is identified

## Planned next batch

- `elitesync-current-entry-sync`
- `elitesync-historical-archive`

## Reserved later

- `elitesync-release-readiness`

## Operating rule

- Keep the first batch small.
- Do not create later-batch directories until they are actually needed.
- Treat `release-readiness` as reserved capacity only.
