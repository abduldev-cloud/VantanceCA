class MiddlewareGrade {
  final String binarySuccessId;
  final String? lmsId;
  final int? score;
  final String studentBinarySuccessId;
  final String assignmentBinarySuccessId;
  final String teacherBinarySuccessId;
  final String classBinarySuccessId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String instituteId;

  MiddlewareGrade({
    required this.binarySuccessId,
    this.lmsId,
    this.score,
    required this.studentBinarySuccessId,
    required this.assignmentBinarySuccessId,
    required this.teacherBinarySuccessId,
    required this.classBinarySuccessId,
    required this.createdAt,
    required this.updatedAt,
    required this.instituteId,
  });

  factory MiddlewareGrade.fromJson(Map<String, dynamic> json) {
    return MiddlewareGrade(
      binarySuccessId: json['BINARY_SUCCESS_ID'] as String? ?? '',
      lmsId: json['LMS_ID'] as String?,
      score: json['SCORE'] as int?,
      studentBinarySuccessId:
          json['STUDENT_BINARY_SUCCESS_ID'] as String? ?? '',
      assignmentBinarySuccessId:
          json['ASSIGNMENT_BINARY_SUCCESS_ID'] as String? ?? '',
      teacherBinarySuccessId:
          json['TEACHER_BINARY_SUCCESS_ID'] as String? ?? '',
      classBinarySuccessId: json['CLASS_BINARY_SUCCESS_ID'] as String? ?? '',
      createdAt: DateTime.parse(
          json['CREATED_AT'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['UPDATED_AT'] as String? ?? DateTime.now().toIso8601String()),
      instituteId: json['INSTITUTE_ID'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'BINARY_SUCCESS_ID': binarySuccessId,
      'LMS_ID': lmsId,
      'SCORE': score,
      'STUDENT_BINARY_SUCCESS_ID': studentBinarySuccessId,
      'ASSIGNMENT_BINARY_SUCCESS_ID': assignmentBinarySuccessId,
      'TEACHER_BINARY_SUCCESS_ID': teacherBinarySuccessId,
      'CLASS_BINARY_SUCCESS_ID': classBinarySuccessId,
      'CREATED_AT': createdAt.toIso8601String(),
      'UPDATED_AT': updatedAt.toIso8601String(),
      'INSTITUTE_ID': instituteId,
    };
  }
}
