import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.title,
    required this.description,
    this.retryLabel = '重试',
    this.onRetry,
  });

  final String title;
  final String description;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(t.spacing.section),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: t.error),
            SizedBox(height: t.spacing.md),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: t.textPrimary),
            ),
            SizedBox(height: t.spacing.xs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
            ),
            if (onRetry != null) ...[
              SizedBox(height: t.spacing.lg),
              AppSecondaryButton(label: retryLabel, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
