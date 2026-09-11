class PrescriptionItem {
  final String medicationName;
  final String dosage;
  final String frequency;
  final String duration;

  const PrescriptionItem({
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
    };
  }

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionItem(
      medicationName: json['medicationName'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
    );
  }
}

class Prescription {
  final String id;
  final String appointmentId;
  final String doctorName;
  final String patientName;
  final DateTime issuedDate;
  final String diagnosis;
  final List<PrescriptionItem> medications;
  final String additionalNotes;

  const Prescription({
    required this.id,
    required this.appointmentId,
    required this.doctorName,
    required this.patientName,
    required this.issuedDate,
    required this.diagnosis,
    required this.medications,
    this.additionalNotes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'doctorName': doctorName,
      'patientName': patientName,
      'issuedDate': issuedDate.toIso8601String(),
      'diagnosis': diagnosis,
      'medications': medications.map((m) => m.toJson()).toList(),
      'additionalNotes': additionalNotes,
    };
  }

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as String,
      appointmentId: json['appointmentId'] as String,
      doctorName: json['doctorName'] as String,
      patientName: json['patientName'] as String,
      issuedDate: DateTime.parse(json['issuedDate'] as String),
      diagnosis: json['diagnosis'] as String,
      medications: (json['medications'] as List<dynamic>)
          .map((e) => PrescriptionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      additionalNotes: json['additionalNotes'] as String? ?? '',
    );
  }
}