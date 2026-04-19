import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_attachment_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/message_bubble.dart';

Future<void> _capture(WidgetTester tester, Finder finder, String path) async {
  await tester.pump(const Duration(milliseconds: 800));
  final boundary = tester.renderObject<RenderRepaintBoundary>(finder);
  final image = await boundary.toImage(pixelRatio: 2.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    throw StateError('failed to encode $path');
  }
  await File(path).writeAsBytes(byteData.buffer.asUint8List());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture image bubble', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 3120));

    final message = MessageEntity(
      id: 'm003',
      mine: true,
      text: '',
      time: '10:17',
      attachments: const [
        MessageAttachmentEntity(
          id: 'a001',
          attachmentType: 'image',
          mediaAssetId: '9001',
          mediaType: 'image',
          publicUrl: 'file:///D:/EliteSync/4_2_demo_image.png',
          status: 'ready',
          mimeType: 'image/png',
          sizeBytes: 58241,
          width: 1024,
          height: 1024,
          durationMs: null,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF0E1728),
          body: Center(
            child: RepaintBoundary(
              key: const ValueKey('bubble_boundary'),
              child: SizedBox(
                width: 520,
                child: MessageBubble(message: message),
              ),
            ),
          ),
        ),
      ),
    );

    await _capture(
      tester,
      find.byKey(const ValueKey('bubble_boundary')),
      'D:/EliteSync/4_2_message_bubble_widget.png',
    );

    await tester.binding.setSurfaceSize(null);
  });
}
