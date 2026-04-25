import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/providers/notification_provider.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_result_entity.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/features/match/presentation/state/match_countdown_ui_state.dart';
import 'package:flutter_elitesync_module/features/match/presentation/state/match_result_ui_state.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_hero_summary_card.dart';

class MatchPortalPage extends ConsumerWidget {
  const MatchPortalPage({super.key});

  String _formatCountdown(DateTime? revealAt) {
    if (revealAt == null) return '--';
    final diff = revealAt.difference(DateTime.now().toLocal());
    if (diff.isNegative) return '即将揭晓';
    final days = diff.inDays;
    final hours = diff.inHours.remainder(24);
    final minutes = diff.inMinutes.remainder(60);
    final hourText = hours.toString().padLeft(2, '0');
    final minuteText = minutes.toString().padLeft(2, '0');
    if (days > 0) {
      return '$days天 $hourText小时 $minuteText分';
    }
    return '$hourText小时 $minuteText分';
  }

  String _formatRevealAt(DateTime? revealAt) {
    if (revealAt == null) return '--';
    String two(int v) => v.toString().padLeft(2, '0');
    return '${revealAt.month}月${two(revealAt.day)}日 ${two(revealAt.hour)}:${two(revealAt.minute)}';
  }

  List<String> _icebreakers(MatchResultEntity data) {
    final tags = data.tags.where((e) => e.trim().isNotEmpty).take(3).toList();
    final firstTag = tags.isNotEmpty ? tags.first : '最近的生活节奏';
    final secondTag = tags.length > 1 ? tags[1] : '周末安排';
    final thirdTag = tags.length > 2 ? tags[2] : '第一次见面';
    final highlight = data.highlights.isNotEmpty
        ? data.highlights.first.desc
        : '最想继续了解的地方';
    return [
      '先从$firstTag聊起，你会怎么开场？',
      '你更愿意聊$secondTag，还是先约一次轻松见面？',
      '如果对方提到$thirdTag，你会怎么接？',
      '最想继续了解：$highlight',
    ];
  }

