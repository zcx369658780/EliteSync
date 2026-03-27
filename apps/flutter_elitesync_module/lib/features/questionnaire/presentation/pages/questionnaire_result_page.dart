import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/providers/questionnaire_provider.dart';

class QuestionnaireResultPage extends ConsumerWidget {
  const QuestionnaireResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.appTokens;
    final asyncState = ref.watch(questionnaireProvider);
    final state = asyncState.asData?.value;

    return AppScaffold(
      appBar: const AppTopBar(title: '问卷结果', mode: AppTopBarMode.backTitle),
      body: state == null
          ? const Center(child: Text('暂无问卷结果'))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  top: t.spacing.lg,
                  bottom: t.spacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionReveal(
                      child: PageTitleRail(
                        title: '问卷提交成功',
                        subtitle: '结果将用于匹配解释与个性画像',
                        trailing: Icon(Icons.verified_rounded, color: Color(0xFF28C98B), size: 28),
                      ),
                    ),
                    SizedBox(height: t.spacing.xs),
                    SectionReveal(
                      delay: const Duration(milliseconds: 70),
                      child: Text(
                        '你已完成 ${state.answeredCount}/${state.questions.length} 题，后续将用于匹配与画像。',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
                      ),
                    ),
                    SizedBox(height: t.spacing.lg),
                    SectionReveal(
                      delay: const Duration(milliseconds: 120),
                      child: AppInfoCard(
                        title: '问卷版本',
                        description:
                            '${state.version} · 预计 ${state.estimatedMinutes} 分钟 · 已提交',
                      ),
                    ),
                    SizedBox(height: t.spacing.md),
                    const SectionReveal(
                      delay: Duration(milliseconds: 170),
                      child: AppInfoCard(
                        title: '下一步',
                        description: '你可以返回首页继续体验匹配、消息与个人资料模块。',
                      ),
                    ),
                    SizedBox(height: t.spacing.xl),
                    SectionReveal(
                      delay: const Duration(milliseconds: 220),
                      child: AppPrimaryButton(
                        label: '返回首页',
                        onPressed: () => context.go(AppRouteNames.home),
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    SectionReveal(
                      delay: const Duration(milliseconds: 260),
                      child: AppSecondaryButton(
                        label: '重新作答',
                        fullWidth: true,
                        onPressed: () async {
                          await ref
                              .read(questionnaireProvider.notifier)
                              .restart();
                          if (!context.mounted) return;
                          context.go(AppRouteNames.questionnaire);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
