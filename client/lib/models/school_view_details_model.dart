
class SchoolStudent {
  final String learnerId;
  final String salutation;
  final String firstName;
  final String lastName;
  final String email;
  final String learnerStatus;
  final String hasFingerprintSubmitted;
  final String joinedAt;

  SchoolStudent({
    required this.learnerId,
    required this.salutation,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.learnerStatus,
    required this.hasFingerprintSubmitted,
    required this.joinedAt,
  });

  factory SchoolStudent.fromJson(Map<String, dynamic> json) {
    return SchoolStudent(
      learnerId: json['learner_id'] ?? '',
      salutation: json['salutation'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      learnerStatus: json['learner_status'] ?? '',
      hasFingerprintSubmitted: json['has_fingerprint_submitted'] ?? 'N',
      joinedAt: json['joined_at'] ?? '',
    );
  }
}
