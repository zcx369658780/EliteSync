class MessageAttachmentDto {
  const MessageAttachmentDto({
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

  factory MessageAttachmentDto.fromJson(Map<String, dynamic> json) =>
      MessageAttachmentDto(
        id: (json['id'] ?? '').toString(),
        attachmentType: (json['attachment_type'] ?? '').toString(),
        mediaAssetId:
            (json['media_asset'] is Map<String, dynamic>
                    ? (json['media_asset']['id'] ?? '')
                    : '')
                .toString(),
        mediaType:
            (json['media_asset'] is Map<String, dynamic>
                    ? (json['media_asset']['media_type'] ?? '')
                    : '')
                .toString(),
        publicUrl:
            (json['media_asset'] is Map<String, dynamic>
                    ? (json['media_asset']['public_url'] ?? '')
                    : '')
                .toString(),
        status:
            (json['media_asset'] is Map<String, dynamic>
                    ? (json['media_asset']['status'] ?? '')
                    : '')
                .toString(),
        mimeType:
            (json['media_asset'] is Map<String, dynamic>
                    ? (json['media_asset']['mime_type'] ?? '')
                    : '')
                .toString(),
        sizeBytes: (json['media_asset'] is Map<String, dynamic>
            ? (json['media_asset']['size_bytes'] as num?)?.toInt() ?? 0
            : 0),
        width: (json['media_asset'] is Map<String, dynamic>
            ? (json['media_asset']['width'] as num?)?.toInt()
            : null),
        height: (json['media_asset'] is Map<String, dynamic>
            ? (json['media_asset']['height'] as num?)?.toInt()
            : null),
        durationMs: (json['media_asset'] is Map<String, dynamic>
            ? (json['media_asset']['duration_ms'] as num?)?.toInt()
            : null),
      );
}
