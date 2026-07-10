class AllergenEntry {
  final int id;
  final String name;

  const AllergenEntry({
    required this.id,
    required this.name,
  });

  factory AllergenEntry.fromJson(Map<String, dynamic> json) {
    return AllergenEntry(
      id: json['id'] as int,
      name: json['allergen_name'] ?? '',
    );
  }
}

class MedicationEntry {
  final int id;
  final String name;

  const MedicationEntry({
    required this.id,
    required this.name,
  });

  factory MedicationEntry.fromJson(Map<String, dynamic> json) {
    return MedicationEntry(
      id: json['id'] as int,
      name: json['medication_name'] ?? '',
    );
  }
}
