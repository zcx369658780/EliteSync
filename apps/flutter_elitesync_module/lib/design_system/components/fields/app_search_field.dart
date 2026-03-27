import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/fields/app_text_field.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hint = '搜索',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hint: hint,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onClear: onClear,
      prefixIcon: const Icon(Icons.search_rounded),
      textInputAction: TextInputAction.search,
    );
  }
}
