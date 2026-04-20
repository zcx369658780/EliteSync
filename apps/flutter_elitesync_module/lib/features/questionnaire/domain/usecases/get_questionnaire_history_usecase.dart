import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/questionnaire_attempt.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/repository/questionnaire_repository.dart';

class GetQuestionnaireHistoryUseCase {
  const GetQuestionnaireHistoryUseCase(this._repository);

  final QuestionnaireRepository _repository;

  Future<List<QuestionnaireAttempt>> call() {
    return _repository.fetchHistory();
  }
}
