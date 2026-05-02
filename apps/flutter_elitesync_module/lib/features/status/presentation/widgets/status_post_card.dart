import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/media/media_url_resolver.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_tag.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_post_entity.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class StatusPostCard extends ConsumerWidget {
  const StatusPostCard({
    super.key,
    required this.post,
    this.onTapAuthor,
    this.onLikeToggle,
    this.onReport,
    this.onDelete,
    this.onContinueUnderstand,
    this.onViewProfile,
    this.onSaveForLater,
    this.onLowPressureChat,
    this.compact = false,
  });

  final StatusPostEntity post;
  final VoidCallback? onTapAuthor;
  final VoidCallback? onLikeToggle;
  final VoidCallback? onReport;
  final VoidCallback? onDelete;
  final VoidCallback? onContinueUnderstand;
  final VoidCallback? onViewProfile;
  final VoidCallback? onSaveForLater;
  final VoidCallback? onLowPressureChat;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.appTokens;
    final time = MaterialLocalizations.of(
      context,
    ).formatShortDate(post.createdAt);
    final showActions =
        onLikeToggle != null || onReport != null || onDelete != null;
    final showReturnflowActions =
        onContinueUnderstand != null ||
        onViewProfile != null ||
        onSaveForLater != null ||
        onLowPressureChat != null;
    final apiBaseUrl = ref.watch(appEnvProvider).apiBaseUrl;
    final coverMediaUrl = post.hasMedia
        ? resolveMediaUrl(post.coverMediaUrl!, apiBaseUrl: apiBaseUrl)
        : null;

    return Material(
      color: Colors.transparent,
      child: AppInfoSectionCard(
        title: post.title,
        subtitle:
            '${post.displayAuthorName} · ${post.locationName.isEmpty ? '同城' : post.locationName} · $time',
        leadingIcon: Icons.waving_hand_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppTag(
                  label: post.visibilityLabel,
                  variant: AppTagVariant.neutral,
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onTapAuthor,
                  borderRadius: BorderRadius.circular(t.radius.md),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Text(
                      post.displayAuthorName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  post.authorLayerLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: t.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${post.likesCount} 喜欢',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: t.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (coverMediaUrl != null) ...[
              SizedBox(height: t.spacing.sm),
              _StatusPostImage(url: coverMediaUrl),
            ],
            SizedBox(height: t.spacing.sm),
            Text(
              post.body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: t.textPrimary,
                height: 1.45,
              ),
            ),
            if (!compact) ...[
              SizedBox(height: t.spacing.sm),
              Text(
                '仅展示轻量动态信息，不参与真值链路。',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: t.textSecondary),
              ),
            ],
            if (showReturnflowActions) ...[
              SizedBox(height: t.spacing.sm),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(t.spacing.sm),
                decoration: BoxDecoration(
                  color: t.secondarySurface.withValues(alpha: 0.54),
                  borderRadius: BorderRadius.circular(t.radius.md),
                  border: Border.all(color: t.overlay.withValues(alpha: 0.42)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '低压关系动作',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '先了解、再决定是否聊天；这些动作不会自动发送消息。',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: t.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: t.spacing.xs),
                    Wrap(
                      spacing: t.spacing.xs,
                      runSpacing: t.spacing.xs,
                      children: [
                        if (onContinueUnderstand != null)
                          OutlinedButton.icon(
                            onPressed: onContinueUnderstand,
                            icon: const Icon(Icons.explore_outlined),
                            label: const Text('继续了解'),
                          ),
                        if (onViewProfile != null)
                          OutlinedButton.icon(
                            onPressed: onViewProfile,
                            icon: const Icon(Icons.person_search_outlined),
                            label: const Text('看看资料'),
                          ),
                        if (onSaveForLater != null)
                          OutlinedButton.icon(
                            onPressed: onSaveForLater,
                            icon: const Icon(Icons.bookmark_border_rounded),
                            label: const Text('稍后再聊'),
                          ),
                        if (onLowPressureChat != null)
                          OutlinedButton.icon(
                            onPressed: onLowPressureChat,
                            icon: const Icon(Icons.chat_bubble_outline_rounded),
                            label: const Text('低压私聊'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (showActions) ...[
              SizedBox(height: t.spacing.sm),
              Wrap(
                spacing: t.spacing.xs,
                runSpacing: t.spacing.xs,
                children: [
                  if (onLikeToggle != null)
                    OutlinedButton.icon(
                      onPressed: onLikeToggle,
                      icon: Icon(
                        post.likedByViewer
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                      ),
                      label: Text(post.likedByViewer ? '取消喜欢' : '喜欢'),
                    ),
                  if (onReport != null)
                    OutlinedButton.icon(
                      onPressed: onReport,
                      icon: const Icon(Icons.flag_outlined),
                      label: const Text('举报'),
                    ),
                  if (onDelete != null)
                    OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('删除'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusPostImage extends StatelessWidget {
  const _StatusPostImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return ClipRRect(
      borderRadius: BorderRadius.circular(t.radius.lg),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: ColoredBox(
          color: t.surface,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image_outlined),
                  const SizedBox(height: 8),
                  Text(
                    '图片加载失败',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
