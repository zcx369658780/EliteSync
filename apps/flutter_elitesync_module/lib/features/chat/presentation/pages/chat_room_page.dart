import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/connection_status_banner.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/icebreaker_card.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/message_input_bar.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/performance_mode_provider.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  const ChatRoomPage({super.key, required this.conversationId, required this.title});

  final String conversationId;
  final String title;

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  final _controller = TextEditingController();
  final _listController = ScrollController();
  final List<MessageEntity> _localMessages = <MessageEntity>[];
  Timer? _draftSaveDebounce;
  bool _sending = false;
  int _lastMergedCount = 0;

  String get _draftKey => '${CacheKeys.chatDraftPrefix}${widget.conversationId}';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onDraftChanged);
    _loadDraft();
  }

  @override
  void dispose() {
    _draftSaveDebounce?.cancel();
    _persistDraftNow();
    _controller.removeListener(_onDraftChanged);
    _controller.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final draft = await ref.read(localStorageProvider).getString(_draftKey);
    if (!mounted || draft == null || draft.isEmpty) return;
    _controller.text = draft;
    _controller.selection = TextSelection.collapsed(offset: draft.length);
  }

  void _onDraftChanged() {
    _draftSaveDebounce?.cancel();
    _draftSaveDebounce = Timer(const Duration(milliseconds: 220), _persistDraftNow);
  }

  Future<void> _persistDraftNow() async {
    final text = _controller.text.trim();
    final local = ref.read(localStorageProvider);
    if (text.isEmpty) {
      await local.remove(_draftKey);
      return;
    }
    await local.setString(_draftKey, text);
  }

  void _scheduleScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listController.hasClients) return;
      final liteMode = ref.read(performanceLiteModeProvider).asData?.value ?? false;
      final max = _listController.position.maxScrollExtent;
      if (liteMode) {
        _listController.jumpTo(max);
      } else {
        _listController.animateTo(
          max,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    _controller.clear();
    await ref.read(localStorageProvider).remove(_draftKey);
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
    _scheduleScrollToBottom();
    try {
      await ref.read(sendMessageUseCaseProvider).call(widget.conversationId, text);
      ref.invalidate(chatRoomMessagesProvider(widget.conversationId));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('发送失败，请稍后重试')),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(chatRoomMessagesProvider(widget.conversationId));
    final connection = ref.watch(chatConnectionProvider);
    final liteMode = ref.watch(performanceLiteModeProvider).asData?.value ?? false;
    final t = context.appTokens;

    return Scaffold(
      appBar: AppTopBar(
        title: widget.title,
        mode: AppTopBarMode.backTitle,
        actions: [
          IconButton(
            tooltip: '刷新消息',
            onPressed: () => ref.invalidate(chatRoomMessagesProvider(widget.conversationId)),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
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
              error: (e, _) => Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: t.spacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '消息加载失败',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: t.spacing.xs),
                      Text(
                        '$e',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: t.textSecondary,
                            ),
                      ),
                      SizedBox(height: t.spacing.md),
                      AppSecondaryButton(
                        label: '重试',
                        fullWidth: true,
                        onPressed: () => ref.invalidate(chatRoomMessagesProvider(widget.conversationId)),
                      ),
                    ],
                  ),
                ),
              ),
              data: (initialMessages) {
                final localPending = _localMessages.where((m) {
                  return !initialMessages.any((r) => r.mine == m.mine && r.text == m.text);
                }).toList();
                final merged = [...initialMessages, ...localPending];
                if (merged.length != _lastMergedCount) {
                  _lastMergedCount = merged.length;
                  _scheduleScrollToBottom();
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(chatRoomMessagesProvider(widget.conversationId));
                    await ref.read(chatRoomMessagesProvider(widget.conversationId).future);
                  },
                  child: ListView.builder(
                    controller: _listController,
                    cacheExtent: liteMode ? 400 : 1200,
                    padding: EdgeInsets.symmetric(
                      horizontal: t.spacing.pageHorizontal,
                      vertical: t.spacing.sm,
                    ),
                    itemCount: merged.length,
                    itemBuilder: (context, index) => RepaintBoundary(
                      child: MessageBubble(message: merged[index]),
                    ),
                  ),
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
                onSend: _sendMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
