import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/app/router/app_router.dart';
import 'package:flutter_elitesync_module/app/router/app_shell.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/providers/notification_provider.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/providers/rtc_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/app/router/app_shell.dart' as shell;

Timer? _rtcInviteTimer;
bool _rtcInviteScanning = false;
int? _rtcInviteHandledCallId;
int? _rtcInviteHandledNotificationId;
int? _rtcIncomingHandledCallId;

final rtcInviteBootstrapProvider = Provider<void>((ref) {
  startRtcInviteWatcher(ref);
});

int _currentUserId(dynamic ref) {
  final session = ref.read(sessionProvider);
  return session.maybeWhen(
    data: (state) => state.user?.id ?? 0,
    orElse: () => 0,
  );
}

Future<void> _openIncomingCall(
  dynamic ref, {
  required int callId,
  required String title,
  int? notificationId,
}) async {
  if (callId <= 0) return;
  if (_rtcIncomingHandledCallId == callId &&
      (notificationId == null || _rtcInviteHandledNotificationId == notificationId)) {
    return;
  }
  _rtcIncomingHandledCallId = callId;
  if (notificationId != null) {
    _rtcInviteHandledNotificationId = notificationId;
  }
  final router = ref.read(appRouterProvider);
  // ignore: avoid_print
  print('RTC_INVITE_PROVIDER_OPEN callId=$callId');
  router.go(
    '${AppRouteNames.rtcIncomingCall}/$callId',
    extra: title.isNotEmpty ? title : '来电',
  );
}

void startRtcInviteWatcher(dynamic ref) {
  if (_rtcInviteTimer != null) return;
  // ignore: avoid_print
  print('RTC_INVITE_PROVIDER_BUILD');

  Future<void> pollOnce() async {
    if (_rtcInviteScanning) return;
    _rtcInviteScanning = true;
    try {
      ref.invalidate(notificationListProvider);
      final notifications = await ref.read(notificationListProvider.future);
      final invite = shell.selectLatestRtcInvite(notifications);
      // ignore: avoid_print
      print(
        'RTC_INVITE_PROVIDER_SCAN total=${notifications.length} invite=${invite?.id ?? 0}',
      );
      if (invite != null) {
        final callId =
            (invite.routeArgs['call_id'] as num?)?.toInt() ??
            (invite.payload['call_id'] as num?)?.toInt() ??
            0;
        if (callId > 0) {
          if (_rtcInviteHandledCallId == callId &&
              _rtcInviteHandledNotificationId == invite.id) {
            return;
          }

          _rtcInviteHandledCallId = callId;
          _rtcInviteHandledNotificationId = invite.id;
          unawaited(
            ref
                .read(notificationRemoteDataSourceProvider)
                .markRead(invite.id)
                .catchError((_) {}),
          );
          ref.invalidate(notificationUnreadCountProvider);
          ref.invalidate(notificationListProvider);
          await _openIncomingCall(
            ref,
            callId: callId,
            title: invite.title,
            notificationId: invite.id,
          );
          return;
        }
      }

      final currentUserId = _currentUserId(ref);
      if (currentUserId <= 0) return;
      ref.invalidate(rtcCallsProvider);
      final calls = await ref.read(rtcCallsProvider.future);
      final incoming = shell.selectLatestIncomingRtcCall(calls, currentUserId);
      // ignore: avoid_print
      print(
        'RTC_INVITE_PROVIDER_CALL_SCAN total=${calls.length} incoming=${incoming?.id ?? 0}',
      );
      if (incoming == null) return;
      if (_rtcIncomingHandledCallId == incoming.id) return;

      await _openIncomingCall(
        ref,
        callId: incoming.id,
        title: incoming.title,
      );
    } catch (_) {
      // ignore: avoid_print
      print('RTC_INVITE_PROVIDER_ERROR');
    } finally {
      _rtcInviteScanning = false;
    }
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    // ignore: avoid_print
    print('RTC_INVITE_PROVIDER_START');
    pollOnce();
    _rtcInviteTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      pollOnce();
    });
  });

  ref.onDispose(() {
    _rtcInviteTimer?.cancel();
    _rtcInviteTimer = null;
    _rtcInviteScanning = false;
    _rtcInviteHandledCallId = null;
    _rtcInviteHandledNotificationId = null;
  });
}

