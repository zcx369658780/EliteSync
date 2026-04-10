import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/fields/app_text_field.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_confirm_dialog.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_empty_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_post_entity.dart';
import 'package:flutter_elitesync_module/features/status/presentation/providers/status_posts_provider.dart';

class StatusSquarePage extends ConsumerStatefulWidget {
  const StatusSquarePage({super.key});

  @override
  ConsumerState<StatusSquarePage> createState() => _StatusSquarePageState();
}

class _StatusSquarePageState extends ConsumerState<StatusSquarePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _visibility = 'public';
  bool _submitting = false;
  bool _prefilledLocation = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      AppFeedback.showInfo(context, '请先填写标题和内容');
      return;
    }
    setState(() => _submitting = true);
    try {
      final item = await ref
          .read(statusRemoteDataSourceProvider)
          .createStatusPost(
            title: title,
            body: body,
            locationName: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
            visibility: _visibility,
          );
      _titleController.clear();
      _bodyController.clear();
      ref.invalidate(statusPostsProvider);
      if (!mounted) return;
      AppFeedback.showSuccess(
        context,
        '状态已发布：${item.locationName.isEmpty ? '同城' : item.locationName}',
      );
    } catch (e) {
      if (!mounted) return;
      AppFeedback.showError(context, '发布失败：$e');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _deletePost(StatusPostEntity post) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: '删除状态',
      message: '确认删除这条状态吗？删除后首页广场将不再展示。',
      confirmLabel: '删除',
      cancelLabel: '取消',
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(statusRemoteDataSourceProvider).deleteStatusPost(post.id);
      ref.invalidate(statusPostsProvider);
      if (!mounted) return;
      AppFeedback.showSuccess(context, '状态已删除');
    } catch (e) {
      if (!mounted) return;
      AppFeedback.showError(context, '删除失败：$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final postsAsync = ref.watch(statusPostsProvider);
    final profileAsync = ref.watch(profileProvider);

    profileAsync.whenData((state) {
      final city = state.summary?.city.trim() ?? '';
      if (!_prefilledLocation &&
          city.isNotEmpty &&
          _locationController.text.trim().isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _prefilledLocation) return;
          if (_locationController.text.trim().isEmpty) {
            _locationController.text = city;
          }
          _prefilledLocation = true;
        });
      }
    });

    return AppScaffold(
      appBar: AppTopBar(
        title: '状态广场',
        mode: AppTopBarMode.backTitle,
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(statusPostsProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(statusPostsProvider);
          await ref.read(statusPostsProvider.future);
        },
        child: ListView(
          padding: EdgeInsets.fromLTRB(0, t.spacing.sm, 0, t.spacing.huge),
          children: [
            AppInfoSectionCard(
              title: '状态分层',
              subtitle: '公开层 / 广场层 / 私密层，展示与治理分开',
              leadingIcon: Icons.layers_outlined,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _TierChip(label: '公开层', description: '全员可见'),
                  _TierChip(label: '广场层', description: '首页 / 广场可见'),
                  _TierChip(label: '私密层', description: '仅自己可见'),
                ],
              ),
            ),
            SizedBox(height: t.spacing.md),
            AppInfoSectionCard(
              title: '发布状态',
              subtitle: '轻量发布，直接进入服务端广场流',
              leadingIcon: Icons.publish_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _titleController,
                    label: '标题',
                    hint: '例如：今晚想找个人散步',
                    maxLength: 40,
                  ),
                  SizedBox(height: t.spacing.sm),
                  AppTextField(
                    controller: _bodyController,
                    label: '内容',
                    hint: '写下一个轻松、自然的状态',
                    maxLength: 240,
                    minLines: 3,
                    maxLines: 5,
                  ),
                  SizedBox(height: t.spacing.sm),
                  AppTextField(
                    controller: _locationController,
                    label: '地点',
                    hint: '默认跟随你的城市，可手动修改',
                    maxLength: 60,
                  ),
                  SizedBox(height: t.spacing.sm),
                  Wrap(
                    spacing: t.spacing.xs,
                    runSpacing: t.spacing.xs,
                    children: [
                      AppChoiceChip(
                        label: '公开',
                        selected: _visibility == 'public',
                        onTap: () => setState(() => _visibility = 'public'),
                      ),
                      AppChoiceChip(
                        label: '广场可见',
                        selected: _visibility == 'square',
                        onTap: () => setState(() => _visibility = 'square'),
                      ),
                      AppChoiceChip(
                        label: '仅自己',
                        selected: _visibility == 'private',
                        onTap: () => setState(() => _visibility = 'private'),
                      ),
                    ],
                  ),
                  SizedBox(height: t.spacing.sm),
                  FilledButton.icon(
                    onPressed: _submitting ? null : _publish,
                    icon: _submitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(_submitting ? '发布中...' : '发布状态'),
                  ),
                ],
              ),
            ),
            SizedBox(height: t.spacing.md),
            AppInfoSectionCard(
              title: '广场最新状态',
              subtitle: '来自服务端的可见状态流',
              leadingIcon: Icons.dynamic_feed_rounded,
              child: postsAsync.when(
                loading: () => const AppLoadingSkeleton(lines: 5),
                error: (e, _) => AppErrorState(
                  title: '状态广场加载失败',
                  description: e.toString(),
                  retryLabel: '重新加载',
                  onRetry: () => ref.invalidate(statusPostsProvider),
                ),
                data: (posts) {
                  if (posts.isEmpty) {
                    return AppEmptyState(
                      title: '还没有公开状态',
                      description: '先发布一条状态，看看会不会出现在广场里。',
                      actionLabel: '去发布',
                      onAction: () {
                        _publish();
                      },
                    );
                  }

                  return Column(
                    children: [
                      for (final post in posts)
                        Padding(
                          padding: EdgeInsets.only(bottom: t.spacing.sm),
                          child: _StatusPostCard(
                            post: post,
                            onDelete: post.canDelete
                                ? () => _deletePost(post)
                                : null,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPostCard extends StatelessWidget {
  const _StatusPostCard({required this.post, this.onDelete});

  final StatusPostEntity post;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final time = MaterialLocalizations.of(
      context,
    ).formatShortDate(post.createdAt);
    return AppInfoSectionCard(
      title: post.title,
      subtitle:
          '${post.authorName} · ${post.locationName.isEmpty ? '同城' : post.locationName} · $time',
      leadingIcon: Icons.waving_hand_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                post.visibilityLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: t.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                post.authorLayerLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: t.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
            ],
          ),
          Text(
            post.body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textPrimary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _TierChip extends StatelessWidget {
  const _TierChip({required this.label, required this.description});

  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: t.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: t.overlay.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: t.textSecondary),
          ),
        ],
      ),
    );
  }
}
