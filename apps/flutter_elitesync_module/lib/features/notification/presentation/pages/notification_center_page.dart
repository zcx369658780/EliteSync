import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/providers/notification_provider.dart';

class NotificationCenterPage extends ConsumerStatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  ConsumerState<NotificationCenterPage> createState() =>
      _NotificationCenterPageState();
}

class _NotificationCenterPageState
    extends ConsumerState<NotificationCenterPage> {
  @override
  void initState() {
    super.initState();
    ref
        .read(frontendTelemetryProvider)
        .notificationCenterOpened(sourcePage: 'notification_center');
  }

  Future<void> _refresh() async {
    ref.invalidate(notificationListProvider);
    ref.invalidate(notificationUnreadCountProvider);
    await ref.read(notificationListProvider.future);
  }

  Future<void> _markAllRead() async {
    final unread = ref.read(notificationUnreadCountProvider).asData?.value;
    await ref.read(notificationRemoteDataSourceProvider).markAllRead();
    ref
        .read(frontendTelemetryProvider)
        .notificationAllRead(
          sourcePage: 'notification_center',
          unreadCount: unread,
        );
    ref.invalidate(notificationListProvider);
    ref.invalidate(notificationUnreadCountProvider);
    if (!mounted) return;
    AppFeedback.showInfo(context, '已全部标记为已读');
  }

  Future<void> _markRead(NotificationItemEntity item) async {
    if (item.isRead) return;
    await ref.read(notificationRemoteDataSourceProvider).markRead(item.id);
    ref
        .read(frontendTelemetryProvider)
        .notificationItemOpened(
          sourcePage: 'notification_center',
          kind: item.kind,
        );
    ref.invalidate(notificationListProvider);
    ref.invalidate(notificationUnreadCountProvider);
  }

  void _openNotification(NotificationItemEntity item) {
    final routeName = item.routeName.trim();
    if (routeName.isEmpty) return;
    if (routeName == 'chat_room') {
      final conversationId = (item.routeArgs['conversation_id'] ?? '')
          .toString();
      final title = (item.routeArgs['title'] ?? '聊天').toString();
      if (conversationId.isNotEmpty) {
        context.push('${AppRouteNames.chatRoom}/$conversationId', extra: title);
      }
      return;
    }
    if (routeName == 'status_author') {
      final userId = (item.routeArgs['user_id'] as num?)?.toInt() ?? 0;
      final name = (item.routeArgs['name'] ?? '用户资料').toString();
      if (userId > 0) {
        context.push(
          '${AppRouteNames.statusAuthor}/$userId?name=${Uri.encodeComponent(name)}',
        );
      }
      return;
    }
    if (routeName == 'match_detail') {
      context.go(AppRouteNames.matchDetail);
      return;
    }
    if (routeName == 'match_result') {
      context.go(AppRouteNames.matchResult);
      return;
    }
    if (routeName == 'match_intention') {
      context.go(AppRouteNames.matchIntention);
      return;
    }
    if (routeName == 'questionnaire_history') {
      context.go(AppRouteNames.questionnaireHistory);
      return;
    }
    if (routeName == 'content_detail') {
      final contentId = (item.routeArgs['content_id'] ?? '').toString();
      if (contentId.isNotEmpty) {
        context.push('${AppRouteNames.contentDetail}/$contentId');
      }
      return;
    }
    if (routeName == 'rtc_call') {
      final callId = (item.routeArgs['call_id'] as num?)?.toInt() ?? 0;
      final title = (item.routeArgs['title'] ?? item.title).toString();
      if (callId > 0) {
        switch (item.kind) {
          case 'rtc_call_invite':
            context.push(
              '${AppRouteNames.rtcIncomingCall}/$callId',
              extra: title,
            );
            return;
          case 'rtc_call_rejected':
          case 'rtc_call_missed':
          case 'rtc_call_ended':
            context.push(
              '${AppRouteNames.rtcCallResult}/$callId',
              extra: title,
            );
            return;
          default:
            context.push('${AppRouteNames.rtcCall}/$callId', extra: title);
            return;
        }
      }
      return;
    }
    if (routeName == 'settings') {
      context.go(AppRouteNames.settings);
      return;
    }
    AppFeedback.showInfo(context, '暂无法打开该通知');
  }

  String _formatTime(String raw) {
    if (raw.isEmpty) return '刚刚';
    final time = DateTime.tryParse(raw);
    if (time == null) return raw;
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
    if (diff.inDays < 1) return '${diff.inHours} 小时前';
    return '${time.month}-${time.day}';
  }

  Widget _buildNotificationCard(NotificationItemEntity item, dynamic t) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await _markRead(item);
          if (!mounted) return;
          _openNotification(item);
        },
        child: Container(
          decoration: BoxDecoration(
            color: t.browseSurface,
            borderRadius: BorderRadius.circular(t.radius.lg),
            border: Border.all(
              color: item.isRead
                  ? t.browseBorder
                  : t.brandPrimary.withValues(alpha: 0.18),
            ),
          ),
          padding: EdgeInsets.all(t.spacing.cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: item.isRead
                      ? t.textSecondary.withValues(alpha: 0.12)
                      : t.brandPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(t.radius.md),
                ),
                child: Icon(
                  switch (item.kind) {
                    'message' => Icons.chat_bubble_outline,
                    'status_like' => Icons.favorite_border,
                    'match_like' => Icons.waving_hand_outlined,
                    'match_success' => Icons.favorite_rounded,
                    'rtc_call_invite' => Icons.call_outlined,
                    'rtc_call_accepted' => Icons.call,
                    'rtc_call_rejected' => Icons.call_end,
                    'rtc_call_missed' => Icons.phone_missed_outlined,
                    _ => Icons.notifications_outlined,
                  },
                  size: 18,
                  color: item.isRead ? t.textSecondary : t.brandPrimary,
                ),
              ),
              SizedBox(width: t.spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: t.textPrimary,
                                  fontWeight: item.isRead
                                      ? FontWeight.w600
                                      : FontWeight.w700,
                                ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: EdgeInsets.only(
                              top: t.spacing.xxs,
                              left: t.spacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: t.brandPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if (item.body.trim().isNotEmpty) ...[
                      SizedBox(height: t.spacing.xxs),
                      Text(
                        item.body.trim(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: t.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                    SizedBox(height: t.spacing.xs),
                    Row(
                      children: [
                        AppChoiceChip(label: item.kind, onTap: null),
                        SizedBox(width: t.spacing.xs),
                        Text(
                          _formatTime(item.createdAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.textSecondary),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(notificationListProvider);
    final unreadAsync = ref.watch(notificationUnreadCountProvider);
    final t = context.appTokens;

    return BrowseScaffold(
      header: Row(
        children: [
          Expanded(
            child: Text(
              '通知中心',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: t.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: _refresh,
            icon: Icon(Icons.refresh_rounded, color: t.textSecondary),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: listAsync.when(
          loading: () => const AppLoadingSkeleton(lines: 6),
          error: (e, _) => ListView(
            padding: EdgeInsets.only(bottom: t.spacing.huge),
            children: [
              AppErrorState(
                title: '通知加载失败',
                description: e.toString(),
                retryLabel: '重新加载',
                onRetry: _refresh,
              ),
            ],
          ),
          data: (items) {
            final unread =
                unreadAsync.asData?.value ??
                items.where((e) => !e.isRead).length;
            if (items.isEmpty) {
              return ListView(
                padding: EdgeInsets.only(bottom: t.spacing.huge),
                children: [
                  AppInfoSectionCard(
                    title: '站内提醒',
                    subtitle: '消息、动态、匹配的关键提醒会在这里收口',
                    leadingIcon: Icons.notifications_active_outlined,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '当前没有通知，完成互动后会自动在这里显示。',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: t.textSecondary),
                          ),
                        ),
                        AppChoiceChip(
                          label: '去首页',
                          leading: const Icon(Icons.home_outlined),
                          onTap: () => context.go(AppRouteNames.home),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: EdgeInsets.only(bottom: t.spacing.huge),
              children: [
                AppInfoSectionCard(
                  title: '站内提醒',
                  subtitle: '低噪声回流通知，帮助你回到正确页面',
                  leadingIcon: Icons.notifications_active_outlined,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '未读 $unread 条',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      AppChoiceChip(
                        label: '全部已读',
                        leading: const Icon(Icons.done_all_rounded),
                        onTap: _markAllRead,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: t.spacing.md),
                ...items.map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: t.spacing.sm),
                    child: _buildNotificationCard(item, t),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
