import 'package:flutter_elitesync_module/features/questionnaire/data/datasource/questionnaire_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/questionnaire/data/dto/questionnaire_attempt_dto.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/question_item.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/questionnaire_attempt.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/questionnaire_bundle.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/questionnaire_submission_result.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/repository/questionnaire_repository.dart';

class QuestionnaireRepositoryImpl implements QuestionnaireRepository {
  const QuestionnaireRepositoryImpl({
    required QuestionnaireRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final QuestionnaireRemoteDataSource _remoteDataSource;

  @override
  Future<QuestionnaireBundle> fetchQuestionnaire() async {
    final dto = await _remoteDataSource.fetchQuestionnaire();
    return QuestionnaireBundle(
      version: dto.version,
      bankVersion: dto.bankVersion,
      attemptVersion: dto.attemptVersion,
      label: dto.label,
      nonOfficialNotice: dto.nonOfficialNotice,
      total: dto.total,
      estimatedMinutes: dto.estimatedMinutes,
      questions: dto.questions
          .map(
            (q) => QuestionItem(
              id: q.id,
              title: q.title,
              options: q.options,
              version: q.version,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<void> saveDraft({
    required int currentIndex,
    required Map<int, int> answers,
  }) {
    return _remoteDataSource.saveDraft(
      currentIndex: currentIndex,
      answers: answers,
    );
  }

  @override
  Future<QuestionnaireSubmissionResult> submitAnswers(
    Map<int, int> answers,
  ) async {
    final dto = await _remoteDataSource.submitAnswers(answers);
    return QuestionnaireSubmissionResult(
      questionnaireVersion: dto.questionnaireVersion,
      bankVersion: dto.bankVersion,
      attemptVersion: dto.attemptVersion,
      profileLabel: dto.profileLabel,
      profileHighlights: dto.profileHighlights,
      profileComplete: dto.profileComplete,
    );
  }

  @override
  Future<List<QuestionnaireAttempt>> fetchHistory() async {
    final items = await _remoteDataSource.fetchHistory();
    return items.map(_mapAttempt).toList();
  }

  QuestionnaireAttempt _mapAttempt(QuestionnaireAttemptDto dto) {
    return QuestionnaireAttempt(
      id: dto.id,
      questionnaireVersion: dto.questionnaireVersion,
      bankVersion: dto.bankVersion,
      attemptVersion: dto.attemptVersion,
      answersCount: dto.answersCount,
      totalCount: dto.totalCount,
      resultLabel: dto.resultLabel,
      resultHighlights: dto.resultHighlights,
      profileComplete: dto.profileComplete,
      completedAt: DateTime.tryParse(dto.completedAt),
    );
  }
}
