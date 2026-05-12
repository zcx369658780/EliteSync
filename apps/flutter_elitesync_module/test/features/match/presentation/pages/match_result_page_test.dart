import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_highlight_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_result_entity.dart';
import 'package:flutter_elitesync_module/features/match/presentation/pages/match_result_page.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/features/match/presentation/state/match_result_ui_state.dart';
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
      matchResultProvider.overrideWith(
        (ref) async => const MatchResultUiState(
          data: MatchResultEntity(
            headline: '你们在沟通与情绪节奏上较契合',
            score: 86,
            tags: ['同城', '高匹配', '节奏接近'],
            highlights: [
              MatchHighlightEntity(title: '依恋安全感', value: 51, desc: '都倾向稳定关系'),
              MatchHighlightEntity(
                title: '冲突修复倾向',
                value: 48,
                desc: '冲突后愿意重建沟通',
              ),
            ],
            matchId: 1703,
            partnerId: 42,
          ),
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
  testWidgets('match result page renders 5.7 relationship explanation layer', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const MatchResultPage()));
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
      find.text('进入首聊'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('进入首聊'), findsWidgets);
    expect(find.text('查看完整解释'), findsWidgets);
  });
}
