import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_empty_state.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_attachment_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/utils/conversation_snapshot_utils.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/connection_status_banner.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/attachment_upload_card.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/icebreaker_card.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/message_input_bar.dart';
import 'package:flutter_elitesync_module/features/moderation/presentation/providers/moderation_provider.dart';
import 'package:flutter_elitesync_module/features/moderation/presentation/widgets/report_block_sheet.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_permission_service.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/providers/rtc_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/performance_mode_provider.dart';

enum ChatAttachmentKind { image, video }

extension ChatAttachmentKindX on ChatAttachmentKind {
  String get label => switch (this) {
    ChatAttachmentKind.image => '图片',
    ChatAttachmentKind.video => '视频',
  };

  String get mediaType => switch (this) {
    ChatAttachmentKind.image => 'image',
    ChatAttachmentKind.video => 'video',
  };

  String get pickerTooltip => switch (this) {
    ChatAttachmentKind.image => '选择图片',
    ChatAttachmentKind.video => '选择视频',
  };
}

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
  final _imagePicker = ImagePicker();
  Timer? _draftSaveDebounce;
  Timer? _realtimeRefreshTimer;
  StreamSubscription<MessageEntity>? _realtimeSubscription;
  bool _sending = false;
  int _lastMergedCount = 0;
  String? _selectedImagePath;
  String? _selectedImageName;
  String? _selectedImagePreviewUrl;
  int? _selectedAttachmentId;
  String? _selectedAttachmentStatus;
  String? _attachmentError;
  ChatAttachmentKind _selectedAttachmentKind = ChatAttachmentKind.image;
  AttachmentUploadStage _attachmentStage = AttachmentUploadStage.pending;

  String get _draftKey =>
      '${CacheKeys.chatDraftPrefix}${widget.conversationId}';
  int? get _peerId => int.tryParse(widget.conversationId);
  bool get _isConversationIdSupported =>
      isSupportedConversationId(widget.conversationId, allowMockIds: false);

  @override
  void initState() {
    super.initState();
    _localStorage = ref.read(localStorageProvider);
    _controller.addListener(_onDraftChanged);
    _loadDraft();
    _startRealtimeSync();
  }

  @override
  void didUpdateWidget(covariant ChatRoomPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversationId != widget.conversationId) {
      _stopRealtimeSync();
      _startRealtimeSync();
    }
  }

  @override
  void dispose() {
    _draftSaveDebounce?.cancel();
    _stopRealtimeSync();
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

  void _startRealtimeSync() {
    if (!_isConversationIdSupported) return;
    _realtimeSubscription = ref
        .read(observeMessagesUseCaseProvider)
        .call(widget.conversationId)
        .listen(
          (_) {
            if (!mounted) return;
            ref.invalidate(chatRoomMessagesProvider(widget.conversationId));
            ref.invalidate(conversationListProvider);
            _scheduleScrollToBottom();
          },
          onError: (_) {
            // Keep the fallback polling timer running; the next tick will refresh.
          },
        );
    _realtimeRefreshTimer?.cancel();
    _realtimeRefreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted) return;
      ref.invalidate(chatRoomMessagesProvider(widget.conversationId));
      ref.invalidate(conversationListProvider);
    });
  }

  void _stopRealtimeSync() {
    _realtimeRefreshTimer?.cancel();
    _realtimeRefreshTimer = null;
    _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
  }

  Future<void> _sendMessage() async {
    if (!_isConversationIdSupported) {
      AppFeedback.showError(context, '当前会话已失效，请返回会话列表重新选择后重试');
      return;
    }
    final text = _controller.text.trim();
    final hasReadyAttachment =
        _attachmentStage == AttachmentUploadStage.ready &&
        _selectedAttachmentId != null;
    if (_sending || (text.isEmpty && !hasReadyAttachment)) return;

    final attachmentIds = hasReadyAttachment
        ? <int>[_selectedAttachmentId!]
        : <int>[];
    final selectedMediaType = _selectedAttachmentKind.mediaType;
    final optimistic = MessageEntity(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      mine: true,
      text: text,
      time: '刚刚',
      attachments: hasReadyAttachment
          ? [
              MessageAttachmentEntity(
                id: 'local-$_selectedAttachmentId',
                attachmentType: selectedMediaType,
                mediaAssetId: '$_selectedAttachmentId',
                mediaType: selectedMediaType,
                publicUrl: _selectedImagePreviewUrl ?? '',
                status: _selectedAttachmentStatus ?? 'ready',
                mimeType: selectedMediaType == 'video' ? 'video/*' : 'image/*',
                sizeBytes: 0,
                width: null,
                height: null,
                durationMs: null,
              ),
            ]
          : const [],
    );
    _controller.clear();
    await _localStorage.remove(_draftKey);
    setState(() {
      _localMessages.add(optimistic);
      _sending = true;
    });
    _scheduleScrollToBottom();
    try {
      await ref
          .read(sendMessageUseCaseProvider)
          .call(widget.conversationId, text, attachmentIds: attachmentIds);
      ref.invalidate(chatRoomMessagesProvider(widget.conversationId));
      if (attachmentIds.isNotEmpty) {
        final telemetry = ref.read(frontendTelemetryProvider);
        if (_selectedAttachmentKind == ChatAttachmentKind.video) {
          telemetry.chatVideoMessageSent(
            sourcePage: 'chat_room',
            attachmentCount: attachmentIds.length,
          );
        } else {
          telemetry.chatImageMessageSent(
            sourcePage: 'chat_room',
            attachmentCount: attachmentIds.length,
          );
        }
      }
      if (hasReadyAttachment) {
        _clearAttachmentDraft();
      }
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

  void _clearAttachmentDraft() {
    setState(() {
      _selectedImagePath = null;
      _selectedImageName = null;
      _selectedImagePreviewUrl = null;
      _selectedAttachmentId = null;
      _selectedAttachmentStatus = null;
      _attachmentError = null;
      _selectedAttachmentKind = ChatAttachmentKind.image;
      _attachmentStage = AttachmentUploadStage.pending;
    });
  }

  Future<void> _pickAndUploadImage() async {
    await _pickAndUploadMedia(ChatAttachmentKind.image);
  }

  Future<void> _pickAndUploadVideo() async {
    await _pickAndUploadMedia(ChatAttachmentKind.video);
  }

  Future<void> _openAttachmentPicker() async {
    if (_sending || _attachmentStage == AttachmentUploadStage.uploading) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final t = context.appTokens;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            t.spacing.pageHorizontal,
            0,
            t.spacing.pageHorizontal,
            t.spacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('选择图片'),
                subtitle: const Text('发送图片附件'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickAndUploadImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: const Text('选择视频'),
                subtitle: const Text('发送单视频消息'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickAndUploadVideo();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startVoiceCall() async {
    final peerId = _peerId;
    if (peerId == null || peerId <= 0) {
      AppFeedback.showError(context, '当前会话无法发起通话');
      return;
    }
    final router = GoRouter.of(context);
    final confirmed = await _confirmVoiceRhythm();
    if (!confirmed) return;

    final permissionService = ref.read(rtcPermissionServiceProvider);
    if (!await permissionService.hasVoiceCallPermission()) {
      final granted =
          await router.push<bool>(
            '${AppRouteNames.rtcPermission}?title=${Uri.encodeComponent('通话权限')}',
          ) ??
          false;
      if (!granted && !await permissionService.hasVoiceCallPermission()) {
        return;
      }
    }

    final telemetry = ref.read(frontendTelemetryProvider);
    telemetry.rtcCallEntryOpened(sourcePage: 'chat_room');

    try {
      final session = await ref
          .read(rtcRemoteDataSourceProvider)
          .createCall(peerUserId: peerId, mode: 'voice');
      telemetry.rtcCallStatusChanged(
        sourcePage: 'chat_room',
        callId: session.id,
        status: session.status,
      );
      if (!mounted) return;
      final target = session.isTerminal
          ? '${AppRouteNames.rtcCallResult}/${session.id}'
          : '${AppRouteNames.rtcCall}/${session.id}';
      router.push(
        target,
        extra: session.title.isNotEmpty ? session.title : widget.title,
      );
    } catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('permission') ||
          message.contains('授权') ||
          message.contains('权限')) {
        if (!mounted) return;
        final granted =
            await router.push<bool>(
              '${AppRouteNames.rtcPermission}?title=${Uri.encodeComponent('通话权限')}',
            ) ??
            false;
        if (granted || await permissionService.hasVoiceCallPermission()) {
          await _startVoiceCall();
          return;
        }
      }
      if (!mounted) return;
      AppFeedback.showError(context, e.toString());
    }
  }

  Future<bool> _confirmVoiceRhythm() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final t = dialogContext.appTokens;
        return AlertDialog(
          title: const Text('语音前先确认节奏'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VoiceRhythmLine(
                icon: Icons.chat_bubble_outline_rounded,
                text: '如果刚开始认识，先用文字接住对方回应会更低压。',
                color: t.brandPrimary,
              ),
              SizedBox(height: t.spacing.xs),
              _VoiceRhythmLine(
                icon: Icons.favorite_outline_rounded,
                text: '当你们已经围绕共同点聊开，再切到语音会更自然。',
                color: t.brandPrimary,
              ),
              SizedBox(height: t.spacing.xs),
              _VoiceRhythmLine(
                icon: Icons.call_outlined,
                text: '现在发起语音邀请，不会自动发送文字消息。',
                color: t.brandPrimary,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('继续文字'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('现在语音'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _pickAndUploadMedia(ChatAttachmentKind kind) async {
    if (_sending || _attachmentStage == AttachmentUploadStage.uploading) return;
    final telemetry = ref.read(frontendTelemetryProvider);
    _selectedAttachmentKind = kind;
    if (kind == ChatAttachmentKind.video) {
      telemetry.chatVideoPickerOpened(sourcePage: 'chat_room');
    } else {
      telemetry.chatImagePickerOpened(sourcePage: 'chat_room');
    }

    final picked = switch (kind) {
      ChatAttachmentKind.image => await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
      ),
      ChatAttachmentKind.video => await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      ),
    };
    if (picked == null) return;

    final selectedName = picked.name.isNotEmpty
        ? picked.name
        : (kind == ChatAttachmentKind.video ? 'video.mp4' : 'image.jpg');

    setState(() {
      _selectedImagePath = picked.path;
      _selectedImageName = selectedName;
      _attachmentStage = AttachmentUploadStage.uploading;
      _attachmentError = null;
    });
    if (kind == ChatAttachmentKind.video) {
      telemetry.chatVideoUploadStarted(sourcePage: 'chat_room');
    } else {
      telemetry.chatImageUploadStarted(sourcePage: 'chat_room');
    }

    try {
      final api = ref.read(apiClientProvider);
      final form = FormData.fromMap({
        'media_type': kind.mediaType,
        'original_name': selectedName,
        'file': await MultipartFile.fromFile(
          picked.path,
          filename: selectedName,
        ),
        'metadata': {'source_page': 'chat_room', 'media_kind': kind.mediaType},
      });
      final result = await api.post('/api/v1/media', body: form);
      if (result is! NetworkSuccess<Map<String, dynamic>>) {
        throw Exception(
          (result as NetworkFailure<Map<String, dynamic>>).message,
        );
      }
      final asset = result.data['asset'];
      if (asset is! Map<String, dynamic>) {
        throw Exception('media upload did not return an asset');
      }
      final assetId = (asset['id'] as num?)?.toInt() ?? 0;
      final publicUrl = (asset['public_url'] ?? '').toString();
      final status = (asset['status'] ?? '').toString();
      if (assetId <= 0 || publicUrl.isEmpty) {
        throw Exception('media asset response incomplete');
      }
      setState(() {
        _selectedAttachmentId = assetId;
        _selectedAttachmentStatus = status.isNotEmpty ? status : 'uploaded';
        _selectedImagePreviewUrl = publicUrl;
        _attachmentStage = status == 'failed'
            ? AttachmentUploadStage.failed
            : AttachmentUploadStage.ready;
      });
      if (!mounted) return;
      if (kind == ChatAttachmentKind.video) {
        telemetry.chatVideoUploadSucceeded(
          sourcePage: 'chat_room',
          assetId: assetId,
        );
        AppFeedback.showSuccess(context, '视频已准备好，可以发送');
      } else {
        telemetry.chatImageUploadSucceeded(
          sourcePage: 'chat_room',
          assetId: assetId,
        );
        AppFeedback.showSuccess(context, '图片已准备好，可以发送');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _selectedAttachmentId = null;
        _selectedImagePreviewUrl = null;
        _selectedAttachmentStatus = 'failed';
        _attachmentStage = AttachmentUploadStage.failed;
        _attachmentError = e.toString();
      });
      if (kind == ChatAttachmentKind.video) {
        telemetry.chatVideoUploadFailed(
          sourcePage: 'chat_room',
          errorCode: 'upload_failed',
        );
        AppFeedback.showError(context, '视频上传失败，请重试');
      } else {
        telemetry.chatImageUploadFailed(
          sourcePage: 'chat_room',
          errorCode: 'upload_failed',
        );
        AppFeedback.showError(context, '图片上传失败，请重试');
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

  Widget _buildAttachmentDraftCard() {
    if (_selectedImagePath == null) return const SizedBox.shrink();
    final t = context.appTokens;
    final file = File(_selectedImagePath!);
    final isVideo = _selectedAttachmentKind == ChatAttachmentKind.video;
    final label = switch (_attachmentStage) {
      AttachmentUploadStage.pending => '待上传',
      AttachmentUploadStage.uploading => '上传中',
      AttachmentUploadStage.processing => '处理中',
      AttachmentUploadStage.failed => '失败',
      AttachmentUploadStage.ready => '已完成',
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: t.overlay.withValues(alpha: 0.75)),
      ),
      child: Padding(
        padding: EdgeInsets.all(t.spacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(t.radius.md),
              child: SizedBox(
                width: 68,
                height: 68,
                child: isVideo
                    ? ColoredBox(
                        color: Colors.black12,
                        child: Center(
                          child: Icon(
                            Icons.videocam_outlined,
                            color: t.textSecondary,
                          ),
                        ),
                      )
                    : Image.file(
                        file,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const ColoredBox(
                              color: Colors.black12,
                              child: Icon(Icons.broken_image_outlined),
                            ),
                      ),
              ),
            ),
            SizedBox(width: t.spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedImageName ?? '已选择${isVideo ? '视频' : '图片'}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: t.secondarySurface,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(label),
                      ),
                    ],
                  ),
                  SizedBox(height: t.spacing.xxs),
                  Text(
                    _attachmentError ??
                        switch (_attachmentStage) {
                          AttachmentUploadStage.pending =>
                            '已选择${isVideo ? '视频' : '图片'}，等待上传。',
                          AttachmentUploadStage.uploading =>
                            '${isVideo ? '视频' : '图片'}正在上传到对象存储主路径。',
                          AttachmentUploadStage.processing =>
                            '${isVideo ? '视频' : '图片'}已入库，正在等待后台处理。',
                          AttachmentUploadStage.failed => '上传失败，可重试或重新选择。',
                          AttachmentUploadStage.ready =>
                            '${isVideo ? '视频' : '图片'}已可发送。',
                        },
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                  ),
                  SizedBox(height: t.spacing.xs),
                  Wrap(
                    spacing: t.spacing.xs,
                    runSpacing: t.spacing.xs,
                    children: [
                      AppSecondaryButton(
                        label: _attachmentStage == AttachmentUploadStage.failed
                            ? '重试上传'
                            : '重新选择',
                        onPressed:
                            _selectedAttachmentKind == ChatAttachmentKind.video
                            ? _pickAndUploadVideo
                            : _pickAndUploadImage,
                      ),
                      AppSecondaryButton(
                        label: '清除',
                        onPressed: _clearAttachmentDraft,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<IcebreakerSuggestion> _icebreakerSuggestions() {
    return const [
      IcebreakerSuggestion(
        label: '继续聊：从周末聊起',
        lane: '继续聊',
        source: '关系摘要 / 共同点',
        description: '适合刚有回应时继续放轻节奏，不抢结论。',
        icon: Icons.forum_outlined,
        prompt: '先从最近一次让你放松的周末安排聊起，你通常会怎么度过？',
      ),
      IcebreakerSuggestion(
        label: '继续聊：问最近状态',
        lane: '继续聊',
        source: '最近互动',
        description: '适合把聊天从问候推进到真实近况。',
        icon: Icons.waving_hand_outlined,
        prompt: '你最近最想投入的一件事是什么？',
      ),
      IcebreakerSuggestion(
        label: '回聊：接住话题',
        lane: '回聊',
        source: '最近互动',
        description: '适合对方已经给出信息时，先接住再追问。',
        icon: Icons.reply_rounded,
        prompt: '你刚刚提到的那个点挺有意思，能多说一点吗？',
      ),
      IcebreakerSuggestion(
        label: '回聊：从共同点延展',
        lane: '回聊',
        source: '匹配解释 / 共同点',
        description: '适合把匹配解释里的共同点转成自然追问。',
        icon: Icons.join_inner_rounded,
        prompt: '我们好像有个相近的地方：都更重视相处里的真实感。你会怎么理解这种感觉？',
      ),
      IcebreakerSuggestion(
        label: '稍后再回：低压回归',
        lane: '稍后再回',
        source: '稍后再回队列',
        description: '适合隔了一段时间后重新接起，不制造压力。',
        icon: Icons.schedule_rounded,
        prompt: '刚刚那段我想了一下，还是挺想听听你的看法。如果你愿意，我们可以从一个轻松的问题重新聊起。',
      ),
      IcebreakerSuggestion(
        label: '冷场恢复：共鸣接起',
        lane: '冷场恢复',
        source: '冷场恢复队列',
        description: '适合聊天中断后，先表达理解，再轻轻追问。',
        icon: Icons.volunteer_activism_outlined,
        prompt: '我刚刚想到你说的那句话，其实挺能理解。你当时最在意的是哪一部分？',
      ),
      IcebreakerSuggestion(
        label: '冷场恢复：周末安排',
        lane: '冷场恢复',
        source: '状态内容 / 生活节奏',
        description: '适合话题停住时，用低压生活问题重新打开。',
        icon: Icons.weekend_outlined,
        prompt: '这个周末你更想安静待着，还是想出去走走？我有点好奇你的放松方式。',
      ),
    ];
  }

  Widget _buildVoiceRhythmInline(dynamic t) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.secondarySurface,
        borderRadius: BorderRadius.circular(t.radius.md),
      ),
      child: Padding(
        padding: EdgeInsets.all(t.spacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.call_outlined, color: t.brandPrimary, size: 20),
            SizedBox(width: t.spacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '语音节奏',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: t.spacing.xxs),
                  Text(
                    '已有连续回聊、共同点被接住时，再发起语音更自然；首聊阶段建议先文字铺垫。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: t.spacing.xs),
                  AppSecondaryButton(
                    label: '查看语音前提示',
                    onPressed: _confirmVoiceRhythm,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConversationHeader(dynamic t) {
    return [
      Padding(
        padding: EdgeInsets.fromLTRB(
          t.spacing.pageHorizontal,
          t.spacing.sm,
          t.spacing.pageHorizontal,
          t.spacing.sm,
        ),
        child: const SectionReveal(
          child: PageTitleRail(title: '慢慢聊', subtitle: '先发一条轻问候，再围绕对方回应继续展开'),
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: t.spacing.pageHorizontal),
        child: AppInfoSectionCard(
          title: '关系摘要',
          subtitle: '首聊 / 回聊 / 关系推进的当前提示',
          leadingIcon: Icons.favorite_outline_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '当前会话适合慢聊推进：先接住对方回应，再围绕共同点、近况和周末安排继续展开；如果节奏合适，也可以再切到语音联动。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: t.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: t.spacing.sm),
              Wrap(
                spacing: t.spacing.xs,
                runSpacing: t.spacing.xs,
                children: [
                  AppChoiceChip(
                    label: '首聊',
                    selected: true,
                    leading: const Icon(Icons.chat_bubble_outline_rounded),
                  ),
                  AppChoiceChip(
                    label: '回聊',
                    selected: true,
                    leading: const Icon(Icons.refresh_rounded),
                  ),
                  AppChoiceChip(
                    label: '关系摘要',
                    selected: true,
                    leading: const Icon(Icons.view_quilt_outlined),
                  ),
                  AppChoiceChip(
                    label: '语音联动',
                    selected: true,
                    leading: const Icon(Icons.call_outlined),
                  ),
                ],
              ),
              SizedBox(height: t.spacing.sm),
              _buildVoiceRhythmInline(t),
            ],
          ),
        ),
      ),
      SizedBox(height: t.spacing.xs),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: t.spacing.pageHorizontal),
        child: IcebreakerCard(
          suggestions: _icebreakerSuggestions(),
          onSuggestionTap: _applyIcebreakerSuggestion,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(
          t.spacing.pageHorizontal,
          t.spacing.xs,
          t.spacing.pageHorizontal,
          t.spacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '图片/视频附件入口已接入，可直接选择并上传。',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            AppSecondaryButton(
              label: '选择图片 / 视频',
              onPressed: _openAttachmentPicker,
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(
          t.spacing.pageHorizontal,
          t.spacing.xs,
          t.spacing.pageHorizontal,
          t.spacing.xs,
        ),
        child: _buildAttachmentDraftCard(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConversationIdSupported) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: BackButton(
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, size: 48),
                const SizedBox(height: 16),
                Text('当前会话已失效', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text(
                  '请返回会话列表后重新选择一个有效的聊天对象。',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('返回会话列表'),
                ),
              ],
            ),
          ),
        ),
      );
    }
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
          IconButton(
            tooltip: '语音通话',
            onPressed: _startVoiceCall,
            icon: const Icon(Icons.call_outlined),
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
                    children: [
                      ..._buildConversationHeader(t),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: t.spacing.pageHorizontal,
                          vertical: t.spacing.lg,
                        ),
                        child: AppEmptyState(
                          title: '还没有消息',
                          description: '先发一条轻问候，聊聊今天的状态或最近一次放松时刻。',
                          actionLabel: '返回会话列表',
                          onAction: () => Navigator.of(context).maybePop(),
                        ),
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
                  child: ListView(
                    controller: _listController,
                    padding: EdgeInsets.only(bottom: t.spacing.sm),
                    children: [
                      ..._buildConversationHeader(t),
                      ...merged.map(
                        (message) => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: t.spacing.pageHorizontal,
                          ),
                          child: RepaintBoundary(
                            child: MessageBubble(message: message),
                          ),
                        ),
                      ),
                    ],
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
              t.spacing.xs,
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
                onAttach: _openAttachmentPicker,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceRhythmLine extends StatelessWidget {
  const _VoiceRhythmLine({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
