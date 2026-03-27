# Flutter Token Freeze (2026-03-26)

## Frozen token files
- `lib/design_system/tokens/app_colors.dart`
- `lib/design_system/tokens/app_spacing.dart`
- `lib/design_system/tokens/app_radius.dart`
- `lib/design_system/tokens/app_motion.dart`
- `lib/design_system/tokens/app_typography.dart`
- `lib/design_system/tokens/app_shadows.dart`
- `lib/design_system/tokens/app_opacity.dart`
- `lib/design_system/tokens/app_gradients.dart`

## Frozen core values
### Color
- brandPrimary: `#5AA8FF`
- brandSecondary: `#8B7CFF`
- brandAccent: `#5FE1C8`
- darkBg: `#08101F`
- darkSurface: `#0F1B33`

### Spacing
- xxs/xs/sm/md/lg/xl = `4/8/12/16/20/24`
- pageHorizontal = `20`
- cardPadding = `16`
- cardPaddingLarge = `20`

### Radius
- xs/sm/md/lg/xl = `8/12/16/20/24`
- pill = `999`

## Freeze rules
1. Do not hardcode page-level colors, spacing, or radius in feature pages.
2. New UI components must read tokens via `context.appTokens`.
3. Any token change requires:
   - before/after screenshot comparison on Auth/Home/Profile
   - documented reason in changelog
4. Prefer creating new semantic token fields over ad-hoc constants.

## Beta-stage exception window
- Beta can add semantic tokens (e.g., match-high, risk-low), but must not break brand base colors.
