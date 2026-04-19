import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_advanced_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';

class AstroTimingFrameworkCard extends StatelessWidget {
  const AstroTimingFrameworkCard({super.key, required this.bundle});

  final AstroTimingFrameworkBundle bundle;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppInfoSectionCard(
      title: '高级时法框架',
      subtitle: '年度视角 / 主时段占位 / 样例矩阵',
      leadingIcon: Icons.schedule_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '3.9 先把时法容器搭起来，再逐步替换占位能力。当前输出只用于展示与说明，不会回写 natal canonical truth，也不会把占位内容冒充成最终真值。',
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
              AstroPill(label: '路线：${_routeModeLabel(bundle.routeMode)}'),
              AstroPill(label: '生成：${bundle.generatedAt}'),
              AstroPill(label: '正式：${bundle.formalSignal.modeLabel}'),
              AstroPill(label: '占位：${bundle.placeholderSignal.modeLabel}'),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          _TimingSignalTile(
            title: bundle.formalSignal.title,
            signal: bundle.formalSignal,
            accent: const Color(0xFF4BCB92),
          ),
          SizedBox(height: t.spacing.sm),
          _TimingSignalTile(
            title: bundle.placeholderSignal.title,
            signal: bundle.placeholderSignal,
            accent: const Color(0xFFF5A623),
          ),
          SizedBox(height: t.spacing.sm),
          Text(
            '样例矩阵',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          ...bundle.sampleCases.map(
            (sampleCase) => Padding(
              padding: EdgeInsets.only(bottom: t.spacing.xs),
              child: _TimingCaseTile(sampleCase: sampleCase),
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
          ...bundle.knownDeviations.map(
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
        ],
      ),
    );
  }
}

class _TimingSignalTile extends StatelessWidget {
  const _TimingSignalTile({
    required this.title,
    required this.signal,
    required this.accent,
  });

  final String title;
  final AstroTimingSignal signal;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: accent.withValues(alpha: 0.26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                signal.modeLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            signal.summary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: signal.badges
                .map((label) => _pill(label, accent))
                .toList(),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            '基础：${signal.basisLabel} · 层：${signal.layerLabel}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.35,
            ),
          ),
          if (signal.tags.isNotEmpty) ...[
            SizedBox(height: t.spacing.xxs),
            Text(
              '标签：${signal.tags.join('，')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pill(String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TimingCaseTile extends StatelessWidget {
  const _TimingCaseTile({required this.sampleCase});

  final AstroTimingSampleCase sampleCase;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final scheme = Theme.of(context).colorScheme;
    final accent = sampleCase.isEdgeCase ? scheme.error : scheme.primary;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  sampleCase.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                sampleCase.isEdgeCase ? 'edge' : 'baseline',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            sampleCase.subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: sampleCase.signals
                .map((signal) => _pill(signal.modeLabel, accent))
                .toList(),
          ),
          SizedBox(height: t.spacing.xs),
          ...sampleCase.notes.map(
            (note) => Padding(
              padding: EdgeInsets.only(bottom: t.spacing.xxs),
              child: Text(
                '• $note',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _routeModeLabel(AstroChartRouteMode mode) => switch (mode) {
  AstroChartRouteMode.standard => '标准路线',
  AstroChartRouteMode.classical => '古典路线',
  AstroChartRouteMode.modern => '现代路线',
};
