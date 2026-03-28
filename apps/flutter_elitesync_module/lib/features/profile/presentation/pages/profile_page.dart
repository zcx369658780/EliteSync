import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/brand/profile_glass_header_card.dart';
import 'package:flutter_elitesync_module/design_system/components/brand/soul_style_feature_card.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/profile_completion_card.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/profile_result_tag_list.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profileProvider);

    return Scaffold(
      body: async.when(
        loading: () => const AppLoadingSkeleton(lines: 6),
        error: (e, _) => AppErrorState(title: '资料加载失败', description: e.toString()),
        data: (state) {
          final summary = state.summary;
          if (summary == null) {
            final t = context.appTokens;
            return BrowseScaffold(
              header: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    Text(
                      '我的',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => context.push(AppRouteNames.settings),
                      icon: Icon(Icons.settings_rounded, color: t.textSecondary),
                    ),
                  ],
                ),
              ),
              body: ListView(
                padding: EdgeInsets.only(top: t.spacing.xs, bottom: t.spacing.huge),
                children: [
                  AppErrorState(
                    title: '资料暂不可用',
                    description: (state.error ?? '').isNotEmpty ? state.error! : '你可以先完善基础资料',
                    retryLabel: '重新加载',
                    onRetry: () => ref.invalidate(profileProvider),
                  ),
                  SizedBox(height: t.spacing.sm),
                  AppInfoSectionCard(
                    title: '资料暂未就绪',
                    subtitle: '先完善基础信息，再查看匹配与画像结果',
                    leadingIcon: Icons.person_outline_rounded,
                    child: Text(
                      '建议先填写昵称、性别、城市与婚恋目标，并完成问卷题库。完成后将自动生成更完整的匹配与画像信息。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: t.textSecondary,
                            height: 1.45,
                          ),
                    ),
                  ),
                  SizedBox(height: t.spacing.sm),
                  Wrap(
                    spacing: t.spacing.sm,
                    runSpacing: t.spacing.sm,
                    children: [
                      AppChoiceChip(
                        label: '完善资料',
                        leading: const Icon(Icons.edit_outlined),
                        selected: true,
                        onTap: () => context.push(AppRouteNames.editProfile),
                      ),
                      AppChoiceChip(
                        label: '星盘画像',
                        leading: const Icon(Icons.auto_awesome_outlined),
                        onTap: () => context.push(AppRouteNames.astroProfile),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          final t = context.appTokens;
          return BrowseScaffold(
            header: SizedBox(
              height: 44,
              child: Row(
                children: [
                  Text(
                    '我的',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.push(AppRouteNames.settings),
                    icon: Icon(Icons.settings_rounded, color: t.textSecondary),
                  ),
                ],
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(profileProvider);
                await ref.read(profileProvider.future);
              },
              child: ListView(
                padding: EdgeInsets.only(top: t.spacing.xs, bottom: t.spacing.huge),
                children: [
                  ProfileGlassHeaderCard(
                    nickname: summary.nickname,
                    city: summary.city,
                    verified: summary.verified,
                  ),
                  SizedBox(height: t.spacing.sm),
                  Wrap(
                    spacing: t.spacing.xs,
                    runSpacing: t.spacing.xs,
                    children: [
                      AppChoiceChip(
                        label: '性格问卷题库',
                        leading: const Icon(Icons.quiz_outlined),
                        selected: true,
                        onTap: () => context.push(AppRouteNames.questionnaire),
                      ),
                      AppChoiceChip(
                        label: '星盘画像',
                        leading: const Icon(Icons.auto_awesome_outlined),
                        onTap: () => context.push(AppRouteNames.astroProfile),
                      ),
                    ],
                  ),
                  SizedBox(height: t.spacing.md),
                  ProfileCompletionCard(completion: summary.completion),
                  SizedBox(height: t.spacing.md),
                  ProfileResultTagList(tags: summary.tags),
                  SizedBox(height: t.spacing.md),
                  SoulStyleFeatureCard(
                    title: 'MBTI 测试',
                    subtitle: '查看/刷新 MBTI 结果',
                    icon: Icons.psychology_alt_outlined,
                    onTap: () => context.push(AppRouteNames.mbtiCenter),
                  ),
                  SizedBox(height: t.spacing.sm),
                  SoulStyleFeatureCard(
                    title: '编辑资料',
                    subtitle: '修改昵称、城市、婚恋目标',
                    icon: Icons.edit_outlined,
                    onTap: () => context.push(AppRouteNames.editProfile),
                  ),
                  SizedBox(height: t.spacing.sm),
                  SoulStyleFeatureCard(
                    title: '设置',
                    subtitle: '隐私、账号与安全',
                    icon: Icons.settings_outlined,
                    onTap: () => context.push(AppRouteNames.settings),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
