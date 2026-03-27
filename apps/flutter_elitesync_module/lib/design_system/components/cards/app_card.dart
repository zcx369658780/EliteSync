import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.border,
    this.shadow,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Border? border;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? t.card,
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: border,
        boxShadow: shadow,
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(t.spacing.cardPadding),
        child: child,
      ),
    );
  }
}
