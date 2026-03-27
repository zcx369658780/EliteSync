import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class BrowseTopSearchBar extends StatelessWidget {
  const BrowseTopSearchBar({
    super.key,
    required this.hint,
    this.editable = false,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onTap,
    this.onRightActionTap,
    this.rightIcon = Icons.tune_rounded,
  });

  final String hint;
  final bool editable;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
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
              onTap: editable ? null : onTap,
              child: Container(
                height: 44,
                padding: EdgeInsets.symmetric(horizontal: t.spacing.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(t.radius.pill),
                  border: Border.all(color: t.browseBorder),
                ),
                child: editable
                    ? Row(
                        children: [
                          Icon(Icons.search_rounded, size: 20, color: t.textTertiary),
                          SizedBox(width: t.spacing.xs),
                          Expanded(
                            child: TextField(
                              controller: controller,
                              focusNode: focusNode,
                              onChanged: onChanged,
                              onSubmitted: onSubmitted,
                              textInputAction: TextInputAction.search,
                              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                              decoration: InputDecoration(
                                hintText: hint,
                                isCollapsed: true,
                                border: InputBorder.none,
                                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: t.textTertiary,
                                    ),
                              ),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: t.textPrimary,
                                  ),
                            ),
                          ),
                          if ((controller?.text ?? '').isNotEmpty)
                            GestureDetector(
                              onTap: onClear,
                              child: Icon(Icons.close_rounded, size: 18, color: t.textTertiary),
                            ),
                        ],
                      )
                    : Row(
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
