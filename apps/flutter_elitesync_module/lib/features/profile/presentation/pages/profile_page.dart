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
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/profile_completion_card.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/profile_expression_advice_card.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/profile_result_tag_list.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profileProvider);

    return Scaffold(
      body: async.when(
        loading: () => const AppLoadingSkeleton(lines: 6),
        error: (e, _) =>
            AppErrorState(title: '资料加载失败', description: e.toString()),
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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: t.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => context.push(AppRouteNames.settings),
                      icon: Icon(
                        Icons.settings_rounded,
                        color: t.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              body: ListView(
                padding: EdgeInsets.only(
                  top: t.spacing.xs,
                  bottom: t.spacing.huge,
                ),
                children: [
                  AppErrorState(
                    title: '资料暂不可用',
                    description: (state.error ?? '').isNotEmpty
                        ? state.error!
                        : '你可以先完善基础资料',
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
                padding: EdgeInsets.only(
                  top: t.spacing.xs,
                  bottom: t.spacing.huge,
                ),
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
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
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
                    subtitle: '生日 / 出生时间 / 出生地 / 经纬度 / 婚恋目标（服务端真值）',
                    leadingIcon: Icons.badge_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileInfoLine(
                          label: '生日',
                          value: summary.birthday.isEmpty
                              ? '未填写'
                              : summary.birthday,
                        ),
                        SizedBox(height: t.spacing.xs),
                        _ProfileInfoLine(
                          label: '出生时间',
                          value: summary.birthTime.isEmpty
                              ? '未填写'
                              : summary.birthTime,
                        ),
                        SizedBox(height: t.spacing.xs),
                        _ProfileInfoLine(
                          label: '出生地',
                          value: (summary.birthPlace ?? '').isEmpty
                              ? '未填写'
                              : summary.birthPlace!,
                        ),
                        SizedBox(height: t.spacing.xs),
                        _ProfileInfoLine(
                          label: '经纬度',
                          value: _formatCoordinates(
                            summary.birthLat,
                            summary.birthLng,
                          ),
                        ),
                        SizedBox(height: t.spacing.xs),
                        _ProfileInfoLine(
                          label: '婚恋目标',
                          value: summary.target.isEmpty
                              ? '未填写'
                              : _targetLabel(summary.target),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: t.spacing.sm),
                  ProfileCompletionCard(completion: summary.completion),
                  SizedBox(height: t.spacing.md),
                  _ProfileOperatingHubSection(summary: summary),
                  SizedBox(height: t.spacing.sm),
                  ProfileExpressionAdviceCard(summary: summary),
                  SizedBox(height: t.spacing.sm),
                  AppInfoSectionCard(
                    title: 'AI 助理 / 展示建议',
                    subtitle: '把资料完整度、标签和关系表达整理成可执行建议',
                    leadingIcon: Icons.smart_toy_outlined,
                    child: _AiDisplayAdviceSection(summary: summary),
                  ),
                  SizedBox(height: t.spacing.sm),
                  AppInfoSectionCard(
                    title: '标签表达体系',
                    subtitle: '把资料字段整理成更像自我介绍的慢约会表达',
                    leadingIcon: Icons.local_offer_outlined,
                    child: _ProfileTagExpressionSection(summary: summary),
                  ),
                  SizedBox(height: t.spacing.sm),
                  AppInfoSectionCard(
                    title: 'AI 草稿助手',
                    subtitle: '只生成表达草稿，由你确认后再使用',
                    leadingIcon: Icons.edit_note_rounded,
                    child: _AiDraftHelperSection(summary: summary),
                  ),
                  SizedBox(height: t.spacing.sm),
                  AppInfoSectionCard(
                    title: '轻语音表达',
                    subtitle: '声音名片候选位，不替代 RTC 通话主链',
                    leadingIcon: Icons.mic_none_rounded,
                    child: const _LightVoiceExpressionSection(),
                  ),
                  SizedBox(height: t.spacing.sm),
                  AppInfoSectionCard(
                    title: '个人空间外观',
                    subtitle: '轻量展示风格预览，与真正设置中心分层',
                    leadingIcon: Icons.palette_outlined,
                    child: const _ProfileAppearanceLayerSection(),
                  ),
                  SizedBox(height: t.spacing.sm),
                  AppInfoSectionCard(
                    title: '资料真值链路',
                    subtitle: '保存后服务端重算，资料页与星盘页会读取最新结果',
                    leadingIcon: Icons.sync_rounded,
                    child: Text(
                      '生日、出生时间、出生地和经纬度都会先写入服务端真值层，再触发八字、紫微与星盘重算。你保存后返回本页，相关摘要会自动刷新；如果刚编辑完，也可以下拉刷新确认最新结果。',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: t.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: t.spacing.sm),
                  AppInfoSectionCard(
                    title: '玄学入口',
                    subtitle: '总览 / 八字 / 星盘 / 紫微（都读取服务端真值）',
                    leadingIcon: Icons.auto_awesome_rounded,
                    child: Column(
                      children: [
                        SoulStyleFeatureCard(
                          title: '玄学总览',
                          subtitle: '模块状态、最近更新时间、入口汇总',
                          icon: Icons.dashboard_outlined,
                          compact: true,
                          onTap: () =>
                              context.push(AppRouteNames.astroOverview),
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
                          onTap: () =>
                              context.push(AppRouteNames.astroNatalChart),
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
                    subtitle: '修改后会触发服务端重算并刷新画像与星盘',
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

class _ProfileOperatingHubSection extends StatelessWidget {
  const _ProfileOperatingHubSection({required this.summary});

  final ProfileSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final highlights = _profileHighlights(summary);
    return AppInfoSectionCard(
      title: '个人经营区',
      subtitle: '把资料、状态和关系表达放在同一个可经营入口',
      leadingIcon: Icons.person_pin_circle_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '先让别人更快看懂你，再决定是否进入聊天或继续了解。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          for (final item in highlights) ...[
            _ProfileActionLine(
              icon: item.icon,
              title: item.title,
              body: item.body,
            ),
            SizedBox(height: t.spacing.xs),
          ],
          SizedBox(height: t.spacing.xs),
          Wrap(
            spacing: t.spacing.sm,
            runSpacing: t.spacing.sm,
            children: [
              AppChoiceChip(
                label: '编辑资料',
                leading: const Icon(Icons.edit_outlined),
                selected: true,
                onTap: () => context.push(AppRouteNames.editProfile),
              ),
              AppChoiceChip(
                label: '看看状态',
                leading: const Icon(Icons.dynamic_feed_outlined),
                onTap: () => context.push(AppRouteNames.statusSquare),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiDisplayAdviceSection extends StatelessWidget {
  const _AiDisplayAdviceSection({required this.summary});

  final ProfileSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final advice = _displayAdvice(summary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '这些建议只帮助你组织表达，不会自动修改资料，也不会回写服务端真值。',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: t.textSecondary, height: 1.5),
        ),
        SizedBox(height: t.spacing.sm),
        for (final item in advice) ...[
          _ProfileActionLine(
            icon: item.icon,
            title: item.title,
            body: item.body,
          ),
          SizedBox(height: t.spacing.xs),
        ],
        SizedBox(height: t.spacing.sm),
        SoulStyleFeatureCard(
          title: '查看画像与展示建议',
          subtitle: '结合当前标签与资料完整度给出推荐表达方式',
          icon: Icons.auto_awesome_outlined,
          compact: true,
          onTap: () => context.push(AppRouteNames.astroOverview),
        ),
      ],
    );
  }
}

class _ProfileTagExpressionSection extends StatelessWidget {
  const _ProfileTagExpressionSection({required this.summary});

  final ProfileSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final sections = _profileTagSections(summary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sections.isEmpty)
          Text(
            '当前还没有可展示的标签，完善资料后会自动生成。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          )
        else
          for (final section in sections) ...[
            Text(
              section.title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: t.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: t.spacing.xs),
            ProfileResultTagList(tags: section.tags),
            SizedBox(height: t.spacing.sm),
          ],
        Text(
          '标签只作为展示和关系推进参考，不代表唯一判断，也不会覆盖资料真值。',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: t.textSecondary, height: 1.45),
        ),
      ],
    );
  }
}

class _AiDraftHelperSection extends StatelessWidget {
  const _AiDraftHelperSection({required this.summary});

  final ProfileSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final drafts = _draftSuggestions(summary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final draft in drafts) ...[
          SoulStyleFeatureCard(
            title: draft.title,
            subtitle: draft.subtitle,
            icon: draft.icon,
            compact: true,
            onTap: () => _showDraftSheet(context, draft),
          ),
          SizedBox(height: t.spacing.xs),
        ],
        Text(
          '草稿不会自动发布、不会自动发送，也不会写入服务端资料。',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: t.textSecondary, height: 1.45),
        ),
      ],
    );
  }
}

class _LightVoiceExpressionSection extends StatelessWidget {
  const _LightVoiceExpressionSection();

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ProfileActionLine(
          icon: Icons.graphic_eq_rounded,
          title: '声音名片候选位',
          body: '先准备一句 8-12 秒的自我介绍，正式录制前再按需申请麦克风权限。',
        ),
        SizedBox(height: t.spacing.sm),
        AppChoiceChip(
          label: '录制前说明',
          leading: const Icon(Icons.mic_none_rounded),
          selected: true,
          onTap: () => _showInfoDialog(
            context,
            title: '声音名片仍是候选位',
            body: '5.2 只提供轻语音表达入口与录制前提示，不改 RTC、LiveKit 或通话状态机。真正录制前会再确认权限。',
          ),
        ),
      ],
    );
  }
}

class _ProfileAppearanceLayerSection extends StatelessWidget {
  const _ProfileAppearanceLayerSection();

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ProfileActionLine(
          icon: Icons.wallpaper_outlined,
          title: '展示封面：温柔清爽',
          body: '默认只做主页展示氛围预览，免费、轻量，不进入商城或币体系。',
        ),
        SizedBox(height: t.spacing.sm),
        Wrap(
          spacing: t.spacing.sm,
          runSpacing: t.spacing.sm,
          children: const [
            AppChoiceChip(label: '清爽', selected: true),
            AppChoiceChip(label: '安静'),
            AppChoiceChip(label: '真诚'),
          ],
        ),
        SizedBox(height: t.spacing.sm),
        AppChoiceChip(
          label: '查看外观说明',
          leading: const Icon(Icons.info_outline_rounded),
          selected: true,
          onTap: () => _showInfoDialog(
            context,
            title: '个人空间外观仍是预览层',
            body:
                '这里只负责主页被怎样看见，不会改写资料真值，也不会进入商城、币体系或真正的设置中心。若后续需要图片背景或相册类入口，会先解释权限再继续。',
          ),
        ),
        SizedBox(height: t.spacing.sm),
        Text(
          '外观层只服务“如何被看见”，隐私、账号与安全仍在设置中心处理。',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: t.textSecondary, height: 1.45),
        ),
      ],
    );
  }
}

