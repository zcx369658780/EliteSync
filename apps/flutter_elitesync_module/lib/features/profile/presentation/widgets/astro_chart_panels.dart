import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';

class AstroRadarChartCard extends StatelessWidget {
  const AstroRadarChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.axisLabels,
    required this.values,
    this.maxValue = 100,
    this.centerTitle,
    this.centerSubtitle,
    this.valueLabels,
    this.fillColor,
    this.borderColor,
  }) : assert(axisLabels.length == values.length, 'axisLabels and values must have the same length');

  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> axisLabels;
  final List<double> values;
  final double maxValue;
  final String? centerTitle;
  final String? centerSubtitle;
  final List<String>? valueLabels;
  final Color? fillColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;
    final normalized = values
        .map((value) => value.clamp(0, safeMax).toDouble())
        .map((value) => value.isFinite ? value : 0.0)
        .toList(growable: false);

    if (normalized.isEmpty) {
      return AstroSectionCard(
        title: title,
        subtitle: subtitle,
        icon: icon,
        child: Text(
          '暂无可视化数据',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
        ),
      );
    }

    final radarFill = fillColor ?? t.brandPrimary.withValues(alpha: 0.26);
    final radarBorder = borderColor ?? t.brandPrimary;

    return AstroSectionCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                RadarChart(
                  RadarChartData(
                    dataSets: [
                      RadarDataSet(
                        dataEntries: normalized.map((value) => RadarEntry(value: value)).toList(growable: false),
                        fillColor: radarFill,
                        borderColor: radarBorder,
                        borderWidth: 2,
                        entryRadius: 4,
                      ),
                    ],
                    radarBackgroundColor: radarBorder.withValues(alpha: 0.04),
                    radarBorderData: BorderSide(color: radarBorder.withValues(alpha: 0.30), width: 1.2),
                    radarShape: RadarShape.polygon,
                    titlePositionPercentageOffset: 0.22,
                    tickCount: 5,
                    ticksTextStyle: Theme.of(context).textTheme.labelSmall?.copyWith(color: t.textSecondary),
                    titleTextStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                    tickBorderData: BorderSide(color: t.browseBorder.withValues(alpha: 0.90), width: 1),
                    gridBorderData: BorderSide(color: t.browseBorder.withValues(alpha: 0.55), width: 1),
                    getTitle: (index, angle) => RadarChartTitle(
                      text: axisLabels[index],
                      angle: angle,
                    ),
                    isMinValueAtCenter: true,
                  ),
                ),
                if ((centerTitle ?? '').isNotEmpty || (centerSubtitle ?? '').isNotEmpty)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.browseSurface.withValues(alpha: 0.94),
                      border: Border.all(color: radarBorder.withValues(alpha: 0.18)),
                    ),
                    padding: EdgeInsets.all(t.spacing.sm),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if ((centerTitle ?? '').isNotEmpty)
                          Text(
                            centerTitle!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        if ((centerSubtitle ?? '').isNotEmpty) ...[
                          SizedBox(height: t.spacing.xxs),
                          Text(
                            centerSubtitle!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: t.textSecondary,
                                  height: 1.25,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: t.spacing.sm),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: List.generate(axisLabels.length, (index) {
              final value = normalized[index];
              final label = axisLabels[index];
              final suffix = valueLabels != null && index < valueLabels!.length ? valueLabels![index] : _formatValueLabel(value);
              return AstroPill(label: '$label $suffix');
            }),
          ),
        ],
      ),
    );
  }
}


