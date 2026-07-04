class PeakFlowReading {
  final double? value;
  final int? id;
  final bool isCompleted;

  const PeakFlowReading({
    required this.value,
    required this.id,
    required this.isCompleted,
  });

  factory PeakFlowReading.fromJson(Map<String, dynamic> json) {
    return PeakFlowReading(
      value: (json['value'] as num?)?.toDouble(),
      id: json['id'] as int?,
      isCompleted: json['is_completed'] ?? false,
    );
  }
}

class PeakFlowStatus {
  final String date;
  final PeakFlowReading morning;
  final PeakFlowReading night;

  const PeakFlowStatus({
    required this.date,
    required this.morning,
    required this.night,
  });

  factory PeakFlowStatus.fromJson(Map<String, dynamic> json) {
    return PeakFlowStatus(
      date: json['date'] ?? '',
      morning: PeakFlowReading.fromJson(json['morning'] ?? {}),
      night: PeakFlowReading.fromJson(json['night'] ?? {}),
    );
  }
}

class PeakFlowSaveResult {
  final int id;
  final String message;

  const PeakFlowSaveResult({
    required this.id,
    required this.message,
  });

  factory PeakFlowSaveResult.fromJson(Map<String, dynamic> json) {
    return PeakFlowSaveResult(
      id: json['id'] as int,
      message: json['message'] ?? '',
    );
  }
}
