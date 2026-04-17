import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_route_sample_set.dart';

class AstroCalibrationReportData {
  const AstroCalibrationReportData({
    required this.sampleSet,
    required this.knownDeviations,
  });

  final AstroRouteSampleSetReport sampleSet;
  final List<String> knownDeviations;

  List<String> toMarkdownLines() {
    final lines = <String>[
      '# 3.8 校准报告',
      '- 报告性质：derived-only / display-only / advanced-context',
      '- 用途：参考样例校准、偏差归档、回归锚点',
      '- 样例数量：${sampleSet.entries.length}',
      '- 说明：以下差异只用于校准与归档，不回写 canonical truth。',
      '',
    ];
    for (final entry in sampleSet.entries) {
      lines.addAll(entry.toMarkdownLines());
      lines.add('');
    }
    lines.add('- 已知偏差：');
    lines.addAll(knownDeviations.map((item) => '- $item'));
    return lines;
  }
}

AstroCalibrationReportData buildAstroCalibrationReport() {
  final sampleSet = buildAstroRouteSampleSetReport();
  return AstroCalibrationReportData(
    sampleSet: sampleSet,
    knownDeviations: [
      'baseline 与 dense-modern 的差异主要来自路线模板与样例密度，不应误判为 canonical truth 回写。',
      '古典路线收紧到核心点位与主相位，现代路线保留扩展相位，这属于预期的 display delta。',
      '校准报告目前仍以 derived-only / display-only / advanced-context 呈现，不作为新真值源。',
    ],
  );
}

class AstroCalibrationReportCard extends StatelessWidget {
  const AstroCalibrationReportCard({
    super.key,
    this.onOpenDetails,
  });

  final VoidCallback? onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final report = buildAstroCalibrationReport();
    return AppInfoSectionCard(
      title: '校准样例',
      subtitle: '参考样例 / 偏差归档 / 回归锚点',
      leadingIcon: Icons.science_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'stage 4 把 baseline 与 dense-modern 两组参考样例固定下来，便于后续重复复核点位与相位差异。这里记录的是校准与偏差归档，不是新的算法真值层。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: [
              AstroPill(label: '样例数：${report.sampleSet.entries.length}'),
              AstroPill(label: '基线：baseline'),
              AstroPill(label: '扩展：dense-modern'),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          ...report.sampleSet.entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(bottom: t.spacing.xs),
              child: _CalibrationTile(entry: entry),
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            '已知偏差',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          ...report.knownDeviations.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: t.spacing.xxs),
              child: Text(
                '• $item',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.35,
                ),
              ),
            ),
          ),
          if (onOpenDetails != null) ...[
            SizedBox(height: t.spacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: onOpenDetails,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('查看校准报告'),
              ),
            ),
          ] else ...[
            SizedBox(height: t.spacing.xs),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.push(AppRouteNames.astroAdvancedPreviewDemo),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('打开校准演示'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CalibrationTile extends StatelessWidget {
  const _CalibrationTile({required this.entry});

  final AstroRouteSampleSetEntry entry;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final standard = entry.standardSummary;
    final classical = entry.classicalSummary;
    final modern = entry.modernSummary;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.md),
      decoration: BoxDecoration(
        color: t.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: t.overlay.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.variant.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            '标准 ${standard.visiblePointCount}/${standard.visibleAspectCount} · '
            '古典 ${classical.visiblePointCount}/${classical.visibleAspectCount} · '
            '现代 ${modern.visiblePointCount}/${modern.visibleAspectCount}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.35,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: [
              AstroPill(label: '标准差：${_signed(entry.standardVsClassical.pointDelta)} / ${_signed(entry.standardVsClassical.aspectDelta)}'),
              AstroPill(label: '现代差：${_signed(entry.standardVsModern.pointDelta)} / ${_signed(entry.standardVsModern.aspectDelta)}'),
            ],
          ),
        ],
      ),
    );
  }
}

String _signed(int value) => value > 0 ? '+$value' : value.toString();
