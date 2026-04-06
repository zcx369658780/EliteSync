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
                  AppInfoSectionCard(
                    title: '账号状态',
                    subtitle: '实名、治理与账号可用性',
                    leadingIcon: Icons.shield_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileInfoLine(
                          label: '实名状态',
                          value: summary.verified ? '已认证' : '未认证',
                        ),
                        SizedBox(height: t.spacing.xs),
                        _ProfileInfoLine(
                          label: '治理状态',
                          value: _moderationLabel(summary.moderationStatus),
                        ),
                        if ((summary.moderationNote ?? '').isNotEmpty) ...[
                          SizedBox(height: t.spacing.xs),
                          Text(
                            summary.moderationNote!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: t.textSecondary,
                                  height: 1.45,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: t.spacing.sm),
                  AppInfoSectionCard(
                    title: '基础资料',
                    subtitle: '生日 / 出生时间 / 出生地 / 婚恋目标',
                    leadingIcon: Icons.badge_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileInfoLine(label: '生日', value: summary.birthday.isEmpty ? '未填写' : summary.birthday),
                        SizedBox(height: t.spacing.xs),
                        _ProfileInfoLine(label: '出生时间', value: summary.birthTime.isEmpty ? '未填写' : summary.birthTime),
                        SizedBox(height: t.spacing.xs),
                        _ProfileInfoLine(
                          label: '出生地',
                          value: (summary.birthPlace ?? '').isEmpty ? '未填写' : summary.birthPlace!,
                        ),
                        SizedBox(height: t.spacing.xs),
                        _ProfileInfoLine(
                          label: '婚恋目标',
                          value: summary.target.isEmpty ? '未填写' : _targetLabel(summary.target),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: t.spacing.sm),
                  ProfileCompletionCard(completion: summary.completion),
                  SizedBox(height: t.spacing.md),
                  ProfileResultTagList(tags: summary.tags),
                  SizedBox(height: t.spacing.sm),
                  AppInfoSectionCard(
                    title: '玄学入口',
                    subtitle: '总览 / 八字 / 星盘 / 紫微',
                    leadingIcon: Icons.auto_awesome_rounded,
                    child: Column(
                      children: [
                        SoulStyleFeatureCard(
                          title: '玄学总览',
                          subtitle: '模块状态、最近更新时间、入口汇总',
                          icon: Icons.dashboard_outlined,
                          compact: true,
                          onTap: () => context.push(AppRouteNames.astroOverview),
                        ),
                        SizedBox(height: t.spacing.xs),
                        SoulStyleFeatureCard(
                          title: '八字详情',
                          subtitle: '四柱、五行、真太阳时与标签摘要',
                          icon: Icons.view_timeline_outlined,
                          compact: true,
                          onTap: () => context.push(AppRouteNames.astroBazi),
                        ),
                        SizedBox(height: t.spacing.xs),
                        SoulStyleFeatureCard(
                          title: '星盘详情',
                          subtitle: '出生地、经纬度、位置修正与元信息',
                          icon: Icons.nightlight_round,
                          compact: true,
                          onTap: () => context.push(AppRouteNames.astroNatalChart),
                        ),
                        SizedBox(height: t.spacing.xs),
                        SoulStyleFeatureCard(
                          title: '紫微详情',
                          subtitle: '命宫、身宫、宫位摘要与运限节选',
                          icon: Icons.grid_view_rounded,
                          compact: true,
                          onTap: () => context.push(AppRouteNames.astroZiwei),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: t.spacing.sm),
                  SoulStyleFeatureCard(
                    title: '编辑资料',
                    subtitle: '修改昵称、生日、出生时间、出生地、城市、婚恋目标',
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

class _ProfileInfoLine extends StatelessWidget {
  const _ProfileInfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textPrimary,
                  height: 1.4,
                ),
          ),
        ),
      ],
    );
  }
}

String _targetLabel(String raw) {
  switch (raw) {
    case 'marriage':
      return '结婚';
    case 'dating':
      return '恋爱';
    case 'friendship':
      return '交友';
    default:
      return raw;
  }
}

String _moderationLabel(String raw) {
  switch (raw) {
    case 'restricted':
      return '受限';
    case 'banned':
      return '已封禁';
    case 'restored':
      return '已恢复';
    case 'normal':
    default:
      return '正常';
  }
}
