class EmergencyContactService {
  final List<Map<String, String>> _medicalContacts = [
    {'title': '兒童急診', 'contactInfo': '分機 1091'},
    {'title': '醫院服務專線', 'contactInfo': '04-7238595'},
    {'title': '個案管理師 Line 諮詢', 'contactInfo': 'ID: @ynz6515t'},
  ];

  final List<Map<String, String>> _personalContacts = [
    {'name': '王媽媽(母親)', 'phone': '0912-345-678'},
    {'name': '王爸爸(父親)', 'phone': '0923-456-789'},
    {'name': '王阿嬤(祖母)', 'phone': '012-345-6789'},
  ];

  final List<String> _allergies = [
    '異位性皮膚炎',
    '過敏性鼻炎',
    '氣喘',
    '蕁麻疹',
    '海鮮',
    '花生',
    '塵蟎',
  ];

  final List<String> _medications = [
    'Seretide 125/25',
    'Ventolin',
  ];

  Map<String, String> _patientInfo = {};

  List<Map<String, String>> getMedicalContacts() => List.from(_medicalContacts);

  List<Map<String, String>> addMedicalContact(Map<String, String> contact) {
    _medicalContacts.add(contact);
    return List.from(_medicalContacts);
  }

  List<Map<String, String>> updateMedicalContact(int index, Map<String, String> contact) {
    if (index >= 0 && index < _medicalContacts.length) {
      _medicalContacts[index] = contact;
    }
    return List.from(_medicalContacts);
  }

  List<Map<String, String>> deleteMedicalContact(int index) {
    if (index >= 0 && index < _medicalContacts.length) {
      _medicalContacts.removeAt(index);
    }
    return List.from(_medicalContacts);
  }

  List<Map<String, String>> getPersonalContacts() => List.from(_personalContacts);

  List<Map<String, String>> addPersonalContact(Map<String, String> contact) {
    _personalContacts.add(contact);
    return List.from(_personalContacts);
  }

  List<Map<String, String>> updatePersonalContact(int index, Map<String, String> contact) {
    if (index >= 0 && index < _personalContacts.length) {
      _personalContacts[index] = contact;
    }
    return List.from(_personalContacts);
  }

  List<Map<String, String>> deletePersonalContact(int index) {
    if (index >= 0 && index < _personalContacts.length) {
      _personalContacts.removeAt(index);
    }
    return List.from(_personalContacts);
  }

  List<String> getAllergies() => List.from(_allergies);

  void saveAllergies(List<String> allergies) {
    _allergies
      ..clear()
      ..addAll(allergies);
  }

  List<String> getMedications() => List.from(_medications);

  void saveMedications(List<String> medications) {
    _medications
      ..clear()
      ..addAll(medications);
  }

  Map<String, String> getPatientInfo() => Map.from(_patientInfo);

  void savePatientInfo(Map<String, String> info) {
    _patientInfo = Map.from(info);
  }
}
