class TaskDetailsAndStats {
  final String taskTitle;
  final int totalSubmitted;
  final int totalMissing;
  final int avgTeacherGrade;

  TaskDetailsAndStats({
    required this.taskTitle,
    required this.totalSubmitted,
    required this.totalMissing,
    required this.avgTeacherGrade,
  });

  factory TaskDetailsAndStats.fromJson(Map<String, dynamic> json) {
    return TaskDetailsAndStats(
      taskTitle: json['task_title'] ?? '',
      totalSubmitted: json['total_submitted'] ?? 0,
      totalMissing: json['total_missing'] ?? 0,
      avgTeacherGrade: json['avg_teacher_grade'] ?? 0,
    );
  }
}

class TaskDetailsPerStudent {
  final String taskId;
  final String learnerId;
  final String salutation;
  final String firstName;
  final String lastName;
  final String email;
  final String learnerStatus;
  final String hasFingerprintSubmitted;
  final String taskStatus;
  final String? submittedAt;
  final int? submittedWordCount;
  final int? grade;

  TaskDetailsPerStudent({
    required this.taskId,
    required this.learnerId,
    required this.salutation,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.learnerStatus,
    required this.hasFingerprintSubmitted,
    required this.taskStatus,
    this.submittedAt,
    this.submittedWordCount,
    this.grade,
  });

  factory TaskDetailsPerStudent.fromJson(Map<String, dynamic> json) {
    return TaskDetailsPerStudent(
      taskId: json['task_id'] ?? '',
      learnerId: json['learner_id'] ?? '',
      salutation: json['salutation'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      learnerStatus: json['learner_status'] ?? '',
      hasFingerprintSubmitted: json['has_fingerprint_submitted'] ?? 'N',
      taskStatus: json['task_status'] ?? '',
      submittedAt: json['submitted_at'],
      submittedWordCount: json['submitted_word_count'],
      grade: json['grade'],
    );
  }
}

class WritingFingerprintViewDetailsResponse {
  final List<TaskDetailsAndStats> taskDetailsAndStats;
  final List<TaskDetailsPerStudent> taskDetailsPerStudent;
  final String outStatus;

  WritingFingerprintViewDetailsResponse({
    required this.taskDetailsAndStats,
    required this.taskDetailsPerStudent,
    required this.outStatus,
  });

  factory WritingFingerprintViewDetailsResponse.fromJson(Map<String, dynamic> json) {
    return WritingFingerprintViewDetailsResponse(
      taskDetailsAndStats: (json['task_details_and_stats'] as List)
          .map((e) => TaskDetailsAndStats.fromJson(e))
          .toList(),
      taskDetailsPerStudent: (json['task_details_per_student'] as List)
          .map((e) => TaskDetailsPerStudent.fromJson(e))
          .toList(),
      outStatus: json['out_status'] ?? '',
    );
  }
}
