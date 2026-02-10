class MiddlewareAssignment {
  final String binarySuccessId;
  final String lmsId;
  final String teacherBinarySuccessId;
  final DateTime? dueAt;
  final int? points;
  final String title;
  final String classBinarySuccessId;
  final String instituteId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String processStatus;
  final String? errorMessage;
  final String description;

  MiddlewareAssignment({
    required this.binarySuccessId,
    required this.lmsId,
    required this.teacherBinarySuccessId,
    required this.dueAt,
    required this.points,
    required this.title,
    required this.classBinarySuccessId,
    required this.instituteId,
    required this.createdAt,
    required this.updatedAt,
    required this.processStatus,
    required this.errorMessage,
    required this.description,
  });

  factory MiddlewareAssignment.fromJson(Map<String, dynamic> json) {
    return MiddlewareAssignment(
      binarySuccessId: json['BINARY_SUCCESS_ID'],
      lmsId: json['LMS_ID'],
      teacherBinarySuccessId: json['TEACHER_BINARY_SUCCESS_ID'],
      dueAt: json['DUE_AT'] != null ? DateTime.parse(json['DUE_AT']) : null,
      points: json['POINTS'],
      title: json['TITLE'],
      classBinarySuccessId: json['CLASS_BINARY_SUCCESS_ID'],
      instituteId: json['INSTITUTE_ID'],
      createdAt: DateTime.parse(json['CREATED_AT']),
      updatedAt: DateTime.parse(json['UPDATED_AT']),
      processStatus: json['PROCESS_STATUS'],
      errorMessage: json['ERROR_MESSAGE'],
      description: json['DESCRIPTION'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'BINARY_SUCCESS_ID': binarySuccessId,
      'LMS_ID': lmsId,
      'TEACHER_BINARY_SUCCESS_ID': teacherBinarySuccessId,
      'DUE_AT': dueAt?.toIso8601String(),
      'POINTS': points,
      'TITLE': title,
      'CLASS_BINARY_SUCCESS_ID': classBinarySuccessId,
      'INSTITUTE_ID': instituteId,
      'CREATED_AT': createdAt.toIso8601String(),
      'UPDATED_AT': updatedAt.toIso8601String(),
      'PROCESS_STATUS': processStatus,
      'ERROR_MESSAGE': errorMessage,
      'DESCRIPTION': description,
    };
  }
}
