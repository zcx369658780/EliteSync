import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync/design_system/tokens/app_colors.dart';
import 'package:flutter_elitesync/design_system/tokens/app_motion.dart';
import 'package:flutter_elitesync/design_system/tokens/app_radius.dart';
import 'package:flutter_elitesync/design_system/tokens/app_spacing.dart';
import 'package:flutter_elitesync/design_system/tokens/app_typography.dart';

ThemeData buildDarkTheme() {
  const colorScheme = ColorScheme.dark(
    primary: AppColors.brandPrimary,
    secondary: AppColors.brandSecondary,
    surface: AppColors.darkSurface,
    error: AppColors.error,
  );

  final tokens = AppThemeTokens(
    pageBackground: AppColors.darkBg,
    surface: AppColors.darkSurface,
    secondarySurface: AppColors.darkOverlay,
    card: AppColors.darkCard,
    overlay: AppColors.darkOverlay,
    browseBackground: const Color(0xFF121B2E),
    browseSurface: const Color(0xFF18233A),
    browseChip: const Color(0xFF233150),
    browseNav: const Color(0xFF17243A),
    browseBorder: const Color(0xFF2F4266),
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    textTertiary: AppColors.textTertiaryDark,
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
    scaffoldBackgroundColor: AppColors.darkBg,
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
          bodyColor: AppColors.textPrimaryDark,
          displayColor: AppColors.textPrimaryDark,
        ),
    extensions: <ThemeExtension<dynamic>>[tokens],
  );
}
