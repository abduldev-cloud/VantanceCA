class MiddlewareClass {
  final String classId;
  final String className;
  final String termId;
  final String middlewareId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String binarySuccessId;

  MiddlewareClass({
    required this.classId,
    required this.className,
    required this.termId,
    required this.middlewareId,
    required this.createdAt,
    required this.updatedAt,
    required this.binarySuccessId,
  });

  factory MiddlewareClass.fromJson(Map<String, dynamic> json) {
    return MiddlewareClass(
      classId: json['CLASS_ID'] ?? '',
      className: json['CLASS_NAME'] ?? '',
      termId: json['TERM_ID'] ?? '',
      middlewareId: json['MIDDLEWARE_ID'] ?? '',
      createdAt: DateTime.parse(json['CREATED_AT']),
      updatedAt: DateTime.parse(json['UPDATED_AT']),
      binarySuccessId: json['BINARY_SUCCESS_ID'] ?? "-",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CLASS_ID': classId,
      'CLASS_NAME': className,
      'TERM_ID': termId,
      'MIDDLEWARE_ID': middlewareId,
      'CREATED_AT': createdAt.toIso8601String(),
      'UPDATED_AT': updatedAt.toIso8601String(),
      'BINARY_SUCCESS_ID': binarySuccessId,
    };
  }
}
