import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/appointment_model.dart';
import '../controllers/appointment_controller.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() => _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final AppointmentController _controller;
  late final TabController _tabController;
  String? _justBookedId;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AppointmentController>();
    _tabController = TabController(length: 2, vsync: this);

    _justBookedId = Get.parameters['justBooked'];
    if (_justBookedId != null) {
      // Clear the highlight after a few seconds so it doesn't linger
      // indefinitely on repeat visits to this screen.
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _justBookedId = null);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _confirmCancel(Appointment appointment) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel Appointment'),
        content: Text('Cancel your appointment with ${appointment.doctorName}?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Keep It')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Cancel Appointment')),
        ],
      ),
    );

    if (confirmed == true) {
      _controller.cancelAppointment(appointment.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: Obx(() {
        return TabBarView(
          controller: _tabController,
          children: [
            _AppointmentList(
              appointments: _controller.upcoming,
              justBookedId: _justBookedId,
              onCancel: _confirmCancel,
              emptyMessage: 'No upcoming appointments.',
            ),
            _AppointmentList(
              appointments: _controller.past,
              justBookedId: null,
              onCancel: null,
              emptyMessage: 'No past appointments yet.',
            ),
          ],
        );
      }),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List<Appointment> appointments;
  final String? justBookedId;
  final void Function(Appointment)? onCancel;
  final String emptyMessage;

  const _AppointmentList({
    required this.appointments,
    required this.justBookedId,
    required this.onCancel,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    if (appointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_outlined, size: 56, color: subTextColor),
              const SizedBox(height: 16),
              Text(emptyMessage, style: TextStyle(color: subTextColor)),
              if (onCancel != null) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.home),
                  child: const Text('Find a Doctor'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final isHighlighted = appointment.id == justBookedId;

        return _AppointmentCard(
          appointment: appointment,
          isHighlighted: isHighlighted,
          onCancel: onCancel != null ? () => onCancel!(appointment) : null,
        );
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool isHighlighted;
  final VoidCallback? onCancel;

  const _AppointmentCard({required this.appointment, required this.isHighlighted, this.onCancel});

  Color _statusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.upcoming:
        return AppColors.primary;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
        return AppColors.error;
    }
  }

  String _statusLabel(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.upcoming:
        return 'Upcoming';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final statusColor = _statusColor(appointment.status);
    final isVideo = appointment.consultationType == ConsultationType.video;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: isHighlighted ? AppColors.success : borderColor, width: isHighlighted ? 2 : 1),
        borderRadius: BorderRadius.circular(14),
        color: isHighlighted ? AppColors.success.withValues(alpha: 0.05) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: appointment.doctorPhotoUrl,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(width: 52, height: 52, color: borderColor, child: const Icon(Icons.person)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.doctorName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(appointment.specialization, style: const TextStyle(color: AppColors.primary, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(_statusLabel(appointment.status), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: subTextColor),
              const SizedBox(width: 4),
              Text(DateFormat('MMM d, yyyy').format(appointment.date), style: TextStyle(color: subTextColor, fontSize: 12)),
              const SizedBox(width: 14),
              Icon(Icons.access_time, size: 14, color: subTextColor),
              const SizedBox(width: 4),
              Text(appointment.timeSlot, style: TextStyle(color: subTextColor, fontSize: 12)),
              const SizedBox(width: 14),
              Icon(isVideo ? Icons.videocam_outlined : Icons.local_hospital_outlined, size: 14, color: subTextColor),
              const SizedBox(width: 4),
              Text(isVideo ? 'Video Call' : 'In-Person', style: TextStyle(color: subTextColor, fontSize: 12)),
            ],
          ),
          if (appointment.notes != null) ...[
            const SizedBox(height: 8),
            Text(appointment.notes!, style: TextStyle(color: subTextColor, fontSize: 12, fontStyle: FontStyle.italic)),
          ],
          if (appointment.status == AppointmentStatus.upcoming) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (isVideo)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.toNamed('/video-consultation/${appointment.id}'),
                      icon: const Icon(Icons.videocam_outlined, size: 16),
                      label: const Text('Join Call'),
                    ),
                  ),
                if (isVideo) const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.toNamed('/prescription-viewer/${appointment.id}'),
                    icon: const Icon(Icons.qr_code, size: 16),
                    label: const Text('QR Token'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.error, size: 20),
                  onPressed: onCancel,
                  tooltip: 'Cancel',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}