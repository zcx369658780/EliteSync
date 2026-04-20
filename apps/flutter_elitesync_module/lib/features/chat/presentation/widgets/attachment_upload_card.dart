import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_tag.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

enum AttachmentUploadStage { pending, uploading, processing, failed, ready }

extension AttachmentUploadStageX on AttachmentUploadStage {
  String get label => switch (this) {
    AttachmentUploadStage.pending => '待上传',
    AttachmentUploadStage.uploading => '上传中',
    AttachmentUploadStage.processing => '处理中',
    AttachmentUploadStage.failed => '失败',
    AttachmentUploadStage.ready => '已完成',
  };

  String get description => switch (this) {
    AttachmentUploadStage.pending => '附件已预留，等待用户选择并发起上传。',
    AttachmentUploadStage.uploading => '文件正在进入对象存储主路径，状态会继续推进。',
    AttachmentUploadStage.processing => '文件已入库，后台正在做最小处理与落库回写。',
    AttachmentUploadStage.failed => '上传或处理遇到问题，可查看原因并重试。',
    AttachmentUploadStage.ready => '附件已准备好，可以进入消息附件链路。',
  };

  AppTagVariant get variant => switch (this) {
    AttachmentUploadStage.pending => AppTagVariant.neutral,
    AttachmentUploadStage.uploading => AppTagVariant.brand,
    AttachmentUploadStage.processing => AppTagVariant.warning,
    AttachmentUploadStage.failed => AppTagVariant.danger,
    AttachmentUploadStage.ready => AppTagVariant.success,
  };

  IconData get icon => switch (this) {
    AttachmentUploadStage.pending => Icons.inbox_outlined,
    AttachmentUploadStage.uploading => Icons.cloud_upload_outlined,
    AttachmentUploadStage.processing => Icons.settings_outlined,
    AttachmentUploadStage.failed => Icons.error_outline,
    AttachmentUploadStage.ready => Icons.check_circle_outline,
  };
}

class AttachmentUploadCard extends StatefulWidget {
  const AttachmentUploadCard({super.key, required this.onAttachTap});

  final VoidCallback onAttachTap;

  @override
  State<AttachmentUploadCard> createState() => _AttachmentUploadCardState();
}

class _AttachmentUploadCardState extends State<AttachmentUploadCard> {
  AttachmentUploadStage _stage = AttachmentUploadStage.pending;

  void _setStage(AttachmentUploadStage stage) {
    setState(() => _stage = stage);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: t.overlay.withValues(alpha: 0.75)),
      ),
      child: Padding(
        padding: EdgeInsets.all(t.spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attachment_outlined, size: 18, color: t.textPrimary),
                SizedBox(width: t.spacing.xs),
                Expanded(
                  child: Text(
                    '图片附件上传面板',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AppTag(label: _stage.label, variant: _stage.variant),
              ],
            ),
            SizedBox(height: t.spacing.xs),
            Text(
              '选择图片后会自动进入上传、处理中、失败重试和已完成状态，供聊天消息直接接入。',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
            ),
            SizedBox(height: t.spacing.sm),
            DecoratedBox(
              decoration: BoxDecoration(
                color: t.secondarySurface.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(t.radius.md),
                border: Border.all(color: t.overlay.withValues(alpha: 0.45)),
              ),
              child: Padding(
                padding: EdgeInsets.all(t.spacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_stage.icon, color: t.textPrimary),
                    SizedBox(width: t.spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '当前状态：${_stage.label}',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: t.spacing.xxs),
                          Text(
                            _stage.description,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: t.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: t.spacing.sm),
            Wrap(
              spacing: t.spacing.xs,
              runSpacing: t.spacing.xs,
              children: AttachmentUploadStage.values
                  .map(
                    (stage) => AppChoiceChip(
                      label: stage.label,
                      selected: _stage == stage,
                      leading: Icon(stage.icon),
                      onTap: () => _setStage(stage),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: t.spacing.sm),
            Wrap(
              spacing: t.spacing.xs,
              runSpacing: t.spacing.xs,
              children: [
                AppChoiceChip(
                  label: '选择图片',
                  leading: const Icon(Icons.add_photo_alternate_outlined),
                  onTap: () {
                    widget.onAttachTap();
                    _setStage(AttachmentUploadStage.uploading);
                  },
                ),
                if (_stage == AttachmentUploadStage.failed)
                  AppChoiceChip(
                    label: '重试',
                    leading: const Icon(Icons.refresh_rounded),
                    onTap: () => _setStage(AttachmentUploadStage.uploading),
                    selected: true,
                  ),
              ],
            ),
            if (_stage == AttachmentUploadStage.failed) ...[
              SizedBox(height: t.spacing.sm),
              Text(
                '失败态会保留在卡片上，便于后续接入真实重试与恢复链路。',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
