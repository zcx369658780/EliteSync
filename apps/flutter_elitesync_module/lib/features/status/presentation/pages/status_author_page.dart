import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_empty_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/moderation/data/datasource/moderation_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/moderation/presentation/widgets/report_block_sheet.dart';
import 'package:flutter_elitesync_module/features/status/presentation/providers/status_posts_provider.dart';
import 'package:flutter_elitesync_module/features/status/presentation/widgets/status_post_card.dart';
import 'package:flutter_elitesync_module/features/status/presentation/widgets/status_report_sheet.dart';

class StatusAuthorPage extends ConsumerWidget {
  const StatusAuthorPage({super.key, required this.userId, required this.name});

  final int userId;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(statusAuthorProvider(userId));
    final t = context.appTokens;

    return AppScaffold(
      appBar: const AppTopBar(title: '作者资料', mode: AppTopBarMode.backTitle),
      body: async.when(
        loading: () => const AppLoadingSkeleton(lines: 6),
        error: (e, _) => AppErrorState(
          title: '作者资料加载失败',
          description: e.toString(),
          retryLabel: '重新加载',
          onRetry: () => ref.invalidate(statusAuthorProvider(userId)),
        ),
        data: (author) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(statusAuthorProvider(userId));
            await ref.read(statusAuthorProvider(userId).future);
          },
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              t.spacing.pageHorizontal,
              t.spacing.sm,
              t.spacing.pageHorizontal,
              t.spacing.huge,
            ),
            children: [
              AppInfoSectionCard(
                title: author.displayName.isNotEmpty
                    ? author.displayName
                    : name,
                subtitle:
                    '${author.city.isEmpty ? '城市未公开' : author.city} · ${author.relationshipGoal.isEmpty ? '未说明目标' : author.relationshipGoal}',
                leadingIcon: Icons.person_outline_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '公开资料与动态仅用于轻量联动，不作为真值层。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AppChoiceChip(
                          label: author.publicMbti.isEmpty
                              ? 'MBTI 未公开'
                              : author.publicMbti,
                          selected: true,
                        ),
                        if (author.publicPersonality.isNotEmpty)
                          AppChoiceChip(
                            label: author.publicPersonality.first,
                            selected: true,
                          ),
                        AppChoiceChip(
                          label: author.isSynthetic ? '测试账号' : '真实账号',
                          selected: true,
                        ),
                      ],
                    ),
                    SizedBox(height: t.spacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: AppChoiceChip(
                            label: '最近动态 ${author.statusCount}',
                            selected: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppChoiceChip(
                          label: '举报 / 拉黑',
                          leading: const Icon(Icons.shield_outlined),
                          onTap: () async {
                            final remote = ref.read(
                              moderationRemoteDataSourceProvider,
                            );
                            await ReportBlockSheet.show(
                              context,
                              targetName: author.displayName,
                              onReport:
                                  ({
                                    required String reasonCode,
                                    String? detail,
                                  }) async {
                                    await remote.reportUser(
                                      targetUserId: userId,
                                      category: 'user',
                                      reasonCode: reasonCode,
                                      sourcePage: 'status_author',
                                      detail: detail,
                                    );
                                  },
                              onBlock: () async {
                                await remote.blockUser(
                                  blockedUserId: userId,
                                  sourcePage: 'status_author',
                                  reasonCode: 'status_author',
                                  detail: 'from_status_author',
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: t.spacing.md),
              AppInfoSectionCard(
                title: '低压回流',
                subtitle: '先从公开资料和动态继续了解',
                leadingIcon: Icons.move_up_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '如果想继续认识，可以先回到消息列表查看是否已有匹配会话；没有匹配关系时，不会伪造私聊入口。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    Wrap(
                      spacing: t.spacing.xs,
                      runSpacing: t.spacing.xs,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => context.push(AppRouteNames.messages),
                          icon: const Icon(Icons.chat_bubble_outline_rounded),
                          label: const Text('回到消息'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => AppFeedback.showSuccess(
                            context,
                            '已作为稍后再聊提示保留在本页，不写入服务端队列',
                          ),
                          icon: const Icon(Icons.bookmark_border_rounded),
                          label: const Text('稍后再聊'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: t.spacing.md),
              AppInfoSectionCard(
                title: '最近状态',
                subtitle: '作者发布过的动态',
                leadingIcon: Icons.dynamic_feed_rounded,
                child: author.recentPosts.isEmpty
                    ? const AppEmptyState(
                        title: '暂无动态',
                        description: '该用户还没有公开的动态内容。',
                      )
                    : Column(
                        children: [
                          for (final post in author.recentPosts)
                            Padding(
                              padding: EdgeInsets.only(bottom: t.spacing.sm),
                              child: StatusPostCard(
                                post: post,
                                compact: true,
                                onContinueUnderstand: () =>
                                    AppFeedback.showInfo(
                                      context,
                                      '正在查看该作者的公开动态，可继续从消息列表确认是否已有会话',
                                    ),
                                onSaveForLater: () => AppFeedback.showSuccess(
                                  context,
                                  '已作为稍后再聊提示保留在本页，不写入服务端队列',
                                ),
                                onReport: () async {
                                  final remote = ref.read(
                                    statusRemoteDataSourceProvider,
                                  );
                                  await StatusReportSheet.show(
                                    context,
                                    targetName: post.displayAuthorName,
                                    onSubmit:
                                        ({
                                          required String reasonCode,
                                          String? detail,
                                        }) async {
                                          await remote.reportStatusPost(
                                            postId: post.id,
                                            reasonCode: reasonCode,
                                            detail: detail,
                                          );
                                        },
                                  );
                                },
                                onLikeToggle: () async {
                                  final remote = ref.read(
                                    statusRemoteDataSourceProvider,
                                  );
                                  if (post.likedByViewer) {
                                    await remote.unlikeStatusPost(post.id);
                                  } else {
                                    await remote.likeStatusPost(post.id);
                                  }
                                  ref.invalidate(statusAuthorProvider(userId));
                                },
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
