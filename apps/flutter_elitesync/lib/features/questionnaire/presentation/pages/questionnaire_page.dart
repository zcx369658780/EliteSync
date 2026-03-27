import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync/app/router/app_route_names.dart';
import 'package:flutter_elitesync/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync/features/questionnaire/presentation/providers/questionnaire_provider.dart';
import 'package:flutter_elitesync/features/questionnaire/presentation/widgets/question_option_button.dart';

class QuestionnairePage extends ConsumerStatefulWidget {
  const QuestionnairePage({super.key});

  @override
  ConsumerState<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends ConsumerState<QuestionnairePage> {
  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final asyncState = ref.watch(questionnaireProvider);

    ref.listen(questionnaireProvider, (previous, next) {
      final wasSubmitted = previous?.asData?.value.submitted ?? false;
      final isSubmitted = next.asData?.value.submitted ?? false;
      if (!wasSubmitted && isSubmitted && mounted) {
        context.go(AppRouteNames.questionnaireResult);
      }
    });

    return AppScaffold(
      appBar: const AppTopBar(title: '性格问卷', mode: AppTopBarMode.backTitle),
      body: asyncState.when(
        loading: () => const AppLoadingSkeleton(lines: 8),
        error: (error, _) => AppErrorState(
          title: '问卷加载失败',
          description: error.toString(),
          onRetry: () => ref.invalidate(questionnaireProvider),
        ),
        data: (state) {
          final q = state.currentQuestion;
          if (q == null) {
            return const Center(child: Text('暂无问卷内容'));
          }

          final selected = state.selectedOptionForCurrent();
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: t.spacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: t.spacing.md),
                  SectionReveal(
                    child: PageTitleRail(
                      title: '性格问卷',
                      subtitle: '版本 ${state.version} · 预计 ${state.estimatedMinutes} 分钟',
                      trailing: Text(
                        '${state.currentIndex + 1}/${state.questions.length}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: t.brandPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: t.spacing.sm),
                  LinearProgressIndicator(
                    value: state.progress,
                    backgroundColor: t.overlay,
                    color: t.brandPrimary,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(t.radius.pill),
                  ),
                  SizedBox(height: t.spacing.xs),
                  Text(
                    '进度 ${state.answeredCount}/${state.questions.length}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                  ),
                  SizedBox(height: t.spacing.lg),
                  SectionReveal(
                    delay: const Duration(milliseconds: 60),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '第 ${state.currentIndex + 1} 题',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(color: t.textTertiary),
                          ),
                          SizedBox(height: t.spacing.xs),
                          Text(
                            q.title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: t.spacing.lg),
                          ...List.generate(q.options.length, (index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: t.spacing.sm),
                              child: QuestionOptionButton(
                                label: q.options[index],
                                selected: selected == index,
                                onTap: () => ref
                                    .read(questionnaireProvider.notifier)
                                    .selectOption(index),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  if ((state.errorMessage ?? '').isNotEmpty) ...[
                    SizedBox(height: t.spacing.sm),
                    Text(
                      state.errorMessage!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: t.error),
                    ),
                  ],
                  if ((state.feedbackMessage ?? '').isNotEmpty) ...[
                    SizedBox(height: t.spacing.sm),
                    Text(
                      state.feedbackMessage!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: t.success),
                    ),
                  ],
                  SizedBox(height: t.spacing.md),
                  SectionReveal(
                    delay: const Duration(milliseconds: 110),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppSecondaryButton(
                            label: '上一题',
                            onPressed: state.isFirst
                                ? null
                                : () => ref
                                      .read(questionnaireProvider.notifier)
                                      .previous(),
                          ),
                        ),
                        SizedBox(width: t.spacing.sm),
                        Expanded(
                          child: AppSecondaryButton(
                            label: '下一题',
                            onPressed: state.isLast
                                ? null
                                : () => ref
                                      .read(questionnaireProvider.notifier)
                                      .next(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: t.spacing.sm),
                  SectionReveal(
                    delay: const Duration(milliseconds: 150),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppSecondaryButton(
                            label: state.isSavingDraft ? '保存中...' : '保存草稿',
                            onPressed: state.isSavingDraft
                                ? null
                                : () => ref
                                      .read(questionnaireProvider.notifier)
                                      .saveDraft(),
                          ),
                        ),
                        SizedBox(width: t.spacing.sm),
                        Expanded(
                          child: AppPrimaryButton(
                            label: state.submitted ? '已提交' : '提交问卷',
                            isLoading: state.isSubmitting,
                            onPressed: (state.submitted || state.isSubmitting)
                                ? null
                                : () => ref
                                      .read(questionnaireProvider.notifier)
                                      .submit(),
                          ),
                        ),
                      ],
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
