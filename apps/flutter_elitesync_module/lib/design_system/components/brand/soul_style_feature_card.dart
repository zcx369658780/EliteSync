import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class SoulStyleFeatureCard extends StatelessWidget {
  const SoulStyleFeatureCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.auto_awesome_rounded,
    this.compact = false,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(t.radius.lg),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? t.spacing.sm : t.spacing.cardPadding,
          vertical: compact ? t.spacing.sm : t.spacing.cardPadding,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(t.radius.lg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              t.surface.withValues(alpha: 0.90),
              t.secondarySurface.withValues(alpha: 0.86),
            ],
          ),
          border: Border.all(color: t.overlay.withValues(alpha: 0.82)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: compact ? 30 : 36,
              height: compact ? 30 : 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.brandPrimary.withValues(alpha: 0.22),
              ),
              child: Icon(icon, color: t.brandPrimary, size: compact ? 15 : 18),
            ),
            SizedBox(width: compact ? 8 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: compact ? 14 : null,
                        ),
                  ),
                  if (!compact && (subtitle ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
