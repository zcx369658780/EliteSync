import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';

class BaziTimelineSection extends StatelessWidget {
  const BaziTimelineSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.isDaYun,
  });

  final String title;
  final String subtitle;
  final List<dynamic> items;
  final bool isDaYun;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
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
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.25,
                ),
          ),
          SizedBox(height: t.spacing.sm),
          if (items.isEmpty)
            Text(
              '暂无数据',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textSecondary),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => SizedBox(height: t.spacing.xs),
              itemBuilder: (context, index) {
                final row = astroMap(items[index]);
                return _TimelineItem(
                  row: row,
                  isDaYun: isDaYun,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.row,
    required this.isDaYun,
  });

  final Map<String, dynamic> row;
  final bool isDaYun;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final ganZhi = astroText(row['gan_zhi'], '-');
    final accent = _elementColor(astroText(ganZhi.isNotEmpty ? _firstRune(ganZhi) : '-'));
    final range = isDaYun
        ? '${astroText(row['start_year'], '-')}-${astroText(row['end_year'], '-')}'
        : astroText(row['year'], '-');
    final secondary = isDaYun
        ? '${astroText(row['start_age'], '-')}-${astroText(row['end_age'], '-')} 岁'
        : '${astroText(row['age'], '-')} 岁';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 56,
                margin: const EdgeInsets.only(top: 2),
                color: accent.withValues(alpha: 0.20),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: t.spacing.sm, vertical: t.spacing.xs),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(t.radius.md),
              border: Border.all(color: accent.withValues(alpha: 0.20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$range · $ganZhi',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.72,
                      child: Text(
                        secondary,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                if (isDaYun) ...[
                  SizedBox(height: t.spacing.xxs),
                  Text(
                    '大运节选',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: t.textSecondary,
                          height: 1.25,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Color _elementColor(String stem) {
  switch (stem) {
    case '甲':
    case '乙':
    case '寅':
    case '卯':
      return const Color(0xFF2F9E44);
    case '丙':
    case '丁':
    case '巳':
    case '午':
      return const Color(0xFFE8590C);
    case '戊':
    case '己':
    case '丑':
    case '辰':
    case '未':
    case '戌':
      return const Color(0xFFB8860B);
    case '庚':
    case '辛':
    case '申':
    case '酉':
      return const Color(0xFF5C7CFA);
    case '壬':
    case '癸':
    case '子':
    case '亥':
      return const Color(0xFF1C7ED6);
    default:
      return const Color(0xFF5AA8FF);
  }
}

String _firstRune(String value) {
  if (value.isEmpty) return '-';
  final runes = value.runes.toList(growable: false);
  if (runes.isEmpty) return '-';
  return String.fromCharCode(runes.first);
}
