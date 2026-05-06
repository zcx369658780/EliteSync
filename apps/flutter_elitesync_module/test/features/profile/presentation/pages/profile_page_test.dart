import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/profile_ui_state.dart';

void main() {
  testWidgets('ProfilePage shows 5.2 operating hub and expression layers', (
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
      completion: 0.5,
      tags: ['生日已保存', '出生时间已保存', '性别已保存', '婚恋目标已保存', '资料已同步'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileProvider.overrideWith(
            (ref) async => const ProfileUiState(summary: summary),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: ProfilePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('个人经营区'),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text('个人经营区'), findsOneWidget);
    expect(find.text('编辑资料'), findsWidgets);
    expect(find.text('看看状态'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('AI 助理 / 展示建议'),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text('AI 助理 / 展示建议'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('标签表达体系'),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text('标签表达体系'), findsOneWidget);
    expect(find.text('关系风格'), findsOneWidget);
    expect(find.text('资料真值提示'), findsOneWidget);
    expect(find.text('慢约会友好表达'), findsOneWidget);
    expect(find.text('生日已保存'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('AI 草稿助手'),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text('AI 草稿助手'), findsOneWidget);
    expect(find.text('帮我写一句自我介绍'), findsOneWidget);
    expect(find.text('帮我写一句问候'), findsOneWidget);
    expect(find.text('整理我的亮点'), findsOneWidget);
    await tester.tap(find.text('帮我写一句问候'));
    await tester.pumpAndSettle();

    expect(
      find.text('看到你的资料里也有让我好奇的部分。我们可以先从一个轻松的问题开始聊，不急着给彼此贴标签。'),
      findsOneWidget,
    );
    expect(find.text('这是本地草稿建议，不会自动发布、自动发送或回写资料。'), findsOneWidget);

    await tester.tap(find.text('知道了'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('轻语音表达'),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text('轻语音表达'), findsOneWidget);
    expect(find.text('声音名片候选位'), findsOneWidget);
    await tester.tap(find.text('录制前说明'));
    await tester.pumpAndSettle();

    expect(find.text('声音名片仍是候选位'), findsOneWidget);
    expect(
      find.text('5.2 只提供轻语音表达入口与录制前提示，不改 RTC、LiveKit 或通话状态机。真正录制前会再确认权限。'),
      findsOneWidget,
    );

    await tester.tap(find.text('知道了'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('个人空间外观'),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text('个人空间外观'), findsOneWidget);
    expect(find.text('展示封面：温柔清爽'), findsOneWidget);
  });
}
