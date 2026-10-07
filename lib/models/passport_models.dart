class PassportInfo {
  final String name;
  final String code;
  final String sex;
  final String age;
  final String birthday;
  final String avatarUrl;

  const PassportInfo({
    required this.name,
    required this.code,
    required this.sex,
    required this.age,
    required this.birthday,
    required this.avatarUrl,
  });

  factory PassportInfo.fromJson(Map<String, dynamic> json) {
    return PassportInfo(
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      sex: json['sex'] ?? '未填寫',
      age: json['age']?.toString() ?? '-',
      birthday: json['birthday'] ?? '未填寫',
      avatarUrl: json['avatar_url'] ?? '',
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

class PassportPlanMedication {
  final String name;
  final String morn;
  final String even;
  // Relief meds only: usage text (e.g. 需要的時候使用) instead of morn/even doses.
  final String? info;
  final String? note;

  const PassportPlanMedication({
    required this.name,
    required this.morn,
    required this.even,
    required this.info,
    required this.note,
  });

  factory PassportPlanMedication.fromJson(Map<String, dynamic> json) {
    return PassportPlanMedication(
      name: json['name'] ?? '',
      morn: json['morn'] ?? '',
      even: json['even'] ?? '',
      info: json['info'] as String?,
      note: json['note'] as String?,
    );
  }
}

// /passport/load: the saved action plan for a given month (target_date
// matches on month, not exact day).
class PassportPlan {
  final bool isCompleted;
  final String? recordDate;
  final String? statusLevel;
  final String? notes;
  final String? doctorName;
  final List<PassportPlanMedication> controlMeds;
  final List<PassportPlanMedication> reliefMeds;

  const PassportPlan({
    required this.isCompleted,
    required this.recordDate,
    required this.statusLevel,
    required this.notes,
    required this.doctorName,
    required this.controlMeds,
    required this.reliefMeds,
  });

  factory PassportPlan.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return PassportPlan(
      isCompleted: json['is_completed'] ?? false,
      recordDate: data['record_date'] as String?,
      statusLevel: data['status_level'] as String?,
      notes: data['notes'] as String?,
      doctorName: data['doctor_name'] as String?,
      controlMeds: (data['control_meds'] as List<dynamic>? ?? [])
          .map((e) => PassportPlanMedication.fromJson(e as Map<String, dynamic>))
          .toList(),
      reliefMeds: (data['relief_meds'] as List<dynamic>? ?? [])
          .map((e) => PassportPlanMedication.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// /passport/history: the most recent record's status, as display-ready
// text from the backend.
class PassportHistorySummary {
  final String? statusLevel;
  final String? recordDate;

  const PassportHistorySummary({
    required this.statusLevel,
    required this.recordDate,
  });

  factory PassportHistorySummary.fromJson(Map<String, dynamic> json) {
    return PassportHistorySummary(
      statusLevel: json['status_level'] as String?,
      recordDate: json['record_date'] as String?,
    );
  }
}
