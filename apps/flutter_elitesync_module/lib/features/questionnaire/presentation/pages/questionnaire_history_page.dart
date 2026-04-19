import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/providers/questionnaire_provider.dart';

class QuestionnaireHistoryPage extends ConsumerStatefulWidget {
  const QuestionnaireHistoryPage({super.key});

  @override
  ConsumerState<QuestionnaireHistoryPage> createState() =>
      _QuestionnaireHistoryPageState();
}

class _QuestionnaireHistoryPageState
    extends ConsumerState<QuestionnaireHistoryPage> {
  bool _historyOpenedTracked = false;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final asyncState = ref.watch(questionnaireHistoryProvider);

    if (asyncState.hasValue && !_historyOpenedTracked) {
      _historyOpenedTracked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(frontendTelemetryProvider)
            .questionnaireHistoryOpened(sourcePage: 'questionnaire_history');
      });
    }

    return AppScaffold(
      appBar: const AppTopBar(title: '问卷历史', mode: AppTopBarMode.backTitle),
      body: asyncState.when(
        loading: () => const AppLoadingSkeleton(lines: 8),
        error: (error, _) => AppErrorState(
          title: '历史记录加载失败',
          description: error.toString(),
          onRetry: () => ref.invalidate(questionnaireHistoryProvider),
        ),
        data: (items) {
          return ListView(
            padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
            children: [
              const SectionReveal(
                child: PageTitleRail(
                  title: '问卷历史',
                  subtitle: '保留每次提交的版本、摘要和完成时间',
                ),
              ),
              SizedBox(height: t.spacing.md),
              AppInfoCard(
                title: '历史说明',
                description: items.isEmpty
                    ? '还没有提交记录，完成一次问卷后会出现在这里。'
                    : '共 ${items.length} 条提交记录，可用于回看画像与复测。',
              ),
              SizedBox(height: t.spacing.md),
              ...items.map((item) {
                final highlights = item.resultHighlights.isEmpty
                    ? '暂无高亮'
                    : item.resultHighlights.join(' · ');
                return Padding(
                  padding: EdgeInsets.only(bottom: t.spacing.md),
                  child: AppInfoCard(
                    title: item.resultLabel.isEmpty ? '问卷结果' : item.resultLabel,
                    description:
                        '${item.questionnaireVersion} / ${item.bankVersion} / ${item.attemptVersion}'
                        ' · ${item.answersCount}/${item.totalCount}'
                        '${item.completedAt == null ? '' : ' · ${item.completedAt!.toLocal().toString().split('.').first}'}'
                        '\n$highlights',
                  ),
                );
              }),
              SizedBox(height: t.spacing.lg),
              AppPrimaryButton(
                label: '重新作答',
                onPressed: () async {
                  ref
                      .read(frontendTelemetryProvider)
                      .questionnaireRetestStarted(
                        sourcePage: 'questionnaire_history',
                      );
                  await ref.read(questionnaireProvider.notifier).restart();
                  if (!context.mounted) return;
                  context.go(AppRouteNames.questionnaire);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
