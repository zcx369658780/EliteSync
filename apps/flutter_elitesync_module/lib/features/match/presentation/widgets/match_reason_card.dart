import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class MatchReasonCard extends StatelessWidget {
  const MatchReasonCard({super.key, required this.reason});
  final String reason;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final isRisk = reason.contains('[风险]');
    final isMatch = reason.contains('[匹配]');
    final color = isRisk ? t.error : (isMatch ? t.success : t.textSecondary);
    final icon = isRisk
        ? Icons.warning_amber_rounded
        : (isMatch ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded);
    final cleaned = reason.replaceAll('[风险]', '').replaceAll('[匹配]', '').trim();

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              cleaned,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: t.textPrimary,
                    height: 1.45,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
