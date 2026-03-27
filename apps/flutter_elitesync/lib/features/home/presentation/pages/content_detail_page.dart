import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync/features/home/presentation/providers/content_detail_provider.dart';

class ContentDetailPage extends ConsumerWidget {
  const ContentDetailPage({
    super.key,
    required this.contentId,
    this.content,
  });

  final String contentId;
  final HomeFeedEntity? content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ContentDetailQuery(contentId: contentId, seed: content);
    final asyncData = ref.watch(contentDetailProvider(query));

    final loadingSeed =
        content ??
        HomeFeedEntity(
          id: contentId,
          title: '内容详情',
          summary: '内容加载中，请稍候。',
          author: '系统',
          likes: 0,
          body: '内容加载中，请稍候。',
          tags: const ['加载中'],
        );

    final data = asyncData.asData?.value ?? loadingSeed;
    return _ContentDetailBody(data: data);
  }
}

class _ContentDetailBody extends StatelessWidget {
  const _ContentDetailBody({required this.data});

  final HomeFeedEntity data;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;

    return AppScaffold(
      appBar: const AppTopBar(title: '内容详情', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
        children: [
          SectionReveal(
            child: PageTitleRail(
              title: data.title,
              subtitle: '${data.author} · ${data.likes} 热度',
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 80),
            child: Container(
              padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
              decoration: BoxDecoration(
                color: t.browseSurface,
                borderRadius: BorderRadius.circular(t.radius.lg),
                border: Border.all(color: t.browseBorder),
              ),
              child: Text(
                (data.body ?? '').isNotEmpty ? data.body! : data.summary,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: t.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (data.tags.isNotEmpty) ...[
            SizedBox(height: t.spacing.md),
            SectionReveal(
              delay: const Duration(milliseconds: 110),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: data.tags
                    .map(
                      (tag) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: t.spacing.sm,
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
            ),
          ],
          if (data.media.isNotEmpty) ...[
            SizedBox(height: t.spacing.md),
            SectionReveal(
              delay: const Duration(milliseconds: 130),
              child: _MediaGallery(media: data.media),
            ),
          ],
          SizedBox(height: t.spacing.md),
          const SectionReveal(
            delay: Duration(milliseconds: 140),
            child: _PlaceholderBlock(),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderBlock extends StatelessWidget {
  const _PlaceholderBlock();

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: EdgeInsets.all(t.spacing.cardPadding),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: t.browseBorder),
      ),
      child: Text(
        '后续这里将接入：正文段落、图片/视频、评论与互动入口。',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: t.textSecondary,
        ),
      ),
    );
  }
}

class _MediaGallery extends StatelessWidget {
  const _MediaGallery({required this.media});

  final List<String> media;

  bool _isLikelyImage(String input) {
    final v = input.toLowerCase();
    return v.endsWith('.png') ||
        v.endsWith('.jpg') ||
        v.endsWith('.jpeg') ||
        v.endsWith('.webp') ||
        v.endsWith('.gif');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '媒体资源',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: t.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: t.spacing.xs),
        for (final item in media)
          Padding(
            padding: EdgeInsets.only(bottom: t.spacing.sm),
            child: Container(
              padding: EdgeInsets.all(t.spacing.xs),
              decoration: BoxDecoration(
                color: t.browseSurface,
                borderRadius: BorderRadius.circular(t.radius.lg),
                border: Border.all(color: t.browseBorder),
              ),
              child: _isLikelyImage(item)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(t.radius.md),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          item,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: t.browseChip,
                              alignment: Alignment.center,
                              child: Text(
                                '图片加载失败',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: t.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Icon(Icons.link_rounded, color: t.textSecondary, size: 18),
                        SizedBox(width: t.spacing.xs),
                        Expanded(
                          child: Text(
                            item,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: t.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
      ],
    );
  }
}
