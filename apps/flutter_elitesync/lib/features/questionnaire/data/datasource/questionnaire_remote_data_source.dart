import 'package:flutter_elitesync/core/error/app_exception.dart';
import 'package:flutter_elitesync/core/network/api_client.dart';
import 'package:flutter_elitesync/core/network/network_result.dart';
import 'package:flutter_elitesync/features/questionnaire/data/dto/questionnaire_bundle_dto.dart';
import 'package:flutter_elitesync/mocks/mock_data/questionnaire_mock.dart';

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

    final result = await _apiClient.post(
      '/api/v1/questionnaire/draft',
      body: {
        'current_index': currentIndex,
        'answers': answers.map((k, v) => MapEntry(k.toString(), v)),
      },
    );

    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return;
    }

    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw ValidationException(
      failure.message,
      code: failure.code ?? 'QUESTIONNAIRE_DRAFT_FAILED',
    );
  }

  Future<void> submitAnswers(Map<int, int> answers) async {
    if (_useMockQuestionnaire) {
      return;
    }

    final result = await _apiClient.post(
      '/api/v1/questionnaire/submit',
      body: {'answers': answers.map((k, v) => MapEntry(k.toString(), v))},
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
