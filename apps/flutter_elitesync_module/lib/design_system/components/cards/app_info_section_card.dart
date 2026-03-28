import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class AppInfoSectionCard extends StatelessWidget {
  const AppInfoSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: t.browseBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 18, color: t.brandPrimary),
                SizedBox(width: t.spacing.xs),
              ],
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          if ((subtitle ?? '').trim().isNotEmpty) ...[
            SizedBox(height: t.spacing.xxs),
            Text(
              subtitle!.trim(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                  ),
            ),
          ],
          SizedBox(height: t.spacing.sm),
          child,
        ],
      ),
    );
  }
}

