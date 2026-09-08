import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/doctor_controller.dart';
import '../widgets/doctor_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(title: const Text('Find a Doctor')),
      body: RefreshIndicator(
        onRefresh: controller.loadDoctors,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.hasError.value) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text('Could not load doctors.', style: TextStyle(color: subTextColor)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: controller.loadDoctors, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.search),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: subTextColor),
                      const SizedBox(width: 10),
                      Text('Search doctors by name or specialty...', style: TextStyle(color: subTextColor)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Specialization quick-filter chips
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.specializations.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final specialization = controller.specializations[index];
                    return ActionChip(
                      label: Text(specialization),
                      onPressed: () => Get.toNamed(
                        '${AppRoutes.search}?specialization=$specialization',
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Available Doctors',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              for (final doctor in controller.doctors)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DoctorCard(
                    doctor: doctor,
                    onTap: () => Get.toNamed('${AppRoutes.doctorDetails}/${doctor.id}'),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}