class AstroBarChartCard extends StatelessWidget {
  const AstroBarChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.labels,
    required this.values,
    this.maxY = 100,
    this.barColor,
    this.centerTitle,
    this.centerSubtitle,
  }) : assert(labels.length == values.length, 'labels and values must have the same length');

  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> labels;
  final List<double> values;
  final double maxY;
  final Color? barColor;
  final String? centerTitle;
  final String? centerSubtitle;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final color = barColor ?? t.brandPrimary;
    return AstroSectionCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.45,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: maxY <= 5 ? 1 : maxY / 4,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: t.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            labels[index],
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: t.textPrimary, fontWeight: FontWeight.w700),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: t.browseBorder.withValues(alpha: 0.55), strokeWidth: 1),
                ),
                barGroups: List.generate(values.length, (index) {
                  final value = values[index].clamp(0, maxY).toDouble();
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        width: 18,
                        color: color.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(6),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: t.browseBorder.withValues(alpha: 0.22),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          if ((centerTitle ?? '').isNotEmpty || (centerSubtitle ?? '').isNotEmpty) ...[
            SizedBox(height: t.spacing.sm),
            Wrap(
              spacing: t.spacing.xs,
              runSpacing: t.spacing.xs,
              children: [
                if ((centerTitle ?? '').isNotEmpty) AstroPill(label: centerTitle!),
                if ((centerSubtitle ?? '').isNotEmpty) AstroPill(label: centerSubtitle!),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class AstroWheelChartCard extends StatelessWidget {
  const AstroWheelChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.centerTitle,
    required this.centerSubtitle,
    required this.sectionLabels,
    this.sectionColors,
    this.highlightLabels = const [],
  }) : assert(sectionLabels.length >= 3, 'sectionLabels must contain at least 3 items');

  final String title;
  final String subtitle;
  final IconData icon;
  final String centerTitle;
  final String centerSubtitle;
  final List<String> sectionLabels;
  final List<Color>? sectionColors;
  final List<String> highlightLabels;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final colors = sectionColors ?? _defaultWheelColors(context, sectionLabels.length);

    return AstroSectionCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 1.2,
                    centerSpaceRadius: 82,
                    startDegreeOffset: -90,
                    titleSunbeamLayout: true,
                    borderData: FlBorderData(show: false),
                    sections: List.generate(sectionLabels.length, (index) {
                      final label = sectionLabels[index];
                      final color = colors[index % colors.length];
                      final isHighlight = highlightLabels.contains(label);
                      return PieChartSectionData(
                        value: 1,
                        color: isHighlight ? color : color.withValues(alpha: 0.76),
                        radius: isHighlight ? 88 : 80,
                        showTitle: true,
                        title: label,
                        titleStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                        titlePositionPercentageOffset: 0.72,
                        borderSide: BorderSide(color: t.browseSurface, width: 1.2),
                      );
                    }),
                  ),
                ),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.browseSurface.withValues(alpha: 0.95),
                    border: Border.all(color: t.brandPrimary.withValues(alpha: 0.18)),
                  ),
                  padding: EdgeInsets.all(t.spacing.sm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        centerTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      SizedBox(height: t.spacing.xxs),
                      Text(
                        centerSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: t.textSecondary,
                              height: 1.25,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: t.spacing.sm),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: sectionLabels.map((label) {
              final highlight = highlightLabels.contains(label);
              return AstroPill(
                label: label,
                color: highlight ? t.brandPrimary : t.textSecondary,
              );
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }
}

String _formatValueLabel(double value) {
  final normalized = value.clamp(0, double.infinity);
  return normalized.truncateToDouble() == normalized ? normalized.toStringAsFixed(0) : normalized.toStringAsFixed(1);
}

List<Color> _defaultWheelColors(BuildContext context, int count) {
  final t = context.appTokens;
  final palette = [
    t.brandPrimary,
    t.brandSecondary,
    t.brandPrimary.withValues(alpha: 0.76),
    t.brandSecondary.withValues(alpha: 0.76),
    t.brandPrimary.withValues(alpha: 0.60),
    t.brandSecondary.withValues(alpha: 0.60),
    t.brandPrimary.withValues(alpha: 0.46),
    t.brandSecondary.withValues(alpha: 0.46),
  ];
  if (count <= palette.length) return palette;
  return List.generate(count, (index) => palette[index % palette.length]);
}
