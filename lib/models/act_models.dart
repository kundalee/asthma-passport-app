class ActOption {
  final int id;
  final int order;
  final String text;
  final int score;

  const ActOption({
    required this.id,
    required this.order,
    required this.text,
    required this.score,
  });

  factory ActOption.fromJson(Map<String, dynamic> json) {
    return ActOption(
      id: json['id'] as int,
      order: json['order'] as int,
      text: json['option_text'] ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
    );
  }
}

class ActQuestion {
  final int id;
  final int order;
  final String text;
  final List<ActOption> options;
  final int? selectedOptionId;

  const ActQuestion({
    required this.id,
    required this.order,
    required this.text,
    required this.options,
    required this.selectedOptionId,
  });

  factory ActQuestion.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List<dynamic>? ?? [])
        .map((o) => ActOption.fromJson(o as Map<String, dynamic>))
        .toList();
    return ActQuestion(
      id: json['id'] as int,
      order: json['order'] as int,
      text: json['question_text'] ?? '',
      options: options,
      selectedOptionId: json['selected_option_id'] as int?,
    );
  }
}

class ActStatus {
  final String targetGroup;
  final bool isCompleted;
  final int? totalScore;
  final String? statusSummary;
  final List<ActQuestion> questions;

  const ActStatus({
    required this.targetGroup,
    required this.isCompleted,
    required this.totalScore,
    required this.statusSummary,
    required this.questions,
  });

  factory ActStatus.fromJson(Map<String, dynamic> json) {
    final questions = (json['questions'] as List<dynamic>? ?? [])
        .map((q) => ActQuestion.fromJson(q as Map<String, dynamic>))
        .toList();
    return ActStatus(
      targetGroup: json['target_group'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      totalScore: (json['total_score'] as num?)?.toInt(),
      statusSummary: json['status_summary'] as String?,
      questions: questions,
    );
  }
}
