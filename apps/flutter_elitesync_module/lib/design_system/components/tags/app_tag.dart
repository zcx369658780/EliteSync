import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

enum AppTagVariant { brand, success, warning, danger, neutral, outlined }

class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.label,
    this.variant = AppTagVariant.neutral,
  });

  final String label;
  final AppTagVariant variant;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;

    final (bg, fg, border) = switch (variant) {
      AppTagVariant.brand => (
        t.brandPrimary.withValues(alpha: 0.18),
        t.brandPrimary,
        Colors.transparent,
      ),
      AppTagVariant.success => (
        t.success.withValues(alpha: 0.16),
        t.success,
        Colors.transparent,
      ),
      AppTagVariant.warning => (
        t.warning.withValues(alpha: 0.2),
        t.warning,
        Colors.transparent,
      ),
      AppTagVariant.danger => (
        t.error.withValues(alpha: 0.16),
        t.error,
        Colors.transparent,
      ),
      AppTagVariant.neutral => (
        t.secondarySurface,
        t.textSecondary,
        Colors.transparent,
      ),
      AppTagVariant.outlined => (
        Colors.transparent,
        t.textSecondary,
        t.overlay,
      ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: t.spacing.sm,
        vertical: t.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(t.radius.pill),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
