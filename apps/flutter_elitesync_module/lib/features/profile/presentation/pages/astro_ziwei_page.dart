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
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state_view.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/standard_ziwei_grid.dart';

class AstroZiweiPage extends ConsumerWidget {
  const AstroZiweiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.appTokens;
    final async = ref.watch(astroSummaryProvider);

    Future<void> reloadAstro() async {
      ref.invalidate(astroSummaryProvider);
      try {
        await ref.read(astroSummaryProvider.future);
      } catch (_) {
        // Error state is rendered by the provider consumer below.
      }
    }

    return AppScaffold(
      appBar: const AppTopBar(title: '紫微斗数详情', mode: AppTopBarMode.backTitle),
      body: RefreshIndicator(
        onRefresh: reloadAstro,
        child: ListView(
          padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
          children: [
            SectionReveal(
              child: const PageTitleRail(
                title: '紫微斗数',
                subtitle: '查看命宫、身宫、主题宫位与宫位摘要',
              ),
            ),
            SizedBox(height: t.spacing.md),
            async.when(
              loading: () =>
                  AstroProfileStateView(spec: astroProfileLoadingSpec('紫微')),
              error: (e, _) {
                final spec = astroProfileErrorSpec('紫微', e);
                return AstroProfileStateView(
                  spec: spec,
                  onAction: spec.actionLabel == '去登录'
                      ? () => context.go(AppRouteNames.login)
                      : reloadAstro,
                );
              },
              data: (profile) {
                if (profile == null) {
                  final spec = astroProfileEmptySpec('紫微');
                  return AstroProfileStateView(
                    spec: spec,
                    onAction: () {
                      reloadAstro();
                    },
                  );
                }

                final ziwei = astroMap(profile['ziwei']);
                final palaces = astroList(ziwei['palaces']);
                final lifePalace = astroText(ziwei['life_palace'], '-');
                final bodyPalace = astroText(ziwei['body_palace'], '-');
                final summary = astroText(ziwei['summary'], '暂无紫微摘要');
                final engine = astroText(
                  ziwei['engine'],
                  'ziwei_canonical_server',
                );
                final precision = astroText(
                  ziwei['precision'],
                  'full_birth_data',
                );
                final confidence = astroText(ziwei['confidence'], '0.0');
                final bazi = astroText(profile['bazi'], '');
                final birthTime = astroText(profile['birth_time']);
                final trueSolarTime = astroText(profile['true_solar_time']);
                final locationShift = astroText(
                  profile['location_shift_minutes'],
                  '0',
                );

                return Column(
                  children: [
                    AstroSectionCard(
                      title: '紫微摘要',
                      subtitle: '命宫和身宫是当前画像的核心锚点',
                      icon: Icons.grid_view_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            summary,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: t.textPrimary, height: 1.45),
                          ),
                          SizedBox(height: t.spacing.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '命宫：$lifePalace',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: t.brandPrimary.withValues(
                                        alpha: 0.92,
                                      ),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              SizedBox(height: t.spacing.xxs),
                              Text(
                                '身宫：$bodyPalace',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: t.brandPrimary.withValues(
                                        alpha: 0.76,
                                      ),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    AstroSectionCard(
                      title: '标准紫微地盘',
                      subtitle: '4x4 方形宫位网格，命宫与身宫高亮',
                      icon: Icons.grid_on_rounded,
                      fullWidth: true,
                      edgeToEdge: true,
                      child: StandardZiweiGrid(
                        palaces: palaces,
                        lifePalace: lifePalace,
                        bodyPalace: bodyPalace,
                        bazi: bazi,
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    AstroSectionCard(
                      title: '关键字段',
                      subtitle: '保留在页面下方，便于查看计算来源',
                      icon: Icons.fact_check_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AstroKeyValueRow(
                            label: '生日',
                            value: astroText(profile['birthday']),
                          ),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(label: '出生时间', value: birthTime),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(label: '真太阳时', value: trueSolarTime),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(
                            label: '位置修正',
                            value: '$locationShift 分钟',
                          ),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(label: '引擎', value: engine),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(label: '精度', value: precision),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(label: '置信', value: confidence),
                        ],
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
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
