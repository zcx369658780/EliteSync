import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';

class WuXingEnergyBar extends StatelessWidget {
  const WuXingEnergyBar({
    super.key,
    required this.wuXing,
  });

  final Map<String, dynamic> wuXing;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final items = _buildItems(wuXing);
    final total = items.fold<double>(0, (sum, item) => sum + item.value);

    return Container(
      padding: EdgeInsets.all(t.spacing.sm),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: t.browseBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '五行能量分布',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            '以服务端五行结果为准，数值按总量折算为百分比',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.25,
                ),
          ),
          SizedBox(height: t.spacing.sm),
          ...items.map((item) {
            final percent = total <= 0 ? 0.0 : (item.value / total * 100);
            return Padding(
              padding: EdgeInsets.only(bottom: t.spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 34,
                        child: Text(
                          item.label,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: item.color,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${percent.toStringAsFixed(0)}%',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: t.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: t.spacing.xxs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(t.radius.pill),
                    child: Stack(
                      children: [
                        Container(
                          height: 10,
                          color: item.color.withValues(alpha: 0.10),
                        ),
                        FractionallySizedBox(
                          widthFactor: total <= 0 ? 0 : (percent / 100).clamp(0.0, 1.0),
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  item.color.withValues(alpha: 0.68),
                                  item.color,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _WuXingItem {
  const _WuXingItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

List<_WuXingItem> _buildItems(Map<String, dynamic> wuXing) {
  const colors = <String, Color>{
    '木': Color(0xFF2F9E44),
    '火': Color(0xFFE8590C),
    '土': Color(0xFFB8860B),
    '金': Color(0xFF5C7CFA),
    '水': Color(0xFF1C7ED6),
  };
  return const ['木', '火', '土', '金', '水']
      .map(
        (label) => _WuXingItem(
          label: label,
          value: astroDouble(wuXing[label]) ?? 0,
          color: colors[label] ?? const Color(0xFF5AA8FF),
        ),
      )
      .toList(growable: false);
}
