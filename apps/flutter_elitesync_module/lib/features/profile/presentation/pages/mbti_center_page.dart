import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
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
    final personality = _extractPersonality(tags);
    final hasPersonality = personality.isNotEmpty;
    final personalityHint = hasPersonality
        ? '当前历史性格特征：$personality'
        : '性格测试已关闭，当前仅保留历史兼容展示。';

    return AppScaffold(
      appBar: const AppTopBar(title: '性格测试已关闭', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
        children: [
          const SectionReveal(
            child: PageTitleRail(
              title: '性格模块已关闭',
              subtitle: '历史数据仍可查看，但不再参与匹配排序',
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 70),
            child: AppInfoSectionCard(
              title: '测评说明',
              subtitle: '当前已关闭测试入口',
              leadingIcon: Icons.info_outline_rounded,
              child: Text(
                '性格测试在 2.5 中已关闭。历史结果仍会保留在资料标签中，但不再作为匹配排序和解释的输入。',
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
              subtitle: '从资料标签中读取历史性格结果',
              leadingIcon: hasPersonality ? Icons.psychology_alt_rounded : Icons.help_outline_rounded,
              child: Row(
                children: [
                  Icon(
                    hasPersonality ? Icons.psychology_alt_rounded : Icons.help_outline_rounded,
                    color: hasPersonality ? t.success : t.warning,
                  ),
                  SizedBox(width: t.spacing.sm),
                  Expanded(
                    child: Text(
                      personalityHint,
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
            child: AppSecondaryButton(
              label: '刷新历史结果',
              fullWidth: true,
              onPressed: () => ref.invalidate(profileProvider),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 180),
            child: AppSecondaryButton(
              label: '查看匹配解释',
              fullWidth: true,
              onPressed: () => context.push('/match/detail'),
            ),
          ),
        ],
      ),
    );
  }

  String _extractPersonality(List<String> tags) {
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
