class PassportInfo {
  final String name;
  final String code;
  final String sex;
  final String age;
  final String birthday;
  final String mrzLine1;
  final String mrzLine2;

  const PassportInfo({
    required this.name,
    required this.code,
    required this.sex,
    required this.age,
    required this.birthday,
    required this.mrzLine1,
    required this.mrzLine2,
  });

  factory PassportInfo.fromJson(Map<String, dynamic> json) {
    return PassportInfo(
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      sex: json['sex'] ?? '',
      age: json['age']?.toString() ?? '',
      birthday: json['birthday'] ?? '',
      mrzLine1: json['mrz_line1'] ?? '',
      mrzLine2: json['mrz_line2'] ?? '',
    );
  }
}

class PassportPlan {
  final int? id;
  final String? recordDate;
  final String statusLevel;
  final String statusTitle;
  final String statusDesc;
  final List<String> controlMeds;
  final List<String> reliefMeds;
  final String notes;
  final String doctorName;

  const PassportPlan({
    required this.id,
    required this.recordDate,
    required this.statusLevel,
    required this.statusTitle,
    required this.statusDesc,
    required this.controlMeds,
    required this.reliefMeds,
    required this.notes,
    required this.doctorName,
  });

  factory PassportPlan.fromJson(Map<String, dynamic> json) {
    return PassportPlan(
      id: json['id'] as int?,
      recordDate: json['record_date'] as String?,
      statusLevel: json['status_level'] ?? '',
      statusTitle: json['status_title'] ?? '',
      statusDesc: json['status_desc'] ?? '',
      controlMeds: List<String>.from(json['control_meds'] ?? []),
      reliefMeds: List<String>.from(json['relief_meds'] ?? []),
      notes: json['notes'] ?? '',
      doctorName: json['doctor_name'] ?? '',
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

class PassportStatus {
  final bool isCompleted;
  final PassportInfo info;
  final PassportPlan plan;

  const PassportStatus({
    required this.isCompleted,
    required this.info,
    required this.plan,
  });

  factory PassportStatus.fromJson(Map<String, dynamic> json) {
    return PassportStatus(
      isCompleted: json['is_completed'] ?? false,
      info: PassportInfo.fromJson(json['passport_info'] ?? {}),
      plan: PassportPlan.fromJson(json['passport_data'] ?? {}),
    );
  }
}
