import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/questionnaire_bundle.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/repository/questionnaire_repository.dart';

class GetQuestionnaireUseCase {
  const GetQuestionnaireUseCase(this._repository);

  final QuestionnaireRepository _repository;

  Future<QuestionnaireBundle> call() {
    return _repository.fetchQuestionnaire();
  }
}