class _ProfileActionLine extends StatelessWidget {
  const _ProfileActionLine({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: t.brandPrimary),
        SizedBox(width: t.spacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.42,
                ),
              ),
            ],
          ),
        ),
      ],
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: t.textPrimary, height: 1.4),
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

String _formatCoordinates(double? lat, double? lng) {
  if (lat == null && lng == null) return '未填写';
  final latText = lat == null ? '-' : lat.toStringAsFixed(6);
  final lngText = lng == null ? '-' : lng.toStringAsFixed(6);
  return '$latText，$lngText';
}

List<_ProfileActionData> _profileHighlights(ProfileSummaryEntity summary) {
  final target = summary.target.isEmpty ? '慢慢了解' : _targetLabel(summary.target);
  final completion = (summary.completion * 100).round().clamp(0, 100);
  return [
    _ProfileActionData(
      icon: Icons.favorite_border_rounded,
      title: '关系目标：$target',
      body: '先把期待讲清楚，让匹配和聊天建议更容易贴近你的节奏。',
    ),
    _ProfileActionData(
      icon: Icons.verified_user_outlined,
      title: '资料完成度：$completion%',
      body: completion >= 70
          ? '已经具备较好的展示基础，可以继续优化亮点表达。'
          : '建议先补齐基础资料，再让 AI 帮你整理主页亮点。',
    ),
    _ProfileActionData(
      icon: Icons.location_on_outlined,
      title: '城市与出生地已分层',
      body: '城市用于主页阅读，出生地与经纬度仍只服务资料真值和星盘计算。',
    ),
  ];
}

