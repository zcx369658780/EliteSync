import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_chart_sample_comparison.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_chart_sample_fixture.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';

class AstroRouteParityReportData {
  const AstroRouteParityReportData({
    required this.currentRouteMode,
    required this.sampleProfileName,
    required this.currentRow,
    required this.standardRow,
    required this.classicalRow,
    required this.modernRow,
    required this.standardVsClassical,
    required this.standardVsModern,
  });

  final AstroChartRouteMode currentRouteMode;
  final String sampleProfileName;
  final AstroRouteParityRow currentRow;
  final AstroRouteParityRow standardRow;
  final AstroRouteParityRow classicalRow;
  final AstroRouteParityRow modernRow;
  final AstroChartSampleComparisonDelta standardVsClassical;
  final AstroChartSampleComparisonDelta standardVsModern;

  List<AstroRouteParityRow> get rows => [standardRow, classicalRow, modernRow];

  List<String> toMarkdownLines() => [
    '# 3.6 路线差异报告',
    '- 报告性质：derived-only / display-only',
    '- 固定样例：$sampleProfileName',
    '- 当前路线：${_routeModeLabel(currentRouteMode)}',
    '- 当前路线说明：${_routeModeDescription(currentRouteMode)}',
    '- 标准路线：${standardRow.summary.visiblePointCount} 点位 / ${standardRow.summary.visibleAspectCount} 相位',
    '- 古典路线：${classicalRow.summary.visiblePointCount} 点位 / ${classicalRow.summary.visibleAspectCount} 相位',
    '- 现代路线：${modernRow.summary.visiblePointCount} 点位 / ${modernRow.summary.visibleAspectCount} 相位',
    '- 标准 vs 古典：${_signed(standardVsClassical.pointDelta)} 点位 / ${_signed(standardVsClassical.aspectDelta)} 相位',
    '- 标准 vs 现代：${_signed(standardVsModern.pointDelta)} 点位 / ${_signed(standardVsModern.aspectDelta)} 相位',
    '- 说明：路线解释只做展示与对照，不回写 canonical truth。',
  ];
}

class AstroRouteParityRow {
  const AstroRouteParityRow({
    required this.routeMode,
    required this.workbench,
    required this.summary,
    required this.deltaFromStandard,
    required this.isCurrent,
  });

  final AstroChartRouteMode routeMode;
  final AstroChartWorkbenchPrefs workbench;
  final AstroChartSampleSummary summary;
  final AstroChartSampleComparisonDelta deltaFromStandard;
  final bool isCurrent;

  String get routeLabel => _routeModeLabel(routeMode);

  String get routeDescription => _routeModeDescription(routeMode);

  String get workbenchLabel => summary.workbenchLabel;

  String get deltaLabel {
    if (routeMode == AstroChartRouteMode.standard) {
      return '基线：标准路线';
    }
    return '相对标准：${_signed(deltaFromStandard.pointDelta)} 点位 / ${_signed(deltaFromStandard.aspectDelta)} 相位';
  }

  String get shortSummary =>
      '可见点位 ${summary.visiblePointCount} 个 / 相位 ${summary.visibleAspectCount} 条';

  List<String> toMarkdownLines() => [
    '- 路线：$routeLabel',
    '- 路线说明：$routeDescription',
    '- 工作台：$workbenchLabel',
    '- 摘要：$shortSummary',
    '- 对照：$deltaLabel',
  ];
}

AstroRouteParityReportData buildAstroRouteParityReport({
  required AstroChartRouteMode currentRouteMode,
}) {
  final standardRow = _buildRow(
    routeMode: AstroChartRouteMode.standard,
    isCurrent: currentRouteMode == AstroChartRouteMode.standard,
  );
  final classicalRow = _buildRow(
    routeMode: AstroChartRouteMode.classical,
    isCurrent: currentRouteMode == AstroChartRouteMode.classical,
  );
  final modernRow = _buildRow(
    routeMode: AstroChartRouteMode.modern,
    isCurrent: currentRouteMode == AstroChartRouteMode.modern,
  );

  return AstroRouteParityReportData(
    currentRouteMode: currentRouteMode,
    sampleProfileName: standardRow.summary.profileName,
    currentRow: switch (currentRouteMode) {
      AstroChartRouteMode.standard => standardRow,
      AstroChartRouteMode.classical => classicalRow,
      AstroChartRouteMode.modern => modernRow,
    },
    standardRow: standardRow,
    classicalRow: classicalRow,
    modernRow: modernRow,
    standardVsClassical: compareAstroChartSampleSummaries(
      standardRow.summary,
      classicalRow.summary,
    ),
    standardVsModern: compareAstroChartSampleSummaries(
      standardRow.summary,
      modernRow.summary,
    ),
  );
}

