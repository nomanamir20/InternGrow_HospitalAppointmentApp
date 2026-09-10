import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/medical_record_model.dart';

class MedicalHistoryController extends GetxController {
  static const _prefsKey = 'medical_records';

  final RxList<MedicalRecord> records = <MedicalRecord>[].obs;

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
      final loaded = decoded.map((e) => MedicalRecord.fromJson(e as Map<String, dynamic>)).toList();
      loaded.sort((a, b) => b.dateRecorded.compareTo(a.dateRecorded));
      records.assignAll(loaded);
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(records.map((r) => r.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  Future<void> addRecord({
    required RecordType type,
    required String title,
    required String notes,
  }) async {
    final record = MedicalRecord(
      id: const Uuid().v4(),
      type: type,
      title: title,
      notes: notes,
      dateRecorded: DateTime.now(),
    );

    records.insert(0, record);
    await _saveToPrefs();
  }

  Future<void> deleteRecord(String id) async {
    records.removeWhere((r) => r.id == id);
    await _saveToPrefs();
  }

  List<MedicalRecord> byType(RecordType type) {
    return records.where((r) => r.type == type).toList();
  }
}