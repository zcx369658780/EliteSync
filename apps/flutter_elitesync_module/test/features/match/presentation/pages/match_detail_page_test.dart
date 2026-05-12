import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_detail_entity.dart';
import 'package:flutter_elitesync_module/features/match/presentation/pages/match_detail_page.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class _FakeLocalStorageService extends LocalStorageService {
  final Map<String, Object?> _values = {};

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<String?> getString(String key) async {
    final value = _values[key];
    return value is String ? value : null;
  }

  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = _values[key];
    return value is Map<String, dynamic> ? value : null;
  }
}

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(
        const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'EliteSync Dev',
          apiBaseUrl: 'http://101.133.161.203',
          useMockData: true,
          useMockHome: true,
          useMockMatch: true,
          useMockChat: true,
        ),
      ),
      localStorageProvider.overrideWithValue(_FakeLocalStorageService()),
      matchDetailProvider.overrideWith(
        (ref) async => const MatchDetailEntity(
          reasons: ['匹配亮点｜沟通节奏：你们都适合先从轻松话题慢慢熟悉'],
          weights: {'沟通节奏': 40, '共同兴趣': 30, '慢约会': 30},
          moduleExplanations: [
            {
              'label': '共同兴趣',
              'score': 82,
              'reason': '资料里有可自然接住的共同话题。',
              'risk_level': 'low',
            },
            {
              'label': '沟通节奏',
              'score': 78,
              'reason': '适合先交换真实感受。',
              'risk_level': 'low',
            },
          ],
          explanationBlocks: [
            {
              'summary': '你们适合从轻松话题慢慢开始。',
              'advice': ['先确认彼此节奏，不急着推进关系。'],
            },
          ],
        ),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: child,
    ),
  );
}

void main() {
  testWidgets('match detail page renders 5.7 relationship explanation layer', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const MatchDetailPage()));
    await tester.pumpAndSettle();

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
    await tester.scrollUntilVisible(
      find.text('解释到聊天'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('解释到聊天'), findsOneWidget);
  });
}
