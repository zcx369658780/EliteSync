import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_hero_summary_card.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_reason_card.dart';

class MatchResultPage extends ConsumerWidget {
  const MatchResultPage({super.key});

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
            return AppErrorState(
              title: '暂无匹配',
              description: '请先完成问卷并等待揭晓',
              onRetry: () => ref.refresh(matchResultProvider),
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
                          label: '立即表态',
                          onPressed: () => context.push(AppRouteNames.matchIntention),
                        ),
                      ),
                      SizedBox(width: t.spacing.sm),
                      Expanded(
                        child: AppSecondaryButton(
                          label: '查看详情',
                          fullWidth: true,
                          onPressed: () => context.push(AppRouteNames.matchDetail),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: t.spacing.md),
                  Text(
                    '核心理由',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: t.spacing.xs),
                  ...data.highlights.take(2).map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: MatchReasonCard(reason: '${e.title} ${e.value}: ${e.desc}'),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ActionChip(
                      avatar: const Icon(Icons.read_more_rounded, size: 14),
                      label: const Text('展开完整解释'),
                      onPressed: () => context.push(AppRouteNames.matchDetail),
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
