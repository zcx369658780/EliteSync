import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

final astroServerProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final result = await ref.read(apiClientProvider).get('/api/v1/profile/astro');
  if (result is NetworkSuccess<Map<String, dynamic>>) {
    final exists = result.data['exists'] == true;
    if (!exists) return null;
    final profile = result.data['profile'];
    if (profile is Map<String, dynamic>) return profile;
    return null;
  }
  final failure = result as NetworkFailure<Map<String, dynamic>>;
  throw Exception(failure.message);
});

class AstroProfilePage extends ConsumerWidget {
  const AstroProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.appTokens;
    final astroAsync = ref.watch(astroServerProfileProvider);
    return AppScaffold(
      appBar: const AppTopBar(title: '星盘画像', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
        children: [
          const SectionReveal(
            child: PageTitleRail(
              title: '星座 / 星盘 / 八字画像',
              subtitle: '用于匹配结果中的过程与结论解释',
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 70),
            child: AppInfoSectionCard(
              title: '画像数据来源',
              subtitle: '服务端优先，支持后续算法升级平滑替换',
              leadingIcon: Icons.storage_rounded,
              child: Text(
                '当前页面优先读取服务端画像（八字/大运/流年/五行），并融合匹配解释中的合盘与星象说明。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: t.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 90),
            child: AppInfoSectionCard(
              title: '当前画像',
              subtitle: '八字/星象/五行/大运/流年',
              leadingIcon: Icons.auto_graph_rounded,
              child: astroAsync.when(
                loading: () => Text(
                  '正在加载服务端画像...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
                ),
                error: (e, _) => Text(
                  '画像加载失败：$e',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.error),
                ),
                data: (profile) {
                  if (profile == null) {
                    return Text(
                      '暂无服务端画像数据（请先在八字页面完成计算并保存）',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
                    );
                  }
                  final bazi = (profile['bazi'] ?? '').toString();
                  final trueSolarTime = (profile['true_solar_time'] ?? '').toString();
                  final sunSign = (profile['sun_sign'] ?? '').toString();
                  final moonSign = (profile['moon_sign'] ?? '').toString();
                  final ascSign = (profile['asc_sign'] ?? '').toString();
                  final daYun = (profile['da_yun'] as List<dynamic>? ?? const []).take(4).toList();
                  final liuNian = (profile['liu_nian'] as List<dynamic>? ?? const []).take(5).toList();
                  final wuXing = (profile['wu_xing'] as Map<String, dynamic>? ?? const {});
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (bazi.isNotEmpty)
                        Text(
                          '八字：$bazi',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      if (trueSolarTime.isNotEmpty) ...[
                        SizedBox(height: t.spacing.xxs),
                        Text(
                          '真太阳时：$trueSolarTime',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                        ),
                      ],
                      if (sunSign.isNotEmpty || moonSign.isNotEmpty || ascSign.isNotEmpty) ...[
                        SizedBox(height: t.spacing.xs),
                        Text(
                          '星象：太阳$sunSign  月亮$moonSign  上升$ascSign',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                        ),
                      ],
                      if (wuXing.isNotEmpty) ...[
                        SizedBox(height: t.spacing.xs),
                        Text(
                          '五行：木${wuXing['木'] ?? 0} 火${wuXing['火'] ?? 0} 土${wuXing['土'] ?? 0} 金${wuXing['金'] ?? 0} 水${wuXing['水'] ?? 0}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                        ),
                      ],
                      if (daYun.isNotEmpty) ...[
                        SizedBox(height: t.spacing.sm),
                        Text(
                          '大运（节选）',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        SizedBox(height: t.spacing.xxs),
                        ...daYun.map((e) => Text(
                              '• ${e is Map ? (e['gan_zhi'] ?? '-') : '-'} '
                              '${e is Map ? ((e['start_year'] ?? '').toString()) : ''}'
                              '~${e is Map ? ((e['end_year'] ?? '').toString()) : ''}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                            )),
                      ],
                      if (liuNian.isNotEmpty) ...[
                        SizedBox(height: t.spacing.sm),
                        Text(
                          '流年（节选）',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        SizedBox(height: t.spacing.xxs),
                        ...liuNian.map((e) => Text(
                              '• ${e is Map ? (e['year'] ?? '-') : '-'}年 '
                              '${e is Map ? (e['gan_zhi'] ?? '-') : '-'}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                            )),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 180),
            child: AppSecondaryButton(
              label: '刷新画像数据',
              fullWidth: true,
              onPressed: () => ref.invalidate(astroServerProfileProvider),
            ),
          ),
        ],
      ),
    );
  }
}
