import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/components/buttons/app_ghost_button.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';

class AuthAgreementRow extends StatelessWidget {
  const AuthAgreementRow({
    super.key,
    required this.value,
    required this.onChanged,
    this.onUserAgreementTap,
    this.onPrivacyTap,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onUserAgreementTap;
  final VoidCallback? onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Text(
                '我已阅读并同意用户协议与隐私政策',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
              ),
            ),
          ],
        ),
        Row(
          children: [
            AppGhostButton(label: '用户协议', onPressed: onUserAgreementTap),
            SizedBox(width: t.spacing.xs),
            AppGhostButton(label: '隐私政策', onPressed: onPrivacyTap),
          ],
        ),
      ],
    );
  }
}
