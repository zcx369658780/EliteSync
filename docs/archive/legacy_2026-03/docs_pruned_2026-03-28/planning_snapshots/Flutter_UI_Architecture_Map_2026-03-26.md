# Flutter UI Architecture Map (2026-03-26)

## 1) Design System Layers
- `tokens`: color/spacing/radius/motion/typography.
- `theme`: `AppThemeTokens` + dark/light theme injection.
- `components/layout`: page shells and section-level composition.
- `components/brand`: navigation/header/search/tab brand atoms.
- `features/*/presentation`: page assembly + business binding.

## 2) New Semantic Modes
- `immersive`: login/branding/atmospheric scenes.
- `browse`: content-heavy shallow light UI for home/discover/messages/profile/match.

`browse` semantic tokens in `AppThemeTokens`:
- `browseBackground`
- `browseSurface`
- `browseChip`
- `browseNav`
- `browseBorder`

## 3) Core Reusable Components (New Baseline)
- `BrowseScaffold`
- `BrowseTopSearchBar`
- `CategoryTabStrip`
- `FloatingDockBottomBar` (dual mode + center CTA)
- `PageTitleRail`
- `SectionReveal`
- `MatchHeroSummaryCard`
- `MediaFeedCard`

## 4) Page Mapping (Current)
### Primary Tabs
- Home: `BrowseScaffold + Search + Tabs + Masonry feed`
- Discover: `BrowseScaffold + Search + Tabs + discover cards`
- Match: `BrowseScaffold + conclusion-first hero + CTA`
- Messages: `BrowseScaffold + Search + Tabs + conversation cards`
- Profile: `BrowseScaffold + title rail style + profile modules`

### Secondary Pages (Unified)
- Match detail: `PageTitleRail + SectionReveal`
- Match intention: `PageTitleRail + SectionReveal`
- Match countdown: `PageTitleRail + SectionReveal`
- Settings: `PageTitleRail + SectionReveal`
- Edit profile: `PageTitleRail + SectionReveal`
- Privacy settings: `PageTitleRail + SectionReveal`
- Questionnaire: `PageTitleRail + SectionReveal`
- Questionnaire result: `PageTitleRail + SectionReveal`
- Verification status: `PageTitleRail + SectionReveal`
- Verification submit: `PageTitleRail + SectionReveal`
- Chat room: `PageTitleRail + SectionReveal`

## 5) Routing / Navigation
- Bottom tabs expanded to 5 entries:
  - Home / Discover / Match / Messages / Profile
- Center CTA in bottom dock:
  - label: `速配`
  - jump target: Match tab

## 6) Legacy Component Status
- `GradientHeroHeader`: retained in DS file for compatibility; business pages migrated away.
- Old single-grammar hero-first structure replaced by browse-first grammar on primary tabs.

## 7) Next Integration Step (Content)
After UI freeze for this phase:
1. Replace remaining mock-driven feeds with backend-driven stream APIs.
2. Add content schema (`topic`, `card_type`, `media`, `author_meta`, `engagement`).
3. Keep DS components unchanged; only data adapters/pages need swapping.
