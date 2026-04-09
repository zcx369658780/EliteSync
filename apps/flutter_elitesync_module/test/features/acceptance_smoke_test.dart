import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_highlight_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_result_entity.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/chat_room_page.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/conversation_list_page.dart';
import 'package:flutter_elitesync_module/features/home/presentation/pages/home_page.dart';
import 'package:flutter_elitesync_module/features/match/presentation/pages/match_result_page.dart';
import 'package:flutter_elitesync_module/features/match/presentation/state/match_result_ui_state.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class FakeLocalStorageService extends LocalStorageService {
  FakeLocalStorageService([Map<String, Object?>? initialValues]) {
    _values.addAll(initialValues ?? const {});
  }

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
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool?> getBool(String key) async {
    final value = _values[key];
    return value is bool ? value : null;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<int?> getInt(String key) async {
    final value = _values[key];
    return value is int ? value : null;
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

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }
}

Widget _wrap(Widget child, {Iterable<dynamic> overrides = const []}) {
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
      localStorageProvider.overrideWithValue(FakeLocalStorageService()),
      ...overrides,
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
  testWidgets('home page renders mock hero and feed', (tester) async {
    await tester.pumpWidget(_wrap(const HomePage()));
    await tester.pumpAndSettle();

    expect(find.text('本周关系进展'), findsOneWidget);
    expect(find.text('先完成问卷，更快看到合适的人'), findsOneWidget);
    expect(find.text('继续完善问卷'), findsWidgets);
  });

  testWidgets('match result page renders explanation and actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const MatchResultPage(),
        overrides: [
          matchResultProvider.overrideWith(
            (ref) async => const MatchResultUiState(
              data: MatchResultEntity(
                headline: '你们在沟通与情绪节奏上较契合',
                score: 86,
                tags: ['同城', '高匹配', '节奏接近'],
                highlights: [
                  MatchHighlightEntity(
                    title: '依恋安全感',
                    value: 51,
                    desc: '都倾向稳定关系',
                  ),
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
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('你们在沟通与情绪节奏上较契合'), findsOneWidget);
    expect(find.text('解释阅读顺序'), findsOneWidget);
    expect(find.text('进入首聊'), findsWidgets);
    expect(find.text('查看完整解释'), findsWidgets);
  });

  testWidgets('conversation list page renders mock conversations', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const ConversationListPage()));
    await tester.pumpAndSettle();

    expect(find.text('当前会话 2 条'), findsOneWidget);
    expect(find.text('晨雾'), findsOneWidget);
    expect(find.text('九紫瑶瑶'), findsOneWidget);
  });

  testWidgets('chat room page renders mock thread and safety menu', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const ChatRoomPage(conversationId: '1', title: '晨雾')),
    );
    await tester.pumpAndSettle();

    expect(find.text('慢慢聊'), findsOneWidget);
    expect(find.text('你好呀，看到你也喜欢看展。'), findsWidgets);

    await tester.tap(find.byTooltip('安全'));
    await tester.pumpAndSettle();

    expect(find.text('举报 / 拉黑'), findsOneWidget);
  });
}
