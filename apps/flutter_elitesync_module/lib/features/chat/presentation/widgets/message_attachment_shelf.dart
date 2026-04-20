import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/attachment_upload_card.dart';

class MessageAttachmentShelf extends StatelessWidget {
  const MessageAttachmentShelf({super.key, required this.onAttachTap});

  final VoidCallback onAttachTap;

  @override
  Widget build(BuildContext context) {
    return AttachmentUploadCard(onAttachTap: onAttachTap);
  }
}
