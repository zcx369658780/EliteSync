import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/design_system/tokens/app_opacity.dart';

enum AppSecondaryButtonStyle { soft, outline }

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
    this.style = AppSecondaryButtonStyle.soft,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final AppSecondaryButtonStyle style;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final textColor = tokens.textPrimary;

    final bgColor = switch (style) {
      AppSecondaryButtonStyle.soft => tokens.secondarySurface,
      AppSecondaryButtonStyle.outline => Colors.transparent,
    };
    final borderColor = switch (style) {
      AppSecondaryButtonStyle.soft => Colors.transparent,
      AppSecondaryButtonStyle.outline => tokens.overlay,
    };

    return AnimatedOpacity(
      duration: tokens.motionFast,
      opacity: _enabled ? 1 : AppOpacity.disabled,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 48,
          minWidth: fullWidth ? double.infinity : 0,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(tokens.radius.md),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(tokens.radius.md),
              onTap: _enabled ? onPressed : null,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing.lg,
                  vertical: tokens.spacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: textColor,
                        ),
                      )
                    else ...[
                      if (prefixIcon != null) ...[
                        prefixIcon!,
                        SizedBox(width: tokens.spacing.xs),
                      ],
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (suffixIcon != null) ...[
                        SizedBox(width: tokens.spacing.xs),
                        suffixIcon!,
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
