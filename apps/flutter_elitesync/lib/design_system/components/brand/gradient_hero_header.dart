import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/components/brand/constellation_hero_canvas.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';

class GradientHeroHeader extends StatelessWidget {
  const GradientHeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.height = 220,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(t.radius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            t.brandSecondary.withValues(alpha: 0.50),
            t.brandPrimary.withValues(alpha: 0.42),
            t.pageBackground,
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(t.radius.xl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ConstellationHeroCanvas(opacity: 0.9),
            Container(color: Colors.black.withValues(alpha: 0.16)),
            Padding(
              padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (trailing != null) Align(alignment: Alignment.topRight, child: trailing!),
                  const Spacer(),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: t.textSecondary),
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

