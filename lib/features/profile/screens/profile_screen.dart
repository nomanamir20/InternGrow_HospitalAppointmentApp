import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../shared/widgets/scaffold_with_nav_bar.dart';
import '../../appointments/controllers/appointment_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Log Out')),
        ],
      ),
    );

    if (confirmed == true) {
      Get.find<AuthController>().signOut();
    }
  }

  void _goToAppointmentsTab() {
    Get.find<NavShellController>().changeTab(1);
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();
    final appointmentController = Get.find<AppointmentController>();
    final user = authController.currentUser;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final displayName = (user?.displayName?.isNotEmpty ?? false) ? user!.displayName! : 'Patient';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary,
                child: Text(
                  initial,
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    if (user?.email != null)
                      Text(user!.email!, style: TextStyle(color: subTextColor, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          Obx(() => Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.calendar_today_outlined,
                      label: 'Upcoming',
                      value: '${appointmentController.upcoming.length}',
                      onTap: _goToAppointmentsTab,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.history,
                      label: 'Past Visits',
                      value: '${appointmentController.past.length}',
                      onTap: _goToAppointmentsTab,
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 28),

          Text('Preferences', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Obx(() => _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                trailing: Switch(
                  value: themeController.isDarkMode.value,
                  onChanged: themeController.toggleTheme,
                ),
              )),

          const SizedBox(height: 20),
          Text('Health', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.folder_shared_outlined,
            title: 'Medical History',
            onTap: () => Get.toNamed(AppRoutes.medicalHistory),
          ),
          _SettingsTile(
            icon: Icons.calendar_today_outlined,
            title: 'My Appointments',
            onTap: _goToAppointmentsTab,
          ),

          const SizedBox(height: 20),
          Text('Account', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Log Out',
            titleColor: AppColors.error,
            iconColor: AppColors.error,
            onTap: () => _handleLogout(context),
          ),

          const SizedBox(height: 20),
          Center(child: Text('InternGrow Hospital v1.0.0', style: TextStyle(color: subTextColor, fontSize: 12))),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _StatCard({required this.icon, required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
            Text(label, style: TextStyle(color: subTextColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.iconColor,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor))),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: titleColor)),
            ),
            trailing ?? const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}