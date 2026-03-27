import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/question_item.dart';

class QuestionnaireState {
  const QuestionnaireState({
    this.version = 'q_v1',
    this.total = 0,
    this.estimatedMinutes = 0,
    this.questions = const [],
    this.answers = const {},
    this.currentIndex = 0,
    this.isSavingDraft = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.feedbackMessage,
    this.submitted = false,
  });

  final String version;
  final int total;
  final int estimatedMinutes;
  final List<QuestionItem> questions;
  final Map<int, int> answers;
  final int currentIndex;
  final bool isSavingDraft;
  final bool isSubmitting;
  final String? errorMessage;
  final String? feedbackMessage;
  final bool submitted;

  bool get hasQuestions => questions.isNotEmpty;
  bool get isLast => currentIndex >= questions.length - 1;
  bool get isFirst => currentIndex == 0;
  int get answeredCount => answers.length;
  double get progress =>
      questions.isEmpty ? 0 : answeredCount / questions.length;

  QuestionItem? get currentQuestion {
    if (questions.isEmpty) return null;
    if (currentIndex < 0 || currentIndex >= questions.length) return null;
    return questions[currentIndex];
  }

  int? selectedOptionForCurrent() {
    final q = currentQuestion;
    if (q == null) return null;
    return answers[q.id];
  }

  QuestionnaireState copyWith({
    String? version,
    int? total,
    int? estimatedMinutes,
    List<QuestionItem>? questions,
    Map<int, int>? answers,
    int? currentIndex,
    bool? isSavingDraft,
    bool? isSubmitting,
    String? errorMessage,
    String? feedbackMessage,
    bool? submitted,
    bool clearError = false,
    bool clearFeedback = false,
  }) {
    return QuestionnaireState(
      version: version ?? this.version,
      total: total ?? this.total,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      currentIndex: currentIndex ?? this.currentIndex,
      isSavingDraft: isSavingDraft ?? this.isSavingDraft,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      feedbackMessage: clearFeedback
          ? null
          : (feedbackMessage ?? this.feedbackMessage),
      submitted: submitted ?? this.submitted,
    );
  }
}
