import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/appointment_controller.dart';

class QrTokenScreen extends StatelessWidget {
  final String appointmentId;

  const QrTokenScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppointmentController>();
    final appointment = controller.byId(appointmentId);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    if (appointment == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Appointment not found.', style: TextStyle(color: subTextColor))),
      );
    }

    final qrData =
        'INTERNGROW-APPOINTMENT|id:${appointment.id}|doctor:${appointment.doctorName}|date:${DateFormat('yyyy-MM-dd').format(appointment.date)}|time:${appointment.timeSlot}';

    return Scaffold(
      appBar: AppBar(title: const Text('Appointment Token')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                // Centers nicely on tall screens, scrolls instead of
                // overflowing on short ones.
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Show this QR code at reception for check-in',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: subTextColor, fontSize: 14),
                    ),
                    const SizedBox(height: 28),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 220,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.primary),
                        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 28),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(label: 'Doctor', value: appointment.doctorName),
                          _DetailRow(label: 'Specialty', value: appointment.specialization),
                          _DetailRow(label: 'Date', value: DateFormat('MMM d, yyyy').format(appointment.date)),
                          _DetailRow(label: 'Time', value: appointment.timeSlot),
                          _DetailRow(label: 'Token ID', value: appointment.id.substring(0, 8).toUpperCase()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: subTextColor, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}