import 'package:flutter/material.dart';

class PrescriptionViewerScreen extends StatelessWidget {
  final String appointmentId;

  const PrescriptionViewerScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Prescription Viewer — TODO (appointment: $appointmentId)')),
    );
  }
}