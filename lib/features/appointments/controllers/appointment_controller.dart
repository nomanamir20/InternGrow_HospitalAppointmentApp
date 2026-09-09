import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/appointment_model.dart';

class AppointmentController extends GetxController {
  static const _prefsKey = 'appointments';

  final RxList<Appointment> appointments = <Appointment>[].obs;

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
      final loaded = decoded.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
      loaded.sort((a, b) => b.date.compareTo(a.date));
      appointments.assignAll(loaded);
      _autoCompletePastAppointments();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(appointments.map((a) => a.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  /// Any "upcoming" appointment whose date has already passed is
  /// automatically marked completed — keeps the history/upcoming split
  /// honest without requiring manual intervention.
  void _autoCompletePastAppointments() {
    final now = DateTime.now();
    bool changed = false;

    final updated = appointments.map((a) {
      if (a.status == AppointmentStatus.upcoming && a.date.isBefore(now)) {
        changed = true;
        return a.copyWith(status: AppointmentStatus.completed);
      }
      return a;
    }).toList();

    if (changed) {
      appointments.assignAll(updated);
      _saveToPrefs();
    }
  }

  Appointment createAppointment({
    required String doctorId,
    required String doctorName,
    required String doctorPhotoUrl,
    required String specialization,
    required DateTime date,
    required String timeSlot,
    required ConsultationType consultationType,
    required double consultationFee,
    String? notes,
  }) {
    final appointment = Appointment(
      id: const Uuid().v4(),
      doctorId: doctorId,
      doctorName: doctorName,
      doctorPhotoUrl: doctorPhotoUrl,
      specialization: specialization,
      date: date,
      timeSlot: timeSlot,
      consultationType: consultationType,
      status: AppointmentStatus.upcoming,
      consultationFee: consultationFee,
      notes: notes,
    );

    appointments.insert(0, appointment);
    _saveToPrefs();
    return appointment;
  }

  Appointment? byId(String id) {
    try {
      return appointments.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> cancelAppointment(String id) async {
    final updated = appointments.map((a) {
      return a.id == id ? a.copyWith(status: AppointmentStatus.cancelled) : a;
    }).toList();
    appointments.assignAll(updated);
    await _saveToPrefs();
  }

  List<Appointment> get upcoming =>
      appointments.where((a) => a.status == AppointmentStatus.upcoming).toList();

  List<Appointment> get past =>
      appointments.where((a) => a.status != AppointmentStatus.upcoming).toList();

  /// A given doctor's already-booked time slots for a specific date —
  /// used to prevent double-booking the same slot.
  List<String> bookedSlotsFor(String doctorId, DateTime date) {
    return appointments
        .where((a) =>
            a.doctorId == doctorId &&
            a.status == AppointmentStatus.upcoming &&
            a.date.year == date.year &&
            a.date.month == date.month &&
            a.date.day == date.day)
        .map((a) => a.timeSlot)
        .toList();
  }
}