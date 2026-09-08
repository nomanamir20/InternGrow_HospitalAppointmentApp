import 'package:dio/dio.dart';

import '../../data/models/doctor_model.dart';
import '../constants/doctor_mock_data.dart';

/// Fetches realistic doctor identities (name, photo) from RandomUser.me,
/// then enriches each with deterministic mock medical data.
class DoctorApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://randomuser.me/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<Doctor>> fetchDoctors({int count = 20}) async {
    // seed ensures the SAME 20 "doctors" are returned every time the app
    // runs, instead of a different random set each load.
    final response = await _dio.get('/', queryParameters: {
      'results': count,
      'seed': 'interngrow-hospital',
      'nat': 'us,gb,ca,au',
    });

    final List<dynamic> results = response.data['results'];

    return results.asMap().entries.map((entry) {
      final index = entry.key;
      final json = entry.value as Map<String, dynamic>;
      final mockData = DoctorMockData.generateFor(index);

      return Doctor.fromRandomUserJson(
        json,
        specialization: mockData['specialization'] as String,
        hospital: mockData['hospital'] as String,
        rating: mockData['rating'] as double,
        yearsExperience: mockData['yearsExperience'] as int,
        consultationFee: mockData['consultationFee'] as double,
        availableDays: mockData['availableDays'] as List<String>,
        bio: mockData['bio'] as String,
      );
    }).toList();
  }
}