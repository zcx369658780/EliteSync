import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/media/media_url_resolver.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_attachment_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/video_message_preview_page.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class MessageBubble extends ConsumerWidget {
  const MessageBubble({super.key, required this.message});
  final MessageEntity message;

  bool _isLocalFileUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    return trimmed.startsWith('file://') ||
        File(trimmed).existsSync() ||
        (trimmed.startsWith('/') && File(trimmed).existsSync());
  }

  Widget _buildImageWidget(String url, {BoxFit fit = BoxFit.cover}) {
    if (_isLocalFileUrl(url)) {
      final path = url.startsWith('file://')
          ? Uri.parse(url).toFilePath()
          : url;
      return Image.file(
        File(path),
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Text('图片加载失败')),
      );
    }
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          const Center(child: Text('图片加载失败')),
    );
  }

  void _openPreview(
    BuildContext context,
    MessageAttachmentEntity attachment,
    String apiBaseUrl,
  ) {
    if (!attachment.isImage || attachment.publicUrl.isEmpty) return;
    final resolvedUrl = resolveMediaUrl(
      attachment.publicUrl,
      apiBaseUrl: apiBaseUrl,
    );
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio:
                    (attachment.width != null &&
                        attachment.height != null &&
                        attachment.width! > 0 &&
                        attachment.height! > 0)
                    ? attachment.width! / attachment.height!
                    : 1,
                child: InteractiveViewer(
                  child: _buildImageWidget(resolvedUrl, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('关闭'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openVideoPreview(
    BuildContext context,
    MessageAttachmentEntity attachment,
    String apiBaseUrl,
  ) {
    if (!attachment.isVideo || attachment.publicUrl.isEmpty) return;
    final resolvedUrl = resolveMediaUrl(
      attachment.publicUrl,
      apiBaseUrl: apiBaseUrl,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            VideoMessagePreviewPage(title: '视频消息', videoUrl: resolvedUrl),
      ),
    );
  }

  String _formatDuration(int? durationMs) {
    if (durationMs == null || durationMs <= 0) return '视频';
    final totalSeconds = (durationMs / 1000).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return minutes > 0
        ? '$minutes:${seconds.toString().padLeft(2, '0')}'
        : '0:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildVideoWidget(
    BuildContext context,
    MessageAttachmentEntity attachment,
    String apiBaseUrl,
  ) {
    final ratio =
        (attachment.width != null &&
            attachment.height != null &&
            attachment.width! > 0 &&
            attachment.height! > 0)
        ? attachment.width! / attachment.height!
        : 16 / 9;
    final durationLabel = _formatDuration(attachment.durationMs);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _openVideoPreview(context, attachment, apiBaseUrl),
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: ratio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: Colors.black.withValues(alpha: 0.14)),
                    Center(
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        size: 56,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.48),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Text(
                            '视频消息',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.48),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Text(
                            durationLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (attachment.status != 'ready')
                      Positioned.fill(
                        child: ColoredBox(
                          color: Colors.black.withValues(alpha: 0.22),
                        ),
                      ),
                    if (attachment.status != 'ready')
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            attachment.status == 'failed' ? '视频加载失败' : '处理中',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiBaseUrl = ref.watch(appEnvProvider).apiBaseUrl;
    final align = message.mine ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.mine
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final hasImages = message.hasImageAttachment;
    final hasVideos = message.hasVideoAttachment;
    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.text.trim().isNotEmpty) Text(message.text),
            if (hasImages) ...[
              if (message.text.trim().isNotEmpty) const SizedBox(height: 8),
              ...message.attachments
                  .where((attachment) => attachment.isImage)
                  .map(
                    (attachment) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () =>
                            _openPreview(context, attachment, apiBaseUrl),
                        borderRadius: BorderRadius.circular(12),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 280),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AspectRatio(
                                aspectRatio:
                                    (attachment.width != null &&
                                        attachment.height != null &&
                                        attachment.width! > 0 &&
                                        attachment.height! > 0)
                                    ? attachment.width! / attachment.height!
                                    : 1,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    _buildImageWidget(
                                      resolveMediaUrl(
                                        attachment.publicUrl,
                                        apiBaseUrl: apiBaseUrl,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      left: 8,
                                      bottom: 8,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.48,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          child: Text(
                                            '图片消息',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            ],
            if (hasVideos) ...[
              if (message.text.trim().isNotEmpty || hasImages)
                const SizedBox(height: 8),
              ...message.attachments
                  .where((attachment) => attachment.isVideo)
                  .map(
                    (attachment) =>
                        _buildVideoWidget(context, attachment, apiBaseUrl),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
