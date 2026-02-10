class MiddlewareStudent {
  final String userId;
  final String firstName;
  final String lastName;
  final String? email;
  final String courseId;
  final String? classId;
  final String middlewareId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String binarySuccessId;

  MiddlewareStudent({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.email,
    required this.courseId,
    this.classId,
    required this.middlewareId,
    required this.createdAt,
    required this.updatedAt,
    required this.binarySuccessId,
  });

  factory MiddlewareStudent.fromJson(Map<String, dynamic> json) {
    return MiddlewareStudent(
      userId: json['USER_ID'] ?? '',
      firstName: json['FIRST_NAME'] ?? '',
      lastName: json['LAST_NAME'] ?? '',
      email: json['EMAIL'],
      courseId: json['COURSE_ID'] ?? '',
      classId: json['CLASS_ID'],
      middlewareId: json['MIDDLEWARE_ID'] ?? '',
      createdAt: DateTime.parse(json['CREATED_AT']),
      updatedAt: DateTime.parse(json['UPDATED_AT']),
      binarySuccessId: json['BINARY_SUCCESS_ID'] ?? "-",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'USER_ID': userId,
      'FIRST_NAME': firstName,
      'LAST_NAME': lastName,
      'EMAIL': email,
      'COURSE_ID': courseId,
      'CLASS_ID': classId,
      'MIDDLEWARE_ID': middlewareId,
      'CREATED_AT': createdAt.toIso8601String(),
      'UPDATED_AT': updatedAt.toIso8601String(),
      'BINARY_SUCCESS_ID': binarySuccessId,
    };
  }
}
