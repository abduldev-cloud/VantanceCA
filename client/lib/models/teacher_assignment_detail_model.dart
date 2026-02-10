import 'dart:convert';

/// Converts JSON string to AssignmentDetailResponse
AssignmentDetailResponse assignmentDetailResponseFromJson(String str) =>
    AssignmentDetailResponse.fromJson(json.decode(str));

/// Converts AssignmentDetailResponse to JSON string
String assignmentDetailResponseToJson(AssignmentDetailResponse data) =>
    json.encode(data.toJson());

class AssignmentDetailResponse {
  final List<TaskStats> taskDetailsAndStats;
  final List<Learner> taskDetailsPerStudent;
  final String outStatus;

  AssignmentDetailResponse({
    required this.taskDetailsAndStats,
    required this.taskDetailsPerStudent,
    required this.outStatus,
  });

  factory AssignmentDetailResponse.fromJson(Map<String, dynamic> json) =>
      AssignmentDetailResponse(
        taskDetailsAndStats: json["task_details_and_stats"] == null
            ? []
            : List<TaskStats>.from(json["task_details_and_stats"]
                .map((x) => TaskStats.fromJson(x))),
        taskDetailsPerStudent: json["task_details_per_student"] == null
            ? []
            : List<Learner>.from(json["task_details_per_student"]
                .map((x) => Learner.fromJson(x))),
        outStatus: json["out_status"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "task_details_and_stats":
            List<dynamic>.from(taskDetailsAndStats.map((x) => x.toJson())),
        "task_details_per_student":
            List<dynamic>.from(taskDetailsPerStudent.map((x) => x.toJson())),
        "out_status": outStatus,
      };
}

class TaskStats {
  final String taskId;
  final String taskTitle;
  final int totalSubmitted;
  final int totalMissing;
  final int avgTeacherGrade;

  TaskStats({
    required this.taskId,
    required this.taskTitle,
    required this.totalSubmitted,
    required this.totalMissing,
    required this.avgTeacherGrade,
  });

  factory TaskStats.fromJson(Map<String, dynamic> json) => TaskStats(
        taskId: json["task_id"] ?? '',
        taskTitle: json["task_title"] ?? '',
        totalSubmitted: json["total_submitted"] ?? 0,
        totalMissing: json["total_missing"] ?? 0,
        avgTeacherGrade: json["avg_teacher_grade"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "task_id": taskId,
        "task_title": taskTitle,
        "total_submitted": totalSubmitted,
        "total_missing": totalMissing,
        "avg_teacher_grade": avgTeacherGrade,
      };
}

class Learner {
  final String learnerId;
  final String salutation;
  final String firstName;
  final String lastName;
  final String email;
  final String learnerStatus;
  final bool hasFingerprintSubmitted;
  final String taskStatus;
  final DateTime? submittedAt;
  final int submittedWordCount;
  final int? grade;
  final String? userId; // NEW
  final int? rn; // NEW
  final int totalPoints; // <-- Added this line

  Learner({
    required this.learnerId,
    required this.salutation,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.learnerStatus,
    required this.hasFingerprintSubmitted,
    required this.taskStatus,
    required this.submittedAt,
    required this.submittedWordCount,
    this.grade,
    this.userId, // NEW
    this.rn, // NEW
    this.totalPoints = 0, // <-- Provide a default if absent in JSON
  });

  factory Learner.fromJson(Map<String, dynamic> json) => Learner(
        learnerId: json["learner_id"] ?? '',
        salutation: json["salutation"] ?? '',
        firstName: json["first_name"] ?? '',
        lastName: json["last_name"] ?? '',
        email: json["email"] ?? '',
        learnerStatus: json["learner_status"] ?? '',
        hasFingerprintSubmitted:
            (json["has_fingerprint_submitted"] ?? 'N') == 'Y',
        taskStatus: json["task_status"] ?? '',
        submittedAt: json["submitted_at"] != null
            ? DateTime.tryParse(json["submitted_at"])
            : null,
        submittedWordCount: json["submitted_word_count"] ?? 0,
        grade: json["grade"],
        userId: json["user_id"]?.toString().trim(), // NEW
        rn: json["rn"] != null ? int.tryParse(json["rn"].toString()) : null, // NEW
        totalPoints: json["total_points"] ?? 0, // <-- Assign from JSON, default 0
      );

  Map<String, dynamic> toJson() => {
        "learner_id": learnerId,
        "salutation": salutation,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "learner_status": learnerStatus,
        "has_fingerprint_submitted": hasFingerprintSubmitted ? 'Y' : 'N',
        "task_status": taskStatus,
        "submitted_at": submittedAt?.toIso8601String(),
        "submitted_word_count": submittedWordCount,
        "grade": grade,
        "user_id": userId, // NEW
        "rn": rn, // NEW
        "total_points": totalPoints, // <-- Add to serialization
      };
}
