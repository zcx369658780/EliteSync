import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';

class BrowseTopSearchBar extends StatelessWidget {
  const BrowseTopSearchBar({
    super.key,
    required this.hint,
    this.onTap,
    this.onRightActionTap,
    this.rightIcon = Icons.tune_rounded,
  });

  final String hint;
  final VoidCallback? onTap;
  final VoidCallback? onRightActionTap;
  final IconData rightIcon;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Row(
      children: [
        Expanded(
          child: Material(
            color: t.browseSurface,
            borderRadius: BorderRadius.circular(t.radius.pill),
            child: InkWell(
              borderRadius: BorderRadius.circular(t.radius.pill),
              onTap: onTap,
              child: Container(
                height: 44,
                padding: EdgeInsets.symmetric(horizontal: t.spacing.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(t.radius.pill),
                  border: Border.all(color: t.browseBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, size: 20, color: t.textTertiary),
                    SizedBox(width: t.spacing.xs),
                    Expanded(
                      child: Text(
                        hint,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: t.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: t.spacing.xs),
        Material(
          color: t.browseNav,
          borderRadius: BorderRadius.circular(t.radius.pill),
          child: InkWell(
            borderRadius: BorderRadius.circular(t.radius.pill),
            onTap: onRightActionTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(t.radius.pill),
                border: Border.all(color: t.browseBorder),
              ),
              child: Icon(rightIcon, size: 20, color: t.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}
