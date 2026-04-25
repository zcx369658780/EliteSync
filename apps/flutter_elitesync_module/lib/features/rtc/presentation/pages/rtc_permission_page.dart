import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_permission_service.dart';

class RtcPermissionPage extends ConsumerStatefulWidget {
  const RtcPermissionPage({
    super.key,
    this.title = '通话权限',
    this.sourcePage = 'rtc_permission',
  });

  final String title;
  final String sourcePage;

  @override
  ConsumerState<RtcPermissionPage> createState() => _RtcPermissionPageState();
}

class _RtcPermissionPageState extends ConsumerState<RtcPermissionPage> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    ref.read(frontendTelemetryProvider).rtcCallEntryOpened(sourcePage: widget.sourcePage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshPermissionState(showFeedback: false);
    });
  }

  Future<void> _refreshPermissionState({required bool showFeedback}) async {
    if (_busy) return;
    final granted =
        await ref.read(rtcPermissionServiceProvider).hasVoiceCallPermission();
    if (!mounted) return;
    if (granted) {
      if (showFeedback) {
        AppFeedback.showSuccess(context, '麦克风权限已开启，可以返回继续通话');
      }
      Navigator.of(context).maybePop(true);
      return;
    }
    if (showFeedback) {
      AppFeedback.showInfo(context, '麦克风权限尚未开启，请先完成授权');
    }
  }

  Future<void> _requestPermission() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final granted = await ref
          .read(rtcPermissionServiceProvider)
          .ensureVoiceCallPermission();
      if (!mounted) return;
      if (granted) {
        AppFeedback.showSuccess(context, '麦克风权限已开启，可以返回继续通话');
        Navigator.of(context).maybePop(true);
      } else {
        AppFeedback.showError(context, '麦克风权限未开启，请在系统设置中授权后重试');
      }
    } catch (e) {
      if (!mounted) return;
      AppFeedback.showError(context, e.toString());
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _openSettings() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(rtcPermissionServiceProvider).openSettings();
    } catch (e) {
      if (!mounted) return;
      AppFeedback.showError(context, e.toString());
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Widget _buildContent(dynamic t) {
    return ListView(
      padding: EdgeInsets.fromLTRB(t.spacing.pageHorizontal, t.spacing.md, t.spacing.pageHorizontal, t.spacing.huge),
      children: [
        AppInfoSectionCard(
          title: '通话权限',
          subtitle: '语音优先 RTC 的最小设备门槛',
          leadingIcon: Icons.mic_none_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: t.brandPrimary.withValues(alpha: 0.14),
                    child: Icon(Icons.mic_none_rounded, color: t.brandPrimary),
                  ),
                  SizedBox(width: t.spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '麦克风权限',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: t.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: t.spacing.xxs),
                        Text(
                          '语音通话需要麦克风权限，视频预留后续再扩。',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  AppChoiceChip(label: '1v1 语音优先', onTap: null, selected: true),
                ],
              ),
              SizedBox(height: t.spacing.md),
              Text(
                '如果权限未开启，来电或发起通话时会先停留在这里，避免直接失败后让用户看不懂。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textSecondary, height: 1.35),
              ),
            ],
          ),
        ),
        SizedBox(height: t.spacing.md),
        AppInfoSectionCard(
          title: '操作',
          subtitle: '授权 / 去设置 / 返回',
          leadingIcon: Icons.tune_rounded,
          child: Column(
            children: [
              AppPrimaryButton(
                label: '申请麦克风权限',
                isLoading: _busy,
                prefixIcon: const Icon(Icons.mic_rounded, color: Colors.white),
                onPressed: _requestPermission,
              ),
              SizedBox(height: t.spacing.sm),
              AppSecondaryButton(
                label: '打开系统设置',
                style: AppSecondaryButtonStyle.outline,
                isLoading: _busy,
                onPressed: _openSettings,
              ),
              SizedBox(height: t.spacing.sm),
              AppSecondaryButton(
                label: '返回',
                fullWidth: true,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
        SizedBox(height: t.spacing.md),
        AppInfoSectionCard(
          title: '提示',
          subtitle: '异常恢复',
          leadingIcon: Icons.info_outline_rounded,
          child: Text(
            '如果你已经授权但仍然无法通话，先返回上一页重试；如果依然失败，再检查系统级麦克风开关。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textSecondary, height: 1.35),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return BrowseScaffold(
      header: AppTopBar(
        title: widget.title,
        mode: AppTopBarMode.backTitle,
        actions: [
          IconButton(
            tooltip: '刷新状态',
            onPressed: () => _refreshPermissionState(showFeedback: true),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: ref.read(rtcPermissionServiceProvider).hasVoiceCallPermission(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingSkeleton(lines: 5);
          }
          if (snapshot.hasError) {
            return ListView(
              padding: EdgeInsets.only(bottom: t.spacing.huge),
              children: [
                AppErrorState(
                  title: '权限状态读取失败',
                  description: snapshot.error.toString(),
                  onRetry: () => setState(() {}),
                ),
              ],
            );
          }
          return _buildContent(t);
        },
      ),
    );
  }
}
