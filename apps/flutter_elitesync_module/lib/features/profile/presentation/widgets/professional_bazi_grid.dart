import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';

class ProfessionalBaziGrid extends StatelessWidget {
  const ProfessionalBaziGrid({
    super.key,
    required this.bazi,
    this.baziDetails,
    this.mockBaziDetails,
  });

  final String bazi;
  final Map<String, dynamic>? baziDetails;
  final Map<String, dynamic>? mockBaziDetails;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final pillars = _resolvePillars(bazi, baziDetails, mockBaziDetails);

    return LayoutBuilder(
      builder: (context, constraints) {
        final gridWidth = constraints.maxWidth;
        final gridHeight = gridWidth * 1.62;
        return Container(
          width: double.infinity,
          height: gridHeight,
          padding: EdgeInsets.all(t.spacing.xs),
          decoration: BoxDecoration(
            color: t.browseSurface,
            borderRadius: BorderRadius.circular(t.radius.lg),
            border: Border.all(color: t.browseBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: pillars
                    .map(
                      (pillar) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: pillar == pillars.last ? 0 : t.spacing.xxs),
                          child: _PillarHeaderTile(pillar: pillar),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
              SizedBox(height: t.spacing.xs),
              Text(
                '十神 / 天干 / 地支 / 藏干 / 地势自坐',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: t.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: t.spacing.xs),
              Expanded(
                child: Column(
                  children: [
                    for (final kind in RowKind.values) ...[
                      Expanded(
                        child: Row(
                          children: [
                            for (final pillar in pillars)
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: pillar == pillars.last ? 0 : t.spacing.xxs,
                                    bottom: t.spacing.xxs,
                                  ),
                                  child: _BaziMatrixCell(
                                    pillar: pillar,
                                    kind: kind,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_BaziPillarModel> _resolvePillars(
    String bazi,
    Map<String, dynamic>? details,
    Map<String, dynamic>? mockDetails,
  ) {
    final rawDetails = details ?? const <String, dynamic>{};
    final rawMockDetails = mockDetails ?? const <String, dynamic>{};
    final rawPillars = astroList(rawDetails['pillars']);
    final mockPillars = astroList(rawMockDetails['pillars']);
    if (rawPillars.isNotEmpty) {
      final parsed = rawPillars
          .asMap()
          .entries
          .map((entry) => _BaziPillarModel.fromMap(astroMap(entry.value), fallbackIndex: entry.key + 1))
          .toList(growable: false);
      if (parsed.length == 4) return parsed;
    }
    if (mockPillars.isNotEmpty) {
      final parsed = mockPillars
          .asMap()
          .entries
          .map((entry) => _BaziPillarModel.fromMap(astroMap(entry.value), fallbackIndex: entry.key + 1))
          .toList(growable: false);
      if (parsed.length == 4) return parsed;
    }

    final tokens = bazi
        .split(RegExp(r'\s+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
    return List.generate(4, (index) {
      final token = index < tokens.length ? tokens[index] : '-';
      return _BaziPillarModel.fromGanZhi(
        index: index + 1,
        label: _pillarLabels[index],
        ganZhi: token,
        shiShen: '-',
        hiddenStems: const [],
        phase: '-',
      );
    });
  }
}

enum RowKind { shiShen, stem, branch, hiddenStem, phase }

class _BaziPillarModel {
  const _BaziPillarModel({
    required this.index,
    required this.label,
    required this.gan,
    required this.zhi,
    required this.ganZhi,
    required this.shiShen,
    required this.hiddenStems,
    required this.phase,
    required this.element,
    required this.isDayPillar,
  });

  factory _BaziPillarModel.fromMap(Map<String, dynamic> map, {required int fallbackIndex}) {
    final ganZhi = astroText(map['gan_zhi'] ?? map['ganzhi'] ?? map['text'], '-');
    final gan = astroText(map['gan'] ?? map['stem'] ?? _splitGan(ganZhi), '-');
    final zhi = astroText(map['zhi'] ?? map['branch'] ?? _splitZhi(ganZhi), '-');
    final index = (map['index'] as num?)?.toInt() ?? fallbackIndex;
    final label = astroText(map['label'] ?? map['name'] ?? (index > 0 ? _pillarLabels[index - 1] : '-'), '-');
    final shiShen = astroText(map['shi_shen'] ?? map['ten_god'] ?? map['tenGod'], '-');
    final hiddenStems = astroList(map['cang_gan'] ?? map['hidden_stems'] ?? map['hidden'])
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList(growable: false);
    final phase = astroText(map['di_shi'] ?? map['phase'] ?? map['zhi_shi'], '-');
    final isDayPillar = _isTruthy(map['is_day_pillar'] ?? map['day_pillar']) || label == '日柱' || index == 3;
    return _BaziPillarModel(
      index: index > 0 ? index : 0,
      label: label,
      gan: gan,
      zhi: zhi,
      ganZhi: ganZhi,
      shiShen: shiShen,
      hiddenStems: hiddenStems,
      phase: phase,
      element: _elementOfGan(gan.isNotEmpty ? gan : zhi),
      isDayPillar: isDayPillar,
    );
  }

  factory _BaziPillarModel.fromGanZhi({
    required int index,
    required String label,
    required String ganZhi,
    required String shiShen,
    required List<dynamic> hiddenStems,
    required String phase,
  }) {
    final gan = _splitGan(ganZhi);
    final zhi = _splitZhi(ganZhi);
    return _BaziPillarModel(
      index: index,
      label: label,
      gan: gan,
      zhi: zhi,
      ganZhi: ganZhi,
      shiShen: shiShen,
      hiddenStems: hiddenStems.map((e) => e.toString()).toList(growable: false),
      phase: phase,
      element: _elementOfGan(gan.isNotEmpty ? gan : zhi),
      isDayPillar: index == 3,
    );
  }

  final int index;
  final String label;
  final String gan;
  final String zhi;
  final String ganZhi;
  final String shiShen;
  final List<String> hiddenStems;
  final String phase;
  final String element;
  final bool isDayPillar;

  String get hiddenStemsLabel => hiddenStems.isEmpty ? '-' : hiddenStems.join(' / ');
}

class _BaziMatrixCell extends StatelessWidget {
  const _BaziMatrixCell({
    required this.pillar,
    required this.kind,
  });

  final _BaziPillarModel pillar;
  final RowKind kind;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final accent = _accentColor(context, pillar.element, pillar.isDayPillar);
    final value = switch (kind) {
      RowKind.shiShen => pillar.shiShen,
      RowKind.stem => pillar.gan.isEmpty ? '-' : pillar.gan,
      RowKind.branch => pillar.zhi.isEmpty ? '-' : pillar.zhi,
      RowKind.hiddenStem => pillar.hiddenStemsLabel,
      RowKind.phase => pillar.phase.isEmpty ? '-' : pillar.phase,
    };
    final label = switch (kind) {
      RowKind.shiShen => '十神',
      RowKind.stem => '天干',
      RowKind.branch => '地支',
      RowKind.hiddenStem => '藏干',
      RowKind.phase => '地势',
    };
    final isPrimary = kind == RowKind.stem || kind == RowKind.branch;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: t.spacing.xxs, vertical: t.spacing.xs),
      decoration: BoxDecoration(
        color: pillar.isDayPillar ? accent.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(t.radius.sm),
        border: Border.all(color: accent.withValues(alpha: pillar.isDayPillar ? 0.34 : 0.16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: t.textSecondary,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: kind == RowKind.hiddenStem ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: kind == RowKind.shiShen ? t.textPrimary : accent,
                  fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w700,
                  fontSize: isPrimary ? 15 : 8.5,
                  height: 1.0,
                ),
          ),
        ],
      ),
    );
  }

  Color _accentColor(BuildContext context, String element, bool isDayPillar) {
    final t = context.appTokens;
    final palette = _elementPalette(context);
    return palette[element] ?? (isDayPillar ? t.brandPrimary : t.textPrimary);
  }
}

class _PillarHeaderTile extends StatelessWidget {
  const _PillarHeaderTile({
    required this.pillar,
  });

  final _BaziPillarModel pillar;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final accent = _accentColor(context, pillar.element, pillar.isDayPillar);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: t.spacing.xxs, vertical: t.spacing.xs),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: pillar.isDayPillar ? 0.14 : 0.06),
        borderRadius: BorderRadius.circular(t.radius.md),
        border: Border.all(color: accent.withValues(alpha: pillar.isDayPillar ? 0.45 : 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pillar.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: t.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            pillar.ganZhi,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            pillar.element,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: t.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Color _accentColor(BuildContext context, String element, bool isDayPillar) {
    final t = context.appTokens;
    final palette = _elementPalette(context);
    return palette[element] ?? (isDayPillar ? t.brandPrimary : t.textPrimary);
  }
}

Map<String, Color> _elementPalette(BuildContext context) {
  return {
    '木': const Color(0xFF2F9E44),
    '火': const Color(0xFFE8590C),
    '土': const Color(0xFFB8860B),
    '金': const Color(0xFF5C7CFA),
    '水': const Color(0xFF1C7ED6),
  };
}

String _splitGan(String ganZhi) {
  if (ganZhi.isEmpty) return '-';
  return String.fromCharCodes(ganZhi.runes.take(1));
}

String _splitZhi(String ganZhi) {
  final chars = ganZhi.runes.toList(growable: false);
  if (chars.length < 2) return '-';
  return String.fromCharCode(chars[1]);
}

String _elementOfGan(String stemOrBranch) {
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
    '子': '水',
    '丑': '土',
    '寅': '木',
    '卯': '木',
    '辰': '土',
    '巳': '火',
    '午': '火',
    '未': '土',
    '申': '金',
    '酉': '金',
    '戌': '土',
    '亥': '水',
  };
  return map[stemOrBranch] ?? '-';
}

bool _isTruthy(dynamic value) {
  if (value is bool) return value;
  final text = (value ?? '').toString().trim().toLowerCase();
  return text == 'true' || text == '1' || text == 'yes' || text == 'y';
}

const List<String> _pillarLabels = ['年柱', '月柱', '日柱', '时柱'];
