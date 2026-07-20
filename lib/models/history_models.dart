// Shared by /diary/history and /act/history, which return the same shape.
class HistoryDay {
  final DateTime date;
  final bool isCompleted;
  final int totalScore;
  final int? statusSummary;

  const HistoryDay({
    required this.date,
    required this.isCompleted,
    required this.totalScore,
    required this.statusSummary,
  });

  factory HistoryDay.fromJson(Map<String, dynamic> json) {
    return HistoryDay(
      date: DateTime.parse(json['date'] as String),
      isCompleted: json['is_completed'] ?? false,
      totalScore: (json['total_score'] as num?)?.toInt() ?? 0,
      statusSummary: (json['status_summary'] as num?)?.toInt(),
    );
  }
}

// Shared by /diary/available-months, /pefr/available-months and
// /act/available-months.
class AvailableMonth {
  final int year;
  final int month;

  const AvailableMonth({required this.year, required this.month});

  String get label => '$year/${month.toString().padLeft(2, '0')}';

  factory AvailableMonth.fromJson(Map<String, dynamic> json) {
    return AvailableMonth(
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
    );
  }
}