final rtcInviteWatcherProvider = Provider<void>((ref) {
  Timer? timer;
  bool scanning = false;
  int? handledCallId;
  int? handledNotificationId;

  Future<void> pollOnce() async {
    if (scanning) return;
    scanning = true;
    try {
      ref.invalidate(notificationListProvider);
      final notifications = await ref.read(notificationListProvider.future);
      final invite = shell.selectLatestRtcInvite(notifications);
      // ignore: avoid_print
      print(
        'RTC_INVITE_PROVIDER_SCAN total=${notifications.length} invite=${invite?.id ?? 0}',
      );
      if (invite != null) {
        final callId =
            (invite.routeArgs['call_id'] as num?)?.toInt() ??
            (invite.payload['call_id'] as num?)?.toInt() ??
            0;
        if (callId > 0) {
          if (handledCallId == callId && handledNotificationId == invite.id) {
            return;
          }

          handledCallId = callId;
          handledNotificationId = invite.id;
          unawaited(
            ref
                .read(notificationRemoteDataSourceProvider)
                .markRead(invite.id)
                .catchError((_) {}),
          );
          ref.invalidate(notificationUnreadCountProvider);
          ref.invalidate(notificationListProvider);
          final router = ref.read(appRouterProvider);
          // ignore: avoid_print
          print('RTC_INVITE_PROVIDER_OPEN callId=$callId');
          router.go(
            '${AppRouteNames.rtcIncomingCall}/$callId',
            extra: invite.title.isNotEmpty ? invite.title : '来电',
          );
          return;
        }
      }

      final currentUserId = _currentUserId(ref);
      if (currentUserId <= 0) return;
      ref.invalidate(rtcCallsProvider);
      final calls = await ref.read(rtcCallsProvider.future);
      final incoming = shell.selectLatestIncomingRtcCall(calls, currentUserId);
      // ignore: avoid_print
      print(
        'RTC_INVITE_PROVIDER_CALL_SCAN total=${calls.length} incoming=${incoming?.id ?? 0}',
      );
      if (incoming == null) return;
      if (handledCallId == incoming.id) return;

      handledCallId = incoming.id;
      handledNotificationId = null;
      await _openIncomingCall(
        ref,
        callId: incoming.id,
        title: incoming.title,
      );
    } catch (_) {
      // ignore: avoid_print
      print('RTC_INVITE_PROVIDER_ERROR');
    } finally {
      scanning = false;
    }
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    // ignore: avoid_print
    print('RTC_INVITE_PROVIDER_START');
    pollOnce();
    timer = Timer.periodic(const Duration(seconds: 2), (_) {
      pollOnce();
    });
  });

  ref.onDispose(() {
    timer?.cancel();
  });
});

class RtcInviteCoordinator extends ConsumerStatefulWidget {
  const RtcInviteCoordinator({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<RtcInviteCoordinator> createState() =>
      _RtcInviteCoordinatorState();
}

class _RtcInviteCoordinatorState extends ConsumerState<RtcInviteCoordinator> {
  Timer? _timer;
  bool _scanning = false;
  int? _handledCallId;
  int? _handledNotificationId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startWatcher();
      _pollOnce();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startWatcher() {
    if (_timer != null) return;
    // ignore: avoid_print
    print('RTC_INVITE_COORDINATOR_START');
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      _pollOnce();
    });
  }

  Future<void> _pollOnce() async {
    if (!mounted) return;
    try {
      ref.invalidate(notificationListProvider);
      final notifications = await ref.read(notificationListProvider.future);
      await _handleNotifications(notifications);
    } catch (_) {
      // ignore: avoid_print
      print('RTC_INVITE_COORDINATOR_ERROR');
    }
  }

  Future<void> _handleNotifications(
    List<NotificationItemEntity> notifications,
  ) async {
    if (_scanning || !mounted) return;
    _scanning = true;
    try {
      // ignore: avoid_print
      print(
        'RTC_INVITE_COORDINATOR_SCAN total=${notifications.length} invite=${notifications.where((item) => item.kind == "rtc_call_invite" && !item.isRead).length}',
      );
      final invite = selectLatestRtcInvite(
        notifications,
      );
      if (invite != null) {
        final callId =
            (invite.routeArgs['call_id'] as num?)?.toInt() ??
            (invite.payload['call_id'] as num?)?.toInt() ??
            0;
        if (callId > 0) {
          if (_handledCallId == callId && _handledNotificationId == invite.id) {
            return;
          }

          _handledCallId = callId;
          _handledNotificationId = invite.id;
          // ignore: avoid_print
          print(
            'RTC_INVITE_COORDINATOR_OPEN callId=$callId notificationId=${invite.id}',
          );
          unawaited(
            ref
                .read(notificationRemoteDataSourceProvider)
                .markRead(invite.id)
                .catchError((_) {}),
          );
          ref.invalidate(notificationUnreadCountProvider);
          ref.invalidate(notificationListProvider);
          final router = ref.read(appRouterProvider);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            router.go(
              '${AppRouteNames.rtcIncomingCall}/$callId',
              extra: invite.title.isNotEmpty ? invite.title : '来电',
            );
          });
          return;
        }
      }

      final currentUserId = _currentUserId(ref);
      if (currentUserId <= 0) return;
      ref.invalidate(rtcCallsProvider);
      final calls = await ref.read(rtcCallsProvider.future);
      final incoming = shell.selectLatestIncomingRtcCall(calls, currentUserId);
      // ignore: avoid_print
      print(
        'RTC_INVITE_COORDINATOR_CALL_SCAN total=${calls.length} incoming=${incoming?.id ?? 0}',
      );
      if (incoming == null) return;
      if (_handledCallId == incoming.id) return;

      _handledCallId = incoming.id;
      _handledNotificationId = null;
      // ignore: avoid_print
      print(
        'RTC_INVITE_COORDINATOR_OPEN callId=${incoming.id} notificationId=0',
      );
      final router = ref.read(appRouterProvider);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        router.go(
          '${AppRouteNames.rtcIncomingCall}/${incoming.id}',
          extra: incoming.title.isNotEmpty ? incoming.title : '来电',
        );
      });
    } catch (_) {
      // ignore: avoid_print
      print('RTC_INVITE_COORDINATOR_ERROR');
      // 轮询失败不应阻断主链路；下一轮继续。
    } finally {
      _scanning = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
