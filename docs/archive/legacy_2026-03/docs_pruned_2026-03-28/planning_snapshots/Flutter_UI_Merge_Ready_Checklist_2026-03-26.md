# Flutter UI Merge-Ready Checklist (2026-03-26)

## Scope Included
- Design tokens + browse semantic mode
- 5-tab shell + center CTA
- Home/Discover/Match/Messages/Profile UI migration
- Secondary pages unified (`PageTitleRail + SectionReveal`)
- Content detail route and backend-first loading
- Home pagination + Discover tab-query loading
- Shortcut configurable route actions

## Merge Preconditions (must pass)
1. `flutter analyze` = no issues.
2. Primary tabs can switch without crash.
3. Home cards and Discover cards open content detail.
4. Login -> tabs -> detail -> back flow stable.
5. No blocking TODO in touched files.

## Known Non-Blocking Gaps (Alpha-acceptable)
1. Discover pagination state currently in page-level controller.
2. Content detail media only supports image/url basic rendering.
3. MBTI/Astro center pages are product placeholders (route-ready).
4. Backend content API may still fallback to mock data.

## Rollback Points
1. Shell rollback: `app_shell.dart` + `app_router.dart` only.
2. Home rollback: `features/home/presentation/pages/home_page.dart`.
3. Discover rollback: `features/discover/presentation/pages/discover_page.dart`.
4. Detail rollback: `features/home/presentation/pages/content_detail_page.dart`.

## Recommended Merge Strategy
1. Merge frontend UI rearchitecture branch as one cohesive PR.
2. Keep backend content API changes in separate PR.
3. After merge, execute one manual smoke pass using `Flutter_UI_Smoke_Checklist_2026-03-26.md`.
