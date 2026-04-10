# Long-term Memory

## 2026-03-28 Open-source verification rule (from user)
- Before handing any advisor-proposed open-source repository to user as implementation dependency, Codex must locally verify:
  1) repository availability (URL reachable/repo exists and active enough),
  2) license type and commercial compatibility,
  3) whether the suggested usage in our project scope is license-compliant.
- If verification is incomplete, label recommendation as "unverified" and do not treat it as final dependency advice.

## 2026-03-29 PR + Code Review workflow rule (from user)
- Code Review is required before each PR.
- PR creation must have explicit user approval first.
- Execution order must be:
  1) request/obtain user approval for PR,
  2) run Code Review,
  3) create PR.

## 2026-03-29 License tracking rule (from user)
- In project root, keep a continuously updated license tracker file for all app dependencies:
  - `D:\EliteSync\LICENSE_DEPENDENCY_STATUS.md`
- This tracker must explicitly mark which libraries:
  1) can be used in commercial closed-source distribution,
  2) require additional authorization/commercial license,
  3) are open-source but still pending verification.
- Any dependency addition or version upgrade must update this tracker in the same task.

## 2026-04-01 Multi-subagent safe development workflow (from user)
- For any non-trivial task, use a plan-first workflow before touching code.
- Plan-first must run these read-only agents in parallel:
  1) `dependency-mapper`
  2) `risk-reviewer`
  3) `test-planner`
  4) `architecture-guardian`
- After implementation, run these acceptance agents in parallel:
  1) `acceptance-auditor`
  2) `regression-sentinel`
  3) `test-planner` as coverage recheck
  4) `architecture-guardian` as boundary recheck
- High-risk surfaces must be protected by plan, rollback, and minimal regression checks:
  - databases / migrations / initialization
  - maps / location / permissions / geocoding
  - routing / navigation / lifecycle
  - state management / cache / session
  - config / environment / third-party SDKs
  - backup / restore / version scripts
- If a task needs PR, run Code Review first and only create the PR after explicit user approval.

## 2026-04-10 Gemini cost-control note (from user)
- Gemini CLI default model in this repo is `gemini-2.5-flash`.
- For UI/acceptance work, keep screenshot inputs small when possible; `1024x1024` or below is enough for layout review.
- For cost tracking, inspect `response.usage_metadata` and compute `prompt_token_count` / `candidates_token_count` / `total_token_count` against the active pricing before estimating spend.

## 2026-04-10 EliteSync 3.2 final closure (from working session)
- Match result cache now preserves `matchId` and `partnerId`, so offline/remote-failure fallback keeps first-chat entry data intact.
- Admin disable now synchronizes `is_match_eligible`, `is_square_visible`, and `exclude_from_metrics` with the batch tooling.
- Status square author labeling now prefers backend `is_synthetic` truth source before falling back to account type.
- `astro_chart_preferences_v1` now covers both summary visibility and natal-chart element visibility; the chart-element toggles are further split into sign grid/labels, house lines/numbers, aspect lines, planet connectors/markers/labels, and center title/subtitle/place. They only affect Flutter-local SVG rendering and must not be treated as backend truth.
- The chart settings page exposes a local "restore defaults" action that resets the above prefs back to recommended values for validation and regression checks; it still must not alter backend truth.
- The chart settings page also exposes local presets `full / balanced / minimal` for quicker validation of chart readability; presets remain app-local SVG/display preferences only.
- Final handoff entry is `docs/version_plans/3.2_HANDOFF_FINAL_20260410.md`; paired evidence is `docs/version_plans/3.2_ACCEPTANCE_REPORT.md` plus screenshots `3_2_home.png`, `3_2_match_result.png`, `3_2_admin_users.png`, `3_2_status_square.png`, `_chat_room.png`.
- Terminal supplement is `docs/version_plans/3.2_TERMINAL_EVIDENCE_PACK_20260410.md`; it records the 1000 synthetic default pool, the 10000 isolated capability run, the overlapping Admin stats rule, and the astro/bazi sample evidence.

## 2026-04-10 Astro rendering split (from working session)
- Server-side astrology flow now stops at computation and persistence: Python returns `chart_data` / planets / houses / aspects, and Flutter builds the SVG locally from `chart_data`.
- `chart_data` is cached into `private_natal_chart`, so the backend chart endpoint can return from cache without forcing a repeated compute call.
- The previous server-generated natal chart SVG path is legacy-only and should not be reintroduced; if a chart needs to be rendered, do it in the app layer.

## 2026-04-10 Android host bootstrap fix (from working session)
- The Android host `MainActivity` must inject `elitesync_api_base_url` and `elitesync_ws_base_url` into the Flutter bootstrap intent before the Flutter module starts.
- This keeps the embedded Flutter app aligned with the host `BuildConfig` and avoids falling back to the implicit `slowdate.top` base URL when bootstrap extras are missing.
- For login timeout investigations, verify the installed APK is the host app build and confirm the bootstrap extras are present before assuming the backend is slow.