List<_ProfileActionData> _displayAdvice(ProfileSummaryEntity summary) {
  final hasBirth =
      summary.birthday.isNotEmpty && (summary.birthPlace ?? '').isNotEmpty;
  return [
    _ProfileActionData(
      icon: Icons.fact_check_outlined,
      title: '资料完整度建议',
      body: summary.completion >= 0.7
          ? '保留当前基础资料，优先补一句更自然的自我介绍。'
          : '先补齐生日、城市、关系目标和问卷结果，再生成更可靠的展示建议。',
    ),
    _ProfileActionData(
      icon: Icons.chat_bubble_outline_rounded,
      title: '首聊友好度建议',
      body: '把标签写成“我通常怎样相处”，比直接堆字段更容易开启低压聊天。',
    ),
    _ProfileActionData(
      icon: Icons.auto_fix_high_outlined,
      title: '亮点梳理建议',
      body: hasBirth
          ? '可以把真值资料转成温和表达，但不要把星盘或人格结果写成绝对判断。'
          : '当前真值资料还不完整，建议只展示轻量兴趣和相处方式。',
    ),
  ];
}

List<_ProfileTagSectionData> _profileTagSections(ProfileSummaryEntity summary) {
  if (summary.tags.isEmpty) return const [];
  final sections = <_ProfileTagSectionData>[];
  final personality = <String>[];
  final relationship = <String>[];
  final lifestyle = <String>[];
  final basics = <String>[];

  for (final tag in summary.tags) {
    if (tag.contains('婚恋') || tag.contains('关系') || tag.contains('交友')) {
      relationship.add(tag);
    } else if (tag.contains('城市') ||
        tag.contains('出生') ||
        tag.contains('生日') ||
        tag.contains('资料')) {
      basics.add(tag);
    } else if (tag.contains('生活') || tag.contains('状态') || tag.contains('同城')) {
      lifestyle.add(tag);
    } else {
      personality.add(tag);
    }
  }

  if (personality.isNotEmpty) {
    sections.add(_ProfileTagSectionData('人格倾向', personality));
  }
  if (relationship.isNotEmpty) {
    sections.add(_ProfileTagSectionData('关系风格', relationship));
  }
  if (lifestyle.isNotEmpty) {
    sections.add(_ProfileTagSectionData('生活状态', lifestyle));
  }
  if (basics.isNotEmpty) {
    sections.add(_ProfileTagSectionData('资料真值提示', basics));
  }
  sections.add(
    _ProfileTagSectionData('慢约会友好表达', ['可以慢慢了解', '先文字后语音', '尊重彼此节奏']),
  );
  return sections;
}

