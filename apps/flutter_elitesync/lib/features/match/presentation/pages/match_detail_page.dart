import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync/features/match/presentation/widgets/match_reason_card.dart';
import 'package:flutter_elitesync/features/match/presentation/widgets/match_weight_breakdown.dart';

class MatchDetailPage extends ConsumerWidget {
  const MatchDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(matchDetailProvider);
    final t = context.appTokens;

    return AppScaffold(
      appBar: const AppTopBar(title: '匹配详情', mode: AppTopBarMode.backTitle),
      body: async.when(
        loading: () => const AppLoadingSkeleton(lines: 7),
        error: (e, _) => AppErrorState(title: '详情加载失败', description: e.toString()),
        data: (data) => ListView(
          padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
          children: [
            const SectionReveal(
              child: PageTitleRail(
                title: '匹配解释',
                subtitle: '分项原因、权重与风险提示',
              ),
            ),
            SizedBox(height: t.spacing.md),
            ...List.generate(data.reasons.length, (index) {
              return SectionReveal(
                delay: Duration(milliseconds: 40 * (index + 1)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: MatchReasonCard(reason: data.reasons[index]),
                ),
              );
            }),
            SectionReveal(
              delay: const Duration(milliseconds: 220),
              child: MatchWeightBreakdown(weights: data.weights),
            ),
          ],
        ),
      ),
    );
  }
}
