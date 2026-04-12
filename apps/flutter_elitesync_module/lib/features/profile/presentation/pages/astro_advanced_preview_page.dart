import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_advanced_capability_card.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_advanced_sample_set.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state_view.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_route_parity_report.dart';

class AstroAdvancedPreviewPage extends ConsumerWidget {
  const AstroAdvancedPreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.appTokens;
    final async = ref.watch(astroAdvancedPreviewProvider);
    final workbenchPrefs = ref.watch(astroChartWorkbenchProvider);

    Future<void> reloadPreview() async {
      ref.invalidate(astroAdvancedPreviewProvider);
      try {
        await ref.read(astroAdvancedPreviewProvider.future);
      } catch (_) {
        // Error state is rendered below.
      }
    }

    return AppScaffold(
      appBar: const AppTopBar(title: '高级解读', mode: AppTopBarMode.backTitle),
      body: RefreshIndicator(
        onRefresh: reloadPreview,
        child: ListView(
          padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
          children: [
            const SectionReveal(
              child: PageTitleRail(
                title: '高级解读',
                subtitle: '合盘 / 行运 / 返照的 scaffold 预览与路线解释',
              ),
            ),
            SizedBox(height: t.spacing.md),
            async.when(
              loading: () =>
                  AstroProfileStateView(spec: astroProfileLoadingSpec('高级解读')),
              error: (e, _) {
                final spec = astroProfileErrorSpec('高级解读', e);
                return AstroProfileStateView(
                  spec: spec,
                  onAction: spec.actionLabel == '去登录'
                      ? () => context.go(AppRouteNames.login)
                      : reloadPreview,
                );
              },
              data: (bundle) {
                if (bundle == null) {
                  final spec = astroProfileEmptySpec('高级解读');
                  return AstroProfileStateView(
                    spec: spec,
                    onAction: reloadPreview,
                  );
                }

                return Column(
                  children: [
                    AppInfoSectionCard(
                      title: '高级能力口径',
                      subtitle:
                          '只展示 derived-only / display-only / advanced-context',
                      leadingIcon: Icons.auto_awesome_rounded,
                      child: Text(
                        '当前高级解读预览基于已保存画像与 scaffold 对照主体生成：合盘、行运、返照都只用于解释层与展示层，不回写 canonical truth。若要微调路线上下文和工作台偏好，请回到设置中心；若要看 route parity，请返回本命盘详情页。',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: t.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    if (bundle.offlineFallback) ...[
                      AppInfoSectionCard(
                        title: '离线预览',
                        subtitle: '服务端高级接口暂不可用，当前展示本地样例矩阵与离线摘要',
                        leadingIcon: Icons.cloud_off_rounded,
                        child: Text(
                          'stage 4 / stage 5 的高级能力仍然遵守 derived-only / display-only / advanced-context 口径。现在页面切换到离线样例预览，方便你完成截图与归档，不会影响 canonical truth。等正式接口恢复后，再回到在线预览即可。',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: t.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ),
                      SizedBox(height: t.spacing.sm),
                    ],
                    AstroRouteParityReportCard(
                      currentRouteMode: bundle.routeMode,
                      currentWorkbench: workbenchPrefs,
                      compact: false,
                      title: '路线能力复核',
                      subtitle: '标准 / 古典 / 现代路线与高级能力同框复核',
                      onOpenDetails: () =>
                          context.push(AppRouteNames.astroChartSettings),
                    ),
                    SizedBox(height: t.spacing.sm),
                    const AstroAdvancedCapabilityCard(),
                    SizedBox(height: t.spacing.sm),
                    AstroAdvancedSampleSetView(bundle: bundle),
                    SizedBox(height: t.spacing.sm),
                    AppInfoSectionCard(
                      title: '预览日志',
                      subtitle: '用于归档与复核的 markdown 摘要',
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
                      label: '返回设置中心',
                      onPressed: () =>
                          context.push(AppRouteNames.astroChartSettings),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
