import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
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
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_livekit_service.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/providers/rtc_providers.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/widgets/rtc_audio_spectrum_bar.dart';
import 'package:livekit_client/livekit_client.dart';

class RtcCallPage extends ConsumerStatefulWidget {
  const RtcCallPage({
    super.key,
    required this.callId,
    this.title = '通话',
    this.autoConnect = true,
  });

  final int callId;
  final String title;
  final bool autoConnect;

  @override
  ConsumerState<RtcCallPage> createState() => _RtcCallPageState();
}

class _RtcCallPageState extends ConsumerState<RtcCallPage> {
  Timer? _pollTimer;
  bool _busy = false;
  int? _autoConnectedCallId;
  int? _liveKitConnectedCallId;
  late final RtcLiveKitService _liveKitService;

  @override
  void initState() {
    super.initState();
    _liveKitService = ref.read(rtcLiveKitServiceProvider);
    ref
        .read(frontendTelemetryProvider)
        .rtcCallEntryOpened(sourcePage: 'rtc_call');
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      ref.invalidate(rtcCallProvider(widget.callId));
    });
  }

  @override
  void dispose() {
    unawaited(_liveKitService.leave(callId: _liveKitConnectedCallId));
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(rtcCallProvider(widget.callId));
    await ref.read(rtcCallProvider(widget.callId).future);
  }

  Future<void> _withAction(
    Future<RtcSessionEntity> Function() action,
    String okMessage,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final session = await action();
      ref
          .read(frontendTelemetryProvider)
          .rtcCallStatusChanged(
            sourcePage: 'rtc_call',
            callId: session.id,
            status: session.status,
          );
      ref.invalidate(rtcCallProvider(widget.callId));
      if (!mounted) return;
      if (session.isTerminal) {
        _liveKitConnectedCallId = null;
        unawaited(
          ref.read(rtcLiveKitServiceProvider).leave(callId: session.id),
        );
      }
      AppFeedback.showInfo(context, okMessage);
    } catch (e) {
      if (!mounted) return;
      AppFeedback.showError(context, e.toString());
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _autoConnect(RtcSessionEntity session) async {
    if (_busy || _autoConnectedCallId == session.id) return;
    if (!session.canConnect) return;
    _autoConnectedCallId = session.id;
    await _withAction(
      () => ref.read(rtcRemoteDataSourceProvider).connectCall(session.id),
      '已自动进入通话',
    );
  }

  Future<void> _syncLiveKit(RtcSessionEntity session) async {
    if (session.mode != 'voice') return;
    final liveKit = _liveKitService;
    if (!liveKit.isEnabled) return;

    if (session.isTerminal) {
      if (_liveKitConnectedCallId == session.id) {
        await liveKit.leave(callId: session.id);
      }
      _liveKitConnectedCallId = null;
      return;
    }

    if (!['connecting', 'in_call'].contains(session.status)) return;
    if (_liveKitConnectedCallId == session.id && liveKit.isConnected) return;

    await liveKit.ensureConnected(session.id);
    if (liveKit.isConnected) {
      _liveKitConnectedCallId = session.id;
    }
  }

  Widget _statusChip(RtcSessionEntity session) {
    return AppChoiceChip(label: session.status, onTap: null, selected: true);
  }

  Widget _buildContent(
    RtcSessionEntity session,
    dynamic t, {
    required AudioTrack? remoteAudioTrack,
  }) {
    final title = session.title.isNotEmpty
        ? session.title
        : (session.mode == 'video' ? '视频通话' : '语音通话');
    final displayPeer = session.isInitiator
        ? session.peerName
        : session.initiatorName;
    final isIncoming = !session.isInitiator;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        t.spacing.pageHorizontal,
        t.spacing.md,
        t.spacing.pageHorizontal,
        t.spacing.huge,
      ),
      children: [
        AppInfoSectionCard(
          title: title,
          subtitle: 'RTC 最小闭环',
          leadingIcon: session.mode == 'video'
              ? Icons.videocam_outlined
              : Icons.call_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: t.brandPrimary.withValues(alpha: 0.14),
                    child: Icon(
                      session.mode == 'video'
                          ? Icons.videocam_outlined
                          : Icons.call_outlined,
                      color: t.brandPrimary,
                    ),
                  ),
                  SizedBox(width: t.spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayPeer,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        SizedBox(height: t.spacing.xxs),
                        Text(
                          session.failureMessage ?? '语音优先通话骨架已接入',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _statusChip(session),
                ],
              ),
              SizedBox(height: t.spacing.md),
              Wrap(
                spacing: t.spacing.xs,
                runSpacing: t.spacing.xs,
                children: [
                  AppChoiceChip(
                    label: session.isInitiator ? '发起方' : '接听方',
                    onTap: null,
                  ),
                  AppChoiceChip(
                    label: session.mode == 'video' ? '视频预留' : '语音优先',
                    onTap: null,
                  ),
                  if (session.latestEventName != null)
                    AppChoiceChip(label: session.latestEventName!, onTap: null),
                ],
              ),
              SizedBox(height: t.spacing.md),
              Text(
                switch (session.status) {
                  'calling' => '等待对方接听',
                  'ringing' => isIncoming ? '有来电进入' : '正在呼叫对方',
                  'connecting' => '正在建立通话',
                  'in_call' => '通话进行中',
                  'rejected' => '对方已拒绝',
                  'missed' => '未接通',
                  'busy' => '对方正在通话中',
                  'ended' => '通话已结束',
                  'failed' => '通话失败',
                  _ => '通话状态未知',
                },
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: t.spacing.xxs),
              Text(
                '当前仅做 1v1 语音优先 RTC 骨架，后续媒体引擎可在此基础上接入。',
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
          title: '通话操作',
          subtitle: '状态机最小闭环',
          leadingIcon: Icons.tune_rounded,
          child: Column(
            children: [
              if (session.canAccept && isIncoming) ...[
                AppPrimaryButton(
                  label: '接听',
                  isLoading: _busy,
                  prefixIcon: const Icon(Icons.call, color: Colors.white),
                  onPressed: () => _withAction(
                    () => ref
                        .read(rtcRemoteDataSourceProvider)
                        .acceptCall(session.id),
                    '已接听通话',
                  ),
                ),
                SizedBox(height: t.spacing.sm),
                AppSecondaryButton(
                  label: '拒绝',
                  style: AppSecondaryButtonStyle.outline,
                  isLoading: _busy,
                  prefixIcon: const Icon(Icons.call_end_rounded),
                  onPressed: () => _withAction(
                    () => ref
                        .read(rtcRemoteDataSourceProvider)
                        .rejectCall(session.id),
                    '已拒绝来电',
                  ),
                ),
              ] else if (session.canConnect) ...[
                AppPrimaryButton(
                  label: '进入通话',
                  isLoading: _busy,
                  prefixIcon: const Icon(
                    Icons.headphones_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => _withAction(
                    () => ref
                        .read(rtcRemoteDataSourceProvider)
                        .connectCall(session.id),
                    '已进入通话',
                  ),
                ),
                SizedBox(height: t.spacing.sm),
                AppSecondaryButton(
                  label: '挂断',
                  style: AppSecondaryButtonStyle.outline,
                  isLoading: _busy,
                  prefixIcon: const Icon(Icons.call_end_rounded),
                  onPressed: () => _withAction(
                    () => ref
                        .read(rtcRemoteDataSourceProvider)
                        .endCall(session.id),
                    '已挂断',
                  ),
                ),
              ] else if (session.canHangup) ...[
                AppPrimaryButton(
                  label: '挂断',
                  isLoading: _busy,
                  prefixIcon: const Icon(
                    Icons.call_end_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => _withAction(
                    () => ref
                        .read(rtcRemoteDataSourceProvider)
                        .endCall(session.id),
                    '已挂断',
                  ),
                ),
              ] else if (session.isTerminal) ...[
                AppPrimaryButton(
                  label: '查看结果',
                  isLoading: _busy,
                  prefixIcon: const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    context.push(
                      '${AppRouteNames.rtcCallResult}/${session.id}',
                      extra: session.title,
                    );
                  },
                ),
                SizedBox(height: t.spacing.sm),
                AppSecondaryButton(
                  label: '返回会话',
                  style: AppSecondaryButtonStyle.outline,
                  onPressed: () => context.go(AppRouteNames.messages),
                ),
              ] else ...[
                AppSecondaryButton(
                  label: '返回会话',
                  fullWidth: true,
                  onPressed: () => context.go(AppRouteNames.messages),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: t.spacing.md),
        AppInfoSectionCard(
          title: '音频频谱',
          subtitle: '远端语音可视化诊断',
          leadingIcon: Icons.graphic_eq_rounded,
          child: RtcAudioSpectrumBar(audioTrack: remoteAudioTrack),
        ),
        SizedBox(height: t.spacing.md),
        AppInfoSectionCard(
          title: '状态回放',
          subtitle: '最新事件与时间线',
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
    final liveKitService = ref.watch(rtcLiveKitServiceProvider);
    final t = context.appTokens;

    return BrowseScaffold(
      header: AppTopBar(
        title: widget.title,
        mode: AppTopBarMode.backTitle,
        actions: [
          IconButton(
            tooltip: '刷新通话',
            onPressed: _refresh,
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
              title: '通话加载失败',
              description: e.toString(),
              onRetry: _refresh,
            ),
          ],
        ),
        data: (session) {
          if (widget.autoConnect) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              unawaited(_autoConnect(session));
            });
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            unawaited(_syncLiveKit(session));
          });
          return _buildContent(
            session,
            t,
            remoteAudioTrack: liveKitService.remoteAudioTrack,
          );
        },
      ),
    );
  }
}
