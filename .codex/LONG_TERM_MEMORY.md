# Long-term Memory

## Current Baseline

- Current release: `0.04.02 / 40200`
- Current completed version: `4.3`
- `3.6` has entered planning/execution prep; stage 0, stage 1, and stage 2 are complete with exec/risk/scope/capability matrices landed and route_mode schema now implemented
- `3.6` stage 3 is complete: route explanation is a lightweight reading layer, the settings page has a route parity report, and the natal chart keeps a compact explanation card
- `3.6` stage 4 is complete: the multi-route sample set and known deviations are documented, and the capability matrix/parity report/sample-set trio is closed
- `3.6` stage 5 is complete: acceptance report, final handoff, and screenshot evidence index are landed; 3.6 is ready for formal archival
- `3.6` multi-agent evidence supplement is archived; Claude / Gemini stage conclusions are consolidated in `3.6_MULTIAGENT_EVIDENCE_SUPPLEMENT.md`
- Current active docs entry: `docs/DOC_INDEX_CURRENT.md`
- Historical materials live under `docs/archive/legacy_2026-04/`
- `3.5` phases 1-5 are now landed and externally accepted
- `3.6` is a dual-route classical/modern chart version; keep canonical truth additive-only and use `route_mode` as route context, not canonical truth
- `3.7` has entered stage 0 decomposition: exec plan, risk review, scope matrix, and advanced capability matrix are landed
- `3.7` is a push-future / advanced-reading release; keep it bounded to synastry, comparison, transit, and one minimal return capability, all as derived-only / display-only / advanced-context
- `3.7` stage 1 architecture boundary is closed locally: `route_mode` stays display-only, `pair_context` / `time_context` / `return_context` / `comparison_context` belong to advanced context, and `chart_data` remains unchanged
- Formal parallel Claude/Gemini review is currently limited by agent thread capacity; local code inspection and docs review were used to complete the stage 1 boundary conclusion, with formal traces to be added later
- `3.7` stage 2 backend scaffold is now landed: FastAPI exposes `/api/v1/profile/astro/pair`, `/transit`, and `/return`, and Laravel proxies those advanced endpoints too; all advanced outputs remain derived-only / display-only / advanced-context
- `3.7` stage 3 Flutter advanced preview is landed: `astro_advanced_profile_provider.dart`, `AstroAdvancedCapabilityCard`, and `AstroAdvancedPreviewPage` now surface pair / transit / return scaffold previews in the overview page and dedicated advanced entry, still keeping everything derived-only / display-only / advanced-context
- `3.7` stage 4 advanced demo is landed: `AstroAdvancedPreviewDemoPage` now serves as the formal stage 4 / stage 5 handoff entry, with sample matrix, route capability matrix, and preview log captured
- `3.7` stage 5 final archive is complete: `3.7_ACCEPTANCE_REPORT.md`, `3.7_HANDOFF_FINAL_20260412.md`, and `3.7_SCREENSHOT_EVIDENCE_INDEX.md` are the current handoff material
- `3.8` stage 0 decomposition is complete and the work has advanced to stage 5 final archive and passed the second顾问验收: Claude stage 1 review returned conditional pass and Gemini stage 2 review returned pass with observations; the parameter linkage region now lands on the settings page and can jump to advanced preview, calibration report / known deviations / beta regression checklist / acceptance report / handoff / screenshot index / screenshot verification note / second acceptance pack have now landed, and the formal screenshots were refreshed on 2026-04-17 to align the version center to `0.03.07 / 30700 / 0.03.07+30700`
- `3.9` has now been formally archived: the fine-grained explanation layer card is landed, preview/demo pages are wired, screenshots and review logs are in place, and Gemini acceptance returned `pass with observations`
- `3.9a` is currently in closeout execution: focus on advanced timing UI copy simplification, fine-grained explanation evidence strengthening, and regression-material thickening; execution note is `docs/version_plans/3.9A_EXECUTION_NOTE.md`
- `3.9a` acceptance materials are ready; recommended acceptance wording is `pass with observations`, with summary and checklist at `docs/version_plans/3.9A_ACCEPTANCE_SUMMARY.md` and `docs/version_plans/3.9A_ACCEPTANCE_CHECKLIST.md`
- `3.9B` regression execution is now documented: the regression report has been upgraded to an executable record and the screenshot evidence index/verification note now map directly to regression notes in `docs/version_plans/3.9B_REGRESSION_EXECUTION.md`
- `3.9C` boundary cleanup is intentionally documentation-only at this stage; runtime contracts remain untouched and the boundary note is `docs/version_plans/3.9C_BOUNDARY_NOTE.md`
- `3.9C` also has a short advisor-facing brief for quick review: `docs/version_plans/3.9C_BOUNDARY_BRIEF.md`
- `4.0` base infrastructure release has started; `4.0A` domain boundary and data skeleton are now landing, with execution notes at `docs/version_plans/4.0A_EXECUTION_NOTE.md`
- `4.0B` media baseline is in place: media config, state machine, and upload policy notes are in `docs/version_plans/4.0B_MEDIA_BASELINE.md`
- `4.0C` queue/cache minimal loop is now landed: HTTP trigger -> job -> state write-back -> cache is documented in `docs/version_plans/4.0C_PIPELINE_NOTE.md`
- `4.0D` Flutter attachment skeleton is now reserved in the chat page, with the placeholder entry documented in `docs/version_plans/4.0D_ATTACHMENT_SKELETON.md`
- `4.0E` observability / rate limiting notes are documented in `docs/version_plans/4.0E_OBSERVABILITY_NOTE.md`
- `4.0` overall acceptance summary is documented in `docs/version_plans/4.0_ACCEPTANCE_SUMMARY.md`
- `4.0` acceptance report and multi-agent review log are archived at `docs/version_plans/4.0_ACCEPTANCE_REPORT.md` and `docs/version_plans/4.0_MULTIAGENT_REVIEW_LOG.md`
- `4.0` closeout patch brought `4.0B` and `4.0D` up to the original plan's minimum complete loop; see `docs/version_plans/4.0_PATCH_CLOSEOUT_NOTE.md`
- `4.0` closeout patch used source + test verification only and did not add new Claude / Gemini / repository subagent calls
- `4.1` non-official four-dimensional personality questionnaire version has started; `4.1A` through `4.1C` finished versioned questionnaire, result closure, and history/retest flow, and `4.1D` now lightly links the questionnaire summary into home and match pages with minimal observability; see `docs/version_plans/4.1D_EXECUTION_NOTE.md`
- `4.1` closeout docs are now landed: execution note, acceptance summary, handoff note, multi-agent review log, and screenshot evidence docs are at `docs/version_plans/4.1_EXECUTION_NOTE.md`, `docs/version_plans/4.1_ACCEPTANCE_SUMMARY.md`, `docs/version_plans/4.1_HANDOFF_NOTE.md`, `docs/version_plans/4.1_MULTIAGENT_REVIEW_LOG.md`, `docs/version_plans/4.1_SCREENSHOT_EVIDENCE_INDEX.md`, and `docs/version_plans/4.1_SCREENSHOT_VERIFICATION_NOTE.md`; recommended acceptance wording is `pass with observations`
- `4.1` GPT-advisor handoff is now consolidated at `docs/version_plans/4.1_GPT_ADVISOR_HANDOFF.md`; the screenshot set is a full walkthrough (home entry, questionnaire q1/q2, post-submit state, result route, history, home linkage, match linkage, version center) and the older `0.03.07` version-center screenshot has been replaced
- `4.2` image-message version has officially passed; image selection, upload, attachment binding, message sending, bubble rendering, preview, and minimal telemetry are implemented, and the walkthrough evidence pack / acceptance summary / closeout docs are complete. Do not expand it into video / dynamic-feed / RTC territory.
- `4.3` dynamic-feed base is now formally archived: `status_posts`, `status_post_likes`, `moderation_reports.target_status_post_id`, the status author page, and the home lightweight linkage are landed; walkthrough evidence, acceptance summary, handoff, and closeout are frozen, and the work should not expand into video / community / recommendation platform territory.
- `4.4` video-message work is now formally archived; the acceptance wording is `pass with observations`, and the evidence pack / acceptance summary / handoff / closeout / multi-agent log are all in place. Keep the boundary frozen and do not expand into video feeds, RTC, calls, or media-platform rewrites.
- `4.4S` is a media-chain stability repair round: `MediaAsset.public_url` now normalizes localhost and relative paths, and Flutter media rendering adds a matching URL fallback so image/video loading is no longer dependent on stale local URLs.
- On 2026-04-19 the production backend was found to be missing the two stable smoke accounts `17094346566` / `SmokeUser` and `13772423130` / `test1`; both were restored, with current passwords `1234567aa` and `zcx658023` respectively. The questionnaire bank was reseeded and the current-week match record was recreated so `match/current` is readable again.
- Versioning rule: treat `apps/android/app/build.gradle.kts` `versionName/versionCode` as the product version source of truth, keep `/api/v1/app/version/check` and `scripts/release_android_update_aliyun.ps1` bound to that same release number, and use `PackageInfo` / Flutter module version only as auxiliary display data.
- Release sync rule: whenever the app version changes, update `apps/android/app/src/main/assets/changelog_v0.txt`, `apps/flutter_elitesync_module/assets/config/about_update_0_xx.json`, `docs/CHANGELOG.md`, and `docs/devlogs/RELEASE_LOG.md` together, then reinstall the newest host APK on emulator / device before capturing version-center screenshots.
- Never let mock / fake / placeholder success or error states leak into the formal runtime. If any UI or data flow can mislead the user, hide a real error, or keep logout/login/message/upload/recovery flows stale, remove the mock branch first and restore the real feedback chain.
- Never use local SQLite / ad hoc `.db` files as the formal runtime source of truth. Keep `*.db` / `*.sqlite` in the repo only as migrations, seeds, backups, or evidence artifacts; production and formal smoke flows must use the remote backend DB. Before any restore, reseed, or recovery operation, explicitly verify whether the target is local dev DB, remote production DB, or a snapshot backup, and never overwrite production data implicitly.
- Database changes require explicit intent. When a user asks to “fix missing accounts / matches / questionnaire data”, prefer the smallest reversible recovery path and state clearly whether the operation writes to remote production or only to a local/dev copy. Do not let debugging steps accidentally mutate the authoritative database.
- Default operating model: local workspace is frontend-only for implementation and UI validation; all backend implementation, database migrations, backups, restores, and other write operations against authoritative data are performed on the Aliyun host. This is the standard way to prevent accidental production database pollution during updates.

