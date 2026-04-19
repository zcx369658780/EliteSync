import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/chat_room_page.dart';

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
}
