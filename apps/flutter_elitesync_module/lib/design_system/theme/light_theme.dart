import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/design_system/tokens/app_colors.dart';
import 'package:flutter_elitesync_module/design_system/tokens/app_motion.dart';
import 'package:flutter_elitesync_module/design_system/tokens/app_radius.dart';
import 'package:flutter_elitesync_module/design_system/tokens/app_spacing.dart';
import 'package:flutter_elitesync_module/design_system/tokens/app_typography.dart';

ThemeData buildLightTheme() {
  const colorScheme = ColorScheme.light(
    primary: AppColors.brandPrimary,
    secondary: AppColors.brandSecondary,
    surface: AppColors.lightSurface,
    error: AppColors.error,
  );

  final tokens = AppThemeTokens(
    pageBackground: AppColors.lightBg,
    surface: AppColors.lightSurface,
    secondarySurface: AppColors.lightSecondarySurface,
    card: AppColors.lightSurface,
    overlay: const Color(0xFFE7EDF8),
    browseBackground: AppColors.browseBg,
    browseSurface: AppColors.browseSurface,
    browseChip: AppColors.browseChip,
    browseNav: AppColors.browseNav,
    browseBorder: AppColors.browseBorder,
    textPrimary: AppColors.textPrimaryLight,
    textSecondary: AppColors.textSecondaryLight,
    textTertiary: AppColors.textTertiaryLight,
    brandPrimary: AppColors.brandPrimary,
    brandSecondary: AppColors.brandSecondary,
    brandAccent: AppColors.brandAccent,
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
    info: AppColors.info,
    spacing: const AppSpacingTokens(
      xxs: AppSpacing.xxs,
      xs: AppSpacing.xs,
      sm: AppSpacing.sm,
      md: AppSpacing.md,
      lg: AppSpacing.lg,
      xl: AppSpacing.xl,
      xxl: AppSpacing.xxl,
      xxxl: AppSpacing.xxxl,
      huge: AppSpacing.huge,
      pageHorizontal: AppSpacing.pageHorizontal,
      section: AppSpacing.section,
      sectionLarge: AppSpacing.sectionLarge,
      cardPadding: AppSpacing.cardPadding,
      cardPaddingLarge: AppSpacing.cardPaddingLarge,
    ),
    radius: const AppRadiusTokens(
      xs: AppRadius.xs,
      sm: AppRadius.sm,
      md: AppRadius.md,
      lg: AppRadius.lg,
      xl: AppRadius.xl,
      pill: AppRadius.pill,
    ),
    motionFast: AppMotion.fast,
    motionNormal: AppMotion.normal,
    motionSlow: AppMotion.slow,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.lightBg,
    textTheme:
        const TextTheme(
          displayLarge: AppTypography.display32Bold,
          displayMedium: AppTypography.display28Bold,
          headlineLarge: AppTypography.headline24SemiBold,
          headlineMedium: AppTypography.headline20SemiBold,
          titleLarge: AppTypography.title18SemiBold,
          titleMedium: AppTypography.title16SemiBold,
          bodyLarge: AppTypography.body16Regular,
          bodyMedium: AppTypography.body14Regular,
          bodySmall: AppTypography.body12Regular,
          labelSmall: AppTypography.label11Medium,
        ).apply(
          bodyColor: AppColors.textPrimaryLight,
          displayColor: AppColors.textPrimaryLight,
        ),
    extensions: <ThemeExtension<dynamic>>[tokens],
  );
}
