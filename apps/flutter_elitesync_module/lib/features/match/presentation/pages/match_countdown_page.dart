import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_summary_card.dart';

class MatchCountdownPage extends ConsumerWidget {
  const MatchCountdownPage({super.key});

  String _formatCountdown(DateTime? revealAt) {
    if (revealAt == null) return '--';
    final diff = revealAt.difference(DateTime.now().toLocal());
    if (diff.isNegative) return '即将揭晓';
    final days = diff.inDays;
    final hours = diff.inHours.remainder(24);
    final minutes = diff.inMinutes.remainder(60);
    if (days > 0) {
      return '$days天 ${hours.toString().padLeft(2, '0')}小时 ${minutes.toString().padLeft(2, '0')}分';
    }
    return '${hours.toString().padLeft(2, '0')}小时 ${minutes.toString().padLeft(2, '0')}分';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(matchCountdownProvider);

    return asyncState.when(
      loading: () => const AppLoadingSkeleton(lines: 6),
      error: (e, _) => AppErrorState(
        title: '加载失败',
        description: e.toString(),
        onRetry: () => ref.refresh(matchCountdownProvider),
      ),
      data: (state) {
        if (state.data == null) {
          return AppErrorState(
            title: '暂无倒计时信息',
            description: '请稍后重试',
            onRetry: () => ref.refresh(matchCountdownProvider),
          );
        }
        final data = state.data!;
        final t = context.appTokens;
        return BrowseScaffold(
          header: SizedBox(
            height: 44,
            child: Row(
              children: [
                Text(
                  '倒计时',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => ref.refresh(matchCountdownProvider),
                  icon: Icon(Icons.refresh_rounded, color: t.textSecondary),
                ),
              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(matchCountdownProvider);
              await ref.read(matchCountdownProvider.future);
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(0, t.spacing.xs, 0, t.spacing.huge),
              children: [
                SectionReveal(
                  child: PageTitleRail(
                    title: '下一次匹配揭晓',
                    subtitle: data.status == 'drop_open'
                        ? '本周结果已揭晓'
                        : '预计 ${_formatCountdown(data.revealAt)} 后揭晓',
                    trailing: Icon(
                      Icons.schedule_rounded,
                      color: t.brandPrimary,
                    ),
                  ),
                ),
                SizedBox(height: t.spacing.md),
                SectionReveal(
                  delay: const Duration(milliseconds: 70),
                  child: MatchSummaryCard(
                    text: data.status == 'drop_open'
                        ? '本周结果已揭晓'
                        : '预计揭晓时间：${data.revealAt ?? '--'}',
                  ),
                ),
                const SizedBox(height: 12),
                SectionReveal(
                  delay: const Duration(milliseconds: 120),
                  child: MatchSummaryCard(text: data.hint),
                ),
                const SizedBox(height: 12),
                SectionReveal(
                  delay: const Duration(milliseconds: 170),
                  child: AppPrimaryButton(
                    label: '查看匹配结果',
                    onPressed: () => context.push(AppRouteNames.matchResult),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
