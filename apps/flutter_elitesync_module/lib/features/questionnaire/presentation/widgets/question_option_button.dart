import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class QuestionOptionButton extends StatelessWidget {
  const QuestionOptionButton({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AnimatedContainer(
      duration: t.motionFast,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? t.brandPrimary.withValues(alpha: 0.18)
            : t.secondarySurface,
        borderRadius: BorderRadius.circular(t.radius.md),
        border: Border.all(
          color: selected ? t.brandPrimary : t.overlay,
          width: selected ? 1.4 : 1,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(t.radius.md),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: t.spacing.md,
              vertical: t.spacing.md,
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: selected ? t.brandPrimary : t.textTertiary,
                ),
                SizedBox(width: t.spacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected ? t.textPrimary : t.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
