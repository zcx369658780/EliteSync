class MessageAttachmentEntity {
  const MessageAttachmentEntity({
    required this.id,
    required this.attachmentType,
    required this.mediaAssetId,
    required this.mediaType,
    required this.publicUrl,
    required this.status,
    required this.mimeType,
    required this.sizeBytes,
    required this.width,
    required this.height,
    required this.durationMs,
  });

  final String id;
  final String attachmentType;
  final String mediaAssetId;
  final String mediaType;
  final String publicUrl;
  final String status;
  final String mimeType;
  final int sizeBytes;
  final int? width;
  final int? height;
  final int? durationMs;

  bool get isImage => mediaType.startsWith('image');
  bool get isVideo => mediaType.startsWith('video');
}
