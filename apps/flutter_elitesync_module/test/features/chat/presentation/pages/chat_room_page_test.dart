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
  }) async {}
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
}
