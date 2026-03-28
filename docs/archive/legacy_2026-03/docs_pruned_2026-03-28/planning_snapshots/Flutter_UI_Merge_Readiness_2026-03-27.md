# Flutter UI Merge Readiness (2026-03-27)

## Summary
- Overall merge status: **97%**
- Scope: Flutter new UI integrated into Android host with core features kept available.
- Current phase: **final stabilization + smoke closure**.

## Ready For Merge (Alpha)
1. Auth entry flow (login/register) stable, no overflow.
2. 5-tab shell stable (Home/Discover/Match/Messages/Profile).
3. Home and Discover card -> ContentDetail route connected.
4. ContentDetail supports backend-first fields + fallback rendering.
5. Messages list and chat room route available.
6. Profile/Settings/About/ChangePassword/Privacy pages connected.
7. Check-update flow still available from About page path.
8. Search experience stabilized:
- query state persistence behavior aligned
- history chips shown only in focused input mode
- local snapshot warm-start for Home/Discover/Messages
9. Performance baseline improved:
- keepAlive on key tabs
- list repaint boundary + cache tuning
- search filtering cached/indexed
- lite mode integrated with reduced animation/cache/scroll behavior
10. Build static checks green:
- flutter analyze PASS
- android :app:assembleDebug PASS

## Beta-Defer Items (Not Blocking Alpha Merge)
1. Full backend content system maturation (replace remaining mock fallback pathways).
2. Rich media detail (full video player / advanced media interactions).
3. Unified domain-level search service (server search + ranking) replacing current local-filter-first behavior.
4. Extended UI polish package (micro-motion catalog and typography fine tune for all secondary pages).
5. Broader automated test coverage for UI states (CI flutter test stability and snapshot tests).

## Risks & Mitigations
1. Risk: CI environment differences can still affect flutter test websocket bootstrap.
- Mitigation: keep release gate based on analyze + assemble + backend smoke, and rerun flutter tests in clean CI image.
2. Risk: backend empty responses still trigger fallback content in some flows.
- Mitigation: clearly track endpoint readiness before Beta switch.

## Release Decision (Current)
- **Alpha merge can proceed** with current code quality and build status.
- Keep Beta entry gated on backend content completeness + test depth expansion.
