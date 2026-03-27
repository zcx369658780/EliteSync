import 'package:flutter_elitesync/features/questionnaire/domain/entities/questionnaire_bundle.dart';

abstract class QuestionnaireRepository {
  Future<QuestionnaireBundle> fetchQuestionnaire();

  Future<void> saveDraft({
    required int currentIndex,
    required Map<int, int> answers,
  });

  Future<void> submitAnswers(Map<int, int> answers);
}
