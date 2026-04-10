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
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_chart_panels.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_state_view.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/natal_chart_svg_builder.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/natal_chart_svg_card.dart';

class AstroNatalChartPage extends ConsumerWidget {
  const AstroNatalChartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.appTokens;
    final async = ref.watch(astroNatalChartProvider);
    final chartPrefs = ref.watch(astroChartSettingsProvider);
    final sectionGap = chartPrefs.compactDensity ? t.spacing.xxs : t.spacing.sm;

    Future<void> reloadAstro() async {
      ref.invalidate(astroNatalChartProvider);
      try {
        await ref.read(astroNatalChartProvider.future);
      } catch (_) {
        // Error state is rendered below.
      }
    }

    return AppScaffold(
      appBar: AppTopBar(
        title: "本命盘详情",
        mode: AppTopBarMode.backTitle,
        actions: [
          IconButton(
            tooltip: '盘面设置',
            onPressed: () => context.push(AppRouteNames.astroChartSettings),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: reloadAstro,
        child: ListView(
          padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
          children: [
            const SectionReveal(
              child: PageTitleRail(title: "西洋星盘", subtitle: "盘面主视觉"),
            ),
            SizedBox(
              height: chartPrefs.compactDensity ? t.spacing.xs : t.spacing.md,
            ),
            async.when(
              loading: () =>
                  AstroProfileStateView(spec: astroProfileLoadingSpec('星盘')),
              error: (e, _) {
                final spec = astroProfileErrorSpec('星盘', e);
                return AstroProfileStateView(
                  spec: spec,
                  onAction: spec.actionLabel == '去登录'
                      ? () => context.go(AppRouteNames.login)
                      : reloadAstro,
                );
              },
              data: (profile) {
                if (profile == null) {
                  final spec = astroProfileEmptySpec('星盘');
                  return AstroProfileStateView(
                    spec: spec,
                    onAction: reloadAstro,
                  );
                }

                final trueSolarTime = astroText(profile['true_solar_time']);
                final birthTime = astroText(profile['birth_time']);
                final birthPlace = astroText(
                  profile['birth_place'] ?? profile['private_birth_place'],
                );
                final birthLat = astroText(profile['birth_lat']);
                final birthLng = astroText(profile['birth_lng']);
                final locationShift =
                    astroDouble(profile['location_shift_minutes']) ?? 0;
                final longitudeOffset =
                    astroDouble(profile['longitude_offset_minutes']) ?? 0;
                final equationOfTime =
                    astroDouble(profile['equation_of_time_minutes']) ?? 0;
                final locationSource = astroText(
                  profile['location_source'],
                  'unknown',
                );
                final westernEngine = astroText(
                  profile['western_engine'],
                  'legacy_input',
                );
                final westernPrecision = astroText(
                  profile['western_precision'],
                  'legacy_estimate',
                );
                final westernConfidence = astroText(
                  profile['western_confidence'],
                  '0.0',
                );
                final rolloutEnabled =
                    (profile['western_rollout_enabled'] ?? false) == true;
                final rolloutReason = astroText(
                  profile['western_rollout_reason'],
                  'unknown',
                );
                final notes = astroList(profile['notes']);
                final svg = buildNatalChartSvgFromProfile(
                  profile,
                  prefs: chartPrefs,
                );
                final planets = _mapList(profile['planets_data']);
                final houses = _mapList(profile['houses_data']);
                final aspects = _mapList(profile['aspects_data']);

                return Column(
                  children: [
                    NatalChartSvgCard(svg: svg),
                    SizedBox(height: sectionGap),
                    AppInfoSectionCard(
                      title: '本地绘制',
                      subtitle: '星盘已改为 APP 端本地生成',
                      leadingIcon: Icons.edit_location_alt_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '当前页面直接使用服务端返回的 chart_data 在本机绘制星盘，不再依赖后端输出 SVG。你可以去编辑资料页修改出生时间、出生地点或经纬度，保存后会重新计算并刷新盘面。',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: t.textSecondary,
                                  height: 1.45,
                                ),
                          ),
                          SizedBox(height: t.spacing.sm),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FilledButton.icon(
                              onPressed: () =>
                                  context.push(AppRouteNames.editProfile),
                              icon: const Icon(Icons.edit_location_alt_rounded),
                              label: const Text('编辑出生资料'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sectionGap),
                    if (chartPrefs.showPlanetSummary) ...[
                      AstroSectionCard(
                        title: '行星摘要',
                        subtitle: '按列表查看行星、度数与落座信息',
                        icon: Icons.public_rounded,
                        child: _StructuredFactList(
                          items: planets
                              .take(12)
                              .map((row) {
                                final name = astroText(
                                  row['name'],
                                  astroText(row['key'], '-'),
                                );
                                final sign = astroText(row['sign'], '-');
                                final house = astroText(row['house'], '-');
                                final position = astroText(
                                  row['position'],
                                  '-',
                                );
                                return _FactRowItem(
                                  icon: _planetGlyph(name),
                                  title: name,
                                  value: position,
                                  subtitle: '$sign / $house',
                                );
                              })
                              .toList(growable: false),
                        ),
                      ),
                      SizedBox(height: sectionGap),
                    ],
                    if (chartPrefs.showHouseSummary && houses.isNotEmpty) ...[
                      AstroSectionCard(
                        title: '宫位摘要',
                        subtitle: '按列表查看宫位与星座归属',
                        icon: Icons.view_column_rounded,
                        child: _StructuredFactList(
                          items: houses
                              .take(12)
                              .map((row) {
                                final name = astroText(
                                  row['name'],
                                  '${astroText(row['index'], '-')}宫',
                                );
                                final sign = astroText(row['sign'], '-');
                                final position = astroText(
                                  row['position'],
                                  '-',
                                );
                                return _FactRowItem(
                                  icon: _zodiacGlyph(sign),
                                  title: name,
                                  value: position,
                                  subtitle: sign,
                                );
                              })
                              .toList(growable: false),
                        ),
                      ),
                      SizedBox(height: sectionGap),
                    ],
                    if (chartPrefs.showAspectSummary && aspects.isNotEmpty) ...[
                      AstroSectionCard(
                        title: '相位摘要',
                        subtitle: '主要相位关系按列表展示',
                        icon: Icons.share_outlined,
                        child: Column(
                          children: aspects
                              .take(8)
                              .map((row) {
                                final p1 = astroText(row['p1_name'], '-');
                                final p2 = astroText(row['p2_name'], '-');
                                final aspect = astroText(row['aspect'], '-');
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: t.spacing.xs,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '✶',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: t.brandPrimary,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      SizedBox(width: t.spacing.xs),
                                      Expanded(
                                        child: Text(
                                          '$p1 · $aspect · $p2',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: t.textPrimary,
                                                height: 1.35,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                              .toList(growable: false),
                        ),
                      ),
                      SizedBox(height: sectionGap),
                    ],
                    if (chartPrefs.showTechnicalParameters) ...[
                      AstroBarChartCard(
                        title: '位置影响',
                        subtitle: '与出生地修正相关的三项指标',
                        icon: Icons.travel_explore_outlined,
                        labels: const ['位置修正', '经度偏移', '均时差'],
                        values: [
                          locationShift.abs(),
                          longitudeOffset.abs(),
                          equationOfTime.abs(),
                        ],
                        maxY: 90,
                      ),
                      SizedBox(height: sectionGap),
                      AstroSectionCard(
                        title: '星盘技术参数',
                        subtitle: '硬核参数统一下沉，避免干扰主视觉',
                        icon: Icons.fact_check_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AstroKeyValueRow(label: '出生时间', value: birthTime),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(
                              label: '真太阳时',
                              value: trueSolarTime,
                              emphasis: true,
                            ),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(label: '出生地', value: birthPlace),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(
                              label: '经纬度',
                              value: '$birthLat / $birthLng',
                            ),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(
                              label: '位置修正',
                              value: '${locationShift.toStringAsFixed(0)} 分钟',
                            ),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(
                              label: '经度偏移',
                              value: '${longitudeOffset.toStringAsFixed(0)} 分钟',
                            ),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(
                              label: '均时差',
                              value: '${equationOfTime.toStringAsFixed(0)} 分钟',
                            ),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(
                              label: '位置来源',
                              value: locationSource,
                            ),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(label: '引擎', value: westernEngine),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(
                              label: '版本',
                              value: westernPrecision,
                            ),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(
                              label: '置信',
                              value: westernConfidence,
                            ),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(
                              label: '滚动开关',
                              value: rolloutEnabled ? '启用' : '关闭',
                            ),
                            SizedBox(height: t.spacing.xs),
                            AstroKeyValueRow(
                              label: '滚动原因',
                              value: rolloutReason,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sectionGap),
                    ],
                    AstroSectionCard(
                      title: '备注',
                      subtitle: '参数与追踪字段',
                      icon: Icons.notes_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: notes.isEmpty
                            ? [
                                Text(
                                  '无备注',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.textSecondary),
                                ),
                              ]
                            : notes
                                  .take(8)
                                  .map((e) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: t.spacing.xs,
                                      ),
                                      child: Text(
                                        '• ${e.toString()}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: t.textSecondary,
                                              height: 1.35,
                                            ),
                                      ),
                                    );
                                  })
                                  .toList(growable: false),
                      ),
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

List<Map<String, dynamic>> _mapList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => item.map((key, val) => MapEntry(key.toString(), val)))
      .toList(growable: false);
}

class _FactRowItem {
  const _FactRowItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String icon;
  final String title;
  final String value;
  final String subtitle;
}

class _StructuredFactList extends StatelessWidget {
  const _StructuredFactList({required this.items});

  final List<_FactRowItem> items;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: t.spacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 26,
                    child: Text(
                      item.icon,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: t.brandPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(width: t.spacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: t.textPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                            SizedBox(width: t.spacing.xs),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(top: 8),
                                height: 1,
                                decoration: BoxDecoration(
                                  color: t.browseBorder,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                            SizedBox(width: t.spacing.xs),
                            Text(
                              item.value,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: t.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: t.spacing.xxs),
                        Text(
                          item.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.textSecondary, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (index != items.length - 1)
              Divider(height: 1, color: t.browseBorder),
          ],
        );
      }),
    );
  }
}

String _planetGlyph(String name) {
  switch (name.toLowerCase()) {
    case 'sun':
      return '☉';
    case 'moon':
      return '☾';
    case 'mercury':
      return '☿';
    case 'venus':
      return '♀';
    case 'mars':
      return '♂';
    case 'jupiter':
      return '♃';
    case 'saturn':
      return '♄';
    case 'uranus':
      return '♅';
    case 'neptune':
      return '♆';
    case 'pluto':
      return '♇';
    case 'ascendant':
      return 'Asc';
    case 'medium coeli':
    case 'medium_coeli':
      return 'MC';
    default:
      return '✦';
  }
}

String _zodiacGlyph(String sign) {
  switch (sign) {
    case '白羊座':
    case 'Aries':
      return '♈';
    case '金牛座':
    case 'Taurus':
      return '♉';
    case '双子座':
    case 'Gemini':
      return '♊';
    case '巨蟹座':
    case 'Cancer':
      return '♋';
    case '狮子座':
    case 'Leo':
      return '♌';
    case '处女座':
    case 'Virgo':
      return '♍';
    case '天秤座':
    case 'Libra':
      return '♎';
    case '天蝎座':
    case 'Scorpio':
      return '♏';
    case '射手座':
    case 'Sagittarius':
      return '♐';
    case '摩羯座':
    case 'Capricorn':
      return '♑';
    case '水瓶座':
    case 'Aquarius':
      return '♒';
    case '双鱼座':
    case 'Pisces':
      return '♓';
    default:
      return '✧';
  }
}
