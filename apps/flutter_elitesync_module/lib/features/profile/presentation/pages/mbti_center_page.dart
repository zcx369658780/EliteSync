import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';

class MbtiCenterPage extends ConsumerWidget {
  const MbtiCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.appTokens;
    final profile = ref.watch(profileProvider);
    final tags = profile.asData?.value.summary?.tags ?? const <String>[];
    final mbti = _extractMbti(tags);
    final hasMbti = mbti.isNotEmpty;
    final mbtiHint = hasMbti ? '当前 MBTI：$mbti' : '当前还没有 MBTI 结果，建议先完成测试';

    return AppScaffold(
      appBar: const AppTopBar(title: 'MBTI测试', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
        children: [
          const SectionReveal(
            child: PageTitleRail(
              title: 'MBTI 快速测评',
              subtitle: '3题简版，用于匹配解释与画像补充',
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 70),
            child: AppInfoSectionCard(
              title: '测评说明',
              subtitle: '当前为轻量入口，后续可替换正式 MBTI 算法',
              leadingIcon: Icons.info_outline_rounded,
              child: Text(
                '当前 MBTI 题目已并入性格问卷流程。测试结果会用于匹配解释中的 MBTI 分项。',
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
            child: AppInfoSectionCard(
              title: '当前状态',
              subtitle: '从资料标签中读取 MBTI 结果',
              leadingIcon: hasMbti ? Icons.psychology_alt_rounded : Icons.help_outline_rounded,
              child: Row(
                children: [
                  Icon(
                    hasMbti ? Icons.psychology_alt_rounded : Icons.help_outline_rounded,
                    color: hasMbti ? t.success : t.warning,
                  ),
                  SizedBox(width: t.spacing.sm),
                  Expanded(
                    child: Text(
                      mbtiHint,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: t.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 140),
            child: AppPrimaryButton(
              label: '开始 MBTI 测试',
              onPressed: () => context.push(AppRouteNames.questionnaire),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 180),
            child: AppSecondaryButton(
              label: '刷新 MBTI 结果',
              fullWidth: true,
              onPressed: () => ref.invalidate(profileProvider),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 210),
            child: AppSecondaryButton(
              label: '查看匹配解释',
              fullWidth: true,
              onPressed: () => context.push(AppRouteNames.matchDetail),
            ),
          ),
        ],
      ),
    );
  }

  String _extractMbti(List<String> tags) {
    final regex = RegExp(r'\b[EI][SN][TF][JP]\b', caseSensitive: false);
    for (final tag in tags) {
      final m = regex.firstMatch(tag);
      if (m != null) {
        return m.group(0)?.toUpperCase() ?? '';
      }
    }
    return '';
  }
}
