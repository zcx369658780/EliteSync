import 'package:flutter_elitesync_module/core/error/app_exception.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/questionnaire/data/dto/questionnaire_bundle_dto.dart';
import 'package:flutter_elitesync_module/mocks/mock_data/questionnaire_mock.dart';

class QuestionnaireRemoteDataSource {
  const QuestionnaireRemoteDataSource({
    required ApiClient apiClient,
    required bool useMockQuestionnaire,
  }) : _apiClient = apiClient,
       _useMockQuestionnaire = useMockQuestionnaire;

  final ApiClient _apiClient;
  final bool _useMockQuestionnaire;

  Future<QuestionnaireBundleDto> fetchQuestionnaire() async {
    if (_useMockQuestionnaire) {
      return QuestionnaireBundleDto.fromJson({
        'meta': QuestionnaireMock.meta,
        'questions': QuestionnaireMock.questions,
      });
    }

    final result = await _apiClient.get('/api/v1/questionnaire/questions');
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return QuestionnaireBundleDto.fromJson(result.data);
    }

    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw ValidationException(
      failure.message,
      code: failure.code ?? 'QUESTIONNAIRE_FETCH_FAILED',
    );
  }

  Future<void> saveDraft({
    required int currentIndex,
    required Map<int, int> answers,
  }) async {
    if (_useMockQuestionnaire) {
      return;
    }
    // Backend draft endpoint has been removed in unified questionnaire API.
    // Keep local draft only to avoid noisy 404/network errors.
    return;
  }

  Future<void> submitAnswers(Map<int, int> answers) async {
    if (_useMockQuestionnaire) {
      return;
    }

    final normalizedAnswers = answers.entries
        .map(
          (entry) => <String, dynamic>{
            'question_id': entry.key,
            // backend accepts legacy "answer" string
            'answer': entry.value.toString(),
            'importance': 2,
            'version': 1,
          },
        )
        .toList();

    final result = await _apiClient.post(
      '/api/v1/questionnaire/answers',
      body: {'answers': normalizedAnswers},
    );

    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return;
    }

    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw ValidationException(
      failure.message,
      code: failure.code ?? 'QUESTIONNAIRE_SUBMIT_FAILED',
    );
  }
}
