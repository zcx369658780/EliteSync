import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_chart_sample_comparison.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_chart_sample_fixture.dart';

class AstroRouteSampleVariant {
  const AstroRouteSampleVariant({
    required this.sampleId,
    required this.title,
    required this.profile,
  });

  final String sampleId;
  final String title;
  final Map<String, dynamic> profile;
}

class AstroRouteSampleSetEntry {
  const AstroRouteSampleSetEntry({
    required this.variant,
    required this.standardSummary,
    required this.classicalSummary,
    required this.modernSummary,
    required this.standardVsClassical,
    required this.standardVsModern,
  });

  final AstroRouteSampleVariant variant;
  final AstroChartSampleSummary standardSummary;
  final AstroChartSampleSummary classicalSummary;
  final AstroChartSampleSummary modernSummary;
  final AstroChartSampleComparisonDelta standardVsClassical;
  final AstroChartSampleComparisonDelta standardVsModern;

  List<String> toMarkdownLines() => [
    '### ${variant.title}',
    '- 样例标识：${variant.sampleId}',
    '- 样例资料：${standardSummary.profileName}',
    '- 标准路线：${standardSummary.visiblePointCount} 点位 / ${standardSummary.visibleAspectCount} 相位',
    '- 古典路线：${classicalSummary.visiblePointCount} 点位 / ${classicalSummary.visibleAspectCount} 相位',
    '- 现代路线：${modernSummary.visiblePointCount} 点位 / ${modernSummary.visibleAspectCount} 相位',
    '- 标准 vs 古典：${_signed(standardVsClassical.pointDelta)} 点位 / ${_signed(standardVsClassical.aspectDelta)} 相位',
    '- 标准 vs 现代：${_signed(standardVsModern.pointDelta)} 点位 / ${_signed(standardVsModern.aspectDelta)} 相位',
  ];
}

class AstroRouteSampleSetReport {
  const AstroRouteSampleSetReport({required this.entries});

  final List<AstroRouteSampleSetEntry> entries;

  List<String> toMarkdownLines() {
    final lines = <String>[
      '# 3.6 多路线样例集',
      '- 报告性质：derived-only / display-only',
      '- 用途：多样例回归、路线能力矩阵、已知偏差归档',
      '- 样例数量：${entries.length}',
    ];
    for (final entry in entries) {
      lines.addAll(entry.toMarkdownLines());
    }
    lines.add('- 说明：所有差异只用于路线解释与对照，不回写真值。');
    return lines;
  }
}

const astroRouteSampleVariants = <AstroRouteSampleVariant>[
  AstroRouteSampleVariant(
    sampleId: 'baseline',
    title: '基线样例',
    profile: astroChartComparisonSampleProfile,
  ),
  AstroRouteSampleVariant(
    sampleId: 'dense-modern',
    title: '现代扩展样例',
    profile: astroChartComparisonDenseSampleProfile,
  ),
];

AstroRouteSampleSetReport buildAstroRouteSampleSetReport({
  List<AstroRouteSampleVariant> variants = astroRouteSampleVariants,
}) {
  return AstroRouteSampleSetReport(
    entries: variants.map(_buildEntry).toList(growable: false),
  );
}

AstroRouteSampleSetEntry _buildEntry(AstroRouteSampleVariant variant) {
  final standard = summarizeAstroChartSample(
    variant.profile,
    workbench: AstroChartWorkbenchPrefs.forRouteMode(
      AstroChartRouteMode.standard,
    ),
    sampleName: variant.title,
  );
  final classical = summarizeAstroChartSample(
    variant.profile,
    workbench: AstroChartWorkbenchPrefs.forRouteMode(
      AstroChartRouteMode.classical,
    ),
    sampleName: variant.title,
  );
  final modern = summarizeAstroChartSample(
    variant.profile,
    workbench: AstroChartWorkbenchPrefs.forRouteMode(
      AstroChartRouteMode.modern,
    ),
    sampleName: variant.title,
  );

  return AstroRouteSampleSetEntry(
    variant: variant,
    standardSummary: standard,
    classicalSummary: classical,
    modernSummary: modern,
    standardVsClassical: compareAstroChartSampleSummaries(classical, standard),
    standardVsModern: compareAstroChartSampleSummaries(standard, modern),
  );
}

String _signed(int value) => value > 0 ? '+$value' : value.toString();
