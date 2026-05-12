import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/repository/chat_repository.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/chat_room_page.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class FakeLocalStorageService extends LocalStorageService {
  final Map<String, Object?> _values = <String, Object?>{};

  @override
  Future<String?> getString(String key) async {
    final value = _values[key];
    return value is String ? value : null;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }
}

class FakeChatRepository implements ChatRepository {
  int sendMessageCount = 0;
  String? lastSentText;

  @override
  Future<List<ConversationEntity>> getConversations() async => const [];

  @override
  Future<List<MessageEntity>> getMessages(String conversationId) async =>
      const [];

  @override
  Stream<MessageEntity> observeMessages(String conversationId) =>
      const Stream<MessageEntity>.empty();

  @override
  Future<void> sendMessage(
    String conversationId,
    String text, {
    List<int> attachmentIds = const [],
  }) async {
    sendMessageCount += 1;
    lastSentText = text;
  }
}

void main() {
  testWidgets('ChatRoomPage shows invalid session state for mock ids', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ChatRoomPage(conversationId: 'c002', title: '九紫瑶瑶'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('当前会话已失效'), findsOneWidget);
    expect(find.text('返回会话列表'), findsOneWidget);
  });

  testWidgets('ChatRoomPage renders voice rhythm guidance for valid chat', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageProvider.overrideWithValue(FakeLocalStorageService()),
          chatRepositoryProvider.overrideWithValue(FakeChatRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: const ChatRoomPage(conversationId: '2', title: '九紫瑶瑶'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('语音节奏'), findsOneWidget);
    expect(find.text('查看语音前提示'), findsOneWidget);

    await tester.tap(find.text('查看语音前提示'));
    await tester.pumpAndSettle();

    expect(find.text('语音前先确认节奏'), findsOneWidget);
    expect(find.text('继续文字'), findsOneWidget);
    expect(find.text('现在语音'), findsOneWidget);
  });

  testWidgets('ChatRoomPage renders 5.9 low-pressure opening contract', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageProvider.overrideWithValue(FakeLocalStorageService()),
          chatRepositoryProvider.overrideWithValue(FakeChatRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: const ChatRoomPage(conversationId: '2', title: '九紫瑶瑶'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('低压开场建议'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('低压开场建议'), findsOneWidget);
    expect(find.text('从共同点开始'), findsOneWidget);
    expect(find.text('换个更自然的说法'), findsOneWidget);
    expect(find.text('低压问候建议'), findsOneWidget);
    expect(find.text('不要太急'), findsOneWidget);
    expect(find.text('可编辑草稿'), findsOneWidget);
    expect(find.text('冷场恢复'), findsOneWidget);
    expect(find.text('续话提示'), findsOneWidget);
    expect(find.text('填入后仍需你自己确认发送'), findsOneWidget);
    expect(find.textContaining('不会读取私密聊天'), findsOneWidget);
    expect(find.textContaining('不会写入资料'), findsOneWidget);
    expect(find.textContaining('不会自动发送消息'), findsOneWidget);
    expect(find.byTooltip('添加图片或视频'), findsOneWidget);

    await tester.tap(find.byTooltip('添加图片或视频'));
    await tester.pumpAndSettle();

    expect(find.text('选择图片'), findsOneWidget);
    expect(find.text('选择视频'), findsOneWidget);
  });

  testWidgets('ChatRoomPage opening suggestions write drafts without sending', (
    tester,
  ) async {
    final repository = FakeChatRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageProvider.overrideWithValue(FakeLocalStorageService()),
          chatRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: const ChatRoomPage(conversationId: '2', title: '九紫瑶瑶'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    const drafts = <String, String>{
      '从共同点开始': '我看到我们有些相近的地方，想从一个轻松的问题开始：你最近最愿意投入的一件事是什么？',
      '换个更自然的说法': '刚刚那句话我想换个轻松点的问法：你平时更喜欢怎么慢慢认识一个人？',
      '低压问候建议': '嗨，今天过得怎么样？不用急着回，我只是想先从一个轻松的问候开始。',
      '不要太急': '我不想聊得太急。我们可以先从最近让你放松的一件小事聊起。',
    };

    for (final entry in drafts.entries) {
      await tester.scrollUntilVisible(
        find.text(entry.key),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();

      final input = tester.widget<TextField>(find.byType(TextField));
      expect(input.controller?.text, entry.value);
      expect(repository.sendMessageCount, 0);
      expect(repository.lastSentText, isNull);
    }
  });
}
