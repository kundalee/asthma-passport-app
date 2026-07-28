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

class SaveActResult {
  final int id;
  final int totalScore;
  // Zone classification, same 0/1/2 (green/yellow/red) scale as peak flow's
  // status_color (adult gets all three; child only ever 0 or 1).
  final int? statusColor;
  // Ready-to-display advice message from the backend.
  final String? statusSummary;

  const SaveActResult({
    required this.id,
    required this.totalScore,
    required this.statusColor,
    required this.statusSummary,
  });

  factory SaveActResult.fromJson(Map<String, dynamic> json) {
    return SaveActResult(
      id: json['id'] as int,
      totalScore: (json['total_score'] as num?)?.toInt() ?? 0,
      statusColor: (json['status_color'] as num?)?.toInt(),
      statusSummary: json['status_summary']?.toString(),
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
      statusSummary: json['status_summary']?.toString(),
      questions: questions,
    );
  }
}
