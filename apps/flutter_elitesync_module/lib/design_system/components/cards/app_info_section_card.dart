import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class AppInfoSectionCard extends StatelessWidget {
  const AppInfoSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    required this.child,
    this.fullWidth = false,
    this.isFullWidth,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget child;
  final bool fullWidth;
  final bool? isFullWidth;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final useFullWidth = fullWidth || (isFullWidth ?? false);
    final useAggressiveFullWidth = useFullWidth;
    final horizontalPadding = useFullWidth ? 0.0 : t.spacing.cardPaddingLarge;
    return Container(
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(
          useAggressiveFullWidth ? 0 : t.radius.lg,
        ),
        border: useAggressiveFullWidth
            ? Border.all(color: Colors.transparent, width: 0)
            : Border.all(color: t.browseBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: t.spacing.cardPaddingLarge,
              bottom: t.spacing.sm,
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
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                  ),
                ],
                SizedBox(height: t.spacing.sm),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              bottom: t.spacing.cardPaddingLarge,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
