import 'package:get/get.dart';

import '../../../core/services/doctor_api_service.dart';
import '../../../data/models/doctor_model.dart';

class DoctorController extends GetxController {
  final DoctorApiService _api = DoctorApiService();

  final RxList<Doctor> doctors = <Doctor>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDoctors();
  }

  Future<void> loadDoctors() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final result = await _api.fetchDoctors();
      doctors.assignAll(result);
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Doctor? byId(String id) {
    try {
      return doctors.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  List<String> get specializations {
    return doctors.map((d) => d.specialization).toSet().toList()..sort();
  }

  List<Doctor> byS­pecialization(String specialization) {
    return doctors.where((d) => d.specialization == specialization).toList();
  }
}