# Long-term Memory

## Current Baseline

- Current release: `0.03.09 / 30900`
- Current completed version: `3.5`
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

## Pointers

- Current project memory: `docs/project_memory.md`
- Current version plans: `docs/version_plans/README.md`
- Current runbooks: `docs/runbooks/README.md`
- Reference material: `docs/reference/README.md`
- Licenses: `docs/licenses/README.md`
