import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_attachment_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

void main() {
  testWidgets('MessageBubble renders image attachment card', (tester) async {
    const message = MessageEntity(
      id: '1',
      mine: false,
      text: '看看这张图',
      time: '刚刚',
      attachments: [
        MessageAttachmentEntity(
          id: '10',
          attachmentType: 'image',
          mediaAssetId: '99',
          mediaType: 'image',
          publicUrl: 'https://cdn.example.test/chat/a.jpg',
          status: 'ready',
          mimeType: 'image/jpeg',
          sizeBytes: 1024,
          width: 800,
          height: 600,
          durationMs: null,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.prod,
              appName: 'EliteSync',
              apiBaseUrl: 'http://101.133.161.203/',
              useMockData: false,
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: MessageBubble(message: message)),
        ),
      ),
    );

    expect(find.text('看看这张图'), findsOneWidget);
    expect(find.text('图片消息'), findsOneWidget);
  });

  testWidgets('MessageBubble renders video attachment card', (tester) async {
    const message = MessageEntity(
      id: '2',
      mine: true,
      text: '',
      time: '刚刚',
      attachments: [
        MessageAttachmentEntity(
          id: '11',
          attachmentType: 'video',
          mediaAssetId: '100',
          mediaType: 'video',
          publicUrl: 'https://cdn.example.test/chat/a.mp4',
          status: 'ready',
          mimeType: 'video/mp4',
          sizeBytes: 2048,
          width: 1280,
          height: 720,
          durationMs: 65000,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.prod,
              appName: 'EliteSync',
              apiBaseUrl: 'http://101.133.161.203/',
              useMockData: false,
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: MessageBubble(message: message)),
        ),
      ),
    );

    expect(find.text('视频消息'), findsOneWidget);
    expect(find.text('1:05'), findsOneWidget);
  });
}
