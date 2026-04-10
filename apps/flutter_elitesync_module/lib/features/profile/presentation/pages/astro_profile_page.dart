import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/app/router/app_route_observer.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state_view.dart';

class AstroProfilePage extends ConsumerStatefulWidget {
  const AstroProfilePage({super.key});

  @override
  ConsumerState<AstroProfilePage> createState() => _AstroProfilePageState();
}

class _AstroProfilePageState extends ConsumerState<AstroProfilePage>
    with RouteAware {
  RouteObserver<PageRoute<dynamic>>? _routeObserver;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final observer = ref.read(appRouteObserverProvider);
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      if (_routeObserver != observer) {
        _routeObserver?.unsubscribe(this);
        _routeObserver = observer;
        _routeObserver?.subscribe(this, route);
      }
    }
  }

  @override
  void dispose() {
    _routeObserver?.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    ref.invalidate(astroSummaryProvider);
  }

  @override
  Widget build(BuildContext context) {
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
      appBar: const AppTopBar(title: '星盘画像', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
        children: [
          SectionReveal(
            child: PageTitleRail(
              title: '星座 / 星盘 / 八字画像',
              subtitle: '用于匹配结果中的过程与结论解释',
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 70),
            child: AppInfoSectionCard(
              title: '当前画像',
              subtitle: '八字 / 星象 / 五行 / 大运 / 流年 / 可信度',
              leadingIcon: Icons.auto_graph_rounded,
              child: astroAsync.when(
                loading: () =>
                    AstroProfileStateView(spec: astroProfileLoadingSpec('画像')),
                error: (e, _) {
                  final spec = astroProfileErrorSpec('画像', e);
                  return AstroProfileStateView(
                    spec: spec,
                    onAction: spec.actionLabel == '去登录'
                        ? () => context.go(AppRouteNames.login)
                        : reloadAstro,
                  );
                },
                data: (profile) {
                  if (profile == null) {
                    final spec = astroProfileEmptySpec('画像');
                    return AstroProfileStateView(
                      spec: spec,
                      onAction: () {
                        reloadAstro();
                      },
                    );
                  }
                  final birthTime = (profile['birth_time'] ?? '').toString();
                  final birthPlace =
                      (profile['birth_place'] ??
                              profile['private_birth_place'] ??
                              '')
                          .toString();
                  final birthLat = profile['birth_lat'];
                  final birthLng = profile['birth_lng'];
                  final bazi = (profile['bazi'] ?? '').toString();
                  final trueSolarTime = (profile['true_solar_time'] ?? '')
                      .toString();
                  final locationShiftMinutes =
                      profile['location_shift_minutes'];
                  final longitudeOffsetMinutes =
                      profile['longitude_offset_minutes'];
                  final equationOfTimeMinutes =
                      profile['equation_of_time_minutes'];
                  final positionSignature =
                      (profile['position_signature'] ?? '').toString();
                  final locationSource = (profile['location_source'] ?? '')
                      .toString();
                  final accuracy = (profile['accuracy'] ?? '').toString();
                  final confidence = (profile['confidence'] ?? '').toString();
                  final westernEngine = (profile['western_engine'] ?? '')
                      .toString();
                  final westernPrecision = (profile['western_precision'] ?? '')
                      .toString();
                  final westernConfidence =
                      (profile['western_confidence'] ?? '').toString();
                  final sunSign = (profile['sun_sign'] ?? '').toString();
                  final moonSign = (profile['moon_sign'] ?? '').toString();
                  final ascSign = (profile['asc_sign'] ?? '').toString();
                  final ziwei =
                      (profile['ziwei'] as Map<String, dynamic>? ?? const {});
                  final majorThemes =
                      (ziwei['major_themes'] as Map<String, dynamic>? ??
                      const {});
                  final ziweiEngine = (ziwei['engine'] ?? '').toString();
                  final ziweiPrecision = (ziwei['precision'] ?? '').toString();
                  final ziweiConfidence = (ziwei['confidence'] ?? '')
                      .toString();
                  final daYun =
                      (profile['da_yun'] as List<dynamic>? ?? const [])
                          .take(4)
                          .toList();
                  final liuNian =
                      (profile['liu_nian'] as List<dynamic>? ?? const [])
                          .take(5)
                          .toList();
                  final wuXing =
                      (profile['wu_xing'] as Map<String, dynamic>? ?? const {});
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AstroSectionCard(
                        title: '基础输入',
                        subtitle: '出生时间、出生地点与经纬度',
                        icon: Icons.pin_drop_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (birthTime.isNotEmpty)
                              AstroKeyValueRow(
                                label: '出生时间',
                                value: birthTime,
                                emphasis: true,
                              ),
                            if (birthTime.isNotEmpty && birthPlace.isNotEmpty)
                              SizedBox(height: t.spacing.xxs),
                            if (birthPlace.isNotEmpty)
                              AstroKeyValueRow(
                                label: '出生地点',
                                value: birthPlace,
                                emphasis: true,
                              ),
                            if (birthPlace.isNotEmpty &&
                                (birthLat != null || birthLng != null))
                              SizedBox(height: t.spacing.xxs),
                            if (birthLat != null || birthLng != null)
                              AstroKeyValueRow(
                                label: '经纬度',
                                value:
                                    '${birthLat == null ? '-' : birthLat.toString()}，${birthLng == null ? '-' : birthLng.toString()}',
                              ),
                            if (bazi.isNotEmpty) ...[
                              SizedBox(height: t.spacing.xs),
                              AstroKeyValueRow(
                                label: '八字',
                                value: bazi,
                                emphasis: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: t.spacing.sm),
                      AstroSectionCard(
                        title: '计算元信息',
                        subtitle: '真太阳时、修正与可信度',
                        icon: Icons.tune_rounded,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (trueSolarTime.isNotEmpty)
                              AstroKeyValueRow(
                                label: '真太阳时',
                                value: trueSolarTime,
                                emphasis: true,
                              ),
                            if (trueSolarTime.isNotEmpty)
                              SizedBox(height: t.spacing.xxs),
                            if (locationShiftMinutes != null ||
                                longitudeOffsetMinutes != null ||
                                equationOfTimeMinutes != null)
                              AstroKeyValueRow(
                                label: '位置修正',
                                value:
                                    '${locationShiftMinutes ?? '-'} 分钟（经度${longitudeOffsetMinutes ?? '-'} / 均时差${equationOfTimeMinutes ?? '-'}）',
                              ),
                            if (positionSignature.isNotEmpty) ...[
                              SizedBox(height: t.spacing.xxs),
                              AstroKeyValueRow(
                                label: '位置签名',
                                value:
                                    '$positionSignature${locationSource.isNotEmpty ? '（$locationSource）' : ''}',
                              ),
                            ],
                            if (accuracy.isNotEmpty ||
                                confidence.isNotEmpty ||
                                westernEngine.isNotEmpty ||
                                westernPrecision.isNotEmpty ||
                                westernConfidence.isNotEmpty) ...[
                              SizedBox(height: t.spacing.xs),
                              if (accuracy.isNotEmpty ||
                                  confidence.isNotEmpty) ...[
                                Text(
                                  '八字可信度',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: t.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                SizedBox(height: t.spacing.xxs),
                                Text(
                                  '${accuracy.isEmpty ? '-' : accuracy} / 置信 ${confidence.isEmpty ? '-' : confidence}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                              ],
                              if (westernEngine.isNotEmpty ||
                                  westernPrecision.isNotEmpty ||
                                  westernConfidence.isNotEmpty) ...[
                                SizedBox(height: t.spacing.sm),
                                Text(
                                  '西占可信度',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: t.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                SizedBox(height: t.spacing.xxs),
                                Text(
                                  '引擎 ${westernEngine.isEmpty ? '-' : westernEngine} · 版本 ${westernPrecision.isEmpty ? '-' : westernPrecision} · 置信 ${westernConfidence.isEmpty ? '-' : westernConfidence}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: t.spacing.sm),
                      AstroSectionCard(
                        title: '模块摘要',
                        subtitle: '星象、五行与紫微核心摘要',
                        icon: Icons.auto_awesome_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (sunSign.isNotEmpty ||
                                moonSign.isNotEmpty ||
                                ascSign.isNotEmpty)
                              Text(
                                '星象：太阳$sunSign  月亮$moonSign  上升$ascSign',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: t.textSecondary),
                              ),
                            if (sunSign.isNotEmpty ||
                                moonSign.isNotEmpty ||
                                ascSign.isNotEmpty)
                              SizedBox(height: t.spacing.xxs),
                            if (wuXing.isNotEmpty)
                              Text(
                                '五行：木${wuXing['木'] ?? 0} 火${wuXing['火'] ?? 0} 土${wuXing['土'] ?? 0} 金${wuXing['金'] ?? 0} 水${wuXing['水'] ?? 0}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: t.textSecondary),
                              ),
                            if (wuXing.isNotEmpty)
                              SizedBox(height: t.spacing.sm),
                            if (ziwei.isNotEmpty) ...[
                              Text(
                                '紫微斗数',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: t.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              SizedBox(height: t.spacing.xxs),
                              if (ziweiEngine.isNotEmpty ||
                                  ziweiPrecision.isNotEmpty ||
                                  ziweiConfidence.isNotEmpty)
                                Text(
                                  '引擎 ${ziweiEngine.isEmpty ? '-' : ziweiEngine} · 版本 ${ziweiPrecision.isEmpty ? '-' : ziweiPrecision} · 置信 ${ziweiConfidence.isEmpty ? '-' : ziweiConfidence}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                              if ((ziwei['summary'] ?? '')
                                  .toString()
                                  .isNotEmpty) ...[
                                SizedBox(height: t.spacing.xxs),
                                Text(
                                  '摘要：${ziwei['summary']}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                              ],
                              if ((ziwei['life_palace'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                                Text(
                                  '命宫：${ziwei['life_palace']}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                              if ((ziwei['body_palace'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                                Text(
                                  '身宫：${ziwei['body_palace']}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                              if (majorThemes.isNotEmpty)
                                Text(
                                  '主题：关系${majorThemes['relationship_bias'] ?? '-'} / 事业${majorThemes['career_bias'] ?? '-'} / 财帛${majorThemes['wealth_bias'] ?? '-'}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: t.spacing.sm),
                      AstroSectionCard(
                        title: '阶段与备注',
                        subtitle: '大运、流年与追踪标签',
                        icon: Icons.timeline_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (daYun.isNotEmpty) ...[
                              Text(
                                '大运（节选）',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: t.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              SizedBox(height: t.spacing.xxs),
                              ...daYun.map(
                                (e) => Text(
                                  '• ${e is Map ? (e['gan_zhi'] ?? '-') : '-'} ${e is Map ? ((e['start_year'] ?? '').toString()) : ''}~${e is Map ? ((e['end_year'] ?? '').toString()) : ''}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                              ),
                              SizedBox(height: t.spacing.sm),
                            ],
                            if (liuNian.isNotEmpty) ...[
                              Text(
                                '流年（节选）',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: t.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              SizedBox(height: t.spacing.xxs),
                              ...liuNian.map(
                                (e) => Text(
                                  '• ${e is Map ? (e['year'] ?? '-') : '-'}年 ${e is Map ? (e['gan_zhi'] ?? '-') : '-'}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                              ),
                            ],
                            if (profile['notes'] != null &&
                                (profile['notes'] as List).isNotEmpty) ...[
                              SizedBox(height: t.spacing.sm),
                              Text(
                                '备注',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: t.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              SizedBox(height: t.spacing.xxs),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: astroList(profile['notes'])
                                    .take(8)
                                    .map((e) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom: t.spacing.xxs,
                                        ),
                                        child: Text(
                                          '• ${e.toString()}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: t.textSecondary
                                                    .withValues(alpha: 0.82),
                                                height: 1.35,
                                              ),
                                        ),
                                      );
                                    })
                                    .toList(growable: false),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 120),
            child: AppInfoSectionCard(
              title: '画像数据来源',
              subtitle: '服务端优先，支持后续算法升级平滑替换',
              leadingIcon: Icons.storage_rounded,
              child: Text(
                '当前页面优先读取服务端画像（八字 / 大运 / 流年 / 五行），并同步展示星盘与紫微的关键字段。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: t.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
