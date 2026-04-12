import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/fields/app_text_field.dart';

class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.onChanged,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      errorText: widget.errorText,
      helperText: widget.helperText,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      suffixIcon: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        ),
        onPressed: widget.enabled
            ? () {
                setState(() {
                  _obscure = !_obscure;
                });
              }
            : null,
      ),
      keyboardType: TextInputType.visiblePassword,
      obscureText: _obscure,
      maxLines: 1,
    );
  }
}
