import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/brand/profile_glass_header_card.dart';
import 'package:flutter_elitesync_module/design_system/components/brand/soul_style_feature_card.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
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
            return const AppErrorState(title: '资料为空', description: '请稍后重试');
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
                    title: '星盘画像',
                    subtitle: '查看分项权重与匹配解释',
                    icon: Icons.auto_awesome_outlined,
                    onTap: () => context.push(AppRouteNames.astroProfile),
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
