class ContactEntry {
  final int? id;
  final String name;
  final String info;

  const ContactEntry({
    this.id,
    required this.name,
    required this.info,
  });

  factory ContactEntry.fromJson(Map<String, dynamic> json) {
    return ContactEntry(
      id: json['id'] as int?,
      name: json['name'] ?? '',
      info: json['info'] ?? '',
    );
  }
}

class ContactList {
  final List<ContactEntry> medical;
  final List<ContactEntry> emergency;

  const ContactList({
    required this.medical,
    required this.emergency,
  });

  factory ContactList.fromJson(Map<String, dynamic> json) {
    return ContactList(
      medical: (json['medical'] as List<dynamic>? ?? [])
          .map((c) => ContactEntry.fromJson(c as Map<String, dynamic>))
          .toList(),
      emergency: (json['emergency'] as List<dynamic>? ?? [])
          .map((c) => ContactEntry.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
