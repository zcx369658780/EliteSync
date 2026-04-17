import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_advanced_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state_view.dart';

class AstroAdvancedCapabilityCard extends ConsumerWidget {
  const AstroAdvancedCapabilityCard({super.key, this.onOpenDetails});

  final VoidCallback? onOpenDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.appTokens;
    final async = ref.watch(astroAdvancedPreviewProvider);

    return async.when(
      loading: () =>
          AstroProfileStateView(spec: astroProfileLoadingSpec('高级时法')),
      error: (error, _) {
        final spec = astroProfileErrorSpec('高级时法', error);
        return AstroProfileStateView(
          spec: spec,
          onAction: spec.actionLabel == '去登录'
              ? () => context.go(AppRouteNames.login)
              : () => ref.invalidate(astroAdvancedPreviewProvider),
        );
      },
      data: (bundle) {
        if (bundle == null) {
          final spec = astroProfileEmptySpec('高级时法');
          return AstroProfileStateView(
            spec: spec,
            onAction: () => ref.invalidate(astroAdvancedPreviewProvider),
          );
        }

        return AppInfoSectionCard(
          title: '高级时法预览',
          subtitle: '合盘 / 行运 / 返照 / 时法 scaffold 预览已接入',
          leadingIcon: Icons.auto_awesome_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '这层内容只展示 derived-only / display-only / advanced-context 的结果，不回写真值；当前会优先使用已保存画像并生成 scaffold 预览，方便验证 3.9 的关系维度、时间维度与时法容器链路。',
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
                  AstroPill(label: '时法：timing mode v1'),
                  AstroPill(label: '接口：pair / comparison / transit / return'),
                  AstroPill(label: '报告：advanced context'),
                ],
              ),
              SizedBox(height: t.spacing.sm),
              _AdvancedPreviewTile(
                item: bundle.pair,
                accent: const Color(0xFF5AA8FF),
              ),
              SizedBox(height: t.spacing.sm),
              _AdvancedPreviewTile(
                item: bundle.comparison,
                accent: const Color(0xFF8F7BFF),
              ),
              SizedBox(height: t.spacing.sm),
              _AdvancedPreviewTile(
                item: bundle.transit,
                accent: const Color(0xFF4BCB92),
              ),
              SizedBox(height: t.spacing.sm),
              _AdvancedPreviewTile(
                item: bundle.returnChart,
                accent: const Color(0xFFF5A623),
              ),
              if (onOpenDetails != null) ...[
                SizedBox(height: t.spacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: onOpenDetails,
                    icon: const Icon(Icons.tune_rounded),
                    label: const Text('打开高级详情'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AdvancedPreviewTile extends StatelessWidget {
  const _AdvancedPreviewTile({required this.item, required this.accent});

  final AstroAdvancedPreviewItem item;
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
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AstroPill(label: item.modeLabel, color: accent),
            ],
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            item.summary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: [
              AstroPill(label: item.routeLabel, color: accent),
              AstroPill(label: '图种：${item.chartKind}', color: accent),
              AstroPill(label: item.metricsLabel, color: accent),
              AstroPill(label: '生成：${item.generatedAt}', color: accent),
            ],
          ),
          if (item.relationshipScoreDescription != null ||
              item.pairMode != null ||
              item.returnType != null) ...[
            SizedBox(height: t.spacing.xs),
            Text(
              _detailLine(item),
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
}

String _detailLine(AstroAdvancedPreviewItem item) {
  final parts = <String>[];
  if ((item.primaryName).isNotEmpty) {
    parts.add('主档 ${item.primaryName}');
  }
  if ((item.secondaryName).isNotEmpty) {
    parts.add('对照 ${item.secondaryName}');
  }
  if ((item.relationshipScoreDescription ?? '').isNotEmpty) {
    parts.add('关系评分 ${item.relationshipScoreDescription}');
  }
  if ((item.pairMode ?? '').isNotEmpty) {
    parts.add('pair_mode ${item.pairMode}');
  }
  if ((item.returnType ?? '').isNotEmpty) {
    parts.add('return_type ${item.returnType}');
  }
  if (item.returnYear != null) {
    parts.add('return_year ${item.returnYear}');
  }
  return parts.join(' · ');
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
