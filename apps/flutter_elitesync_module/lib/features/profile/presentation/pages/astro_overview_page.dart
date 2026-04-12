import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_overview_components.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_advanced_capability_card.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state_view.dart';

class AstroOverviewPage extends ConsumerWidget {
  const AstroOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.appTokens;
    final astroAsync = ref.watch(astroSummaryProvider);

    Future<void> reloadAstro() async {
      ref.invalidate(astroSummaryProvider);
      try {
        await ref.read(astroSummaryProvider.future);
      } catch (_) {
        // Error state is rendered by the provider consumer below.
      }
    }

    return AppScaffold(
      appBar: const AppTopBar(title: '玄学总览', mode: AppTopBarMode.backTitle),
      body: RefreshIndicator(
        onRefresh: reloadAstro,
        child: ListView(
          padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
          children: [
            const SectionReveal(
              child: PageTitleRail(title: '玄学总览', subtitle: '身份摘要、视觉门户与当前五行能量'),
            ),
            SizedBox(height: t.spacing.md),
            astroAsync.when(
              loading: () =>
                  AstroProfileStateView(spec: astroProfileLoadingSpec('玄学总览')),
              error: (e, _) {
                final spec = astroProfileErrorSpec('玄学总览', e);
                return AstroProfileStateView(
                  spec: spec,
                  onAction: spec.actionLabel == '去登录'
                      ? () => context.go(AppRouteNames.login)
                      : reloadAstro,
                );
              },
              data: (profile) {
                if (profile == null) {
                  final spec = astroProfileEmptySpec('玄学总览');
                  return AstroProfileStateView(
                    spec: spec,
                    onAction: reloadAstro,
                  );
                }

                final bazi = astroText(profile['bazi'], '暂无八字');
                final ziwei = astroMap(profile['ziwei']);
                final wuXing = astroMap(profile['wu_xing']);
                final computedAt = astroDateTimeLabel(profile['computed_at']);

                return Column(
                  children: [
                    AstroIdentityHeader(profile: profile),
                    SizedBox(height: t.spacing.sm),
                    AstroAdvancedCapabilityCard(
                      onOpenDetails: () =>
                          context.push(AppRouteNames.astroAdvancedPreviewDemo),
                    ),
                    SizedBox(height: t.spacing.sm),
                    AstroSectionCard(
                      title: '视觉门户',
                      subtitle: '从总览直接进入八字、星盘与紫微详情',
                      icon: Icons.dashboard_customize_outlined,
                      child: Column(
                        children: [
                          AstroPortalCard(
                            title: '八字详情',
                            subtitle: '四柱矩阵、五行能量、大运与流年（服务端真值）',
                            preview: BaziOverviewPreview(bazi: bazi),
                            onTap: () => context.push(AppRouteNames.astroBazi),
                          ),
                          SizedBox(height: t.spacing.sm),
                          AstroPortalCard(
                            title: '本命盘详情',
                            subtitle: '总览只展示三轴识别，完整盘面进入详情页查看（本地绘制）',
                            preview: NatalAxisPoster(profile: profile),
                            onTap: () =>
                                context.push(AppRouteNames.astroNatalChart),
                          ),
                          SizedBox(height: t.spacing.sm),
                          AstroPortalCard(
                            title: '紫微斗数详情',
                            subtitle: '方形宫位地盘、命宫命星与结构化宫位摘要',
                            preview: ZiweiOverviewPreview(ziwei: ziwei),
                            onTap: () => context.push(AppRouteNames.astroZiwei),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    WuXingPulseStrip(wuXing: wuXing),
                    SizedBox(height: t.spacing.sm),
                    AstroModuleCard(
                      title: '画像详情',
                      subtitle: '技术参数与完整画像保留在详情/诊断页，资料修改后会自动刷新',
                      summary: '查看服务端画像字段、调试字段与更新时间。最近更新：$computedAt',
                      icon: Icons.analytics_outlined,
                      badge: 'diagnostics',
                      onTap: () => context.push(AppRouteNames.astroProfile),
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

