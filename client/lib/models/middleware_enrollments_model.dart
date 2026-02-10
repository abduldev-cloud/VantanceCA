class MiddlewareEnrollments {
  final String enrollmentId;
  final String? firstName;
  final String? lastName;
  final String? className;
  final String middlewareId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? processStatus;
  final String? errorMessage;

  MiddlewareEnrollments({
    required this.enrollmentId,
    this.firstName,
    this.lastName,
    this.className,
    required this.middlewareId,
    required this.createdAt,
    required this.updatedAt,
    this.processStatus,
    this.errorMessage,
  });

  factory MiddlewareEnrollments.fromJson(Map<String, dynamic> json) {
    return MiddlewareEnrollments(
      enrollmentId: json['ENROLLMENT_ID'] ?? '',
      firstName: json['FIRST_NAME'],
      lastName: json['LAST_NAME'],
      className: json['CLASS_NAME'],
      middlewareId: json['MIDDLEWARE_ID'] ?? '',
      createdAt: DateTime.tryParse(json['CREATED_AT'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['UPDATED_AT'] ?? '') ?? DateTime.now(),
      processStatus: json['PROCESS_STATUS'],
      errorMessage: json['ERROR_MESSAGE'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ENROLLMENT_ID": enrollmentId,
      "FIRST_NAME": firstName,
      "LAST_NAME": lastName,
      "CLASS_NAME": className,
      "MIDDLEWARE_ID": middlewareId,
      "CREATED_AT": createdAt.toIso8601String(),
      "UPDATED_AT": updatedAt.toIso8601String(),
      "PROCESS_STATUS": processStatus,
      "ERROR_MESSAGE": errorMessage,
    };
  }
}
