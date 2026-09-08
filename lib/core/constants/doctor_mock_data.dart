import 'dart:math';

/// Since RandomUser.me only provides names/photos, this generates the
/// medical-specific attributes (specialization, hospital, rating, etc.)
/// deterministically per doctor index, so the same doctor always shows
/// consistent data across app sessions.
class DoctorMockData {
  DoctorMockData._();

  static const specializations = [
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Neurologist',
    'Orthopedic Surgeon',
    'General Physician',
    'ENT Specialist',
    'Psychiatrist',
    'Gynecologist',
    'Dentist',
  ];

  static const hospitals = [
    'InternGrow General Hospital',
    'Sunrise Medical Center',
    'City Care Clinic',
    'Wellness Family Hospital',
    'Metro Health Institute',
  ];

  static const bios = [
    'Dedicated to providing compassionate, evidence-based care for every patient.',
    'Specializes in early diagnosis and long-term management of chronic conditions.',
    'Passionate about patient education and preventive healthcare.',
    'Combines modern medicine with a patient-first approach to treatment.',
    'Committed to making healthcare accessible and stress-free for families.',
  ];

  static const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static Map<String, dynamic> generateFor(int seedIndex) {
    final random = Random(seedIndex); // seeded — same index always produces same data

    final availableCount = 2 + random.nextInt(4); // 2-5 available days
    final shuffledDays = List.of(weekdays)..shuffle(random);

    return {
      'specialization': specializations[seedIndex % specializations.length],
      'hospital': hospitals[random.nextInt(hospitals.length)],
      'rating': 3.5 + random.nextDouble() * 1.5, // 3.5 - 5.0
      'yearsExperience': 3 + random.nextInt(22), // 3-25 years
      'consultationFee': (20 + random.nextInt(80)).toDouble(), // $20-$100
      'availableDays': shuffledDays.take(availableCount).toList(),
      'bio': bios[random.nextInt(bios.length)],
    };
  }
}