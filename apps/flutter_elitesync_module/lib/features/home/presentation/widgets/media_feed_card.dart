import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/highlight_text.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';

class MediaFeedCard extends StatelessWidget {
  const MediaFeedCard({
    super.key,
    required this.item,
    required this.index,
    this.highlightQuery = '',
    this.onTap,
  });

  final HomeFeedEntity item;
  final int index;
  final String highlightQuery;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final base = 120.0 + (index % 3) * 20;
    final imageHeight = base + math.min(item.summary.length * 0.2, 22);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(t.radius.lg),
        onTap: onTap,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: t.browseSurface,
            borderRadius: BorderRadius.circular(t.radius.lg),
            border: Border.all(color: t.browseBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: imageHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      t.brandPrimary.withValues(alpha: 0.24),
                      t.brandSecondary.withValues(alpha: 0.2),
                      t.brandAccent.withValues(alpha: 0.18),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: t.spacing.xs,
                          vertical: t.spacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: t.browseSurface.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(t.radius.pill),
                        ),
                        child: Text(
                          '推荐',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: t.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(t.spacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HighlightText(
                      text: item.title,
                      query: highlightQuery,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      highlightStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: t.brandPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    SizedBox(height: t.spacing.xxs),
                    Text(
                      item.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.textSecondary,
                      ),
                    ),
                    SizedBox(height: t.spacing.xs),
                    Wrap(
                      spacing: t.spacing.xxs,
                      runSpacing: t.spacing.xxs,
                      children: _buildTags(item).map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: t.spacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: t.brandPrimary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(t.radius.pill),
                          ),
                          child: Text(
                            tag,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: t.brandPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: t.spacing.xs),
                    Text(
                      '${item.author} · ${item.likes} 喜欢',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: t.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _buildTags(HomeFeedEntity entity) {
    final tags = <String>{};
    for (final tag in entity.tags) {
      if (tags.length >= 2) break;
      final t = tag.trim();
      if (t.isNotEmpty) tags.add(t);
    }
    final text = '${entity.title} ${entity.summary}'.toLowerCase();
    if (tags.isEmpty) {
      if (text.contains('沟通')) tags.add('沟通技巧');
      if (text.contains('星') || text.contains('盘')) tags.add('星盘');
      if (text.contains('mbti')) tags.add('MBTI');
      if (text.contains('匹配')) tags.add('匹配提升');
      if (text.contains('关系')) tags.add('关系研究');
    }
    if (tags.isEmpty) tags.add('关系研究');
    if (tags.length < 2 && !tags.contains('匹配提升')) tags.add('匹配提升');
    return tags.take(2).toList();
  }
}
