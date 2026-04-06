import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync/app/router/app_route_names.dart';
import 'package:flutter_elitesync/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync/features/match/domain/entities/match_result_entity.dart';
import 'package:flutter_elitesync/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync/features/match/presentation/widgets/match_hero_summary_card.dart';

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
    final tags = data.tags.where((e) => e.trim().isNotEmpty).take(2).toList();
    final firstTag = tags.isNotEmpty ? tags.first : '最近的生活节奏';
    final secondTag = tags.length > 1 ? tags[1] : '周末安排';
    return [
      '如果先从$firstTag聊起，你会想问对方什么？',
      '你更喜欢先聊$secondTag，还是先约一次轻松见面？',
      '这次揭晓里最让你想继续了解的一点是什么？',
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdownAsync = ref.watch(matchCountdownProvider);
    final resultAsync = ref.watch(matchResultProvider);
    final t = context.appTokens;

    Future<void> refreshAll() async {
      ref.invalidate(matchCountdownProvider);
      ref.invalidate(matchResultProvider);
      await Future.wait([
        ref.read(matchCountdownProvider.future),
        ref.read(matchResultProvider.future),
      ]);
    }

    Widget buildBlindBoxSection() {
      return countdownAsync.when(
        loading: () => const AppLoadingSkeleton(lines: 4),
        error: (e, _) => AppErrorState(
          title: '盲盒资料加载失败',
          description: e.toString(),
          retryLabel: '重新加载',
          onRetry: refreshAll,
        ),
        data: (countdownState) {
          final resultData = resultAsync.maybeWhen(
            data: (state) => state.data,
            orElse: () => null,
          );
          final revealAt = countdownState.data?.revealAt;
          final isOpen =
              revealAt != null &&
              revealAt.isBefore(DateTime.now().toLocal()) &&
              resultData != null;
          final t = context.appTokens;
          final rows = isOpen
              ? <({IconData icon, String title, String value, Color color})>[
                  (
                    icon: Icons.person_rounded,
                    title: '轮廓',
                    value: resultData.headline,
                    color: t.success,
                  ),
                  (
                    icon: Icons.sell_rounded,
                    title: '标签',
                    value: resultData.tags.take(3).join(' · '),
                    color: t.brandPrimary,
                  ),
                  (
                    icon: Icons.chat_bubble_outline_rounded,
                    title: '开场建议',
                    value: resultData.highlights.isNotEmpty
                        ? resultData.highlights.first.desc
                        : '继续下看完整解释',
                    color: t.info,
                  ),
                ]
              : <({IconData icon, String title, String value, Color color})>[
                  (
                    icon: Icons.lock_outline_rounded,
                    title: '头像轮廓',
                    value: '揭晓后逐步展开',
                    color: t.textSecondary,
                  ),
                  (
                    icon: Icons.style_rounded,
                    title: '标签剪影',
                    value: '先看气质，再看细节',
                    color: t.textSecondary,
                  ),
                  (
                    icon: Icons.chat_bubble_outline_rounded,
                    title: '一句话提示',
                    value: countdownState.data?.hint ?? '到点后会自动解锁',
                    color: t.textSecondary,
                  ),
                ];

          return AppCard(
            padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isOpen
                          ? Icons.lock_open_rounded
                          : Icons.shopping_bag_outlined,
                      color: isOpen ? t.success : t.brandPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOpen ? '盲盒资料已解锁' : '盲盒资料预告',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: t.spacing.xs),
                Text(
                  isOpen
                      ? '你现在可以从更轻的视角看完整匹配轮廓，先看气质，再看解释。'
                      : '揭晓后会逐步展开头像、标签与开场建议，先保留一点悬念。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: t.textSecondary,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: t.spacing.md),
                ...rows.expand(
                  (row) => [
                    Padding(
                      padding: EdgeInsets.only(bottom: t.spacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: row.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Icon(row.icon, size: 16, color: row.color),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  row.title,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: t.textSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  row.value,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: t.textPrimary,
                                        height: 1.45,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: t.spacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: AppSecondaryButton(
                        label: isOpen ? '查看完整结果' : '前往倒计时',
                        fullWidth: true,
                        onPressed: () => isOpen
                            ? context.push(AppRouteNames.matchResult)
                            : context.push(AppRouteNames.matchCountdown),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppPrimaryButton(
                        label: '完整解释',
                        onPressed: () =>
                            context.push(AppRouteNames.matchUnlock),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

    Widget buildCountdownSection() {
      return countdownAsync.when(
        loading: () => const AppLoadingSkeleton(lines: 4),
        error: (e, _) => AppErrorState(
          title: 'Drop 信息加载失败',
          description: e.toString(),
          retryLabel: '重新加载',
          onRetry: () => ref.refresh(matchCountdownProvider),
        ),
        data: (state) {
          final revealLabel = _formatRevealAt(state.data?.revealAt);
          final revealAt = state.data?.revealAt;
          final isOpen =
              revealAt != null && revealAt.isBefore(DateTime.now().toLocal());
          final countdownLabel = isOpen
              ? '本周已揭晓'
              : _formatCountdown(state.data?.revealAt);
          return AppCard(
            padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isOpen ? t.success : t.brandPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOpen ? '本周 Drop 已揭晓' : '本周 Drop 倒计时',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: t.spacing.sm),
                Text(
                  isOpen
                      ? '现在可以查看悬念版结果，再决定要不要进一步了解。'
                      : '结果会在约定时间揭晓，先别急，等一会儿会更有仪式感。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: t.textSecondary,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: t.spacing.md),
                Text(
                  countdownLabel,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: isOpen ? t.success : t.brandPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: t.spacing.xs),
                Text(
                  isOpen ? '立即揭晓本周匹配' : '预计揭晓：$revealLabel',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
                ),
                if ((state.data?.hint ?? '').isNotEmpty) ...[
                  SizedBox(height: t.spacing.sm),
                  Text(
                    state.data!.hint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
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
                            context.push(AppRouteNames.matchUnlock),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

    Widget buildRevealSection() {
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
                  Text(
                    '完整结果还在揭晓中',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
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
                  AppSecondaryButton(
                    label: '回到倒计时',
                    fullWidth: true,
                    onPressed: () => context.push(AppRouteNames.matchCountdown),
                  ),
                ],
              ),
            );
          }

          final questions = _icebreakers(data);
          return Column(
            children: [
              MatchHeroSummaryCard(
                headline: data.headline,
                score: data.score,
                tags: data.tags,
              ),
              SizedBox(height: t.spacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppPrimaryButton(
                      label: '愿意认识',
                      onPressed: () =>
                          context.push(AppRouteNames.matchIntention),
                    ),
                  ),
                  SizedBox(width: t.spacing.sm),
                  Expanded(
                    child: AppSecondaryButton(
                      label: '完整解释',
                      fullWidth: true,
                      onPressed: () => context.push(AppRouteNames.matchUnlock),
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
                    Text(
                      '破冰问题',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: t.spacing.xs),
                    Text(
                      '从轻话题开始，先把对话节奏打开。',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: t.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: t.spacing.md),
                    ...questions.asMap().entries.expand((entry) {
                      final index = entry.key + 1;
                      final question = entry.value;
                      final isLast = index == questions.length;
                      return [
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: isLast ? 0 : t.spacing.sm,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: t.brandPrimary.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$index',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: t.brandPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  question,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: t.textPrimary,
                                        height: 1.5,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Divider(
                            color: t.browseBorder.withValues(alpha: 0.55),
                            height: t.spacing.md,
                          ),
                      ];
                    }),
                  ],
                ),
              ),
            ],
          );
        },
      );
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
              child: buildCountdownSection(),
            ),
            SizedBox(height: t.spacing.md),
            SectionReveal(
              delay: const Duration(milliseconds: 90),
              child: buildBlindBoxSection(),
            ),
            SizedBox(height: t.spacing.md),
            SectionReveal(
              delay: const Duration(milliseconds: 130),
              child: buildRevealSection(),
            ),
          ],
        ),
      ),
    );
  }
}