List<_DraftSuggestionData> _draftSuggestions(ProfileSummaryEntity summary) {
  final city = summary.city.isEmpty ? '现在所在的城市' : summary.city;
  final target = summary.target.isEmpty ? '慢慢了解' : _targetLabel(summary.target);
  final tag = summary.tags.isEmpty ? '真诚、慢热、愿意认真了解' : summary.tags.first;
  return [
    _DraftSuggestionData(
      icon: Icons.article_outlined,
      title: '帮我写一句自我介绍',
      subtitle: '生成主页展示草稿',
      draft: '我在$city，比较看重$target。比起很快下判断，我更希望先从轻松的话题开始，慢慢确认彼此是否舒服。',
    ),
    _DraftSuggestionData(
      icon: Icons.waving_hand_outlined,
      title: '帮我写一句问候',
      subtitle: '用于首聊前的低压开场',
      draft: '看到你的资料里也有让我好奇的部分。我们可以先从一个轻松的问题开始聊，不急着给彼此贴标签。',
    ),
    _DraftSuggestionData(
      icon: Icons.tips_and_updates_outlined,
      title: '整理我的亮点',
      subtitle: '把标签转成更自然的表达',
      draft: '可以先展示“$tag”，再补一句你平时怎样相处。这样比直接罗列标签更像真实的自我介绍。',
    ),
  ];
}

void _showDraftSheet(BuildContext context, _DraftSuggestionData draft) {
  final t = context.appTokens;
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          t.spacing.cardPaddingLarge,
          t.spacing.sm,
          t.spacing.cardPaddingLarge,
          t.spacing.cardPaddingLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              draft.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: t.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: t.spacing.sm),
            Text(
              draft.draft,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: t.textPrimary,
                height: 1.5,
              ),
            ),
            SizedBox(height: t.spacing.sm),
            Text(
              '这是本地草稿建议，不会自动发布、自动发送或回写资料。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.45,
              ),
            ),
            SizedBox(height: t.spacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('知道了'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showInfoDialog(
  BuildContext context, {
  required String title,
  required String body,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('知道了'),
        ),
      ],
    ),
  );
}

class _ProfileActionData {
  const _ProfileActionData({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _ProfileTagSectionData {
  const _ProfileTagSectionData(this.title, this.tags);

  final String title;
  final List<String> tags;
}

class _DraftSuggestionData {
  const _DraftSuggestionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.draft,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String draft;
}
