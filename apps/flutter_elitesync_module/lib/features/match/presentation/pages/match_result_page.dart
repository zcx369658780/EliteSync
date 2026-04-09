import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_highlight_entity.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_hero_summary_card.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_reason_card.dart';

class MatchResultPage extends ConsumerWidget {
  const MatchResultPage({super.key});

  void _trackMatchExplanationEntry(
    WidgetRef ref,
    int targetUserId,
    int? matchId,
  ) {
    ref
        .read(frontendTelemetryProvider)
        .matchExplanationEntry(
          targetUserId: targetUserId,
          sourcePage: 'match_result',
          matchId: matchId,
        );
  }

  void _trackFirstChatEntry(WidgetRef ref, int targetUserId, int? matchId) {
    ref
        .read(frontendTelemetryProvider)
        .firstChatEntry(
          targetUserId: targetUserId,
          sourcePage: 'match_result',
          matchId: matchId,
        );
  }

  String _sectionLabel(int index) {
    switch (index) {
      case 0:
        return '结论层｜为什么推荐你们认识';
      case 1:
        return '证据层｜关系中的顺滑区';
      default:
        return '行动层｜建议怎样开始聊天';
    }
  }

  String _sectionDesc(int index) {
    switch (index) {
      case 0:
        return '先看核心匹配结论';
      case 1:
        return '再看支持结论的关键证据';
      default:
        return '给你一个可直接使用的开场动作';
    }
  }

  String _buildReasonCardContent({
    required String sectionLabel,
    required String sectionDesc,
    required MatchHighlightEntity highlight,
  }) {
    final title = highlight.title.trim().isEmpty
        ? '关键信号'
        : highlight.title.trim();
    final value = highlight.value;
    final desc = highlight.desc.trim().isEmpty
        ? '当前解释信息已返回，建议结合完整解释继续判断。'
        : highlight.desc.trim();
    return '$sectionLabel\n$sectionDesc\n$title $value：$desc';
  }

  String _evidenceFallback() {
    return '当前证据层信息暂不完整，建议先查看完整解释，再决定是否进入首聊。';
  }

  String _actionSuggestion(List<MatchHighlightEntity> highlights) {
    final first = highlights.isNotEmpty ? highlights.first : null;
    if (first != null) {
      final title = first.title.trim();
      if (title.isNotEmpty) {
        return '可以先从「$title」聊起：分享一个你最近的真实感受，再问对方一个开放问题。';
      }
    }
    return '可以先从最近一周的生活节奏聊起：你最近最想投入的一件事是什么？';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(matchResultProvider);

    return Scaffold(
      body: asyncState.when(
        loading: () => const AppLoadingSkeleton(lines: 8),
        error: (e, _) => AppErrorState(
          title: '匹配结果加载失败',
          description: '网络或服务暂不可用，请稍后重试。',
          onRetry: () => ref.refresh(matchResultProvider),
        ),
        data: (state) {
          final data = state.data;
          if (data == null) {
            final tip = '请先完成问卷并等待揭晓，若已完成可稍后下拉刷新。';
            return BrowseScaffold(
              header: const SizedBox.shrink(),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
                children: [
                  AppErrorState(
                    title: '暂无匹配',
                    description: tip,
                    retryLabel: '重新加载',
                    onRetry: () => ref.refresh(matchResultProvider),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: AppSecondaryButton(
                          label: '去做问卷',
                          fullWidth: true,
                          onPressed: () =>
                              context.push(AppRouteNames.questionnaire),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppPrimaryButton(
                          label: '完善资料',
                          onPressed: () =>
                              context.push(AppRouteNames.editProfile),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          final t = context.appTokens;
          final targetUserId = data.partnerId;
          final matchId = data.matchId;
          return BrowseScaffold(
            header: SizedBox(
              height: 44,
              child: Row(
                children: [
                  Text(
                    '匹配',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => ref.refresh(matchResultProvider),
                    icon: Icon(Icons.refresh_rounded, color: t.textSecondary),
                  ),
                ],
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(matchResultProvider);
                await ref.read(matchResultProvider.future);
              },
              child: ListView(
                padding: EdgeInsets.only(
                  top: t.spacing.xs,
                  bottom: t.spacing.huge,
                ),
                children: [
                  MatchHeroSummaryCard(
                    headline: data.headline,
                    score: data.score,
                    tags: data.tags,
                  ),
                  SizedBox(height: t.spacing.md),
                  AppCard(
                    padding: EdgeInsets.all(t.spacing.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '解释阅读顺序',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        SizedBox(height: t.spacing.xs),
                        Text(
                          '结论 -> 证据 -> 行动建议。先理解“为什么推荐”，再决定是否进入聊天。',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.textSecondary, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: t.spacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: AppPrimaryButton(
                          label: '进入首聊',
                          onPressed: () {
                            if (targetUserId != null && targetUserId > 0) {
                              _trackFirstChatEntry(ref, targetUserId, matchId);
                            }
                            if (!context.mounted) return;
                            context.push(AppRouteNames.matchIntention);
                          },
                        ),
                      ),
                      SizedBox(width: t.spacing.sm),
                      Expanded(
                        child: AppSecondaryButton(
                          label: '查看完整解释',
                          fullWidth: true,
                          onPressed: () {
                            if (targetUserId != null && targetUserId > 0) {
                              _trackMatchExplanationEntry(
                                ref,
                                targetUserId,
                                matchId,
                              );
                            }
                            if (!context.mounted) return;
                            context.push(AppRouteNames.matchDetail);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: t.spacing.md),
                  if (data.highlights.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: t.spacing.sm),
                      child: MatchReasonCard(
                        reason:
                            '结论层｜为什么推荐你们认识\n先看核心匹配结论\n当前结论信息已返回，但关键亮点暂未完整展开，建议先查看完整解释。',
                      ),
                    ),
                  ...List.generate(
                    data.highlights.take(2).length,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: t.spacing.sm),
                      child: MatchReasonCard(
                        reason: _buildReasonCardContent(
                          sectionLabel: _sectionLabel(index),
                          sectionDesc: _sectionDesc(index),
                          highlight: data.highlights[index],
                        ),
                      ),
                    ),
                  ),
                  if (data.highlights.length < 2)
                    Padding(
                      padding: EdgeInsets.only(bottom: t.spacing.sm),
                      child: MatchReasonCard(
                        reason:
                            '证据层｜关系中的顺滑区\n再看支持结论的关键证据\n${_evidenceFallback()}',
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(bottom: t.spacing.md),
                    child: MatchReasonCard(
                      reason:
                          '行动层｜建议怎样开始聊天\n给你一个可直接使用的开场动作\n${_actionSuggestion(data.highlights)}',
                    ),
                  ),
                  AppCard(
                    padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '匹配后反馈',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '反馈会用于后续匹配解释优化。若遇到不一致或不理解，请优先提交反馈。',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: t.textSecondary, height: 1.45),
                        ),
                        const SizedBox(height: 10),
                        AppSecondaryButton(
                          label: '提交反馈（帮助优化解释）',
                          fullWidth: true,
                          onPressed: () =>
                              context.push(AppRouteNames.matchFeedback),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: t.spacing.md),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
