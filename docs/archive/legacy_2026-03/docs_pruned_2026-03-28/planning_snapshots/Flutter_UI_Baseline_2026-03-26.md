# Flutter UI Baseline (2026-03-26)

## Scope
- Client track: `apps/flutter_elitesync`
- Baseline purpose: lock current visual language before Beta-stage enhancements.

## Primary pages covered
- Auth: login / register
- Home: hero + shortcut grid + feed cards
- Match: countdown / result / detail / intention
- Chat: conversation list / chat room
- Profile: profile / edit / settings / privacy

## Key visual system
- Floating dock bottom bar
- Gradient hero header with constellation canvas
- Glass-style profile header
- Soul-style feature cards
- Brand action pill chip
- Unified transition: fade + slight slide

## Baseline component map
- `design_system/components/brand/floating_dock_bottom_bar.dart`
- `design_system/components/brand/gradient_hero_header.dart`
- `design_system/components/brand/constellation_hero_canvas.dart`
- `design_system/components/brand/profile_glass_header_card.dart`
- `design_system/components/brand/soul_style_feature_card.dart`
- `design_system/components/brand/brand_action_pill.dart`

## Route transition baseline
- Implemented in `app/router/app_router.dart`
- Transition policy:
  - enter: fade in + vertical slide (0.05 -> 0)
  - duration: 360ms
  - reverse: 260ms

## Acceptance checklist (visual)
- Auth has immersive star background and glass card style
- Home and Profile are no longer list-template style
- Match/Chat share same hero-card language
- Settings and Privacy use grouped card layout
- Bottom bar is floating-dock style on all shell tabs

## Notes
- This baseline is intentionally stable for upcoming algorithm and backend coupling work.
- Next visual changes should be incremental and token-driven.
