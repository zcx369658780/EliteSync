import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_elitesync_module/core/media/media_url_resolver.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_tag.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/content_detail_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class ContentDetailPage extends ConsumerWidget {
  const ContentDetailPage({super.key, required this.contentId, this.content});

  final String contentId;
  final HomeFeedEntity? content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ContentDetailQuery(contentId: contentId, seed: content);
    final asyncData = ref.watch(contentDetailProvider(query));
    final apiBaseUrl = ref.watch(appEnvProvider).apiBaseUrl;

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
    return _ContentDetailBody(data: data, apiBaseUrl: apiBaseUrl);
  }
}

class _ContentDetailBody extends StatelessWidget {
  const _ContentDetailBody({required this.data, required this.apiBaseUrl});

  final HomeFeedEntity data;
  final String apiBaseUrl;

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
                children: data.tags.map((tag) => AppTag(label: tag)).toList(),
              ),
            ),
          ],
          if (data.media.isNotEmpty) ...[
            SizedBox(height: t.spacing.md),
            SectionReveal(
              delay: const Duration(milliseconds: 130),
              child: _MediaGallery(media: data.media, apiBaseUrl: apiBaseUrl),
            ),
          ],
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 140),
            child: _MetaBlock(
              author: data.author,
              likes: data.likes,
              body: data.body ?? data.summary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({
    required this.author,
    required this.likes,
    required this.body,
  });

  final String author;
  final int likes;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final words = body.trim().isEmpty
        ? 0
        : body.trim().split(RegExp(r'\s+')).length;
    final readMinutes = (words / 180).ceil().clamp(1, 10);
    return Container(
      padding: EdgeInsets.all(t.spacing.cardPadding),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: t.browseBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.menu_book_rounded, size: 16, color: t.textSecondary),
          SizedBox(width: t.spacing.xs),
          Expanded(
            child: Text(
              '作者：$author · 预计阅读 $readMinutes 分钟 · 热度 $likes',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaGallery extends StatelessWidget {
  const _MediaGallery({required this.media, required this.apiBaseUrl});

  final List<String> media;
  final String apiBaseUrl;

  bool _isLikelyImage(String input) {
    final v = input.toLowerCase();
    return v.endsWith('.png') ||
        v.endsWith('.jpg') ||
        v.endsWith('.jpeg') ||
        v.endsWith('.webp') ||
        v.endsWith('.gif');
  }

  Future<void> _openExternal(BuildContext context, String raw) async {
    final uri = Uri.tryParse(raw);
    if (uri == null) {
      AppFeedback.showError(context, '链接格式无效');
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      AppFeedback.showError(context, '无法打开该链接');
    }
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
                          resolveMediaUrl(item, apiBaseUrl: apiBaseUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: t.browseChip,
                              alignment: Alignment.center,
                              child: Text(
                                '图片加载失败',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: t.textSecondary),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : InkWell(
                      borderRadius: BorderRadius.circular(t.radius.md),
                      onTap: () => _openExternal(context, item),
                      child: Padding(
                        padding: EdgeInsets.all(t.spacing.xs),
                        child: Row(
                          children: [
                            Icon(
                              Icons.open_in_new_rounded,
                              color: t.textSecondary,
                              size: 18,
                            ),
                            SizedBox(width: t.spacing.xs),
                            Expanded(
                              child: Text(
                                item,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: t.textSecondary,
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}
