import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';

class AstroIdentityHeader extends StatelessWidget {
  const AstroIdentityHeader({
    super.key,
    required this.profile,
  });

  final Map<String, dynamic> profile;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final sun = astroText(profile['sun_sign'], '-');
    final moon = astroText(profile['moon_sign'], '-');
    final asc = astroText(profile['asc_sign'], '-');
    final bazi = astroText(profile['bazi'], '');
    final ziwei = astroMap(profile['ziwei']);
    final lifePalace = astroText(ziwei['life_palace'], '-');
    final destinyStar = _resolveLifePalaceMainStar(ziwei);
    final dayMaster = _resolveDayMaster(bazi);
    final dayMasterElement = _elementOfStem(dayMaster);

    return Container(
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.xl),
        border: Border.all(color: t.browseBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '玄学身份摘要',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            '将西占三轴、八字日主与紫微命星整合为一个统一入口',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.35,
                ),
          ),
          SizedBox(height: t.spacing.md),
          Wrap(
            spacing: t.spacing.sm,
            runSpacing: t.spacing.sm,
            children: [
              _IdentityMetricCard(
                title: '西占三轴',
                primary: '太阳$sun',
                secondary: '月亮$moon / 上升$asc',
                accent: t.brandPrimary,
                icon: Icons.auto_awesome_rounded,
              ),
              _IdentityMetricCard(
                title: '八字日主',
                primary: dayMaster.isEmpty ? '-' : dayMaster,
                secondary: dayMasterElement.isEmpty ? '未知五行' : '$dayMasterElement 日主',
                accent: _elementColor(dayMasterElement),
                icon: Icons.view_module_rounded,
              ),
              _IdentityMetricCard(
                title: '紫微命星',
                primary: destinyStar,
                secondary: '命宫 $lifePalace',
                accent: const Color(0xFF7C6CFF),
                icon: Icons.grid_view_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AstroPortalCard extends StatelessWidget {
  const AstroPortalCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.preview,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(t.radius.xl),
        child: Container(
          decoration: BoxDecoration(
            color: t.browseSurface,
            borderRadius: BorderRadius.circular(t.radius.xl),
            border: Border.all(color: t.browseBorder),
          ),
          padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              SizedBox(height: t.spacing.xxs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.35,
                    ),
              ),
              SizedBox(height: t.spacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(t.radius.lg),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(t.radius.lg),
                    border: Border.all(color: t.browseBorder.withValues(alpha: 0.9)),
                  ),
                  padding: EdgeInsets.all(t.spacing.sm),
                  child: preview,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BaziOverviewPreview extends StatelessWidget {
  const BaziOverviewPreview({
    super.key,
    required this.bazi,
  });

  final String bazi;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final pillars = bazi
        .split(RegExp(r'\s+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
    const labels = ['年', '月', '日', '时'];

    return SizedBox(
      height: 132,
      child: Row(
        children: List.generate(4, (index) {
          final pillar = index < pillars.length ? pillars[index] : '--';
          final stem = pillar.isNotEmpty ? String.fromCharCode(pillar.runes.first) : '-';
          final branch = pillar.runes.length > 1 ? String.fromCharCode(pillar.runes.elementAt(1)) : '-';
          final accent = _elementColor(_elementOfStem(stem));
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index == 3 ? 0 : t.spacing.xs),
              padding: EdgeInsets.symmetric(horizontal: t.spacing.xs, vertical: t.spacing.sm),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(t.radius.lg),
                border: Border.all(color: accent.withValues(alpha: 0.28)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    labels[index],
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: t.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    stem,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    branch,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class NatalAxisPoster extends StatelessWidget {
  const NatalAxisPoster({
    super.key,
    required this.profile,
  });

  final Map<String, dynamic> profile;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final sun = astroText(profile['sun_sign'], '-');
    final moon = astroText(profile['moon_sign'], '-');
    final asc = astroText(profile['asc_sign'], '-');

    return SizedBox(
      height: 164,
      child: Row(
        children: [
          Expanded(
            child: _AxisPreviewTile(
              emoji: '☉',
              label: '太阳',
              value: sun,
              accent: const Color(0xFFF5A623),
            ),
          ),
          SizedBox(width: t.spacing.xs),
          Expanded(
            child: _AxisPreviewTile(
              emoji: '☾',
              label: '月亮',
              value: moon,
              accent: const Color(0xFF7C6CFF),
            ),
          ),
          SizedBox(width: t.spacing.xs),
          Expanded(
            child: _AxisPreviewTile(
              emoji: 'Asc',
              label: '上升',
              value: asc,
              accent: t.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class ZiweiOverviewPreview extends StatelessWidget {
  const ZiweiOverviewPreview({
    super.key,
    required this.ziwei,
  });

  final Map<String, dynamic> ziwei;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final palaces = astroList(ziwei['palaces']);
    final lifePalace = astroText(ziwei['life_palace'], '-');
    final bodyPalace = astroText(ziwei['body_palace'], '-');
    final order = <String>[
      '命宫',
      '兄弟宫',
      '夫妻宫',
      '子女宫',
      '父母宫',
      '',
      '',
      '财帛宫',
      '福德宫',
      '',
      '',
      '疾厄宫',
      '田宅宫',
      '官禄宫',
      '仆役宫',
      '迁移宫',
    ];

    return SizedBox(
      height: 164,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: order.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final name = order[index];
          if (name.isEmpty) {
            return Container(
              decoration: BoxDecoration(
                color: t.surface.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(t.radius.md),
              ),
            );
          }
          final palace = palaces
              .whereType<Map>()
              .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
              .cast<Map<String, dynamic>>()
              .firstWhere(
                (row) => astroText(row['name'], '') == name,
                orElse: () => const <String, dynamic>{},
              );
          final isLife = name == lifePalace;
          final isBody = name == bodyPalace;
          final accent = isLife
              ? const Color(0xFF5AA8FF)
              : isBody
                  ? const Color(0xFF8A7CFF)
                  : t.textSecondary;
          return Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isLife || isBody ? 0.12 : 0.05),
              borderRadius: BorderRadius.circular(t.radius.md),
              border: Border.all(color: accent.withValues(alpha: isLife || isBody ? 0.40 : 0.16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.replaceAll('宫', ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const Spacer(),
                Text(
                  astroText(palace['main_star'], '-'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class WuXingPulseStrip extends StatelessWidget {
  const WuXingPulseStrip({
    super.key,
    required this.wuXing,
  });

  final Map<String, dynamic> wuXing;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final items = _buildPulseItems(wuXing);
    final total = items.fold<double>(0, (sum, item) => sum + item.value);

    return Container(
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.xl),
        border: Border.all(color: t.browseBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '五行能量脉冲条',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            '只保留用户可感知的五行能量，不在总览页暴露技术参数',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.35,
                ),
          ),
          SizedBox(height: t.spacing.sm),
          ...items.map((item) {
            final percent = total <= 0 ? 0.0 : (item.value / total * 100).clamp(0.0, 100.0);
            return Padding(
              padding: EdgeInsets.only(bottom: t.spacing.sm),
              child: Row(
                children: [
                  SizedBox(
                    width: 26,
                    child: Text(
                      item.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: item.color,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(t.radius.pill),
                      child: SizedBox(
                        height: 14,
                        child: Stack(
                          children: [
                            Container(color: item.color.withValues(alpha: 0.10)),
                            FractionallySizedBox(
                              widthFactor: percent / 100,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      item.color.withValues(alpha: 0.55),
                                      item.color,
                                      item.color.withValues(alpha: 0.72),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: t.spacing.sm),
                  SizedBox(
                    width: 42,
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
            );
          }),
        ],
      ),
    );
  }
}

class _IdentityMetricCard extends StatelessWidget {
  const _IdentityMetricCard({
    required this.title,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String primary;
  final String secondary;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return SizedBox(
      width: 176,
      child: Container(
        padding: EdgeInsets.all(t.spacing.md),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(t.radius.lg),
          border: Border.all(color: accent.withValues(alpha: 0.28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 18),
            SizedBox(height: t.spacing.xs),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            SizedBox(height: t.spacing.xxs),
            Text(
              primary,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            SizedBox(height: t.spacing.xxs),
            Text(
              secondary,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                    height: 1.35,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

String _resolveDayMaster(String bazi) {
  final pillars = bazi
      .split(RegExp(r'\s+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);
  if (pillars.length < 3 || pillars[2].isEmpty) return '';
  return String.fromCharCode(pillars[2].runes.first);
}

String _resolveLifePalaceMainStar(Map<String, dynamic> ziwei) {
  final lifePalace = astroText(ziwei['life_palace'], '');
  if (lifePalace.isEmpty) return '-';
  final palaces = astroList(ziwei['palaces']);
  final target = palaces
      .whereType<Map>()
      .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
      .cast<Map<String, dynamic>>()
      .firstWhere(
        (row) => astroText(row['name'], '') == lifePalace,
        orElse: () => const <String, dynamic>{},
      );
  return astroText(target['main_star'], '-');
}

String _elementOfStem(String stem) {
  const map = {
    '甲': '木',
    '乙': '木',
    '丙': '火',
    '丁': '火',
    '戊': '土',
    '己': '土',
    '庚': '金',
    '辛': '金',
    '壬': '水',
    '癸': '水',
  };
  return map[stem] ?? '';
}

Color _elementColor(String element) {
  switch (element) {
    case '木':
      return const Color(0xFF2F9E44);
    case '火':
      return const Color(0xFFE8590C);
    case '土':
      return const Color(0xFFB8860B);
    case '金':
      return const Color(0xFF5C7CFA);
    case '水':
      return const Color(0xFF1C7ED6);
    default:
      return const Color(0xFF6C7A89);
  }
}

class _AxisPreviewTile extends StatelessWidget {
  const _AxisPreviewTile({
    required this.emoji,
    required this.label,
    required this.value,
    required this.accent,
  });

  final String emoji;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: t.spacing.sm,
        vertical: t.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            emoji,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: t.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

List<_PulseItem> _buildPulseItems(Map<String, dynamic> wuXing) {
  const labels = ['木', '火', '土', '金', '水'];
  return labels
      .map((label) => _PulseItem(
            label: label,
            value: astroDouble(wuXing[label]) ?? 0,
            color: _elementColor(label),
          ))
      .toList(growable: false);
}

class _PulseItem {
  const _PulseItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}
