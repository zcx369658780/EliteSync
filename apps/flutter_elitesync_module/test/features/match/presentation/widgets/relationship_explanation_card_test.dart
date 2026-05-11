import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/relationship_explanation_card.dart';

void main() {
  testWidgets('relationship explanation card renders display-only contract', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: RelationshipExplanationCard(
            summary: '你们有相近的表达节奏，适合从轻松的话题慢慢开始。',
            dimensions: [
              RelationshipExplanationDimension(
                title: '共同点',
                description: '可以从共同兴趣或城市经历问起。',
                tag: '同城',
              ),
              RelationshipExplanationDimension(
                title: '表达节奏',
                description: '先交换真实感受，再逐步深入。',
              ),
              RelationshipExplanationDimension(
                title: '慢约会适配度',
                description: '先确认彼此节奏，不急着推进关系。',
              ),
            ],
            suggestions: ['从共同兴趣或城市经历问起。', '先用一句轻问候。'],
            avoidances: ['避免一开始就问隐私。', '避免把匹配提示说成确定结论。'],
          ),
        ),
      ),
    );

    expect(find.text('为什么值得聊'), findsOneWidget);
    expect(find.text('共同点'), findsOneWidget);
    expect(find.text('表达节奏'), findsOneWidget);
    expect(find.text('慢约会适配度'), findsOneWidget);
    expect(find.text('建议这样开始'), findsOneWidget);
    expect(find.text('先避免这样表达'), findsOneWidget);
    expect(find.text('轻追问建议 · 敬请期待'), findsOneWidget);
    expect(find.textContaining('不会写入资料'), findsOneWidget);
    expect(find.textContaining('不会改变匹配算法'), findsOneWidget);
    expect(find.textContaining('不会自动发送消息'), findsOneWidget);
  });
}
