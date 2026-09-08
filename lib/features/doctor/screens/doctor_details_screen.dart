import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/controllers/doctor_controller.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final String doctorId;

  const DoctorDetailsScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorController>();
    final doctor = controller.byId(doctorId);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    if (doctor == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Doctor not found.', style: TextStyle(color: subTextColor))),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: doctor.photoUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                errorWidget: (context, url, error) => Container(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  child: Icon(Icons.person, size: 80, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.specialization,
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: subTextColor),
                      const SizedBox(width: 4),
                      Expanded(child: Text(doctor.hospital, style: TextStyle(color: subTextColor))),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _StatChip(icon: Icons.star, label: doctor.rating.toStringAsFixed(1), color: AppColors.ratingStar),
                      const SizedBox(width: 10),
                      _StatChip(icon: Icons.work_outline, label: '${doctor.yearsExperience} yrs exp', color: AppColors.primary),
                      const SizedBox(width: 10),
                      _StatChip(icon: Icons.attach_money, label: '\$${doctor.consultationFee.toStringAsFixed(0)}', color: AppColors.success),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text('About', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(doctor.bio, style: TextStyle(color: subTextColor, height: 1.5)),
                  const SizedBox(height: 24),

                  Text('Available Days', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final day in doctor.availableDays)
                        Chip(
                          label: Text(day),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                          side: BorderSide.none,
                        ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.bookAppointment, arguments: doctor),
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text('Book Appointment'),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}