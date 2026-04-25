import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_session_entity.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/providers/rtc_providers.dart';

class RtcIncomingCallPage extends ConsumerStatefulWidget {
  const RtcIncomingCallPage({
    super.key,
    required this.callId,
    this.title = '来电',
    this.autoAccept = true,
  });

  final int callId;
  final String title;
  final bool autoAccept;

  @override
  ConsumerState<RtcIncomingCallPage> createState() =>
      _RtcIncomingCallPageState();
}

class _RtcIncomingCallPageState extends ConsumerState<RtcIncomingCallPage> {
  bool _busy = false;
  int? _autoAcceptedCallId;

  @override
  void initState() {
    super.initState();
    ref
        .read(frontendTelemetryProvider)
        .rtcCallEntryOpened(sourcePage: 'rtc_incoming_call');
  }

  Future<RtcSessionEntity?> _withAction(
    Future<RtcSessionEntity> Function() action,
    String okMessage,
  ) async {
    if (_busy) return null;
    setState(() => _busy = true);
    try {
      final session = await action();
      ref
          .read(frontendTelemetryProvider)
          .rtcCallStatusChanged(
            sourcePage: 'rtc_incoming_call',
            callId: session.id,
            status: session.status,
          );
      ref.invalidate(rtcCallProvider(widget.callId));
      if (!mounted) return session;
      AppFeedback.showInfo(context, okMessage);
      return session;
    } catch (e) {
      if (!mounted) return null;
      AppFeedback.showError(context, e.toString());
      return null;
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _autoAcceptAndEnter(RtcSessionEntity session) async {
    if (_busy || _autoAcceptedCallId == session.id) return;
    if (!session.canAccept) return;
    _autoAcceptedCallId = session.id;
    final updated = await _withAction(
      () => ref.read(rtcRemoteDataSourceProvider).acceptCall(session.id),
      '已自动接听来电',
    );
    if (!mounted || updated == null) return;
    context.go(
      '${AppRouteNames.rtcCall}/${updated.id}',
      extra: updated.title.isNotEmpty ? updated.title : widget.title,
    );
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

  Widget _buildContent(RtcSessionEntity session, dynamic t) {
    final peerName = session.isIncoming
        ? session.initiatorName
        : session.peerName;
    final title = session.title.isNotEmpty ? session.title : '来电';

    return ListView(
      padding: EdgeInsets.fromLTRB(
        t.spacing.pageHorizontal,
        t.spacing.md,
        t.spacing.pageHorizontal,
        t.spacing.huge,
      ),
      children: [
        AppInfoSectionCard(
          title: '来电提醒',
          subtitle: '1v1 语音优先 RTC 最小闭环',
          leadingIcon: Icons.call_received_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: t.brandPrimary.withValues(alpha: 0.14),
                    child: Icon(Icons.call_outlined, color: t.brandPrimary),
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
                          session.failureMessage ?? '邀请你进行 $title。',
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
                    label: session.isIncoming ? '来电方' : '发起方',
                    onTap: null,
                  ),
                  if (session.latestEventName != null)
                    AppChoiceChip(label: session.latestEventName!, onTap: null),
                ],
              ),
              SizedBox(height: t.spacing.md),
              Text(
                '当前只做 1v1 通话最小闭环，接听后会进入通话页，拒绝后会回到结果页。',
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
          title: '来电操作',
          subtitle: '接听 / 拒绝 / 结果回流',
          leadingIcon: Icons.tune_rounded,
          child: Column(
            children: [
              AppPrimaryButton(
                label: '接听',
                isLoading: _busy,
                prefixIcon: const Icon(Icons.call, color: Colors.white),
                onPressed: () async {
                  final updated = await _withAction(
                    () => ref
                        .read(rtcRemoteDataSourceProvider)
                        .acceptCall(session.id),
                    '已接听来电',
                  );
                  if (!mounted || updated == null) return;
                  context.go(
                    '${AppRouteNames.rtcCall}/${updated.id}',
                    extra: updated.title.isNotEmpty
                        ? updated.title
                        : widget.title,
                  );
                },
              ),
              SizedBox(height: t.spacing.sm),
              AppSecondaryButton(
                label: '拒绝',
                style: AppSecondaryButtonStyle.outline,
                isLoading: _busy,
                prefixIcon: const Icon(Icons.call_end_rounded),
                onPressed: () async {
                  final updated = await _withAction(
                    () => ref
                        .read(rtcRemoteDataSourceProvider)
                        .rejectCall(session.id),
                    '已拒绝来电',
                  );
                  if (!mounted || updated == null) return;
                  context.go(
                    '${AppRouteNames.rtcCallResult}/${updated.id}',
                    extra: updated.title.isNotEmpty
                        ? updated.title
                        : widget.title,
                  );
                },
              ),
              SizedBox(height: t.spacing.sm),
              AppSecondaryButton(
                label: '返回',
                fullWidth: true,
                onPressed: () => context.go(AppRouteNames.messages),
              ),
            ],
          ),
        ),
        SizedBox(height: t.spacing.md),
        AppInfoSectionCard(
          title: '状态回放',
          subtitle: '来电事件时间线',
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
            tooltip: '刷新来电',
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
              title: '来电加载失败',
              description: e.toString(),
              onRetry: () => ref.invalidate(rtcCallProvider(widget.callId)),
            ),
          ],
        ),
        data: (session) {
          if (widget.autoAccept) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              unawaited(_autoAcceptAndEnter(session));
            });
          }
          return _buildContent(session, t);
        },
      ),
    );
  }
}
