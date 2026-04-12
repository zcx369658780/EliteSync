import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.readOnly = false,
    this.enabled = true,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.onClear,
    this.inputFormatters,
    this.obscureText = false,
    this.minLines,
    this.maxLines,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool readOnly;
  final bool enabled;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onClear;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final int? minLines;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final hasError = (errorText ?? '').isNotEmpty;

    InputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(t.radius.md),
      borderSide: BorderSide(color: color),
    );

    final trailing =
        suffixIcon ??
        (onClear != null
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: enabled ? onClear : null,
              )
            : null);

    final resolvedMinLines = obscureText ? 1 : minLines;
    final resolvedMaxLines = obscureText ? 1 : maxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: t.spacing.xs),
        ],
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          minLines: resolvedMinLines,
          maxLines: resolvedMaxLines,
          readOnly: readOnly,
          enabled: enabled,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: t.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: t.textTertiary),
            helperText: helperText,
            errorText: errorText,
            counterText: '',
            filled: true,
            fillColor: t.surface,
            prefixIcon: prefixIcon,
            suffixIcon: trailing,
            contentPadding: EdgeInsets.symmetric(
              horizontal: t.spacing.md,
              vertical: t.spacing.md,
            ),
            border: border(t.overlay),
            enabledBorder: border(t.overlay),
            focusedBorder: border(t.brandPrimary),
            errorBorder: border(t.error),
            focusedErrorBorder: border(t.error),
            helperStyle: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
            errorStyle: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: t.error),
          ),
        ),
        if (!hasError && helperText == null) SizedBox(height: t.spacing.xs),
      ],
    );
  }
}
