import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/telemetry/app_telemetry_service.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/questionnaire_attempt.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/pages/questionnaire_history_page.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/providers/questionnaire_provider.dart';

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

Widget _wrap(Widget child, {List<dynamic> overrides = const []}) {
  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: child,
    ),
  );
}

void main() {
  testWidgets('questionnaire history page renders attempt list and restart', (
    tester,
  ) async {
    final telemetry = FakeAppTelemetryService();

    await tester.pumpWidget(
      _wrap(
        const QuestionnaireHistoryPage(),
        overrides: [
          questionnaireHistoryProvider.overrideWith(
            (ref) async => [
              QuestionnaireAttempt(
                id: 101,
                questionnaireVersion: 'q_v2',
                bankVersion: 'qb_v1',
                attemptVersion: 'qa_v1',
                answersCount: 2,
                totalCount: 20,
                resultLabel: '倾向：attachment_security + communication_clarity',
                resultHighlights: const [
                  'attachment_security 56',
                  'communication_clarity 63',
                ],
                profileComplete: false,
                completedAt: DateTime(2026, 4, 18, 9, 10),
              ),
            ],
          ),
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('问卷历史'), findsWidgets);
    expect(find.textContaining('共 1 条提交记录'), findsOneWidget);
    expect(
      find.textContaining('attachment_security + communication_clarity'),
      findsOneWidget,
    );
    expect(find.text('重新作答'), findsOneWidget);
    expect(
      telemetry.calls.any(
        (row) =>
            row['path'] == '/api/v1/telemetry/events' &&
            (row['body'] as Map<String, dynamic>)['event_name'] ==
                'questionnaire_history_opened',
      ),
      isTrue,
    );
  });
}
