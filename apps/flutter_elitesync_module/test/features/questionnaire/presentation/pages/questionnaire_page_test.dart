import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/telemetry/app_telemetry_service.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/question_item.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/providers/questionnaire_provider.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/pages/questionnaire_page.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/pages/questionnaire_result_page.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/state/questionnaire_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class FakeAppTelemetryService extends AppTelemetryService {
  FakeAppTelemetryService()
    : super(
        apiClient: ApiClient(
          dio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1')),
        ),
        appVersionProvider: () async => '0.04.04',
      );

  final List<Map<String, Object?>> calls = <Map<String, Object?>>[];

  @override
  Future<NetworkResult<Map<String, dynamic>>> postEvent(
    String path, {
    required String sourcePage,
    Object? body,
  }) async {
    calls.add({'path': path, 'sourcePage': sourcePage, 'body': body});
    return const NetworkSuccess(<String, dynamic>{});
  }
}

class FakeQuestionnaireNotifier extends QuestionnaireNotifier {
  FakeQuestionnaireNotifier(this._state);

  final QuestionnaireState _state;

  @override
  Future<QuestionnaireState> build() async => _state;
}

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

Widget _wrap(Widget child, {List<dynamic> overrides = const []}) {
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
      ...overrides.cast(),
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
  final baseState = QuestionnaireState(
    version: 'q_v2',
    bankVersion: 'qb_v1',
    attemptVersion: 'qa_v1',
    label: '非官方人格四维问卷',
    nonOfficialNotice: '仅用于产品内人格倾向参考，不代表官方 MBTI。',
    total: 1,
    estimatedMinutes: 6,
    questions: const [
      QuestionItem(
        id: 1,
        title: '面对冲突时，你更倾向？',
        options: ['先冷静再沟通'],
        version: 2,
      ),
    ],
    answers: const {1: 0},
    currentIndex: 0,
  );

  testWidgets('questionnaire page renders versioned meta and notice', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const QuestionnairePage(),
        overrides: [
          questionnaireProvider.overrideWith(
            () => FakeQuestionnaireNotifier(baseState),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('非官方人格四维问卷'), findsOneWidget);
    expect(find.textContaining('版本 q_v2 · 题库 qb_v1'), findsOneWidget);
    expect(find.textContaining('仅用于产品内人格倾向参考，不代表官方 MBTI。'), findsOneWidget);
    expect(find.text('面对冲突时，你更倾向？'), findsOneWidget);
  });

  testWidgets('questionnaire page records entry open telemetry', (
    tester,
  ) async {
    final telemetry = FakeAppTelemetryService();

    await tester.pumpWidget(
      _wrap(
        const QuestionnairePage(),
        overrides: [
          questionnaireProvider.overrideWith(
            () => FakeQuestionnaireNotifier(baseState),
          ),
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(
      telemetry.calls.any(
        (row) =>
            row['path'] == '/api/v1/telemetry/events' &&
            (row['body'] as Map<String, dynamic>)['event_name'] ==
                'questionnaire_entry_opened',
      ),
      isTrue,
    );
  });

  testWidgets('questionnaire result page renders version lineage', (
    tester,
  ) async {
    final telemetry = FakeAppTelemetryService();

    await tester.pumpWidget(
      _wrap(
        const QuestionnaireResultPage(),
        overrides: [
          questionnaireProvider.overrideWith(
            () => FakeQuestionnaireNotifier(
              baseState.copyWith(
                submitted: true,
                resultLabel: '倾向：attachment_security + communication_clarity',
                resultHighlights: const [
                  'attachment_security 56',
                  'communication_clarity 63',
                ],
                resultComplete: false,
              ),
            ),
          ),
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('性格提交成功'), findsOneWidget);
    expect(find.textContaining('q_v2 / qb_v1 / qa_v1'), findsOneWidget);
    expect(find.text('问卷画像'), findsOneWidget);
    expect(
      find.text('倾向：attachment_security + communication_clarity'),
      findsOneWidget,
    );
    expect(find.textContaining('attachment_security 56'), findsOneWidget);
    expect(find.textContaining('仅用于产品内人格倾向参考'), findsOneWidget);
    expect(find.text('查看历史记录'), findsOneWidget);
    expect(find.text('返回首页'), findsOneWidget);
    expect(find.text('重新作答'), findsOneWidget);
    expect(
      telemetry.calls.any(
        (row) =>
            row['path'] == '/api/v1/telemetry/events' &&
            (row['body'] as Map<String, dynamic>)['event_name'] ==
                'questionnaire_result_viewed',
      ),
      isTrue,
    );
  });
}
