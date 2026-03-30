import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/features/questionnaire/data/datasource/questionnaire_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/questionnaire/data/repository/questionnaire_repository_impl.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/repository/questionnaire_repository.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/usecases/get_questionnaire_usecase.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/usecases/save_questionnaire_draft_usecase.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/usecases/submit_questionnaire_usecase.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/state/questionnaire_state.dart';

final questionnaireRemoteDataSourceProvider =
    Provider<QuestionnaireRemoteDataSource>((ref) {
      final env = ref.watch(appEnvProvider);
      final apiClient = ref.watch(apiClientProvider);
      return QuestionnaireRemoteDataSource(
        apiClient: apiClient,
        useMockQuestionnaire: env.useMockQuestionnaire,
      );
    });

final questionnaireRepositoryProvider = Provider<QuestionnaireRepository>((
  ref,
) {
  return QuestionnaireRepositoryImpl(
    remoteDataSource: ref.watch(questionnaireRemoteDataSourceProvider),
  );
});

final getQuestionnaireUseCaseProvider = Provider<GetQuestionnaireUseCase>((
  ref,
) {
  return GetQuestionnaireUseCase(ref.watch(questionnaireRepositoryProvider));
});

final saveQuestionnaireDraftUseCaseProvider =
    Provider<SaveQuestionnaireDraftUseCase>((ref) {
      return SaveQuestionnaireDraftUseCase(
        ref.watch(questionnaireRepositoryProvider),
      );
    });

final submitQuestionnaireUseCaseProvider = Provider<SubmitQuestionnaireUseCase>(
  (ref) {
    return SubmitQuestionnaireUseCase(
      ref.watch(questionnaireRepositoryProvider),
    );
  },
);

class QuestionnaireNotifier extends AsyncNotifier<QuestionnaireState> {
  QuestionnaireState? get _current => state.asData?.value;

  Map<int, int> _parseAnswers(dynamic raw) {
    if (raw is! Map) return const <int, int>{};
    final mapped = <int, int>{};
    raw.forEach((key, value) {
      final k = int.tryParse(key.toString());
      final v = int.tryParse(value.toString());
      if (k != null && v != null) {
        mapped[k] = v;
      }
    });
    return mapped;
  }

  Future<void> _persistLocalDraft(QuestionnaireState state) async {
    await ref.read(localStorageProvider).setJson(CacheKeys.questionnaireDraft, {
      'version': state.version,
      'current_index': state.currentIndex,
      'answers': state.answers.map((k, v) => MapEntry(k.toString(), v)),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _clearLocalDraft() async {
    await ref.read(localStorageProvider).remove(CacheKeys.questionnaireDraft);
  }

  @override
  Future<QuestionnaireState> build() async {
    final bundle = await ref.read(getQuestionnaireUseCaseProvider).call();
    var base = QuestionnaireState(
      version: bundle.version,
      total: bundle.total,
      estimatedMinutes: bundle.estimatedMinutes,
      questions: bundle.questions,
    );

    final draft = await ref
        .read(localStorageProvider)
        .getJson(CacheKeys.questionnaireDraft);
    if (draft != null) {
      final answers = _parseAnswers(draft['answers']);
      final rawIndex =
          int.tryParse((draft['current_index'] ?? 0).toString()) ?? 0;
      final maxIndex = (bundle.questions.length - 1).clamp(0, 1000000).toInt();
      final safeIndex = rawIndex.clamp(0, maxIndex).toInt();
      base = base.copyWith(answers: answers, currentIndex: safeIndex);
    }

    return base;
  }

  void selectOption(int optionIndex) {
    final current = _current;
    if (current == null) return;
    final question = current.currentQuestion;
    if (question == null) return;

    final nextAnswers = Map<int, int>.from(current.answers)
      ..[question.id] = optionIndex;

    state = AsyncData(
      current.copyWith(
        answers: nextAnswers,
        clearError: true,
        clearFeedback: true,
      ),
    );
    final fresh = _current;
    if (fresh != null) {
      unawaited(_persistLocalDraft(fresh));
    }
  }

  Future<void> selectOptionAndProceed(int optionIndex) async {
    final before = _current;
    if (before == null) return;

    selectOption(optionIndex);

    final after = _current;
    if (after == null) return;

    if (after.isLast) {
      await submit();
      return;
    }

    next();
  }

  void next() {
    final current = _current;
    if (current == null || current.questions.isEmpty) return;
    if (!current.isLast) {
      state = AsyncData(
        current.copyWith(
          currentIndex: current.currentIndex + 1,
          clearError: true,
          clearFeedback: true,
        ),
      );
      final fresh = _current;
      if (fresh != null) {
        unawaited(_persistLocalDraft(fresh));
      }
    }
  }

  void previous() {
    final current = _current;
    if (current == null || current.questions.isEmpty) return;
    if (!current.isFirst) {
      state = AsyncData(
        current.copyWith(
          currentIndex: current.currentIndex - 1,
          clearError: true,
          clearFeedback: true,
        ),
      );
      final fresh = _current;
      if (fresh != null) {
        unawaited(_persistLocalDraft(fresh));
      }
    }
  }

  Future<void> saveDraft() async {
    final current = _current;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        isSavingDraft: true,
        clearError: true,
        clearFeedback: true,
      ),
    );
    try {
      await ref
          .read(saveQuestionnaireDraftUseCaseProvider)
          .call(currentIndex: current.currentIndex, answers: current.answers);
      final fresh = _current ?? current;
      await _persistLocalDraft(fresh);
      state = AsyncData(
        fresh.copyWith(isSavingDraft: false, feedbackMessage: '草稿已保存'),
      );
    } catch (e) {
      final fresh = _current ?? current;
      state = AsyncData(
        fresh.copyWith(isSavingDraft: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> submit() async {
    final current = _current;
    if (current == null) return;
    if (current.questions.isEmpty) return;
    if (current.answers.length < current.questions.length) {
      state = AsyncData(current.copyWith(errorMessage: '请先完成全部题目再提交'));
      return;
    }

    state = AsyncData(
      current.copyWith(
        isSubmitting: true,
        clearError: true,
        clearFeedback: true,
      ),
    );

    try {
      await ref.read(submitQuestionnaireUseCaseProvider).call(current.answers);
      final fresh = _current ?? current;
      await _clearLocalDraft();
      state = AsyncData(
        fresh.copyWith(
          isSubmitting: false,
          submitted: true,
          feedbackMessage: '问卷提交成功',
        ),
      );
    } catch (e) {
      final fresh = _current ?? current;
      state = AsyncData(
        fresh.copyWith(isSubmitting: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> restart() async {
    final current = _current;
    if (current == null) return;
    await _clearLocalDraft();
    state = AsyncData(
      current.copyWith(
        currentIndex: 0,
        answers: const {},
        submitted: false,
        clearError: true,
        clearFeedback: true,
      ),
    );
  }
}

final questionnaireProvider =
    AsyncNotifierProvider<QuestionnaireNotifier, QuestionnaireState>(
      QuestionnaireNotifier.new,
    );
