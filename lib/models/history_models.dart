// /diary/history: one entry per day of the target month.
class HistoryDay {
  final DateTime date;
  final bool isCompleted;

  const HistoryDay({
    required this.date,
    required this.isCompleted,
  });

  factory HistoryDay.fromJson(Map<String, dynamic> json) {
    return HistoryDay(
      date: _parseSlashDate(json['record_date'] as String),
      isCompleted: json['is_completed'] ?? false,
    );
  }
}

// "YYYY/MM/DD" -> DateTime; DateTime.parse requires dashes, and the backend
// uses slashes here.
DateTime _parseSlashDate(String value) {
  final parts = value.split('/').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

// /act/history: one entry per month across a rolling window (ACT is done at
// most once a month), unlike /diary/history's one-entry-per-day.
class ActMonthSummary {
  final String month; // "YYYY-MM"
  final DateTime? recordDate;
  final bool isCompleted;
  final int? totalScore;

  const ActMonthSummary({
    required this.month,
    required this.recordDate,
    required this.isCompleted,
    required this.totalScore,
  });

  factory ActMonthSummary.fromJson(Map<String, dynamic> json) {
    final recordDate = json['record_date'] as String?;
    return ActMonthSummary(
      month: json['month'] ?? '',
      recordDate: recordDate == null ? null : _parseSlashDate(recordDate),
      isCompleted: json['is_completed'] ?? false,
      totalScore: (json['total_score'] as num?)?.toInt(),
    );
  }
}

// /pefr/history: one entry per day of the target month. Unlike /pefr/load,
// history doesn't include the measured value or status_color, just
// per-session completion.
class PeakFlowHistoryDay {
  final DateTime date;
  final bool morningCompleted;
  final bool eveningCompleted;

  const PeakFlowHistoryDay({
    required this.date,
    required this.morningCompleted,
    required this.eveningCompleted,
  });

  factory PeakFlowHistoryDay.fromJson(Map<String, dynamic> json) {
    return PeakFlowHistoryDay(
      date: _parseSlashDate(json['record_date'] as String),
      morningCompleted: json['morning_completed'] ?? false,
      eveningCompleted: json['evening_completed'] ?? false,
    );
  }
}

// /summary/dashboard: pre-aggregated data for the 綜合資料 tab, replacing
// what used to be computed locally from /diary/history, /pefr/history and
// /act/history.
class DashboardSummary {
  final int days;
  final double diaryAvg;
  final int pefrAvg;
  final int actAvg;
  // (day-of-month, score) pairs; sparse - only days with a completed entry.
  final List<(int, double)> symptomTrend;
  final int greenDays;
  final int yellowDays;
  final int redDays;
  final int? actLatestScore;
  final String? actLatestDate;

  const DashboardSummary({
    required this.days,
    required this.diaryAvg,
    required this.pefrAvg,
    required this.actAvg,
    required this.symptomTrend,
    required this.greenDays,
    required this.yellowDays,
    required this.redDays,
    required this.actLatestScore,
    required this.actLatestDate,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final cards = json['cards'] as Map<String, dynamic>? ?? {};
    final pefrDistribution = json['pefr_distribution'] as Map<String, dynamic>? ?? {};
    final actLatest = json['act_latest'] as Map<String, dynamic>?;

    return DashboardSummary(
      days: (cards['days'] as num?)?.toInt() ?? 0,
      diaryAvg: (cards['diary_avg'] as num?)?.toDouble() ?? 0,
      pefrAvg: (cards['pefr_avg'] as num?)?.toInt() ?? 0,
      actAvg: (cards['act_avg'] as num?)?.toInt() ?? 0,
      symptomTrend: (json['symptom_trend'] as List<dynamic>? ?? [])
          .map((pair) => ((pair[0] as num).toInt(), (pair[1] as num).toDouble()))
          .toList(),
      greenDays: (pefrDistribution['green_days'] as num?)?.toInt() ?? 0,
      yellowDays: (pefrDistribution['yellow_days'] as num?)?.toInt() ?? 0,
      redDays: (pefrDistribution['red_days'] as num?)?.toInt() ?? 0,
      actLatestScore: (actLatest?['score'] as num?)?.toInt(),
      actLatestDate: actLatest?['date'] as String?,
    );
  }
}
