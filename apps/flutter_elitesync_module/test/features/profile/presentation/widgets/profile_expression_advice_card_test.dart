import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/profile_expression_advice_card.dart';

void main() {
  testWidgets('ProfileExpressionAdviceCard renders 5.8 display-only contract', (
    tester,
  ) async {
    const summary = ProfileSummaryEntity(
      nickname: 'test1',
      birthday: '1998-01-01',
      birthTime: '10:30',
      birthPlace: '北京动物园',
      birthLat: 39.947735,
      birthLng: 116.343376,
      city: '南阳',
      target: 'dating',
      verified: true,
      moderationStatus: 'normal',
      moderationNote: null,
      completion: 0.76,
      tags: ['生日已保存', '婚恋目标已保存', '资料已同步'],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: ProfileExpressionAdviceCard(summary: summary),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('我的慢约会表达建议'), findsOneWidget);
    expect(find.text('真实感'), findsOneWidget);
    expect(find.text('表达清晰度'), findsOneWidget);
    expect(find.text('慢约会适配度'), findsOneWidget);
    expect(find.text('开场友好度'), findsOneWidget);
    expect(find.text('资料展示建议'), findsOneWidget);
    expect(find.text('慢约会友好表达'), findsOneWidget);
    expect(find.text('可以补充什么'), findsOneWidget);
    expect(find.text('帮我整理一句表达 · 敬请期待'), findsOneWidget);
    expect(
      find.text('以上内容仅为自我表达参考，不会写入资料，不会改变星盘或匹配算法，也不会自动修改个人资料。'),
      findsOneWidget,
    );
  });
}
