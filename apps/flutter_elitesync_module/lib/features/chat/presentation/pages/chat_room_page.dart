import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_empty_state.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/connection_status_banner.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/icebreaker_card.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/message_input_bar.dart';
import 'package:flutter_elitesync_module/features/moderation/presentation/providers/moderation_provider.dart';
import 'package:flutter_elitesync_module/features/moderation/presentation/widgets/report_block_sheet.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/performance_mode_provider.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  const ChatRoomPage({
    super.key,
    required this.conversationId,
    required this.title,
  });

  final String conversationId;
  final String title;

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  final _controller = TextEditingController();
  final _listController = ScrollController();
  final List<MessageEntity> _localMessages = <MessageEntity>[];
  late final LocalStorageService _localStorage;
  Timer? _draftSaveDebounce;
  bool _sending = false;
  int _lastMergedCount = 0;

  String get _draftKey =>
      '${CacheKeys.chatDraftPrefix}${widget.conversationId}';
  int? get _peerId => int.tryParse(widget.conversationId);

  @override
  void initState() {
    super.initState();
    _localStorage = ref.read(localStorageProvider);
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
    final draft = await _localStorage.getString(_draftKey);
    if (!mounted || draft == null || draft.isEmpty) return;
    _controller.text = draft;
    _controller.selection = TextSelection.collapsed(offset: draft.length);
  }

  void _onDraftChanged() {
    _draftSaveDebounce?.cancel();
    _draftSaveDebounce = Timer(
      const Duration(milliseconds: 220),
      _persistDraftNow,
    );
  }

  Future<void> _persistDraftNow() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      await _localStorage.remove(_draftKey);
      return;
    }
    await _localStorage.setString(_draftKey, text);
  }

  void _scheduleScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listController.hasClients) return;
      final liteMode =
          ref.read(performanceLiteModeProvider).asData?.value ?? false;
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
    await _localStorage.remove(_draftKey);
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
      await ref
          .read(sendMessageUseCaseProvider)
          .call(widget.conversationId, text);
      ref.invalidate(chatRoomMessagesProvider(widget.conversationId));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _localMessages.removeWhere((m) => m.id == optimistic.id);
      });
      _controller.text = text;
      _controller.selection = TextSelection.collapsed(offset: text.length);
      AppFeedback.showError(context, '发送失败，已恢复输入框，请检查网络后重试');
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _openModerationSheet() async {
    final peerId = _peerId;
    if (peerId == null || peerId <= 0) {
      AppFeedback.showError(context, '当前会话对象无效');
      return;
    }
    final remote = ref.read(moderationRemoteDataSourceProvider);
    await ReportBlockSheet.show(
      context,
      targetName: widget.title,
      onReport: ({required String reasonCode, String? detail}) async {
        await remote.reportUser(
          targetUserId: peerId,
          category: 'user',
          reasonCode: reasonCode,
          sourcePage: 'chat_room',
          detail: detail,
        );
      },
      onBlock: () async {
        await remote.blockUser(
          blockedUserId: peerId,
          sourcePage: 'chat_room',
          reasonCode: 'chat_menu',
          detail: 'from_chat_room',
        );
      },
    );
  }

  void _applyIcebreakerSuggestion(String prompt) {
    final text = prompt.trim();
    if (text.isEmpty) return;
    setState(() {
      _controller.text = text;
      _controller.selection = TextSelection.collapsed(offset: text.length);
    });
    FocusScope.of(context).unfocus();
  }

  List<IcebreakerSuggestion> _icebreakerSuggestions() {
    return const [
      IcebreakerSuggestion(
        label: '从周末聊起',
        prompt: '先从最近一次让你放松的周末安排聊起，你通常会怎么度过？',
      ),
      IcebreakerSuggestion(label: '问最近状态', prompt: '你最近最想投入的一件事是什么？'),
      IcebreakerSuggestion(label: '接住话题', prompt: '你刚刚提到的那个点挺有意思，能多说一点吗？'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(chatRoomMessagesProvider(widget.conversationId));
    final connection = ref.watch(chatConnectionProvider);
    final t = context.appTokens;

    return Scaffold(
      appBar: AppTopBar(
        title: widget.title,
        mode: AppTopBarMode.backTitle,
        actions: [
          IconButton(
            tooltip: '刷新消息',
            onPressed: () =>
                ref.invalidate(chatRoomMessagesProvider(widget.conversationId)),
            icon: const Icon(Icons.refresh_rounded),
          ),
          PopupMenuButton<String>(
            tooltip: '安全',
            onSelected: (value) async {
              if (value == 'moderation') {
                await _openModerationSheet();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'moderation',
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.shield_outlined),
                  title: Text('举报 / 拉黑'),
                ),
              ),
            ],
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
                subtitle: '先发一条轻问候，再围绕对方回应继续展开',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: t.spacing.pageHorizontal),
            child: IcebreakerCard(
              suggestions: _icebreakerSuggestions(),
              onSuggestionTap: _applyIcebreakerSuggestion,
            ),
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: t.spacing.xs),
                      Text(
                        '当前网络或服务暂不可用。你可以先重试，或返回会话列表后再进入。',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                      ),
                      SizedBox(height: t.spacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: AppSecondaryButton(
                              label: '返回会话列表',
                              fullWidth: true,
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                          ),
                          SizedBox(width: t.spacing.sm),
                          Expanded(
                            child: AppSecondaryButton(
                              label: '重试',
                              fullWidth: true,
                              onPressed: () => ref.invalidate(
                                chatRoomMessagesProvider(widget.conversationId),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              data: (initialMessages) {
                final localPending = _localMessages.where((m) {
                  return !initialMessages.any(
                    (r) => r.mine == m.mine && r.text == m.text,
                  );
                }).toList();
                final merged = [...initialMessages, ...localPending];
                if (merged.isEmpty) {
                  return ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: t.spacing.pageHorizontal,
                      vertical: t.spacing.lg,
                    ),
                    children: [
                      AppEmptyState(
                        title: '还没有消息',
                        description: '先发一条轻问候，聊聊今天的状态或最近一次放松时刻。',
                        actionLabel: '返回会话列表',
                        onAction: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  );
                }
                if (merged.length != _lastMergedCount) {
                  _lastMergedCount = merged.length;
                  _scheduleScrollToBottom();
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(
                      chatRoomMessagesProvider(widget.conversationId),
                    );
                    await ref.read(
                      chatRoomMessagesProvider(widget.conversationId).future,
                    );
                  },
                  child: ListView.builder(
                    controller: _listController,
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
