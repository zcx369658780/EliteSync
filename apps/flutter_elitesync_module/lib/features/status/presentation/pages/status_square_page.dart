import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
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
import 'package:flutter_elitesync_module/features/status/presentation/widgets/status_post_card.dart';
import 'package:flutter_elitesync_module/features/status/presentation/widgets/status_report_sheet.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

enum _CoverUploadStage { idle, uploading, processing, ready, failed }

class StatusSquarePage extends ConsumerStatefulWidget {
  const StatusSquarePage({super.key});

  @override
  ConsumerState<StatusSquarePage> createState() => _StatusSquarePageState();
}

class _StatusSquarePageState extends ConsumerState<StatusSquarePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  String _visibility = 'public';
  bool _submitting = false;
  bool _prefilledLocation = false;
  String? _coverImagePath;
  String? _coverImageName;
  int? _coverMediaAssetId;
  String? _coverUploadError;
  _CoverUploadStage _coverStage = _CoverUploadStage.idle;

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
    if (_coverStage == _CoverUploadStage.uploading) {
      AppFeedback.showInfo(context, '封面图片正在上传，请稍后再发布');
      return;
    }
    if (_coverImagePath != null && _coverStage == _CoverUploadStage.failed) {
      AppFeedback.showInfo(context, '封面图片上传失败，请重试或清除后再发布');
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
            coverMediaAssetId: _coverStage == _CoverUploadStage.ready
                ? _coverMediaAssetId
                : null,
          );
      ref
          .read(frontendTelemetryProvider)
          .statusPostPublished(sourcePage: 'status_square', postId: item.id);
      _titleController.clear();
      _bodyController.clear();
      _clearCoverImage();
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

  Future<void> _toggleLike(StatusPostEntity post) async {
    try {
      final remote = ref.read(statusRemoteDataSourceProvider);
      if (post.likedByViewer) {
        await remote.unlikeStatusPost(post.id);
      } else {
        await remote.likeStatusPost(post.id);
      }
      ref
          .read(frontendTelemetryProvider)
          .statusPostLiked(
            sourcePage: 'status_square',
            postId: post.id,
            liked: !post.likedByViewer,
          );
      ref.invalidate(statusPostsProvider);
    } catch (e) {
      if (!mounted) return;
      AppFeedback.showError(context, '操作失败：$e');
    }
  }

  Future<void> _reportPost(StatusPostEntity post) async {
    final remote = ref.read(statusRemoteDataSourceProvider);
    await StatusReportSheet.show(
      context,
      targetName: post.displayAuthorName,
      onSubmit: ({required String reasonCode, String? detail}) async {
        await remote.reportStatusPost(
          postId: post.id,
          reasonCode: reasonCode,
          detail: detail,
        );
        ref
            .read(frontendTelemetryProvider)
            .statusPostReported(sourcePage: 'status_square', postId: post.id);
      },
    );
  }

  Future<void> _openAuthor(StatusPostEntity post) async {
    ref
        .read(frontendTelemetryProvider)
        .statusAuthorOpened(sourcePage: 'status_square', userId: post.authorId);
    if (!mounted) return;
    await context.push(
      '${AppRouteNames.statusAuthor}/${post.authorId}?name=${Uri.encodeComponent(post.displayAuthorName)}',
    );
  }

  void _savePostForLater(StatusPostEntity post) {
    AppFeedback.showSuccess(context, '已作为稍后再聊提示保留在本页，不写入服务端队列');
  }

  Future<void> _openLowPressureChatPath(StatusPostEntity post) async {
    AppFeedback.showInfo(context, '先看看公开资料；只有匹配关系成立后才会进入真实聊天');
    await _openAuthor(post);
  }

  Future<void> _pickAndUploadCoverImage() async {
    if (_submitting || _coverStage == _CoverUploadStage.uploading) return;
    ref
        .read(frontendTelemetryProvider)
        .statusImagePickerOpened(sourcePage: 'status_square');
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
    );
    if (picked == null) return;

    setState(() {
      _coverImagePath = picked.path;
      _coverImageName = picked.name.isNotEmpty ? picked.name : 'status.jpg';
      _coverStage = _CoverUploadStage.uploading;
      _coverUploadError = null;
    });
    ref
        .read(frontendTelemetryProvider)
        .statusImageUploadStarted(sourcePage: 'status_square');

    try {
      final api = ref.read(apiClientProvider);
      final form = FormData.fromMap({
        'media_type': 'image',
        'original_name': _coverImageName,
        'file': await MultipartFile.fromFile(
          picked.path,
          filename: _coverImageName,
        ),
        'metadata': {'source_page': 'status_square'},
      });
      final result = await api.post('/api/v1/media', body: form);
      if (result is! NetworkSuccess<Map<String, dynamic>>) {
        throw Exception(
          (result as NetworkFailure<Map<String, dynamic>>).message,
        );
      }
      final asset = result.data['asset'];
      if (asset is! Map<String, dynamic>) {
        throw Exception('media upload did not return an asset');
      }
      final assetId = (asset['id'] as num?)?.toInt() ?? 0;
      final status = (asset['status'] ?? '').toString();
      if (!mounted) return;
      setState(() {
        _coverMediaAssetId = assetId > 0 ? assetId : null;
        _coverStage = status == 'processing'
            ? _CoverUploadStage.processing
            : _CoverUploadStage.ready;
        _coverUploadError = null;
      });
      ref
          .read(frontendTelemetryProvider)
          .statusImageUploadSucceeded(
            sourcePage: 'status_square',
            assetId: assetId,
          );
      AppFeedback.showSuccess(context, '封面图片已准备好，可以发布状态');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _coverMediaAssetId = null;
        _coverStage = _CoverUploadStage.failed;
        _coverUploadError = e.toString();
      });
      ref
          .read(frontendTelemetryProvider)
          .statusImageUploadFailed(
            sourcePage: 'status_square',
            errorCode: 'upload_failed',
          );
      AppFeedback.showError(context, '封面上传失败，请重试');
    }
  }

  void _clearCoverImage() {
    setState(() {
      _coverImagePath = null;
      _coverImageName = null;
      _coverMediaAssetId = null;
      _coverUploadError = null;
      _coverStage = _CoverUploadStage.idle;
    });
  }

  Widget _buildCoverPreview(BuildContext context) {
    final t = context.appTokens;
    final label = switch (_coverStage) {
      _CoverUploadStage.uploading => '上传中',
      _CoverUploadStage.processing => '处理中',
      _CoverUploadStage.failed => '失败',
      _CoverUploadStage.ready => '已完成',
      _CoverUploadStage.idle => '待选择',
    };
    final detail =
        _coverUploadError ??
        switch (_coverStage) {
          _CoverUploadStage.uploading => '封面正在上传到对象存储主路径。',
          _CoverUploadStage.processing => '封面已入库，等待后台处理。',
          _CoverUploadStage.failed => '封面上传失败，可重试或重新选择。',
          _CoverUploadStage.ready => '封面已可用于状态发布。',
          _CoverUploadStage.idle => '单图状态优先，建议先补一张轻量封面。',
        };

    return AppInfoSectionCard(
      title: '封面图片',
      subtitle: '单图状态，先上传再发布',
      leadingIcon: Icons.photo_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_coverImagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(t.radius.lg),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.file(
                  File(_coverImagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: t.surface,
                    alignment: Alignment.center,
                    child: const Text('图片预览失败'),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(t.spacing.lg),
              decoration: BoxDecoration(
                color: t.surface.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(t.radius.lg),
                border: Border.all(color: t.overlay.withValues(alpha: 0.22)),
              ),
              child: Column(
                children: [
                  Icon(Icons.image_outlined, color: t.textSecondary),
                  SizedBox(height: t.spacing.xs),
                  Text(
                    '暂未选择封面图片',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
                  ),
                ],
              ),
            ),
          SizedBox(height: t.spacing.sm),
          Row(
            children: [
              AppChoiceChip(label: label, selected: true),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  detail,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: [
              FilledButton.icon(
                onPressed:
                    _submitting || _coverStage == _CoverUploadStage.uploading
                    ? null
                    : _pickAndUploadCoverImage,
                icon: _coverStage == _CoverUploadStage.uploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.photo_library_outlined),
                label: Text(
                  _coverStage == _CoverUploadStage.uploading
                      ? '上传中...'
                      : '选择封面',
                ),
              ),
              OutlinedButton(
                onPressed: _coverImagePath == null ? null : _clearCoverImage,
                child: const Text('清除封面'),
              ),
            ],
          ),
        ],
      ),
    );
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
                  _buildCoverPreview(context),
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
                      onAction: _publish,
                    );
                  }

                  return Column(
                    children: [
                      for (final post in posts)
                        Padding(
                          padding: EdgeInsets.only(bottom: t.spacing.sm),
                          child: StatusPostCard(
                            post: post,
                            onTapAuthor: () => _openAuthor(post),
                            onContinueUnderstand: () => _openAuthor(post),
                            onViewProfile: () => _openAuthor(post),
                            onSaveForLater: () => _savePostForLater(post),
                            onLowPressureChat: () =>
                                _openLowPressureChatPath(post),
                            onLikeToggle: () => _toggleLike(post),
                            onReport: post.canDelete
                                ? null
                                : () => _reportPost(post),
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
