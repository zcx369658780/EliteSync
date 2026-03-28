import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    super.key,
    required this.label,
    this.onTap,
    this.leading,
    this.selected = false,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget? leading;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final bg = selected ? t.brandPrimary.withValues(alpha: 0.18) : t.browseChip;
    final border = selected ? t.brandPrimary.withValues(alpha: 0.45) : t.browseBorder;
    final fg = selected ? t.brandPrimary : t.textSecondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(t.radius.pill),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: t.spacing.sm, vertical: t.spacing.xs),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(t.radius.pill),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                IconTheme(
                  data: IconThemeData(size: 14, color: fg),
                  child: leading!,
                ),
                SizedBox(width: t.spacing.xxs),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
