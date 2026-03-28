import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class MatchWeightBreakdown extends StatelessWidget {
  const MatchWeightBreakdown({super.key, required this.weights});
  final Map<String, int> weights;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final sorted = weights.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '分项权重',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            '用于解释综合分的贡献比例',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                ),
          ),
          SizedBox(height: t.spacing.sm),
          if (sorted.isEmpty)
            Text(
              '暂无权重数据',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                  ),
            ),
          ...sorted.map(
            (e) {
              final value = e.value.clamp(0, 100);
              final progress = value / 100.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.key,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        Text(
                          '$value%',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: t.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: t.spacing.xxs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(t.radius.pill),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: progress,
                        backgroundColor: t.browseChip,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          t.brandPrimary.withValues(alpha: 0.78),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

