import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';

class AppSection extends StatelessWidget {
  const AppSection({
    super.key,
    this.title,
    this.trailing,
    required this.child,
    this.margin,
  });

  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Padding(
      padding: margin ?? EdgeInsets.only(bottom: t.spacing.section),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ...?(trailing != null ? <Widget>[trailing!] : null),
              ],
            ),
            SizedBox(height: t.spacing.md),
          ],
          child,
        ],
      ),
    );
  }
}
