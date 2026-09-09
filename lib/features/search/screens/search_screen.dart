import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/doctor_model.dart';
import '../../home/controllers/doctor_controller.dart';
import '../../home/widgets/doctor_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  late final DoctorController _doctorController;
  String? _activeSpecializationFilter;

  @override
  void initState() {
    super.initState();
    _doctorController = Get.find<DoctorController>();

    // Support arriving here pre-filtered from Home's specialization chips,
    // via a query parameter (e.g. /search?specialization=Cardiologist).
    final specializationParam = Get.parameters['specialization'];
    if (specializationParam != null && specializationParam.isNotEmpty) {
      _activeSpecializationFilter = specializationParam;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Doctor> get _filteredDoctors {
    final query = _controller.text.trim().toLowerCase();
    var results = _doctorController.doctors.toList();

    if (_activeSpecializationFilter != null) {
      results = results.where((d) => d.specialization == _activeSpecializationFilter).toList();
    }

    if (query.isNotEmpty) {
      results = results.where((d) {
        return d.fullName.toLowerCase().contains(query) ||
            d.specialization.toLowerCase().contains(query) ||
            d.hospital.toLowerCase().contains(query);
      }).toList();
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: subTextColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search by name, specialty, hospital...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() => _controller.clear()),
                  child: Icon(Icons.close, color: subTextColor, size: 18),
                ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          if (_activeSpecializationFilter != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text('Filter: $_activeSpecializationFilter'),
                  onDeleted: () => setState(() => _activeSpecializationFilter = null),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                  deleteIconColor: AppColors.primary,
                  side: BorderSide.none,
                ),
              ),
            ),
          Expanded(
            child: Obx(() {
              if (_doctorController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final results = _filteredDoctors;

              if (_controller.text.isEmpty && _activeSpecializationFilter == null) {
                return Center(
                  child: Text('Search for a doctor by name or specialty', style: TextStyle(color: subTextColor)),
                );
              }

              if (results.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 48, color: subTextColor),
                        const SizedBox(height: 12),
                        Text('No doctors found.', style: TextStyle(color: subTextColor)),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: results.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doctor = results[index];
                  return DoctorCard(
                    doctor: doctor,
                    onTap: () => Get.toNamed('${AppRoutes.doctorDetails}/${doctor.id}'),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}