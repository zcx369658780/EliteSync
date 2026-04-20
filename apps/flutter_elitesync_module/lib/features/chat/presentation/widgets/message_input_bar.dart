import 'package:flutter/material.dart';

class MessageInputBar extends StatelessWidget {
  const MessageInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.sending,
    this.onAttach,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;
  final VoidCallback? onAttach;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Row(
        children: [
          IconButton(
            tooltip: '添加图片或视频',
            onPressed: onAttach,
            icon: const Icon(Icons.add_photo_alternate_outlined),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: '输入首句问候或你想继续聊的话题…'),
            ),
          ),
          IconButton(
            onPressed: sending ? null : onSend,
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}
