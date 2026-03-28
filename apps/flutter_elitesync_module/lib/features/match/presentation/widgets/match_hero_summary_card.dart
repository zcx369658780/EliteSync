import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_tag.dart';
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

  String _scoreNarrative() {
    if (score >= 90) return '高匹配，建议尽快进入深入交流';
    if (score >= 80) return '中高匹配，关系潜力较强';
    if (score >= 70) return '中等匹配，建议从轻话题慢慢建立连接';
    if (score >= 60) return '可尝试匹配，建议重点关注沟通节奏';
    return '当前匹配度较保守，建议先观察再决定';
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
            '本周匹配已更新',
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
          Text(
            _scoreNarrative(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: t.textSecondary,
                  fontWeight: FontWeight.w500,
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
                return AppTag(label: tag, variant: AppTagVariant.outlined);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
