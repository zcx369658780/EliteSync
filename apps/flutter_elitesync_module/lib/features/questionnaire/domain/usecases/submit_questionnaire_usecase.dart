import 'package:flutter_elitesync_module/features/questionnaire/domain/repository/questionnaire_repository.dart';

class SubmitQuestionnaireUseCase {
  const SubmitQuestionnaireUseCase(this._repository);

  final QuestionnaireRepository _repository;

  Future<void> call(Map<int, int> answers) {
    return _repository.submitAnswers(answers);
  }
}
