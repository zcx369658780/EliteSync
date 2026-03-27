import 'package:flutter/material.dart';

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.pageBackground,
    required this.surface,
    required this.secondarySurface,
    required this.card,
    required this.overlay,
    required this.browseBackground,
    required this.browseSurface,
    required this.browseChip,
    required this.browseNav,
    required this.browseBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.brandPrimary,
    required this.brandSecondary,
    required this.brandAccent,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.spacing,
    required this.radius,
    required this.motionFast,
    required this.motionNormal,
    required this.motionSlow,
  });

  final Color pageBackground;
  final Color surface;
  final Color secondarySurface;
  final Color card;
  final Color overlay;
  final Color browseBackground;
  final Color browseSurface;
  final Color browseChip;
  final Color browseNav;
  final Color browseBorder;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  final Color brandPrimary;
  final Color brandSecondary;
  final Color brandAccent;

  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  final AppSpacingTokens spacing;
  final AppRadiusTokens radius;

  final Duration motionFast;
  final Duration motionNormal;
  final Duration motionSlow;

  @override
  AppThemeTokens copyWith({
    Color? pageBackground,
    Color? surface,
    Color? secondarySurface,
    Color? card,
    Color? overlay,
    Color? browseBackground,
    Color? browseSurface,
    Color? browseChip,
    Color? browseNav,
    Color? browseBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? brandPrimary,
    Color? brandSecondary,
    Color? brandAccent,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    AppSpacingTokens? spacing,
    AppRadiusTokens? radius,
    Duration? motionFast,
    Duration? motionNormal,
    Duration? motionSlow,
  }) {
    return AppThemeTokens(
      pageBackground: pageBackground ?? this.pageBackground,
      surface: surface ?? this.surface,
      secondarySurface: secondarySurface ?? this.secondarySurface,
      card: card ?? this.card,
      overlay: overlay ?? this.overlay,
      browseBackground: browseBackground ?? this.browseBackground,
      browseSurface: browseSurface ?? this.browseSurface,
      browseChip: browseChip ?? this.browseChip,
      browseNav: browseNav ?? this.browseNav,
      browseBorder: browseBorder ?? this.browseBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      brandAccent: brandAccent ?? this.brandAccent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      motionFast: motionFast ?? this.motionFast,
      motionNormal: motionNormal ?? this.motionNormal,
      motionSlow: motionSlow ?? this.motionSlow,
    );
  }

  @override
  ThemeExtension<AppThemeTokens> lerp(
    covariant ThemeExtension<AppThemeTokens>? other,
    double t,
  ) {
    if (other is! AppThemeTokens) return this;

    return AppThemeTokens(
      pageBackground:
          Color.lerp(pageBackground, other.pageBackground, t) ?? pageBackground,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      secondarySurface:
          Color.lerp(secondarySurface, other.secondarySurface, t) ??
          secondarySurface,
      card: Color.lerp(card, other.card, t) ?? card,
      overlay: Color.lerp(overlay, other.overlay, t) ?? overlay,
      browseBackground:
          Color.lerp(browseBackground, other.browseBackground, t) ??
          browseBackground,
      browseSurface:
          Color.lerp(browseSurface, other.browseSurface, t) ?? browseSurface,
      browseChip: Color.lerp(browseChip, other.browseChip, t) ?? browseChip,
      browseNav: Color.lerp(browseNav, other.browseNav, t) ?? browseNav,
      browseBorder:
          Color.lerp(browseBorder, other.browseBorder, t) ?? browseBorder,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textTertiary:
          Color.lerp(textTertiary, other.textTertiary, t) ?? textTertiary,
      brandPrimary:
          Color.lerp(brandPrimary, other.brandPrimary, t) ?? brandPrimary,
      brandSecondary:
          Color.lerp(brandSecondary, other.brandSecondary, t) ?? brandSecondary,
      brandAccent: Color.lerp(brandAccent, other.brandAccent, t) ?? brandAccent,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      error: Color.lerp(error, other.error, t) ?? error,
      info: Color.lerp(info, other.info, t) ?? info,
      spacing: AppSpacingTokens.lerp(spacing, other.spacing, t),
      radius: AppRadiusTokens.lerp(radius, other.radius, t),
      motionFast: t < 0.5 ? motionFast : other.motionFast,
      motionNormal: t < 0.5 ? motionNormal : other.motionNormal,
      motionSlow: t < 0.5 ? motionSlow : other.motionSlow,
    );
  }
}

@immutable
class AppSpacingTokens {
  const AppSpacingTokens({
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.xxxl,
    required this.huge,
    required this.pageHorizontal,
    required this.section,
    required this.sectionLarge,
    required this.cardPadding,
    required this.cardPaddingLarge,
  });

  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;
  final double huge;
  final double pageHorizontal;
  final double section;
  final double sectionLarge;
  final double cardPadding;
  final double cardPaddingLarge;

  static AppSpacingTokens lerp(
    AppSpacingTokens a,
    AppSpacingTokens b,
    double t,
  ) {
    double l(double x, double y) => x + (y - x) * t;
    return AppSpacingTokens(
      xxs: l(a.xxs, b.xxs),
      xs: l(a.xs, b.xs),
      sm: l(a.sm, b.sm),
      md: l(a.md, b.md),
      lg: l(a.lg, b.lg),
      xl: l(a.xl, b.xl),
      xxl: l(a.xxl, b.xxl),
      xxxl: l(a.xxxl, b.xxxl),
      huge: l(a.huge, b.huge),
      pageHorizontal: l(a.pageHorizontal, b.pageHorizontal),
      section: l(a.section, b.section),
      sectionLarge: l(a.sectionLarge, b.sectionLarge),
      cardPadding: l(a.cardPadding, b.cardPadding),
      cardPaddingLarge: l(a.cardPaddingLarge, b.cardPaddingLarge),
    );
  }
}

@immutable
class AppRadiusTokens {
  const AppRadiusTokens({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.pill,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double pill;

  static AppRadiusTokens lerp(AppRadiusTokens a, AppRadiusTokens b, double t) {
    double l(double x, double y) => x + (y - x) * t;
    return AppRadiusTokens(
      xs: l(a.xs, b.xs),
      sm: l(a.sm, b.sm),
      md: l(a.md, b.md),
      lg: l(a.lg, b.lg),
      xl: l(a.xl, b.xl),
      pill: l(a.pill, b.pill),
    );
  }
}

extension AppThemeX on BuildContext {
  AppThemeTokens get appTokens => Theme.of(this).extension<AppThemeTokens>()!;
}
