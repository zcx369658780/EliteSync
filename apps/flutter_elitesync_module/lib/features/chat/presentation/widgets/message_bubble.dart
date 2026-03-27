import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});
  final MessageEntity message;

  @override
  Widget build(BuildContext context) {
    final align = message.mine ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.mine ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest;
    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
        child: Text(message.text),
      ),
    );
  }
}
