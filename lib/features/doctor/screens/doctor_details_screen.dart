import 'package:flutter/material.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final String doctorId;

  const DoctorDetailsScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Doctor Details — TODO (id: $doctorId)')),
    );
  }
}