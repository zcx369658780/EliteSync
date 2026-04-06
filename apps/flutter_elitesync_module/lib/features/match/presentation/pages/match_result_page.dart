import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_hero_summary_card.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_reason_card.dart';

class MatchResultPage extends ConsumerWidget {
  const MatchResultPage({super.key});

  String _sectionLabel(int index) {
    switch (index) {
      case 0:
        return '你们为什么值得认识';
      case 1:
        return '相处中可能舒服的地方';
      case 2:
        return '需要留意的地方';
      default:
        return '建议怎样开始聊天';
    }
  }

  String _sectionDesc(int index) {
    switch (index) {
      case 0:
        return '先看匹配核心动因';
      case 1:
        return '这是关系中的潜在顺滑区';
      case 2:
        return '提前理解差异会更轻松';
      default:
        return '建议用轻话题自然开场';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(matchResultProvider);

    return Scaffold(
      body: asyncState.when(
        loading: () => const AppLoadingSkeleton(lines: 8),
        error: (e, _) => AppErrorState(
          title: '匹配结果加载失败',
          description: e.toString(),
          onRetry: () => ref.refresh(matchResultProvider),
        ),
        data: (state) {
          final data = state.data;
          if (data == null) {
            final tip = (state.error ?? '').isNotEmpty ? state.error! : '请先完成问卷并等待揭晓';
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
                          onPressed: () => context.push(AppRouteNames.questionnaire),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppPrimaryButton(
                          label: '完善资料',
                          onPressed: () => context.push(AppRouteNames.editProfile),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          final t = context.appTokens;
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
                padding: EdgeInsets.only(top: t.spacing.xs, bottom: t.spacing.huge),
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
                          onPressed: () => context.push(AppRouteNames.matchIntention),
                        ),
                      ),
                      SizedBox(width: t.spacing.sm),
                      Expanded(
                        child: AppSecondaryButton(
                          label: '查看完整解释',
                          fullWidth: true,
                          onPressed: () => context.push(AppRouteNames.matchDetail),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: t.spacing.md),
                  ...List.generate(
                    data.highlights.take(4).length,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: t.spacing.sm),
                      child: MatchReasonCard(
                        reason:
                            '${_sectionLabel(index)}\n${_sectionDesc(index)}\n${data.highlights[index].title} ${data.highlights[index].value}：${data.highlights[index].desc}',
                      ),
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
                  SizedBox(height: t.spacing.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppChoiceChip(
                      label: '展开完整解释',
                      leading: const Icon(Icons.read_more_rounded),
                      onTap: () => context.push(AppRouteNames.matchDetail),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
