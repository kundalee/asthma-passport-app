class MasterOption {
  final int id;
  final String code;
  final String text;

  const MasterOption({
    required this.id,
    required this.code,
    required this.text,
  });

  factory MasterOption.fromJson(Map<String, dynamic> json) {
    return MasterOption(
      id: json['id'] as int,
      code: json['option_code'] ?? '',
      text: json['option_text'] ?? '',
    );
  }
}

class MasterQuestion {
  final int id;
  final String level;
  final String text;
  final List<MasterOption> options;

  const MasterQuestion({
    required this.id,
    required this.level,
    required this.text,
    required this.options,
  });

  factory MasterQuestion.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List<dynamic>? ?? [])
        .map((o) => MasterOption.fromJson(o as Map<String, dynamic>))
        .toList();
    return MasterQuestion(
      id: json['id'] as int,
      level: json['level'] ?? '',
      text: json['question_text'] ?? '',
      options: options,
    );
  }
}

class MasterQuiz {
  final int totalCount;
  final List<MasterQuestion> questions;

  const MasterQuiz({
    required this.totalCount,
    required this.questions,
  });

  factory MasterQuiz.fromJson(Map<String, dynamic> json) {
    final questions = (json['questions'] as List<dynamic>? ?? [])
        .map((q) => MasterQuestion.fromJson(q as Map<String, dynamic>))
        .toList();
    return MasterQuiz(
      totalCount: (json['total_count'] as num?)?.toInt() ?? questions.length,
      questions: questions,
    );
  }
}

class MasterAnswerDetail {
  final int questionId;
  final String userChoice;
  final String correctAnswer;
  final bool isCorrect;

  const MasterAnswerDetail({
    required this.questionId,
    required this.userChoice,
    required this.correctAnswer,
    required this.isCorrect,
  });

  factory MasterAnswerDetail.fromJson(Map<String, dynamic> json) {
    return MasterAnswerDetail(
      questionId: json['question_id'] as int,
      userChoice: json['user_choice'] ?? '',
      correctAnswer: json['correct_answer'] ?? '',
      isCorrect: json['is_correct'] ?? false,
    );
  }
}

class MasterQuizResult {
  final int finalScore;
  final int correctAnswersCount;
  final String summaryTitle;
  final String summarySubtitle;
  final List<MasterAnswerDetail> details;

  const MasterQuizResult({
    required this.finalScore,
    required this.correctAnswersCount,
    required this.summaryTitle,
    required this.summarySubtitle,
    required this.details,
  });

  factory MasterQuizResult.fromJson(Map<String, dynamic> json) {
    final details = (json['details'] as List<dynamic>? ?? [])
        .map((d) => MasterAnswerDetail.fromJson(d as Map<String, dynamic>))
        .toList();
    return MasterQuizResult(
      finalScore: (json['final_score'] as num?)?.toInt() ?? 0,
      correctAnswersCount: (json['correct_answers_count'] as num?)?.toInt() ?? 0,
      summaryTitle: json['summary_title'] ?? '',
      summarySubtitle: json['summary_subtitle'] ?? '',
      details: details,
    );
  }
}
