import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync/features/home/domain/entities/home_feed_entity.dart';

class MediaFeedCard extends StatelessWidget {
  const MediaFeedCard({
    super.key,
    required this.item,
    required this.index,
    this.onTap,
  });

  final HomeFeedEntity item;
  final int index;
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
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w700,
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
}
