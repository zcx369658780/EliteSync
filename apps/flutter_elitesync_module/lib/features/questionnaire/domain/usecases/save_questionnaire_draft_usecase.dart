import 'package:flutter_elitesync_module/features/questionnaire/domain/repository/questionnaire_repository.dart';

class SaveQuestionnaireDraftUseCase {
  const SaveQuestionnaireDraftUseCase(this._repository);

  final QuestionnaireRepository _repository;

  Future<void> call({
    required int currentIndex,
    required Map<int, int> answers,
  }) {
    return _repository.saveDraft(currentIndex: currentIndex, answers: answers);
  }
}
