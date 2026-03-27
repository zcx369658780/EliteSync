import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync/features/chat/presentation/widgets/connection_status_banner.dart';
import 'package:flutter_elitesync/features/chat/presentation/widgets/icebreaker_card.dart';
import 'package:flutter_elitesync/features/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter_elitesync/features/chat/presentation/widgets/message_input_bar.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  const ChatRoomPage({super.key, required this.conversationId, required this.title});

  final String conversationId;
  final String title;

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  final _controller = TextEditingController();
  final List<MessageEntity> _localMessages = <MessageEntity>[];
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(chatRoomMessagesProvider(widget.conversationId));
    final connection = ref.watch(chatConnectionProvider);
    final t = context.appTokens;

    return Scaffold(
      appBar: AppTopBar(title: widget.title, mode: AppTopBarMode.backTitle),
      body: Column(
        children: [
          ConnectionStatusBanner(status: connection),
          Padding(
            padding: EdgeInsets.fromLTRB(
              t.spacing.pageHorizontal,
              t.spacing.sm,
              t.spacing.pageHorizontal,
              t.spacing.sm,
            ),
            child: const SectionReveal(
              child: PageTitleRail(
                title: '慢慢聊',
                subtitle: '认真表达，关系会更稳定',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: t.spacing.pageHorizontal),
            child: const IcebreakerCard(),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (initialMessages) {
                final merged = [...initialMessages, ..._localMessages];
                return ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: t.spacing.pageHorizontal,
                    vertical: t.spacing.sm,
                  ),
                  children: merged.map((e) => MessageBubble(message: e)).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              t.spacing.pageHorizontal,
              t.spacing.xs,
              t.spacing.pageHorizontal,
              t.spacing.sm,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: t.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(t.radius.lg),
                border: Border.all(color: t.overlay.withValues(alpha: 0.75)),
              ),
              child: MessageInputBar(
                controller: _controller,
                sending: _sending,
                onSend: () {
                  final text = _controller.text.trim();
                  if (text.isEmpty) return;
                  _controller.clear();
                  final optimistic = MessageEntity(
                    id: 'local-${DateTime.now().millisecondsSinceEpoch}',
                    mine: true,
                    text: text,
                    time: '刚刚',
                  );
                  setState(() {
                    _localMessages.add(optimistic);
                    _sending = true;
                  });
                  ref.read(sendMessageUseCaseProvider).call(widget.conversationId, text).whenComplete(() {
                    if (!mounted) return;
                    setState(() => _sending = false);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