class AstroRouteParityReportCard extends StatelessWidget {
  const AstroRouteParityReportCard({
    super.key,
    required this.currentRouteMode,
    required this.currentWorkbench,
    this.compact = false,
    this.title,
    this.subtitle,
    this.onOpenDetails,
  });

  final AstroChartRouteMode currentRouteMode;
  final AstroChartWorkbenchPrefs currentWorkbench;
  final bool compact;
  final String? title;
  final String? subtitle;
  final VoidCallback? onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final report = buildAstroRouteParityReport(
      currentRouteMode: currentRouteMode,
    );
    final resolvedTitle = title ?? (compact ? '路线解释' : '路线差异报告');
    final resolvedSubtitle =
        subtitle ?? (compact ? '当前路线与固定样例的差异摘要' : '同一份固定样例，用于重复复核三条路线的差异');

    return AppInfoSectionCard(
      title: resolvedTitle,
      subtitle: resolvedSubtitle,
      leadingIcon: Icons.change_circle_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '这层内容只做路线解释与对照，属于 derived-only / display-only；它不会改写服务端 canonical truth，也不会把路线模板变成新的真值源。',
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
              AstroPill(label: '当前路线：${_routeModeLabel(currentRouteMode)}'),
              AstroPill(label: '当前工作台：${_workbenchLabel(currentWorkbench)}'),
              AstroPill(label: '固定样例：${report.sampleProfileName}'),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          if (compact) ...[
            Text(
              report.currentRow.routeMode == AstroChartRouteMode.standard
                  ? '当前路线与标准路线一致，作为当前路线解释的基线。'
                  : '当前路线相对标准路线会变化可见点位与相位，解释层只说明差异，不改写真值。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.45,
              ),
            ),
            SizedBox(height: t.spacing.xs),
            Wrap(
              spacing: t.spacing.xs,
              runSpacing: t.spacing.xs,
              children: [
                AstroPill(label: report.currentRow.shortSummary),
                AstroPill(label: report.currentRow.deltaLabel),
              ],
            ),
          ] else ...[
            Column(
              children: [
                for (var index = 0; index < report.rows.length; index++) ...[
                  _RouteParityRowTile(
                    row: report.rows[index],
                    isCurrentRoute:
                        report.rows[index].routeMode == currentRouteMode,
                  ),
                  if (index != report.rows.length - 1)
                    SizedBox(height: t.spacing.sm),
                ],
              ],
            ),
            SizedBox(height: t.spacing.sm),
            Text(
              '固定样例盘只用于回归对照：标准路线是基线，古典路线收紧到核心点位与主相位，现代路线保留更多扩展相位。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.45,
              ),
            ),
          ],
          if (onOpenDetails != null) ...[
            SizedBox(height: t.spacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: onOpenDetails,
                icon: const Icon(Icons.tune_rounded),
                label: Text(compact ? '打开路线设置' : '回到路线工作台'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RouteParityRowTile extends StatelessWidget {
  const _RouteParityRowTile({required this.row, required this.isCurrentRoute});

  final AstroRouteParityRow row;
  final bool isCurrentRoute;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final scheme = Theme.of(context).colorScheme;
    final background = isCurrentRoute
        ? scheme.primary.withValues(alpha: 0.08)
        : t.surface.withValues(alpha: 0.55);
    final borderColor = isCurrentRoute
        ? scheme.primary.withValues(alpha: 0.34)
        : t.overlay.withValues(alpha: 0.60);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: isCurrentRoute,
            tilePadding: EdgeInsets.symmetric(
              horizontal: t.spacing.md,
              vertical: t.spacing.xs,
            ),
            childrenPadding: EdgeInsets.fromLTRB(
              t.spacing.md,
              0,
              t.spacing.md,
              t.spacing.md,
            ),
            title: Wrap(
              spacing: t.spacing.xs,
              runSpacing: t.spacing.xs,
              children: [
                AstroPill(label: row.routeLabel),
                if (isCurrentRoute) const AstroPill(label: '当前路线'),
              ],
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: t.spacing.xs),
              child: Text(
                '${row.shortSummary} · ${row.deltaLabel}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.35,
                ),
              ),
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  row.routeDescription,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                    height: 1.45,
                  ),
                ),
              ),
              SizedBox(height: t.spacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '工作台：${row.workbenchLabel}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

AstroRouteParityRow _buildRow({
  required AstroChartRouteMode routeMode,
  required bool isCurrent,
}) {
  final workbench = AstroChartWorkbenchPrefs.forRouteMode(routeMode);
  final summary = summarizeAstroChartSample(
    astroChartComparisonSampleProfile,
    workbench: workbench,
    sampleName: _routeModeLabel(routeMode),
  );
  final standard = summarizeAstroChartSample(
    astroChartComparisonSampleProfile,
    workbench: AstroChartWorkbenchPrefs.forRouteMode(
      AstroChartRouteMode.standard,
    ),
    sampleName: _routeModeLabel(AstroChartRouteMode.standard),
  );
  final delta = compareAstroChartSampleSummaries(standard, summary);
  return AstroRouteParityRow(
    routeMode: routeMode,
    workbench: workbench,
    summary: summary,
    deltaFromStandard: delta,
    isCurrent: isCurrent,
  );
}

String _routeModeLabel(AstroChartRouteMode mode) {
  switch (mode) {
    case AstroChartRouteMode.standard:
      return '标准路线';
    case AstroChartRouteMode.classical:
      return '古典路线';
    case AstroChartRouteMode.modern:
      return '现代路线';
  }
}

String _routeModeDescription(AstroChartRouteMode mode) {
  switch (mode) {
    case AstroChartRouteMode.standard:
      return '默认展示与解释上下文，保持现有信息密度';
    case AstroChartRouteMode.classical:
      return '收紧到核心点位与主相位，强调古典阅读';
    case AstroChartRouteMode.modern:
      return '保留更丰富的扩展点位与相位，强调现代阅读';
  }
}

String _workbenchLabel(AstroChartWorkbenchPrefs workbench) =>
    '黄道=${_zodiacModeLabel(workbench.zodiacMode)} / 宫位=${_houseSystemLabel(workbench.houseSystem)} / '
    '相位=${_aspectModeLabel(workbench.aspectMode)} / 容许度=${_orbPresetLabel(workbench.orbPreset)} / '
    '点位=${_pointModeLabel(workbench.pointMode)}';

String _zodiacModeLabel(AstroZodiacMode mode) {
  switch (mode) {
    case AstroZodiacMode.tropical:
      return '回归黄道';
    case AstroZodiacMode.sidereal:
      return '恒星黄道';
  }
}

String _houseSystemLabel(AstroHouseSystem mode) {
  switch (mode) {
    case AstroHouseSystem.whole:
      return 'Whole';
    case AstroHouseSystem.placidus:
      return 'Placidus';
    case AstroHouseSystem.alcabitius:
      return 'Alcabitius';
  }
}

String _aspectModeLabel(AstroAspectMode mode) {
  switch (mode) {
    case AstroAspectMode.major:
      return '主相位';
    case AstroAspectMode.standard:
      return '标准';
    case AstroAspectMode.extended:
      return '扩展';
  }
}

String _orbPresetLabel(AstroOrbPreset mode) {
  switch (mode) {
    case AstroOrbPreset.tight:
      return '紧凑';
    case AstroOrbPreset.standard:
      return '标准';
    case AstroOrbPreset.wide:
      return '宽松';
  }
}

String _pointModeLabel(AstroPointMode mode) {
  switch (mode) {
    case AstroPointMode.core:
      return '核心';
    case AstroPointMode.extended:
      return '扩展';
    case AstroPointMode.full:
      return '全量';
  }
}

String _signed(int value) => value > 0 ? '+$value' : value.toString();
