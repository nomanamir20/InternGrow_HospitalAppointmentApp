enum AppointmentStatus { upcoming, completed, cancelled }
enum ConsultationType { inPerson, video }

class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorPhotoUrl;
  final String specialization;
  final DateTime date;
  final String timeSlot;
  final ConsultationType consultationType;
  final AppointmentStatus status;
  final double consultationFee;
  final String? notes;

  const Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorPhotoUrl,
    required this.specialization,
    required this.date,
    required this.timeSlot,
    required this.consultationType,
    required this.status,
    required this.consultationFee,
    this.notes,
  });

  Appointment copyWith({AppointmentStatus? status}) {
    return Appointment(
      id: id,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorPhotoUrl: doctorPhotoUrl,
      specialization: specialization,
      date: date,
      timeSlot: timeSlot,
      consultationType: consultationType,
      status: status ?? this.status,
      consultationFee: consultationFee,
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorPhotoUrl': doctorPhotoUrl,
      'specialization': specialization,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'consultationType': consultationType.index,
      'status': status.index,
      'consultationFee': consultationFee,
      'notes': notes,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      doctorPhotoUrl: json['doctorPhotoUrl'] as String,
      specialization: json['specialization'] as String,
      date: DateTime.parse(json['date'] as String),
      timeSlot: json['timeSlot'] as String,
      consultationType: ConsultationType.values[json['consultationType'] as int],
      status: AppointmentStatus.values[json['status'] as int],
      consultationFee: (json['consultationFee'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }
}