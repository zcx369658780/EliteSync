import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';

class AstroProfilePage extends ConsumerWidget {
  const AstroProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.appTokens;
    final detailAsync = ref.watch(matchDetailProvider);
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
            child: Container(
              padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
              decoration: BoxDecoration(
                color: t.browseSurface,
                borderRadius: BorderRadius.circular(t.radius.lg),
                border: Border.all(color: t.browseBorder),
              ),
              child: Text(
                '当前画像结果已接入匹配解释链路。你可以在这里快速查看最新分项权重与解释摘要。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: t.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 110),
            child: Container(
              padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
              decoration: BoxDecoration(
                color: t.browseSurface,
                borderRadius: BorderRadius.circular(t.radius.lg),
                border: Border.all(color: t.browseBorder),
              ),
              child: detailAsync.when(
                loading: () => Text(
                  '正在加载最新匹配分项...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
                ),
                error: (e, _) => Text(
                  '分项加载失败：$e',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.error),
                ),
                data: (detail) {
                  final rows = <String>[];
                  detail.weights.forEach((k, v) {
                    rows.add('${_weightName(k)}：$v%');
                  });
                  final reasons = detail.reasons.take(3).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rows.isEmpty ? '暂无分项权重数据' : rows.join('  ·  '),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (reasons.isNotEmpty) ...[
                        SizedBox(height: t.spacing.sm),
                        ...reasons.map(
                          (r) => Padding(
                            padding: EdgeInsets.only(bottom: t.spacing.xxs),
                            child: Text(
                              '• $r',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 140),
            child: AppPrimaryButton(
              label: '查看匹配画像解释',
              onPressed: () => context.push(AppRouteNames.matchDetail),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 180),
            child: AppSecondaryButton(
              label: '刷新画像数据',
              fullWidth: true,
              onPressed: () => ref.invalidate(matchDetailProvider),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 210),
            child: AppSecondaryButton(
              label: '返回匹配首页',
              fullWidth: true,
              onPressed: () => context.go(AppRouteNames.match),
            ),
          ),
        ],
      ),
    );
  }

  String _weightName(String key) {
    switch (key.trim().toLowerCase()) {
      case 'bazi':
        return '八字';
      case 'zodiac':
        return '属相';
      case 'constellation':
        return '星座';
      case 'natal_chart':
        return '星盘';
      case 'mbti':
        return 'MBTI';
      case 'personality':
        return '性格问卷';
      default:
        return key;
    }
  }
}