## Workflow Rules

- For non-trivial work, use plan-first with parallel read-only review agents before editing.
- PRs require explicit user approval and code review before creation.
- High-risk surfaces include databases, migrations, location, permissions, routing, state/cache, config, third-party SDKs, backup/restore, and version scripts.

## Product Rules

- Star-chart computation and persistence happen on the server; SVG rendering happens locally in Flutter.
- `astro_chart_preferences_v1` is local display state only and must not change canonical backend truth.
- `POST /api/v1/profile/basic` returns the recomputed `astro_profile` snapshot; front-end should prefer that snapshot first.
- Android host bootstrap must inject `elitesync_api_base_url` and `elitesync_ws_base_url`.
- `3.6` introduces `route_mode` and route capability matrices; route selection must remain additive and must not overwrite canonical truth fields.
- `route_mode` is now returned by FastAPI / Laravel astro endpoints as display context and is also recorded in `metadata.route_context`; old cache entries remain readable.
- Route explanation and parity reports must remain derived-only / display-only and must never write back canonical truth.
- The multi-route sample set and known deviations must stay aligned with the capability matrix; derived differences must not be mislabeled as algorithm bugs.
- Stage 5 archive artifacts for 3.6 are complete and should be treated as the baseline for any later 3.7 work
- The multi-agent evidence supplement is the canonical reference for 3.6 Claude / Gemini review summaries

