import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/message_attachment_shelf.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ThemeMode.light,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('attachment shelf exposes visible upload states and retry', (
    tester,
  ) async {
    var attachCount = 0;
    await tester.pumpWidget(
      _wrap(
        MessageAttachmentShelf(
          onAttachTap: () {
            attachCount += 1;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('图片附件上传面板'), findsOneWidget);
    expect(find.text('当前状态：待上传'), findsOneWidget);
    expect(find.text('选择图片'), findsOneWidget);
    expect(find.text('上传中'), findsWidgets);
    expect(find.text('处理中'), findsWidgets);
    expect(find.text('失败'), findsWidgets);
    expect(find.text('已完成'), findsWidgets);

    await tester.tap(find.text('失败').last);
    await tester.pumpAndSettle();
    expect(find.text('当前状态：失败'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(find.text('当前状态：上传中'), findsOneWidget);

    await tester.tap(find.text('选择图片'));
    await tester.pumpAndSettle();
    expect(attachCount, 1);
    expect(find.text('当前状态：上传中'), findsOneWidget);
  });
}
