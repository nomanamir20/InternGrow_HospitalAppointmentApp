import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/prescription_model.dart';

class PrescriptionController extends GetxController {
  static const _prefsKey = 'prescriptions';

  final RxList<Prescription> prescriptions = <Prescription>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored != null) {
      final List<dynamic> decoded = jsonDecode(stored);
      prescriptions.assignAll(
        decoded.map((e) => Prescription.fromJson(e as Map<String, dynamic>)).toList(),
      );
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(prescriptions.map((p) => p.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  Prescription? byAppointmentId(String appointmentId) {
    try {
      return prescriptions.firstWhere((p) => p.appointmentId == appointmentId);
    } catch (_) {
      return null;
    }
  }

  /// Generates a realistic sample prescription for a given appointment —
  /// since this is a portfolio app with no real doctor issuing prescriptions
  /// live, this simulates what a doctor would have entered post-visit.
  Future<Prescription> generateSampleFor({
    required String appointmentId,
    required String doctorName,
    required String patientName,
    required String specialization,
  }) async {
    final existing = byAppointmentId(appointmentId);
    if (existing != null) return existing;

    final sample = _sampleFor(specialization);

    final prescription = Prescription(
      id: const Uuid().v4(),
      appointmentId: appointmentId,
      doctorName: doctorName,
      patientName: patientName,
      issuedDate: DateTime.now(),
      diagnosis: sample.diagnosis,
      medications: sample.medications,
      additionalNotes: sample.notes,
    );

    prescriptions.add(prescription);
    await _saveToPrefs();
    return prescription;
  }

  ({String diagnosis, List<PrescriptionItem> medications, String notes}) _sampleFor(String specialization) {
    switch (specialization) {
      case 'Cardiologist':
        return (
          diagnosis: 'Mild Hypertension',
          medications: const [
            PrescriptionItem(medicationName: 'Amlodipine', dosage: '5mg', frequency: 'Once daily', duration: '30 days'),
            PrescriptionItem(medicationName: 'Aspirin', dosage: '81mg', frequency: 'Once daily', duration: '30 days'),
          ],
          notes: 'Monitor blood pressure daily. Reduce sodium intake. Follow up in 4 weeks.',
        );
      case 'Dermatologist':
        return (
          diagnosis: 'Mild Eczema',
          medications: const [
            PrescriptionItem(medicationName: 'Hydrocortisone Cream', dosage: '1%', frequency: 'Twice daily', duration: '14 days'),
          ],
          notes: 'Apply to affected areas. Avoid harsh soaps. Use fragrance-free moisturizer.',
        );
      case 'Pediatrician':
        return (
          diagnosis: 'Common Cold',
          medications: const [
            PrescriptionItem(medicationName: 'Children\'s Acetaminophen', dosage: '160mg', frequency: 'Every 6 hours as needed', duration: '5 days'),
          ],
          notes: 'Encourage fluids and rest. Return if fever persists beyond 3 days.',
        );
      default:
        return (
          diagnosis: 'General Wellness Check',
          medications: const [
            PrescriptionItem(medicationName: 'Multivitamin', dosage: '1 tablet', frequency: 'Once daily', duration: '30 days'),
          ],
          notes: 'No significant concerns noted. Continue routine checkups.',
        );
    }
  }
}