import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/questionnaire_profile_snapshot.dart';

class QuestionnaireProfileSummaryCard extends StatelessWidget {
  const QuestionnaireProfileSummaryCard({
    super.key,
    required this.snapshot,
    this.title = '问卷倾向已同步',
    this.subtitle = '这份摘要只用于产品内轻量联动，不会改变你的匹配分数或资料真值。',
    this.onViewHistory,
    this.onContinueQuestionnaire,
  });

  final QuestionnaireProfileSnapshot snapshot;
  final String title;
  final String subtitle;
  final VoidCallback? onViewHistory;
  final VoidCallback? onContinueQuestionnaire;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final highlights = snapshot.highlights.take(2).toList();
    final statusText = snapshot.complete ? '已完成问卷' : '当前为进行中摘要';
    return AppCard(
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.quiz_outlined, size: 18, color: t.brandPrimary),
              SizedBox(width: t.spacing.xs),
              Expanded(
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppChoiceChip(
                label: statusText,
                leading: const Icon(Icons.auto_graph_rounded),
                selected: snapshot.complete,
              ),
              AppChoiceChip(
                label: snapshot.versionLineage,
                leading: const Icon(Icons.fingerprint_rounded),
                selected: true,
              ),
            ],
          ),
          if (snapshot.label.trim().isNotEmpty) ...[
            SizedBox(height: t.spacing.sm),
            Text(
              snapshot.label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: t.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (highlights.isNotEmpty) ...[
            SizedBox(height: t.spacing.xs),
            Text(
              '要点：${highlights.join(' / ')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.45,
              ),
            ),
          ],
          if (onViewHistory != null || onContinueQuestionnaire != null) ...[
            SizedBox(height: t.spacing.sm),
            Row(
              children: [
                if (onViewHistory != null)
                  Expanded(
                    child: AppSecondaryButton(
                      label: '查看历史记录',
                      fullWidth: true,
                      onPressed: onViewHistory,
                    ),
                  ),
                if (onViewHistory != null && onContinueQuestionnaire != null)
                  SizedBox(width: t.spacing.xs),
                if (onContinueQuestionnaire != null)
                  Expanded(
                    child: AppPrimaryButton(
                      label: snapshot.complete ? '重新作答' : '继续完善问卷',
                      fullWidth: true,
                      onPressed: onContinueQuestionnaire,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
