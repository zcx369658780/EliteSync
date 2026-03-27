import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class MatchHeroSummaryCard extends StatelessWidget {
  const MatchHeroSummaryCard({
    super.key,
    required this.headline,
    required this.score,
    required this.tags,
  });

  final String headline;
  final int score;
  final List<String> tags;

  Color _scoreColor(BuildContext context) {
    final t = context.appTokens;
    if (score >= 85) return t.success;
    if (score >= 70) return t.brandPrimary;
    if (score >= 55) return t.warning;
    return t.error;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final scoreColor = _scoreColor(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(t.radius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            t.brandPrimary.withValues(alpha: 0.2),
            t.brandSecondary.withValues(alpha: 0.16),
            t.brandAccent.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(color: t.browseBorder),
      ),
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '匹配结论',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: t.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            headline,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          Row(
            children: [
              Text(
                '$score',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: t.spacing.xs),
              Text(
                '综合匹配分',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: t.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            SizedBox(height: t.spacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.take(4).map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: t.spacing.sm,
                    vertical: t.spacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: t.browseSurface.withValues(alpha: 0.76),
                    borderRadius: BorderRadius.circular(t.radius.pill),
                    border: Border.all(color: t.browseBorder),
                  ),
                  child: Text(
                    tag,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: t.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
