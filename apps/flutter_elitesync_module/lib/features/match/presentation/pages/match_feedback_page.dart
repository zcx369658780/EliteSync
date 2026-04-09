import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/fields/app_text_field.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_feedback_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_result_entity.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_feedback_provider.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';

class MatchFeedbackPage extends ConsumerStatefulWidget {
  const MatchFeedbackPage({super.key});

  @override
  ConsumerState<MatchFeedbackPage> createState() => _MatchFeedbackPageState();
}

class _MatchFeedbackPageState extends ConsumerState<MatchFeedbackPage> {
  final TextEditingController _noteController = TextEditingController();
  String _overall = '值得继续';
  String _accuracy = '基本符合';
  String _icebreaker = '有帮助';
  String _nextWeek = '愿意';
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(time.month)}/${two(time.day)} ${two(time.hour)}:${two(time.minute)}';
  }

  Widget _choiceSection(
    BuildContext context, {
    required String title,
    required String hint,
    required List<String> options,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    final t = context.appTokens;
    return AppCard(
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            hint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              return AppChoiceChip(
                label: option,
                selected: value == option,
                onTap: () => onChanged(option),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(MatchResultEntity? result) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final hasResult = result != null && result.headline.trim().isNotEmpty;
      final entry = MatchFeedbackEntity(
        createdAt: DateTime.now().toLocal(),
        matchHeadline: hasResult ? result.headline : '匹配反馈',
        matchScore: result?.score ?? 0,
        matchTags: result?.tags ?? const [],
        overallFeedback: _overall,
        explanationFeedback: _accuracy,
        icebreakerFeedback: _icebreaker,
        nextWeekIntention: _nextWeek,
        note: _noteController.text.trim(),
      );
      await saveMatchFeedbackEntry(ref, entry);
      final partnerId = result?.partnerId;
      if (partnerId != null && partnerId > 0) {
        ref
            .read(frontendTelemetryProvider)
            .matchFeedbackSubmitted(
              targetUserId: partnerId,
              matchId: result?.matchId,
              sourcePage: 'match_feedback',
            );
      }
      if (!mounted) return;
      AppFeedback.showSuccess(context, '反馈已保存到本机');
      setState(() {
        _noteController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      AppFeedback.showError(context, '保存失败：$e');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Widget _historyCard(BuildContext context, List<MatchFeedbackEntity> items) {
    final t = context.appTokens;
    return AppCard(
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, size: 18, color: t.brandPrimary),
              const SizedBox(width: 8),
              Text(
                '最近本机反馈',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            '本机历史只用于回看感受，不会影响服务端匹配。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          if (items.isEmpty)
            Text(
              '暂无提交记录。',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
            )
          else
            ...items
                .take(3)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: t.browseSurface,
                        borderRadius: BorderRadius.circular(t.radius.md),
                        border: Border.all(color: t.browseBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_formatTime(item.createdAt)} · ${item.matchHeadline}',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '整体：${item.overallFeedback} · 解释：${item.explanationFeedback} · 破冰：${item.icebreakerFeedback} · 下周：${item.nextWeekIntention}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: t.textSecondary,
                                  height: 1.45,
                                ),
                          ),
                          if (item.note.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              '备注：${item.note}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: t.textSecondary,
                                    height: 1.45,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resultAsync = ref.watch(matchResultProvider);
    final historyAsync = ref.watch(matchFeedbackHistoryProvider);
    final t = context.appTokens;

    return BrowseScaffold(
      header: SizedBox(
        height: 44,
        child: Row(
          children: [
            Text(
              '匹配后反馈',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: t.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                ref.invalidate(matchResultProvider);
                ref.invalidate(matchFeedbackHistoryProvider);
              },
              icon: Icon(Icons.refresh_rounded, color: t.textSecondary),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(matchResultProvider);
          ref.invalidate(matchFeedbackHistoryProvider);
          await Future.wait([
            ref.read(matchResultProvider.future),
            ref.read(matchFeedbackHistoryProvider.future),
          ]);
        },
        child: ListView(
          padding: EdgeInsets.only(top: t.spacing.xs, bottom: t.spacing.huge),
          children: [
            const SectionReveal(
              child: PageTitleRail(
                title: '匹配后反馈',
                subtitle: '先给系统一个最小反馈，帮助下一次揭晓和破冰更贴近你的感受',
              ),
            ),
            SizedBox(height: t.spacing.md),
            resultAsync.when(
              loading: () => const AppLoadingSkeleton(lines: 4),
              error: (e, _) => AppErrorState(
                title: '当前匹配信息加载失败',
                description: e.toString(),
                retryLabel: '重试',
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
                          '暂无当前匹配结果',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '你依然可以先填写反馈，记录这次慢约会流程的感受。',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: t.textSecondary, height: 1.45),
                        ),
                      ],
                    ),
                  );
                }
                return AppCard(
                  padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '当前匹配',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: t.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.headline,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '综合分 ${data.score} · ${data.tags.take(3).join(' · ')}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: t.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: t.spacing.md),
            _choiceSection(
              context,
              title: '这次匹配是否值得继续了解',
              hint: '先记录你对整体关系的直觉判断。',
              options: const ['值得继续', '先观察', '不太值得'],
              value: _overall,
              onChanged: (value) => setState(() => _overall = value),
            ),
            SizedBox(height: t.spacing.md),
            _choiceSection(
              context,
              title: '匹配解释是否准确',
              hint: '看看系统给出的说明有没有帮助你理解这次结果。',
              options: const ['很准确', '基本符合', '不太符合'],
              value: _accuracy,
              onChanged: (value) => setState(() => _accuracy = value),
            ),
            SizedBox(height: t.spacing.md),
            _choiceSection(
              context,
              title: '破冰问题是否有帮助',
              hint: '确认系统给你的开场建议是否真的能降低聊天门槛。',
              options: const ['很有帮助', '一般', '帮助不大'],
              value: _icebreaker,
              onChanged: (value) => setState(() => _icebreaker = value),
            ),
            SizedBox(height: t.spacing.md),
            _choiceSection(
              context,
              title: '愿不愿意参加下周匹配',
              hint: '这项反馈用于判断慢约会节奏是否还值得继续。',
              options: const ['愿意', '观望', '暂不'],
              value: _nextWeek,
              onChanged: (value) => setState(() => _nextWeek = value),
            ),
            SizedBox(height: t.spacing.md),
            AppCard(
              padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '补充说明',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _noteController,
                    label: '可选备注',
                    hint: '例如：希望揭晓更慢一点、破冰问题更轻松一点……',
                    maxLength: 280,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 8),
                  AppPrimaryButton(
                    label: _submitting ? '保存中...' : '保存到本机',
                    onPressed: _submitting
                        ? null
                        : () async {
                            final current = resultAsync.maybeWhen(
                              data: (state) => state.data,
                              orElse: () => null,
                            );
                            await _submit(current);
                          },
                  ),
                ],
              ),
            ),
            SizedBox(height: t.spacing.md),
            historyAsync.when(
              loading: () => const AppLoadingSkeleton(lines: 3),
              error: (e, _) => AppErrorState(
                title: '本机反馈历史加载失败',
                description: e.toString(),
                retryLabel: '重试',
                onRetry: () => ref.refresh(matchFeedbackHistoryProvider),
              ),
              data: (items) => _historyCard(context, items),
            ),
          ],
        ),
      ),
    );
  }
}
