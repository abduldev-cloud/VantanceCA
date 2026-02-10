class CreateClassRequest {
  final String instituteId;
  final String teacherId;
  final String className;
  final int maxLearners;
  final String gradeLevelId;
  final String description;
  final String term;
  final String createdBy;
  final String inviteCode;

  CreateClassRequest({
    required this.instituteId,
    required this.teacherId,
    required this.className,
    required this.maxLearners,
    required this.gradeLevelId,
    required this.description,
    required this.term,
    required this.createdBy,
    required this.inviteCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'institute_id': instituteId,
      'teacher_id': teacherId,
      'class_name': className,
      'max_learners': maxLearners,
      'grade_name': gradeLevelId,
      'description': description,
      'created_by': createdBy,
      'invite_code': inviteCode,
    };
  }
}

class CreateClassResponse {
  final bool success;
  final String? message;
  final String? classId;
  final String? classCode;
  final String? error;

  CreateClassResponse({
    required this.success,
    this.message,
    this.classId,
    this.classCode,
     this.error,
  });

  factory CreateClassResponse.fromJson(Map<String, dynamic> json) {
    // Handle both old and new API response formats
    bool isSuccess = false;
    if (json['success'] != null) {
      isSuccess = json['success'] ?? false;
    } else if (json['out_status'] != null) {
      isSuccess = json['out_status'] == 'SUCCESS';
    }
    
    return CreateClassResponse(
      success: isSuccess,
      message: json['message'] ?? json['out_status'],
      classId: json['class_id'] ?? json['out_class_id'],
      classCode: json['class_code'],
      error: json['error'], 
    );
  }
}
