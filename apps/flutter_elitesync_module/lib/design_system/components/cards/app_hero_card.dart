import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class AppHeroCard extends StatelessWidget {
  const AppHeroCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(t.radius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            t.brandPrimary.withValues(alpha: 0.9),
            t.brandSecondary.withValues(alpha: 0.9),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x335AA8FF),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(t.spacing.cardPaddingLarge),
        child: child,
      ),
    );
  }
}
