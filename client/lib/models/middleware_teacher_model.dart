class MiddlewareTeacher {
  final String userId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? courseId;
  final String? classId;
  final String middlewareId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String binarySuccessId;

  MiddlewareTeacher({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.courseId,
    this.classId,
    required this.middlewareId,
    required this.createdAt,
    required this.updatedAt,
    required this.binarySuccessId,
  });

  factory MiddlewareTeacher.fromJson(Map<String, dynamic> json) {
    return MiddlewareTeacher(
      userId: json['USER_ID'] as String,
      firstName: json['FIRST_NAME'] ?? "",
      lastName: json['LAST_NAME'] ?? "",
      email: json['EMAIL'] as String?,
      courseId: json['COURSE_ID'] as String?,
      classId: json['CLASS_ID'] as String?,
      middlewareId: json['MIDDLEWARE_ID'] as String,
      createdAt: DateTime.parse(json['CREATED_AT'] as String),
      updatedAt: DateTime.parse(json['UPDATED_AT'] as String),
      binarySuccessId: json['BINARY_SUCCESS_ID'] ?? "-",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'USER_ID': userId,
      'FIRST_NAME': firstName,
      'LAST_NAME': firstName,
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
