import 'package:flutter/material.dart';

class VideoConsultationScreen extends StatelessWidget {
  final String appointmentId;

  const VideoConsultationScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Video Consultation — TODO (appointment: $appointmentId)')),
    );
  }
}