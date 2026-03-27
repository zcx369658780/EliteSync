import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class AppInfoCard extends StatelessWidget {
  const AppInfoCard({
    super.key,
    required this.title,
    required this.description,
    this.icon,
  });

  final String title;
  final String description;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      decoration: BoxDecoration(
        color: t.secondarySurface,
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: t.overlay),
      ),
      child: Padding(
        padding: EdgeInsets.all(t.spacing.cardPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[icon!, SizedBox(width: t.spacing.md)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary,
                    ),
                  ),
                  SizedBox(height: t.spacing.xs),
                  Text(
                    description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
