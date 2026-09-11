import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../core/services/prescription_pdf_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../appointments/controllers/appointment_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/prescription_controller.dart';

class PrescriptionViewerScreen extends StatefulWidget {
  final String appointmentId;

  const PrescriptionViewerScreen({super.key, required this.appointmentId});

  @override
  State<PrescriptionViewerScreen> createState() => _PrescriptionViewerScreenState();
}

class _PrescriptionViewerScreenState extends State<PrescriptionViewerScreen> {
  late final AppointmentController _appointmentController;
  late final PrescriptionController _prescriptionController;
  late final AuthController _authController;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _appointmentController = Get.find<AppointmentController>();
    _prescriptionController = Get.find<PrescriptionController>();
    _authController = Get.find<AuthController>();
    _ensurePrescriptionExists();
  }

  Future<void> _ensurePrescriptionExists() async {
    final existing = _prescriptionController.byAppointmentId(widget.appointmentId);
    if (existing != null) return;

    final appointment = _appointmentController.byId(widget.appointmentId);
    if (appointment == null) return;

    setState(() => _isGenerating = true);

    final patientName = _authController.currentUser?.displayName ?? 'Patient';

    await _prescriptionController.generateSampleFor(
      appointmentId: widget.appointmentId,
      doctorName: appointment.doctorName,
      patientName: patientName,
      specialization: appointment.specialization,
    );

    if (mounted) setState(() => _isGenerating = false);
  }

  Future<void> _exportPdf() async {
    final prescription = _prescriptionController.byAppointmentId(widget.appointmentId);
    if (prescription == null) return;

    final pdfService = PrescriptionPdfService();
    final doc = await pdfService.buildPrescription(prescription);

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'InternGrow_Prescription_${DateFormat('yyyy-MM-dd').format(prescription.issuedDate)}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Download PDF',
            onPressed: _isGenerating ? null : _exportPdf,
          ),
        ],
      ),
      body: Obx(() {
        if (_isGenerating) {
          return const Center(child: CircularProgressIndicator());
        }

        final prescription = _prescriptionController.byAppointmentId(widget.appointmentId);

        if (prescription == null) {
          return Center(child: Text('No prescription available for this appointment.', style: TextStyle(color: subTextColor)));
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('InternGrow Hospital', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const Text('Rx', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _LabelValue(label: 'Patient', value: prescription.patientName),
                      _LabelValue(label: 'Date', value: DateFormat('MMM d, yyyy').format(prescription.issuedDate)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  Text('Diagnosis', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(prescription.diagnosis),
                  const SizedBox(height: 16),

                  Text('Medications', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  for (final med in prescription.medications)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(med.medicationName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('${med.dosage} • ${med.frequency} • ${med.duration}', style: TextStyle(color: subTextColor, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),

                  if (prescription.additionalNotes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Notes', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(prescription.additionalNotes, style: TextStyle(color: subTextColor, fontSize: 13)),
                  ],

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text('— ${prescription.doctorName}', style: const TextStyle(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _exportPdf,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Download as PDF'),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;

  const _LabelValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: subTextColor, fontSize: 11)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }
}