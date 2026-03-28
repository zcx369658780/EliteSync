import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class MatchModuleInsightCard extends StatelessWidget {
  const MatchModuleInsightCard({
    super.key,
    required this.module,
    required this.score,
    required this.reason,
    this.risk,
    this.tags = const [],
  });

  final String module;
  final int score;
  final String reason;
  final String? risk;
  final List<String> tags;

  Color _scoreColor(BuildContext context) {
    final t = context.appTokens;
    if (score >= 85) return t.success;
    if (score >= 70) return t.brandPrimary;
    if (score >= 60) return t.warning;
    return t.error;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final scoreColor = _scoreColor(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(t.spacing.cardPadding),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.md),
        border: Border.all(color: t.browseBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_graph_rounded,
                size: 15,
                color: scoreColor.withValues(alpha: 0.9),
              ),
              SizedBox(width: t.spacing.xxs),
              Text(
                module,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: t.spacing.xs,
                  vertical: t.spacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(t.radius.pill),
                  border: Border.all(color: scoreColor.withValues(alpha: 0.35)),
                ),
                child: Text(
                  '$score分',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scoreColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            reason,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.45,
                ),
          ),
          if ((risk ?? '').trim().isNotEmpty) ...[
            SizedBox(height: t.spacing.xs),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: t.spacing.xs,
                vertical: t.spacing.xxs,
              ),
              decoration: BoxDecoration(
                color: t.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(t.radius.sm),
                border: Border.all(color: t.warning.withValues(alpha: 0.28)),
              ),
              child: Text(
                '风险提示：${risk!.trim()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.warning,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
          if (tags.isNotEmpty) ...[
            SizedBox(height: t.spacing.xs),
            Text(
              '证据标签',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: t.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: t.spacing.xxs),
            Wrap(
              spacing: t.spacing.xs,
              runSpacing: t.spacing.xs,
              children: tags
                  .map(
                    (tag) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: t.spacing.xs,
                        vertical: t.spacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: t.browseChip,
                        borderRadius: BorderRadius.circular(t.radius.pill),
                        border: Border.all(color: t.browseBorder),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: t.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
