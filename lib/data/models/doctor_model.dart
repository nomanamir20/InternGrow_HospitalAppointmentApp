/// A doctor profile — real name/photo from RandomUser.me, paired with
/// mock medical specialization and rating data (RandomUser.me has no
/// concept of medical specialties, so that part is generated locally).
class Doctor {
  final String id;
  final String fullName;
  final String photoUrl;
  final String specialization;
  final String hospital;
  final double rating;
  final int yearsExperience;
  final double consultationFee;
  final List<String> availableDays;
  final String bio;

  const Doctor({
    required this.id,
    required this.fullName,
    required this.photoUrl,
    required this.specialization,
    required this.hospital,
    required this.rating,
    required this.yearsExperience,
    required this.consultationFee,
    required this.availableDays,
    required this.bio,
  });

  factory Doctor.fromRandomUserJson(Map<String, dynamic> json, {
    required String specialization,
    required String hospital,
    required double rating,
    required int yearsExperience,
    required double consultationFee,
    required List<String> availableDays,
    required String bio,
  }) {
    final name = json['name'] as Map<String, dynamic>;
    final picture = json['picture'] as Map<String, dynamic>;
    final login = json['login'] as Map<String, dynamic>;

    return Doctor(
      id: login['uuid'] as String,
      fullName: 'Dr. ${name['first']} ${name['last']}',
      photoUrl: picture['large'] as String,
      specialization: specialization,
      hospital: hospital,
      rating: rating,
      yearsExperience: yearsExperience,
      consultationFee: consultationFee,
      availableDays: availableDays,
      bio: bio,
    );
  }
}