import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_advanced_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_advanced_sample_set.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_advanced_explanation_layer_card.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_timing_framework_card.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_route_parity_report.dart';

class AstroAdvancedPreviewDemoPage extends StatelessWidget {
  const AstroAdvancedPreviewDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final bundle = _buildDemoBundle();
    final workbenchPrefs = AstroChartWorkbenchPrefs.forRouteMode(
      bundle.routeMode,
    );

    return AppScaffold(
      appBar: const AppTopBar(title: '高级时法演示', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
        children: [
          const SectionReveal(
            child: PageTitleRail(
              title: '高级时法演示',
              subtitle: '离线样例矩阵 / 路线对照 / 归档截图',
            ),
          ),
          SizedBox(height: t.spacing.md),
          AppInfoSectionCard(
            title: '演示口径',
            subtitle: 'stage 4 / stage 5 归档用静态页面',
            leadingIcon: Icons.rocket_launch_rounded,
            child: Text(
              '这一页不依赖服务端高级接口，专门用于 stage 4 / stage 5 的视觉验收、截图归档和 Gemini 复核。它保留展示与关联说明口径，重点展示路线差异、时法框架、样例矩阵和已知偏差。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.45,
              ),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          AstroTimingFrameworkCard(bundle: bundle.timing),
          SizedBox(height: t.spacing.sm),
          AstroAdvancedExplanationLayerCard(bundle: bundle),
          SizedBox(height: t.spacing.sm),
          AstroRouteParityReportCard(
            currentRouteMode: bundle.routeMode,
            currentWorkbench: workbenchPrefs,
            compact: false,
            title: '路线能力复核',
            subtitle: '标准 / 古典 / 现代路线与高级时法同框复核',
            onOpenDetails: () => context.push(AppRouteNames.astroChartSettings),
          ),
          SizedBox(height: t.spacing.sm),
          AppInfoSectionCard(
            title: '高级能力口径',
            subtitle: '只做展示与关联说明',
            leadingIcon: Icons.auto_awesome_rounded,
            child: Text(
              '当前演示页面把合盘、对比盘、行运、返照与时法框架分开陈列，作为 3.9 的正式截图入口。等正式高级页面恢复在线预览后，这个演示页仍然可作为回归基线保留。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.45,
              ),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          AstroAdvancedSampleSetView(bundle: bundle),
          SizedBox(height: t.spacing.sm),
          AppInfoSectionCard(
            title: '预览日志',
            subtitle: '用于归档和复核的 markdown 摘要',
            leadingIcon: Icons.receipt_long_rounded,
            child: SelectableText(
              bundle.toMarkdownLines().join('\n'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.45,
              ),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          AppPrimaryButton(
            label: '返回高级预览',
            onPressed: () => context.push(AppRouteNames.astroAdvancedPreview),
          ),
        ],
      ),
    );
  }
}

AstroAdvancedPreviewBundle _buildDemoBundle() {
  const routeMode = AstroChartRouteMode.modern;
  const nowLabel = '2026-04-12 10:30';
  const subject = 'EliteSync';

  return AstroAdvancedPreviewBundle(
    routeMode: routeMode,
    offlineFallback: true,
    timing: buildAstroTimingFrameworkBundle(
      const {'name': subject, 'birthday': '1994-04-17', 'birth_time': '09:30'},
      routeMode,
      referenceNow: DateTime(2026, 4, 17, 10, 30),
    ),
    requests: AstroAdvancedPreviewRequests(
      pair: const {
        'first': {'name': subject},
        'second': {'name': '示例对照档'},
        'pair_mode': 'synastry',
        'route_mode': 'modern',
      },
      comparison: const {
        'first': {'name': subject},
        'second': {'name': '示例对比档'},
        'pair_mode': 'comparison',
        'route_mode': 'modern',
      },
      transit: const {
        'natal': {'name': subject},
        'transit': {'name': '行运参考盘'},
        'route_mode': 'modern',
      },
      returnChart: const {
        'natal': {'name': subject},
        'return_year': 2026,
        'return_type': 'Lunar',
        'route_mode': 'modern',
      },
    ),
    pair: AstroAdvancedPreviewItem(
      title: '合盘预览（演示）',
      summary: '$subject × 示例对照档 · 演示样例 · 9 相位',
      routeMode: routeMode.name,
      generatedAt: nowLabel,
      primaryName: subject,
      secondaryName: '示例对照档',
      primaryPointCount: 20,
      secondaryPointCount: 20,
      aspectCount: 9,
      chartKind: 'synastry',
      advancedMode: 'pair',
      pairMode: 'synastry',
      relationshipScoreDescription: '演示样例',
      relationshipScoreValue: 78,
    ),
    comparison: AstroAdvancedPreviewItem(
      title: '对比盘预览（演示）',
      summary: '$subject × 示例对比档 · 演示样例 · 10 相位',
      routeMode: routeMode.name,
      generatedAt: nowLabel,
      primaryName: subject,
      secondaryName: '示例对比档',
      primaryPointCount: 20,
      secondaryPointCount: 20,
      aspectCount: 10,
      chartKind: 'comparison',
      advancedMode: 'pair',
      pairMode: 'comparison',
      relationshipScoreDescription: '对照差异',
      relationshipScoreValue: 63,
    ),
    transit: AstroAdvancedPreviewItem(
      title: '行运预览（演示）',
      summary: '$subject · 时间维度样例 · 6 相位',
      routeMode: routeMode.name,
      generatedAt: nowLabel,
      primaryName: subject,
      secondaryName: '行运参考盘',
      primaryPointCount: 20,
      secondaryPointCount: 20,
      aspectCount: 6,
      chartKind: 'transit',
      advancedMode: 'transit',
      pairMode: 'transit',
      relationshipScoreDescription: '时间维度',
      relationshipScoreValue: 55,
    ),
    returnChart: AstroAdvancedPreviewItem(
      title: '返照预览（演示）',
      summary: '$subject · 年度返照样例 · 5 相位',
      routeMode: routeMode.name,
      generatedAt: nowLabel,
      primaryName: subject,
      secondaryName: '返照参考盘',
      primaryPointCount: 20,
      secondaryPointCount: 20,
      aspectCount: 5,
      chartKind: 'return',
      advancedMode: 'return',
      returnType: 'Lunar',
      returnYear: 2026,
      relationshipScoreDescription: '年度解释',
      relationshipScoreValue: 49,
    ),
  );
}
