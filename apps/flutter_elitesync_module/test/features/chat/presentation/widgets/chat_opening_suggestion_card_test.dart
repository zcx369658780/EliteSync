import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/chat_opening_suggestion_card.dart';

void main() {
  testWidgets('ChatOpeningSuggestionCard renders 5.9 no-auto-send contract', (
    tester,
  ) async {
    var selectedDraft = '';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ChatOpeningSuggestionCard(
              suggestions: const [
                ChatOpeningSuggestion(
                  title: '从共同点开始',
                  description: '从共同点轻轻开口。',
                  prompt: '我们可以先从共同点聊起。',
                  tag: '共同点',
                  icon: Icons.forum_outlined,
                ),
                ChatOpeningSuggestion(
                  title: '换个更自然的说法',
                  description: '把语气放轻一点。',
                  prompt: '我想换个更轻松的问法。',
                  tag: '改写',
                  icon: Icons.tune_rounded,
                ),
                ChatOpeningSuggestion(
                  title: '低压问候建议',
                  description: '轻问候，不催促。',
                  prompt: '嗨，今天过得怎么样？',
                  tag: '问候',
                  icon: Icons.waving_hand_outlined,
                ),
                ChatOpeningSuggestion(
                  title: '不要太急',
                  description: '先接住节奏。',
                  prompt: '我们可以慢慢聊。',
                  tag: '节奏',
                  icon: Icons.spa_outlined,
                ),
              ],
              onDraftSelected: (draft) {
                selectedDraft = draft;
              },
            ),
          ),
        ),
      ),
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

    await tester.tap(find.text('低压问候建议'));
    await tester.pumpAndSettle();

    expect(selectedDraft, '嗨，今天过得怎么样？');
  });
}
