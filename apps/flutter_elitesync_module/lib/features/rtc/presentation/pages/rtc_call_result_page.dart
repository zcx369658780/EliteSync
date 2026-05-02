import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_session_entity.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/providers/rtc_providers.dart';

class RtcCallResultPage extends ConsumerStatefulWidget {
  const RtcCallResultPage({
    super.key,
    required this.callId,
    this.title = '通话结果',
  });

  final int callId;
  final String title;

  @override
  ConsumerState<RtcCallResultPage> createState() => _RtcCallResultPageState();
}

class _RtcCallResultPageState extends ConsumerState<RtcCallResultPage> {
  @override
  void initState() {
    super.initState();
    ref
        .read(frontendTelemetryProvider)
        .rtcCallEntryOpened(sourcePage: 'rtc_call_result');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref.read(rtcLiveKitServiceProvider).leave(callId: widget.callId),
      );
    });
  }

  String _statusLabel(RtcSessionEntity session) {
    return switch (session.status) {
      'calling' => '等待接听',
      'ringing' => '来电中',
      'connecting' => '已接听，正在连接',
      'in_call' => '通话进行中',
      'rejected' => '已拒绝',
      'missed' => '未接通',
      'busy' => '对方忙线',
      'ended' => '通话结束',
      'failed' => '通话失败',
      _ => '状态未知',
    };
  }

  String _rhythmTitle(RtcSessionEntity session) {
    return switch (session.status) {
      'ended' || 'in_call' => '通话后的继续建议',
      'missed' || 'rejected' || 'busy' || 'failed' => '未接通后的回聊建议',
      _ => '语音后的关系回流',
    };
  }

  String _rhythmBody(RtcSessionEntity session) {
    return switch (session.status) {
      'ended' || 'in_call' => '如果刚刚聊得顺，可以回到文字里接住一个具体细节，不急着追问下一次安排。',
      'missed' => '未接通时先别连续打扰，可以发一句低压说明，给对方留出稍后回复空间。',
      'rejected' => '对方暂时没有接起时，建议回到文字里轻轻接一句，不把拒接解释成负面信号。',
      'busy' => '对方忙线时适合稍后再聊，先保留关系节奏，不需要立刻再次呼叫。',
      'failed' => '通话失败更像技术中断，建议回到文字说明情况，再决定是否稍后重试。',
      _ => '语音只是关系推进的一步，结束后仍建议回到聊天里继续低压确认。',
    };
  }

  String _followupPrompt(RtcSessionEntity session) {
    return switch (session.status) {
      'ended' || 'in_call' => '刚刚聊到的那个点我还挺想继续听你说，我们可以先用文字慢慢接上。',
      'missed' || 'rejected' || 'busy' => '刚刚语音可能不太方便，没关系。你有空的时候我们再用文字慢慢聊就好。',
      'failed' => '刚才语音好像没有连上，先不急，我们可以继续用文字聊。',
      _ => '如果你愿意，我们可以先回到文字里继续刚才的节奏。',
    };
  }

  Widget _buildContent(RtcSessionEntity session, dynamic t) {
    final peerName = session.isInitiator
        ? session.peerName
        : session.initiatorName;
    final isSuccess = session.status == 'ended' || session.status == 'in_call';

    return ListView(
      padding: EdgeInsets.fromLTRB(
        t.spacing.pageHorizontal,
        t.spacing.md,
        t.spacing.pageHorizontal,
        t.spacing.huge,
      ),
      children: [
        AppInfoSectionCard(
          title: '通话结果',
          subtitle: 'RTC 最小闭环终态',
          leadingIcon: isSuccess
              ? Icons.call_end_rounded
              : Icons.call_missed_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: t.brandPrimary.withValues(alpha: 0.14),
                    child: Icon(
                      isSuccess
                          ? Icons.call_end_rounded
                          : Icons.phone_missed_outlined,
                      color: t.brandPrimary,
                    ),
                  ),
                  SizedBox(width: t.spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          peerName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        SizedBox(height: t.spacing.xxs),
                        Text(
                          session.failureMessage ?? '通话已完成归档，可回看终态。',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  AppChoiceChip(
                    label: _statusLabel(session),
                    onTap: null,
                    selected: true,
                  ),
                ],
              ),
              SizedBox(height: t.spacing.md),
              Wrap(
                spacing: t.spacing.xs,
                runSpacing: t.spacing.xs,
                children: [
                  AppChoiceChip(
                    label: session.mode == 'video' ? '视频预留' : '语音优先',
                    onTap: null,
                  ),
                  AppChoiceChip(
                    label: session.isInitiator ? '发起方' : '接听方',
                    onTap: null,
                  ),
                  if (session.latestEventName != null)
                    AppChoiceChip(label: session.latestEventName!, onTap: null),
                ],
              ),
              SizedBox(height: t.spacing.md),
              Text(
                isSuccess ? '当前通话已结束，可查看事件回放或返回上一页。' : '当前通话未成功接通，可查看结果并返回。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: t.spacing.md),
        AppInfoSectionCard(
          title: _rhythmTitle(session),
          subtitle: '从语音回到文字，不制造回复压力',
          leadingIcon: Icons.forum_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _rhythmBody(session),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: t.textSecondary,
                  height: 1.45,
                ),
              ),
              SizedBox(height: t.spacing.sm),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(t.spacing.sm),
                decoration: BoxDecoration(
                  color: t.secondarySurface,
                  borderRadius: BorderRadius.circular(t.radius.md),
                ),
                child: Text(
                  _followupPrompt(session),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: t.spacing.sm),
              Wrap(
                spacing: t.spacing.xs,
                runSpacing: t.spacing.xs,
                children: [
                  AppChoiceChip(
                    label: '回到文字',
                    selected: true,
                    leading: const Icon(Icons.chat_bubble_outline_rounded),
                  ),
                  AppChoiceChip(
                    label: '低压接续',
                    selected: true,
                    leading: const Icon(Icons.spa_outlined),
                  ),
                  AppChoiceChip(
                    label: '稍后再聊',
                    selected: true,
                    leading: const Icon(Icons.schedule_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: t.spacing.md),
        AppInfoSectionCard(
          title: '结果回放',
          subtitle: '事件与时间线',
          leadingIcon: Icons.timeline_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'call_id: ${session.id} / ${session.callKey}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
              ),
              SizedBox(height: t.spacing.sm),
              if (session.events.isEmpty)
                Text(
                  '暂无事件记录',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
                )
              else
                Column(
                  children: session.events.map((event) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: t.spacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            margin: EdgeInsets.only(top: t.spacing.xs),
                            decoration: BoxDecoration(
                              color: t.brandPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: t.spacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.eventName,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: t.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                if (event.payload.isNotEmpty)
                                  Text(
                                    event.payload.toString(),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: t.textSecondary),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
        SizedBox(height: t.spacing.md),
        AppSecondaryButton(
          label: '返回上一页',
          fullWidth: true,
          onPressed: () => context.go(AppRouteNames.messages),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(rtcCallProvider(widget.callId));
    final t = context.appTokens;

    return BrowseScaffold(
      header: AppTopBar(
        title: widget.title,
        mode: AppTopBarMode.backTitle,
        actions: [
          IconButton(
            tooltip: '刷新结果',
            onPressed: () => ref.invalidate(rtcCallProvider(widget.callId)),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: sessionAsync.when(
        loading: () => const AppLoadingSkeleton(lines: 6),
        error: (e, _) => ListView(
          padding: EdgeInsets.only(bottom: t.spacing.huge),
          children: [
            AppErrorState(
              title: '结果加载失败',
              description: e.toString(),
              onRetry: () => ref.invalidate(rtcCallProvider(widget.callId)),
            ),
          ],
        ),
        data: (session) => _buildContent(session, t),
      ),
    );
  }
}
