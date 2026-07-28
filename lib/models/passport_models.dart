class PassportInfo {
  final String name;
  final String code;
  final String sex;
  final String age;
  final String birthday;

  const PassportInfo({
    required this.name,
    required this.code,
    required this.sex,
    required this.age,
    required this.birthday,
  });

  factory PassportInfo.fromJson(Map<String, dynamic> json) {
    return PassportInfo(
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      sex: json['sex'] ?? '未填寫',
      age: json['age']?.toString() ?? '-',
      birthday: json['birthday'] ?? '未填寫',
    );
  }
}

class SavePlanResult {
  final int? id;
  final String message;

  const SavePlanResult({required this.id, required this.message});

  factory SavePlanResult.fromJson(Map<String, dynamic> json) {
    return SavePlanResult(
      id: (json['passport_id'] as num?)?.toInt(),
      message: json['message'] ?? '',
    );
  }
}

class MedicationOptions {
  final List<String> controlMedications;
  final List<String> reliefMedications;

  const MedicationOptions({
    required this.controlMedications,
    required this.reliefMedications,
  });

  factory MedicationOptions.fromJson(Map<String, dynamic> json) {
    return MedicationOptions(
      controlMedications: List<String>.from(json['control_medications'] ?? []),
      reliefMedications: List<String>.from(json['relief_medications'] ?? []),
    );
  }
}

// /passport/history: the most recent record's status, as display-ready
// text from the backend.
class PassportHistorySummary {
  final String statusLevel;
  final String? recordDate;

  const PassportHistorySummary({
    required this.statusLevel,
    required this.recordDate,
  });

  factory PassportHistorySummary.fromJson(Map<String, dynamic> json) {
    return PassportHistorySummary(
      statusLevel: json['status_level'] ?? '尚未填寫',
      recordDate: json['record_date'] as String?,
    );
  }
}
