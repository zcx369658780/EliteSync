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
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/bazi_timeline_section.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/professional_bazi_grid.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/wu_xing_energy_bar.dart';

class AstroBaziPage extends ConsumerWidget {
  const AstroBaziPage({super.key});

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
      appBar: const AppTopBar(title: '八字详情', mode: AppTopBarMode.backTitle),
      body: RefreshIndicator(
        onRefresh: reloadAstro,
        child: ListView(
          padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
          children: [
            SectionReveal(
              child: const PageTitleRail(
                title: '八字',
                subtitle: '查看真太阳时、四柱、五行、大运与流年',
              ),
            ),
            SizedBox(height: t.spacing.md),
            async.when(
              loading: () =>
                  AstroProfileStateView(spec: astroProfileLoadingSpec('八字')),
              error: (e, _) {
                final spec = astroProfileErrorSpec('八字', e);
                return AstroProfileStateView(
                  spec: spec,
                  onAction: spec.actionLabel == '去登录'
                      ? () => context.go(AppRouteNames.login)
                      : reloadAstro,
                );
              },
              data: (profile) {
                if (profile == null) {
                  final spec = astroProfileEmptySpec('八字');
                  return AstroProfileStateView(
                    spec: spec,
                    onAction: () {
                      reloadAstro();
                    },
                  );
                }

                final bazi = astroText(profile['bazi'], '暂无八字');
                final backendBaziDetails = astroMap(profile['bazi_details']);
                // 临时前端模拟数据仅用于 UI 演示；最终应由后端 /api/v1/profile/astro 提供。
                final mockBaziDetails = _buildMockBaziDetails(bazi);
                final baziDetails = _mergeBaziDetails(
                  mockBaziDetails,
                  backendBaziDetails,
                );
                final trueSolarTime = astroText(profile['true_solar_time']);
                final birthTime = astroText(profile['birth_time']);
                final birthPlace = astroText(
                  profile['birth_place'] ?? profile['private_birth_place'],
                );
                final birthday = astroText(profile['birthday']);
                final locationShift = astroText(
                  profile['location_shift_minutes'],
                  '0',
                );
                final longitudeOffset = astroText(
                  profile['longitude_offset_minutes'],
                  '0',
                );
                final equationOfTime = astroText(
                  profile['equation_of_time_minutes'],
                  '0',
                );
                final locationSource = astroText(
                  profile['location_source'],
                  'unknown',
                );
                final accuracy = astroText(
                  profile['accuracy'],
                  'canonical_server',
                );
                final confidence = astroText(profile['confidence'], '0.0');
                final wuXing = astroMap(profile['wu_xing']);
                final notes = astroList(profile['notes']);
                final daYun = astroList(profile['da_yun']);
                final liuNian = astroList(profile['liu_nian']);

                return Column(
                  children: [
                    AstroSectionCard(
                      title: '四柱矩阵',
                      subtitle: '按四柱查看命盘核心信息',
                      icon: Icons.fact_check_outlined,
                      fullWidth: true,
                      edgeToEdge: true,
                      child: ProfessionalBaziGrid(
                        bazi: bazi,
                        baziDetails: baziDetails,
                        mockBaziDetails: mockBaziDetails,
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    AstroSectionCard(
                      title: '五行能量',
                      subtitle: '按总量折算为百分比，直观看到五行分布',
                      icon: Icons.waterfall_chart_outlined,
                      child: WuXingEnergyBar(wuXing: wuXing),
                    ),
                    SizedBox(height: t.spacing.sm),
                    AstroSectionCard(
                      title: '大运 / 流年',
                      subtitle: '时间轴式展示阶段变化',
                      icon: Icons.timeline_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BaziTimelineSection(
                            title: '大运',
                            subtitle: '以起止年份和年龄段呈现大运流向',
                            items: daYun,
                            isDaYun: true,
                          ),
                          SizedBox(height: t.spacing.sm),
                          BaziTimelineSection(
                            title: '流年',
                            subtitle: '以年份节点和流年干支呈现年度变化',
                            items: liuNian,
                            isDaYun: false,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    AstroSectionCard(
                      title: '八字技术参数',
                      subtitle: '保留在页面底部，便于诊断和验收',
                      icon: Icons.fact_check_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AstroKeyValueRow(label: '生日', value: birthday),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(label: '出生时间', value: birthTime),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(label: '出生地', value: birthPlace),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(label: '真太阳时', value: trueSolarTime),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(
                            label: '位置修正',
                            value: '$locationShift 分钟',
                          ),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(
                            label: '经度修正',
                            value: '$longitudeOffset 分钟',
                          ),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(
                            label: '均时差',
                            value: '$equationOfTime 分钟',
                          ),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(
                            label: '位置来源',
                            value: locationSource,
                          ),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(label: '引擎', value: accuracy),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(label: '精度', value: accuracy),
                          SizedBox(height: t.spacing.xxs),
                          AstroKeyValueRow(label: '置信', value: confidence),
                        ],
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    AstroSectionCard(
                      title: '备注',
                      subtitle: '保留后端生成的参数标记',
                      icon: Icons.notes_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: notes.isEmpty
                            ? [
                                Text(
                                  '无备注',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: t.textSecondary.withValues(
                                          alpha: 0.78,
                                        ),
                                      ),
                                ),
                              ]
                            : notes
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
                                              color: t.textSecondary.withValues(
                                                alpha: 0.82,
                                              ),
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

Map<String, dynamic> _buildMockBaziDetails(String bazi) {
  final pillars = _parseBaziPillars(bazi);
  if (pillars.isEmpty) return const {};

  final dayStem = pillars.length >= 3
      ? pillars[2]['tian_gan']?.toString() ?? ''
      : '';
  final dayMasterWuxing = _elementOfGan(dayStem);
  return {'pillars': pillars, 'day_master_wuxing': dayMasterWuxing};
}

Map<String, dynamic> _mergeBaziDetails(
  Map<String, dynamic> mockBaziDetails,
  Map<String, dynamic> backendBaziDetails,
) {
  if (mockBaziDetails.isEmpty) return backendBaziDetails;
  if (backendBaziDetails.isEmpty) return mockBaziDetails;
  return {
    ...mockBaziDetails,
    ...backendBaziDetails,
    'pillars': _mergeBaziPillars(
      astroList(mockBaziDetails['pillars']),
      astroList(backendBaziDetails['pillars']),
    ),
  };
}

List<Map<String, dynamic>> _mergeBaziPillars(
  List<dynamic> mockPillars,
  List<dynamic> backendPillars,
) {
  if (mockPillars.isEmpty) {
    return backendPillars.map((e) => astroMap(e)).toList(growable: false);
  }
  if (backendPillars.isEmpty) {
    return mockPillars.map((e) => astroMap(e)).toList(growable: false);
  }
  final maxLength = mockPillars.length > backendPillars.length
      ? mockPillars.length
      : backendPillars.length;
  return List.generate(maxLength, (index) {
    final mock = index < mockPillars.length
        ? astroMap(mockPillars[index])
        : const <String, dynamic>{};
    final backend = index < backendPillars.length
        ? astroMap(backendPillars[index])
        : const <String, dynamic>{};
    return {...mock, ...backend};
  });
}

List<Map<String, dynamic>> _parseBaziPillars(String bazi) {
  final tokens = bazi
      .split(RegExp(r'\s+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);
  if (tokens.length != 4) return const [];

  const shiShenFallbacks = ['正印', '比肩', '日主', '伤官'];
  const hiddenStemMap = <String, String>{
    '子': '癸',
    '丑': '己癸辛',
    '寅': '甲丙戊',
    '卯': '乙',
    '辰': '戊乙癸',
    '巳': '丙庚戊',
    '午': '丁己',
    '未': '己丁乙',
    '申': '庚壬戊',
    '酉': '辛',
    '戌': '戊辛丁',
    '亥': '壬甲',
  };
  const phaseMap = <String, String>{
    '子': '沐浴',
    '丑': '冠带',
    '寅': '长生',
    '卯': '临官',
    '辰': '冠带',
    '巳': '临官',
    '午': '帝旺',
    '未': '衰',
    '申': '绝',
    '酉': '胎',
    '戌': '养',
    '亥': '长生',
  };

  return List.generate(tokens.length, (index) {
    final ganZhi = tokens[index];
    final tianGan = ganZhi.runes.isNotEmpty
        ? String.fromCharCode(ganZhi.runes.first)
        : '-';
    final diZhi = ganZhi.runes.length > 1
        ? String.fromCharCode(ganZhi.runes.elementAt(1))
        : '-';
    final dayStem = tokens.length > 2 && tokens[2].runes.isNotEmpty
        ? String.fromCharCode(tokens[2].runes.first)
        : '';
    return {
      'gan_zhi': ganZhi,
      'tian_gan': tianGan,
      'di_zhi': diZhi,
      'shi_shen': shiShenFallbacks[index],
      'cang_gan': hiddenStemMap[diZhi] ?? '-',
      'di_shi': phaseMap[diZhi] ?? '-',
      'day_master_wuxing': _elementOfGan(dayStem),
      'index': index + 1,
      'label': _pillarLabels[index],
      'is_day_pillar': index == 2,
    };
  }, growable: false);
}

String _elementOfGan(String stemOrBranch) {
  const map = {
    '甲': '木',
    '乙': '木',
    '丙': '火',
    '丁': '火',
    '戊': '土',
    '己': '土',
    '庚': '金',
    '辛': '金',
    '壬': '水',
    '癸': '水',
    '子': '水',
    '丑': '土',
    '寅': '木',
    '卯': '木',
    '辰': '土',
    '巳': '火',
    '午': '火',
    '未': '土',
    '申': '金',
    '酉': '金',
    '戌': '土',
    '亥': '水',
  };
  return map[stemOrBranch] ?? '-';
}

const List<String> _pillarLabels = ['年柱', '月柱', '日柱', '时柱'];
