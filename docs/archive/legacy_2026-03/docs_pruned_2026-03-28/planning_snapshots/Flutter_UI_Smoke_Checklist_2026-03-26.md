# Flutter UI Smoke Checklist (2026-03-26)

## A. Auth Entry
1. Login page loads without layout overflow.
2. Register flow reachable and back navigation works.

## B. Primary Tabs (5)
1. Home tab renders search + category tabs + content list.
2. Discover tab renders independent content stream.
3. Match tab first screen shows conclusion-first layout.
4. Messages tab list readable and entry to chat room works.
5. Profile tab opens settings/edit entries.

## C. Content Flow
1. Home cards clickable -> content detail page opens.
2. Discover cards clickable -> content detail page opens.
3. Content detail displays title/author/likes/body(summary fallback).
4. If media urls exist, image rows render.

## D. Error/Empty Handling
1. Discover error state shows retry action.
2. Discover empty state shows reload action.
3. Home empty state text is visible and non-blocking.

## E. Data Refresh/Paging
1. Home pull-to-refresh updates list.
2. Home near-bottom triggers loadMore spinner.
3. Discover pull-to-refresh updates current tab data.
4. Discover tab switch reloads content.

## F. Navigation Consistency
1. Bottom 5 tabs switch with same transition behavior.
2. Center CTA (速配) jumps to Match tab.
3. Secondary pages top title style unified.

## G. Performance Sanity
1. No obvious frame drop on tab switch.
2. No repeated full-screen loading flicker after first load.
3. No crash when rapidly switching Home/Discover tabs.

## H. Build/Static
1. `flutter analyze` = No issues.
2. debug run launches successfully on target device.
