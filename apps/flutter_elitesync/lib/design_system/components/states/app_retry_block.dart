import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';

class AppRetryBlock extends StatelessWidget {
  const AppRetryBlock({
    super.key,
    this.message = '加载失败，请稍后重试',
    this.buttonLabel = '重新加载',
    required this.onRetry,
  });

  final String message;
  final String buttonLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.cardPadding),
      decoration: BoxDecoration(
        color: t.secondarySurface,
        borderRadius: BorderRadius.circular(t.radius.md),
        border: Border.all(color: t.overlay),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
          ),
          SizedBox(height: t.spacing.md),
          AppSecondaryButton(label: buttonLabel, onPressed: onRetry),
        ],
      ),
    );
  }
}
