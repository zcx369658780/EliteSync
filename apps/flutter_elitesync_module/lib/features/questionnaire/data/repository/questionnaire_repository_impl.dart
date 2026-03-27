import 'package:flutter_elitesync_module/features/questionnaire/data/datasource/questionnaire_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/question_item.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/questionnaire_bundle.dart';
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
      total: dto.total,
      estimatedMinutes: dto.estimatedMinutes,
      questions: dto.questions
          .map(
            (q) => QuestionItem(id: q.id, title: q.title, options: q.options),
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
  Future<void> submitAnswers(Map<int, int> answers) {
    return _remoteDataSource.submitAnswers(answers);
  }
}
