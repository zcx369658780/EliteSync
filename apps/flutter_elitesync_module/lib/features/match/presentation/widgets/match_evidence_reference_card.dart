import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class MatchEvidenceReferenceCard extends StatelessWidget {
  const MatchEvidenceReferenceCard({
    super.key,
    required this.sections,
  });

  final List<MatchEvidenceReferenceSection> sections;

  Color _priorityColor(BuildContext context, String level) {
    final t = context.appTokens;
    switch (level) {
      case 'high':
        return t.error;
      case 'medium':
        return t.warning;
      default:
        return t.info;
    }
  }

  String _priorityLabel(String level) {
    switch (level) {
      case 'high':
        return '优先关注';
      case 'medium':
        return '建议关注';
      default:
        return '常规关注';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) return const SizedBox.shrink();
    final t = context.appTokens;
    return Container(
      margin: EdgeInsets.only(bottom: t.spacing.sm),
      padding: EdgeInsets.all(t.spacing.cardPadding),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: t.browseBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '理论依据',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: t.spacing.xs),
          ...sections.map((section) {
            final color = _priorityColor(context, section.priorityLevel);
            return Container(
              margin: EdgeInsets.only(bottom: t.spacing.xs),
              padding: EdgeInsets.all(t.spacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(t.radius.md),
                border: Border.all(color: color.withValues(alpha: 0.30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: t.spacing.xs,
                          vertical: t.spacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(t.radius.pill),
                          border: Border.all(color: color.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          '${_priorityLabel(section.priorityLevel)} TOP${section.rank}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      SizedBox(width: t.spacing.xs),
                      Expanded(
                        child: Text(
                          section.moduleLabel,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: t.spacing.xs),
                  ...section.references.map(
                    (r) => Padding(
                      padding: EdgeInsets.only(bottom: t.spacing.xxs),
                      child: Text(
                        '• $r',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: t.textSecondary,
                              height: 1.45,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class MatchEvidenceReferenceSection {
  const MatchEvidenceReferenceSection({
    required this.moduleLabel,
    required this.priorityLevel,
    required this.rank,
    required this.references,
  });

  final String moduleLabel;
  final String priorityLevel;
  final int rank;
  final List<String> references;
}

