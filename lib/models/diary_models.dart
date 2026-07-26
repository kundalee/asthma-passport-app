class DiaryOption {
  final int id;
  final int order;
  final String text;
  final int score;

  const DiaryOption({
    required this.id,
    required this.order,
    required this.text,
    required this.score,
  });

  factory DiaryOption.fromJson(Map<String, dynamic> json) {
    return DiaryOption(
      id: json['id'] as int,
      order: json['order'] as int,
      text: json['option_text'] ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
    );
  }
}

class DiaryQuestion {
  final int id;
  final int order;
  final String text;
  final List<DiaryOption> options;
  final int? selectedOptionId;

  const DiaryQuestion({
    required this.id,
    required this.order,
    required this.text,
    required this.options,
    required this.selectedOptionId,
  });

  // The survey's last question is yes/no (2 options); the rest are a 5-point scale.
  bool get isYesNo => options.length == 2;

  factory DiaryQuestion.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List<dynamic>? ?? [])
        .map((o) => DiaryOption.fromJson(o as Map<String, dynamic>))
        .toList();
    return DiaryQuestion(
      id: json['id'] as int,
      order: json['order'] as int,
      text: json['question_text'] ?? '',
      options: options,
      selectedOptionId: json['selected_option_id'] as int?,
    );
  }
}

class DiaryStatus {
  final bool isCompleted;
  final int? totalScore;
  // Ready-to-display advice message from the backend (e.g. "症狀控制良好，請繼續維持").
  final String? statusSummary;
  final List<DiaryQuestion> questions;

  const DiaryStatus({
    required this.isCompleted,
    required this.totalScore,
    required this.statusSummary,
    required this.questions,
  });

  factory DiaryStatus.fromJson(Map<String, dynamic> json) {
    final questions = (json['questions'] as List<dynamic>? ?? [])
        .map((q) => DiaryQuestion.fromJson(q as Map<String, dynamic>))
        .toList();
    return DiaryStatus(
      isCompleted: json['is_completed'] ?? false,
      totalScore: (json['total_score'] as num?)?.toInt(),
      statusSummary: json['status_summary']?.toString(),
      questions: questions,
    );
  }
}

class DiarySaveResult {
  final int id;
  final int totalScore;
  final String? statusSummary;

  const DiarySaveResult({
    required this.id,
    required this.totalScore,
    required this.statusSummary,
  });

  factory DiarySaveResult.fromJson(Map<String, dynamic> json) {
    return DiarySaveResult(
      id: json['id'] as int,
      totalScore: (json['total_score'] as num?)?.toInt() ?? 0,
      statusSummary: json['status_summary']?.toString(),
    );
  }
}