  Widget _buildStageStep(
    BuildContext context, {
    required String label,
    required String sublabel,
    required IconData icon,
    required Color tone,
    required bool active,
    required bool completed,
  }) {
    final t = context.appTokens;
    final background = completed
        ? tone.withValues(alpha: 0.12)
        : (active
              ? tone.withValues(alpha: 0.08)
              : t.browseSurface.withValues(alpha: 0.72));
    final borderColor = completed
        ? tone.withValues(alpha: 0.30)
        : (active
              ? tone.withValues(alpha: 0.22)
              : t.browseBorder.withValues(alpha: 0.55));
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: tone),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (completed)
                Text(
                  '已完成',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: tone,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            sublabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String body,
    required IconData icon,
    required Color accent,
    required bool locked,
    required bool highlighted,
    required double top,
    required double inset,
    required double opacity,
  }) {
    final t = context.appTokens;
    final isMasked = locked && !highlighted;
    return Positioned(
      top: top,
      left: inset,
      right: inset,
      child: Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(0, highlighted ? 0 : top * 0.06),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: highlighted
                  ? t.browseSurface
                  : t.browseSurface.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(t.radius.xl),
              border: Border.all(
                color: accent.withValues(alpha: highlighted ? 0.24 : 0.14),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: highlighted ? 0.08 : 0.05,
                  ),
                  blurRadius: highlighted ? 18 : 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    locked ? Icons.lock_outline_rounded : icon,
                    size: 20,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: t.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          if (locked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '待解锁',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: accent,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isMasked ? '••• · ••• · •••' : body,
                        maxLines: isMasked ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: t.textPrimary.withValues(
                            alpha: isMasked ? 0.56 : 1,
                          ),
                          height: 1.45,
                          fontWeight: highlighted
                              ? FontWeight.w600
                              : FontWeight.w500,
                          letterSpacing: isMasked ? 1.1 : 0,
                        ),
                      ),
                      if (isMasked) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Text(
                            '喜欢后逐层展开',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<MatchCountdownUiState> countdownAsync,
    AsyncValue<MatchResultUiState> resultAsync,
  ) {
    final t = context.appTokens;
    return countdownAsync.when(
      loading: () => const AppLoadingSkeleton(lines: 4),
      error: (e, _) => AppErrorState(
        title: '盲盒资料加载失败',
        description: e.toString(),
        retryLabel: '重新加载',
        onRetry: () async {
          ref.invalidate(matchCountdownProvider);
          ref.invalidate(matchResultProvider);
          await Future.wait([
            ref.read(matchCountdownProvider.future),
            ref.read(matchResultProvider.future),
          ]);
        },
      ),
      data: (countdownState) {
        final resultData = resultAsync.maybeWhen(
          data: (state) => state.data,
          orElse: () => null,
        );
        final status = (countdownState.data?.status ?? '').toLowerCase();
        final isOpen = status == 'drop_open' && resultData != null;
        final accent = isOpen ? t.success : t.brandPrimary;
        final stageTitle = isOpen ? '本周 Drop 已揭晓' : '本周 Drop 倒计时';
        final stageSubtitle = isOpen
            ? '结果已经亮起，进入揭晓页后可以直接查看完整结果。'
            : '结果会在约定时间揭晓，把期待留到最后一刻。';
        final countdownLabel = isOpen
            ? '已揭晓'
            : _formatCountdown(countdownState.data?.revealAt);
        final revealLabel = _formatRevealAt(countdownState.data?.revealAt);
        final stageHint = countdownState.data?.hint.trim() ?? '';

        return Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF171229),
                const Color(0xFF242A4E),
                t.browseSurface,
              ],
            ),
            borderRadius: BorderRadius.circular(t.radius.xl),
            border: Border.all(
              color: accent.withValues(alpha: isOpen ? 0.34 : 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -18,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: 0.26),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -42,
                left: -16,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        t.info.withValues(alpha: 0.16),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.06),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            isOpen
                                ? Icons.auto_awesome_rounded
                                : Icons.lock_clock_rounded,
                            size: 22,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stageTitle,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: t.textPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                stageSubtitle,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: t.textSecondary,
                                      height: 1.45,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isOpen ? 'REVEALED' : 'COUNTDOWN',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: t.spacing.lg),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(t.radius.xl),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                'DROP',
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.06),
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 8,
                                    ),
                              ),
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 700),
                                tween: Tween(begin: isOpen ? 0.96 : 0.92, end: 1),
                                curve: Curves.easeOutBack,
                                builder: (context, scale, child) {
                                  return Transform.scale(
                                    scale: scale,
                                    child: child,
                                  );
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      countdownLabel,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                            color: accent,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -0.8,
                                            fontSize: isOpen ? 40 : 48,
                                            shadows: [
                                              Shadow(
                                                color: accent.withValues(
                                                  alpha: 0.32,
                                                ),
                                                blurRadius: 18,
                                              ),
                                            ],
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      isOpen
                                          ? '点击进入揭晓结果'
                                          : '预计揭晓：$revealLabel',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: t.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildStageStep(
                                context,
                                label: '倒计时',
                                sublabel: '等待结果到点亮起',
                                icon: Icons.schedule_rounded,
                                tone: accent,
                                active: !isOpen,
                                completed: isOpen,
                              ),
                              _buildStageStep(
                                context,
                                label: '揭晓',
                                sublabel: '先看到结果，再往下看',
                                icon: Icons.auto_awesome_rounded,
                                tone: t.info,
                                active: isOpen,
                                completed: isOpen,
                              ),
                              _buildStageStep(
                                context,
                                label: '解锁',
                                sublabel: '资料逐层展开',
                                icon: Icons.lock_open_rounded,
                                tone: t.success,
                                active: isOpen,
                                completed: isOpen,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (stageHint.isNotEmpty) ...[
                      SizedBox(height: t.spacing.md),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(t.radius.lg),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.auto_graph_rounded,
                              size: 18,
                              color: t.info,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                stageHint,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: t.textSecondary,
                                      height: 1.45,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: t.spacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: AppPrimaryButton(
                            label: isOpen ? '查看揭晓结果' : '刷新状态',
                            onPressed: () {
                              if (isOpen) {
                                context.push(AppRouteNames.matchResult);
                              } else {
                                ref.invalidate(matchCountdownProvider);
                              }
                            },
                          ),
                        ),
                        SizedBox(width: t.spacing.sm),
                        Expanded(
                          child: AppSecondaryButton(
                            label: '完整解释',
                            fullWidth: true,
                            onPressed: () =>
                                context.push(AppRouteNames.matchDetail),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlindBoxSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<MatchCountdownUiState> countdownAsync,
    AsyncValue<MatchResultUiState> resultAsync,
  ) {
    final t = context.appTokens;
    return countdownAsync.when(
      loading: () => const AppLoadingSkeleton(lines: 4),
      error: (e, _) => AppErrorState(
        title: '盲盒资料加载失败',
        description: e.toString(),
        retryLabel: '重新加载',
        onRetry: () async {
          ref.invalidate(matchCountdownProvider);
          ref.invalidate(matchResultProvider);
          await Future.wait([
            ref.read(matchCountdownProvider.future),
            ref.read(matchResultProvider.future),
          ]);
        },
      ),
      data: (countdownState) {
        final resultData = resultAsync.maybeWhen(
          data: (state) => state.data,
          orElse: () => null,
        );
        final status = (countdownState.data?.status ?? '').toLowerCase();
        final isOpen = status == 'drop_open' && resultData != null;
        final openResult =
            resultData ??
            const MatchResultEntity(
              headline: '',
              score: 0,
              tags: [],
              highlights: [],
            );
        final topBody = isOpen
            ? '${openResult.headline} · 头像轮廓、昵称缩写、关键亮点已展开。'
            : '头像轮廓、昵称缩写、3 个轻提示。';
        final middleBody = isOpen
            ? openResult.tags.take(3).join(' · ')
            : '单边喜欢后，会先露出更多标签和相处提示。';
        final bottomBody = isOpen
            ? '${openResult.headline} · 完整解释、破冰问题和匹配后反馈都可继续查看。'
            : '双边喜欢后，才会展开完整资料与破冰问题。';

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                t.browseSurface,
                t.browseSurface.withValues(alpha: 0.96),
                const Color(0xFFF8FAFF),
              ],
            ),
            borderRadius: BorderRadius.circular(t.radius.xl),
            border: Border.all(color: t.browseBorder.withValues(alpha: 0.92)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: t.brandPrimary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.layers_rounded,
                        size: 18,
                        color: t.brandPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '盲盒资料分层解锁',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '先看轮廓，再看摘要，最后再看完整解释。',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: t.textSecondary,
                                  height: 1.35,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: t.spacing.md),
                SizedBox(
                  height: 320,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildLayerCard(
                        context,
                        title: '双边喜欢后',
                        subtitle: isOpen ? '完整资料已展开' : '完整解锁',
                        body: bottomBody,
                        icon: Icons.lock_open_rounded,
                        accent: t.success,
                        locked: !isOpen,
                        highlighted: isOpen,
                        top: 88,
                        inset: 24,
                        opacity: isOpen ? 1 : 0.40,
                      ),
                      _buildLayerCard(
                        context,
                        title: '单边喜欢后',
                        subtitle: isOpen ? '更多标签与提示' : '先露出更多标签',
                        body: middleBody,
                        icon: Icons.visibility_rounded,
                        accent: t.brandPrimary,
                        locked: !isOpen,
                        highlighted: false,
                        top: 44,
                        inset: 12,
                        opacity: isOpen ? 0.96 : 0.58,
                      ),
                      _buildLayerCard(
                        context,
                        title: '悬念版',
                        subtitle: isOpen ? '现在可见的轻内容' : '现在就看到的内容',
                        body: topBody,
                        icon: Icons.auto_awesome_rounded,
                        accent: t.info,
                        locked: false,
                        highlighted: true,
                        top: 0,
                        inset: 0,
                        opacity: 1,
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.02),
                                  Colors.black.withValues(alpha: 0.05),
                                ],
                                stops: const [0.0, 0.56, 0.82, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!isOpen)
                        Positioned(
                          left: 18,
                          right: 18,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 16,
                                  color: t.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '喜欢后逐层解锁',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: t.textSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: t.spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppPrimaryButton(
                        label: isOpen ? '查看揭晓结果' : '刷新状态',
                        onPressed: () {
                          if (isOpen) {
                            context.push(AppRouteNames.matchResult);
                          } else {
                            ref.invalidate(matchCountdownProvider);
                            ref.invalidate(matchResultProvider);
                          }
                        },
                      ),
                    ),
                    SizedBox(width: t.spacing.sm),
                    Expanded(
                      child: AppSecondaryButton(
                        label: '完整解释',
                        fullWidth: true,
                        onPressed: () =>
                            context.push(AppRouteNames.matchDetail),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevealSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<MatchResultUiState> resultAsync,
  ) {
    final t = context.appTokens;
    return resultAsync.when(
      loading: () => const AppLoadingSkeleton(lines: 7),
      error: (e, _) => AppErrorState(
        title: '揭晓结果加载失败',
        description: e.toString(),
        retryLabel: '重新加载',
        onRetry: () => ref.refresh(matchResultProvider),
      ),
      data: (state) {
        final data = state.data;
        if (data == null) {
          return AppCard(
            padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lock_clock_rounded,
                      size: 18,
                      color: t.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '完整结果还在揭晓中',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: t.spacing.xs),
                Text(
                  '盲盒资料会在揭晓后自动展开头像、标签和破冰问题。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: t.textSecondary,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: t.spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppSecondaryButton(
                        label: '回到倒计时',
                        fullWidth: true,
                        onPressed: () =>
                            context.push(AppRouteNames.matchCountdown),
                      ),
                    ),
                    SizedBox(width: t.spacing.sm),
                    Expanded(
                      child: AppPrimaryButton(
                        label: '完整解释',
                        onPressed: () =>
                            context.push(AppRouteNames.matchDetail),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        final questions = _icebreakers(data);
        return Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    t.brandPrimary.withValues(alpha: 0.10),
                    t.browseSurface,
                  ],
                ),
                borderRadius: BorderRadius.circular(t.radius.xl),
                border: Border.all(
                  color: t.brandPrimary.withValues(alpha: 0.16),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
                child: MatchHeroSummaryCard(
                  headline: data.headline,
                  score: data.score,
                  tags: data.tags,
                ),
              ),
            ),
            SizedBox(height: t.spacing.md),
            Row(
              children: [
                Expanded(
                  child: AppPrimaryButton(
                    label: '愿意认识',
                    onPressed: () => context.push(AppRouteNames.matchIntention),
                  ),
                ),
                SizedBox(width: t.spacing.sm),
                Expanded(
                  child: AppSecondaryButton(
                    label: '完整解释',
                    fullWidth: true,
                    onPressed: () => context.push(AppRouteNames.matchDetail),
                  ),
                ),
              ],
            ),
            SizedBox(height: t.spacing.md),
            AppCard(
              padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.question_answer_rounded,
                        size: 18,
                        color: t.brandPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '破冰问题',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: t.spacing.xs),
                  Text(
                    '先从轻话题开始，让对话自然展开。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: t.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: t.spacing.md),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: questions.length,
                      separatorBuilder: (context, separatorIndex) =>
                          SizedBox(width: t.spacing.sm),
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        return Container(
                          width: 260,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: t.browseSurface,
                            borderRadius: BorderRadius.circular(t.radius.lg),
                            border: Border.all(
                              color: t.browseBorder.withValues(alpha: 0.85),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: t.brandPrimary.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${index + 1}',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: t.brandPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Text(
                                  question,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: t.textPrimary,
                                        height: 1.45,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(
                                    Icons.send_rounded,
                                    size: 16,
                                    color: t.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '适合直接开聊',
                                    style: Theme.of(context).textTheme.labelSmall
                                        ?.copyWith(
                                          color: t.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: t.spacing.md),
            AppCard(
              padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '匹配后反馈',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '反馈只会保存在本机，用来回看这次慢约会体验。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: t.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppSecondaryButton(
                    label: '写下反馈',
                    fullWidth: true,
                    onPressed: () => context.push(AppRouteNames.matchFeedback),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdownAsync = ref.watch(matchCountdownProvider);
    final resultAsync = ref.watch(matchResultProvider);
    final notificationUnreadAsync = ref.watch(notificationUnreadCountProvider);
    final t = context.appTokens;

    Future<void> refreshAll() async {
      ref.invalidate(matchCountdownProvider);
      ref.invalidate(matchResultProvider);
      await Future.wait([
        ref.read(matchCountdownProvider.future),
        ref.read(matchResultProvider.future),
      ]);
    }

    return BrowseScaffold(
      header: SizedBox(
        height: 44,
        child: Row(
          children: [
            Text(
              '慢约会',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: t.textPrimary,
                fontWeight: FontWeight.w800,
              ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.push(AppRouteNames.notificationCenter),
            icon: Icon(
              notificationUnreadAsync.asData?.value != null &&
                      notificationUnreadAsync.asData!.value > 0
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              color: t.textSecondary,
            ),
          ),
          IconButton(
            onPressed: refreshAll,
            icon: Icon(Icons.refresh_rounded, color: t.textSecondary),
          ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refreshAll,
        child: ListView(
          padding: EdgeInsets.fromLTRB(0, t.spacing.xs, 0, t.spacing.huge),
          children: [
            const SectionReveal(
              child: PageTitleRail(
                title: 'Drop 与揭晓',
                subtitle: '先等结果，再看悬念版，最后再决定是否继续了解',
              ),
            ),
            SizedBox(height: t.spacing.md),
            SectionReveal(
              delay: const Duration(milliseconds: 50),
              child: _buildCountdownSection(
                context,
                ref,
                countdownAsync,
                resultAsync,
              ),
            ),
            SizedBox(height: t.spacing.md),
            SectionReveal(
              delay: const Duration(milliseconds: 90),
              child: _buildBlindBoxSection(
                context,
                ref,
                countdownAsync,
                resultAsync,
              ),
            ),
            SizedBox(height: t.spacing.md),
            SectionReveal(
              delay: const Duration(milliseconds: 130),
              child: _buildRevealSection(context, ref, resultAsync),
            ),
          ],
        ),
      ),
    );
  }
}
