import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/message_input_bar.dart';

void main() {
  testWidgets('MessageInputBar exposes attachment picker for image and video', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageInputBar(
            controller: TextEditingController(),
            onSend: () {},
            sending: false,
            onAttach: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.byTooltip('添加图片或视频'), findsOneWidget);
    await tester.tap(find.byTooltip('添加图片或视频'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });
}