## External Tooling

- Gemini CLI default model in this repo is `gemini-3-flash-preview`, stored in `~/.gemini/settings.json` under `model.name`.
- Direct PowerShell usage is now the default workflow for both tools:
  - `claude -p "<prompt>" --output-format text --tools ""`
  - `gemini -p "<prompt>" --output-format text --approval-mode plan`
  - `gemini -p "<prompt>" --output-format json --approval-mode plan`
- `claude` should resolve to `C:\Users\zcxve\.local\bin\claude.exe`.
- Use `Get-Command claude` / `Get-Command gemini` to confirm the current direct entrypoints.
- Claude-mcp / Codex-mcp are no longer default entrypoints in this workspace.
- Gemini web app may be used only for ad hoc exploration; acceptance/review work must default back to PowerShell `gemini` CLI.
- If Claude fails because of errors, budget, quota, or availability, or if Gemini fails because of quota, limit, or availability, use an authorized subagent to take over the corresponding review, acceptance, or archive-support duties instead of stalling the task.
- The same Claude/Gemini fallback applies to 4.0 and later work packages: if either tool is unavailable, switch an authorized subagent into that role immediately rather than pausing the infrastructure rollout.

## Pointers

- Current project memory: `docs/project_memory.md`
- Current version plans: `docs/version_plans/README.md`
- 3.x closeout handoff: `docs/HANDOFF_3X_CLOSEOUT_20260417.md`
- Current runbooks: `docs/runbooks/README.md`
- Reference material: `docs/reference/README.md`
- Licenses: `docs/licenses/README.md`
