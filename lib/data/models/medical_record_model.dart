enum RecordType { condition, allergy, medication, surgery }

extension RecordTypeX on RecordType {
  String get label {
    switch (this) {
      case RecordType.condition:
        return 'Condition';
      case RecordType.allergy:
        return 'Allergy';
      case RecordType.medication:
        return 'Medication';
      case RecordType.surgery:
        return 'Surgery';
    }
  }
}

class MedicalRecord {
  final String id;
  final RecordType type;
  final String title;
  final String notes;
  final DateTime dateRecorded;

  const MedicalRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.notes,
    required this.dateRecorded,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'title': title,
      'notes': notes,
      'dateRecorded': dateRecorded.toIso8601String(),
    };
  }

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] as String,
      type: RecordType.values[json['type'] as int],
      title: json['title'] as String,
      notes: json['notes'] as String,
      dateRecorded: DateTime.parse(json['dateRecorded'] as String),
    );
  }
}