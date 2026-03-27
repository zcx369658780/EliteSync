import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync/app/router/app_route_names.dart';
import 'package:flutter_elitesync/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync/features/match/presentation/widgets/match_summary_card.dart';

class MatchCountdownPage extends ConsumerWidget {
  const MatchCountdownPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(matchCountdownProvider);

    return Scaffold(
      body: asyncState.when(
        loading: () => const AppLoadingSkeleton(lines: 6),
        error: (e, _) => AppErrorState(title: '加载失败', description: e.toString()),
        data: (state) {
          if (state.data == null) {
            return const AppErrorState(title: '暂无倒计时信息', description: '请稍后重试');
          }
          final data = state.data!;
          final t = context.appTokens;
          return ListView(
            padding: EdgeInsets.fromLTRB(
              t.spacing.pageHorizontal,
              t.spacing.xl,
              t.spacing.pageHorizontal,
              t.spacing.huge,
            ),
            children: [
              SectionReveal(
                child: PageTitleRail(
                  title: '下一次匹配揭晓',
                  subtitle: '${data.revealAt ?? '--'}',
                  trailing: Icon(Icons.schedule_rounded, color: t.brandPrimary),
                ),
              ),
              SizedBox(height: t.spacing.md),
              SectionReveal(
                delay: const Duration(milliseconds: 70),
                child: MatchSummaryCard(text: '下次揭晓：${data.revealAt ?? '--'}'),
              ),
              const SizedBox(height: 12),
              SectionReveal(
                delay: const Duration(milliseconds: 120),
                child: MatchSummaryCard(text: data.hint),
              ),
              const SizedBox(height: 12),
              SectionReveal(
                delay: const Duration(milliseconds: 170),
                child: FilledButton(
                  onPressed: () => context.push(AppRouteNames.matchResult),
                  child: const Text('查看模拟结果'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
