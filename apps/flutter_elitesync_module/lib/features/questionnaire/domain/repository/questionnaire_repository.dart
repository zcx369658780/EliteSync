import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/questionnaire_bundle.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/questionnaire_attempt.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/questionnaire_submission_result.dart';

abstract class QuestionnaireRepository {
  Future<QuestionnaireBundle> fetchQuestionnaire();

  Future<void> saveDraft({
    required int currentIndex,
    required Map<int, int> answers,
  });

  Future<QuestionnaireSubmissionResult> submitAnswers(Map<int, int> answers);

  Future<List<QuestionnaireAttempt>> fetchHistory();
}
