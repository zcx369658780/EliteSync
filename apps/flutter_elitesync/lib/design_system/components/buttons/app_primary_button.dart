import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync/design_system/tokens/app_opacity.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        else ...[
          if (prefixIcon != null) ...[
            prefixIcon!,
            SizedBox(width: tokens.spacing.xs),
          ],
          Text(label, style: textStyle),
          if (suffixIcon != null) ...[
            SizedBox(width: tokens.spacing.xs),
            suffixIcon!,
          ],
        ],
      ],
    );

    return AnimatedOpacity(
      duration: tokens.motionFast,
      curve: Curves.easeOutCubic,
      opacity: _enabled ? 1.0 : AppOpacity.disabled,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 52,
          minWidth: fullWidth ? double.infinity : 0,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [tokens.brandPrimary, tokens.brandSecondary],
            ),
            borderRadius: BorderRadius.circular(tokens.radius.lg),
            boxShadow: const [
              BoxShadow(
                color: Color(0x335AA8FF),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              onTap: _enabled ? onPressed : null,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing.lg,
                  vertical: tokens.spacing.sm,
                ),
                child: Center(child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
