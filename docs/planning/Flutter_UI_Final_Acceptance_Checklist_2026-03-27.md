# Flutter UI Final Acceptance Checklist (2026-03-27)

## Current Merge Progress
- UI + Android host merge progress: **97%**
- Status: **Feature complete for Alpha, pending final manual acceptance pass**

## Goal
Provide one executable checklist for final manual verification before branch freeze/merge.

## A. Auth & Entry
1. Login page opens without overflow or input lag spikes.
2. Register page opens and back navigation is stable.
3. Login success lands on Home tab (not blank/loading loop).

## B. Main Shell (5 Tabs)
1. Bottom tabs switch correctly: Home / Discover / Match / Messages / Profile.
2. Center CTA jumps to Match tab.
3. Repeated rapid tab switching does not crash.
4. Tab content retains context (keepAlive active):
- Home search state preserved
- Discover tab index preserved
- Messages filters/search preserved

## C. Search & Interaction
1. Home search:
- typing is smooth
- result filtering updates
- clear button works
- history chips show only when input focused and query empty
2. Discover search:
- same behavior as Home
3. Messages search:
- same behavior as Home
- unread filter + tab filter both work

## D. List & Scroll Behavior
1. Home list:
- pull-to-refresh works
- near-bottom loadMore works
2. Discover list:
- pull-to-refresh works
- tab switch restores per-tab scroll position
3. Messages list:
- pull-to-refresh works
- tab switch restores per-tab scroll position
4. Chat room:
- message send works
- manual refresh works
- draft text persists when leaving and returning

## E. Detail & Route Links
1. Home card opens ContentDetail.
2. Discover card opens ContentDetail.
3. ContentDetail shows title/author/likes/body fallback correctly.
4. Non-image media URL can open externally.

## F. Profile & Settings
1. Profile page loads basic info and tag summaries.
2. Settings page:
- logout works
- password change route opens
- privacy settings route opens
- about/update route opens
3. Performance mode switch:
- ON: animations/cache/preload reduced
- OFF: normal behavior restored

## G. Error/Empty States
1. Discover error state includes "重新加载" action.
2. Messages error state includes "重新加载" action.
3. Home/Discover/Messages empty states have clear action guidance.

## H. Performance Quick Check
1. First tab open latency acceptable (prewarm path works when lite mode OFF).
2. Search typing no obvious stutter under normal data size.
3. No visible full-screen flicker after cached snapshot warm-start.

## I. Build Gate
1. `flutter analyze` -> PASS
2. `:app:assembleDebug` -> PASS

## Beta-Defer (Not Blocking This Merge)
1. Full backend content coverage replacing remaining fallback data.
2. Rich media player support in content detail.
3. Wider UI regression automation and screenshot testing.

## Final Decision Rule
- If A~I all pass => this UI merge is release-ready for current Alpha branch.
- If failures only occur in Beta-Defer scope => merge still allowed, but track issue in beta backlog.
