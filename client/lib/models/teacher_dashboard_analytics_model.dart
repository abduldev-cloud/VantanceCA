import 'dart:convert';

// Main response model for teacher dashboard analytics
TeacherDashboardAnalyticsModel teacherDashboardAnalyticsModelFromJson(String str) =>
    TeacherDashboardAnalyticsModel.fromJson(json.decode(str));

String teacherDashboardAnalyticsModelToJson(TeacherDashboardAnalyticsModel data) =>
    json.encode(data.toJson());

class TeacherDashboardAnalyticsModel {
  final PendingSubmissions? pendingSubmissions;
  final GradedThisWeek? gradedThisWeek;
  final ActiveStudentsTeacher? activeStudents;
  final String? message;
  final String? timestamp;

  TeacherDashboardAnalyticsModel({
    this.pendingSubmissions,
    this.gradedThisWeek,
    this.activeStudents,
    this.message,
    this.timestamp,
  });

  factory TeacherDashboardAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      TeacherDashboardAnalyticsModel(
        pendingSubmissions: json["pending_submissions"] == null
            ? null
            : PendingSubmissions.fromJson(json["pending_submissions"]),
        gradedThisWeek: json["graded_this_week"] == null
            ? null
            : GradedThisWeek.fromJson(json["graded_this_week"]),
        activeStudents: json["active_students"] == null
            ? null
            : ActiveStudentsTeacher.fromJson(json["active_students"]),
        message: json["message"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "pending_submissions": pendingSubmissions?.toJson(),
        "graded_this_week": gradedThisWeek?.toJson(),
        "active_students": activeStudents?.toJson(),
        "message": message,
        "timestamp": timestamp,
      };
}

// Pending Submissions model
class PendingSubmissions {
  final int? count;
  final bool? awaitingReview;

  PendingSubmissions({
    this.count,
    this.awaitingReview,
  });

  factory PendingSubmissions.fromJson(Map<String, dynamic> json) =>
      PendingSubmissions(
        count: json["count"],
        awaitingReview: json["awaiting_review"],
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "awaiting_review": awaitingReview,
      };
}

// Graded This Week model
class GradedThisWeek {
  final int? count;
  final List<RecentlyGradedAssignment>? recentlyGradedAssignments;

  GradedThisWeek({
    this.count,
    this.recentlyGradedAssignments,
  });

  factory GradedThisWeek.fromJson(Map<String, dynamic> json) => GradedThisWeek(
        count: json["count"],
        recentlyGradedAssignments: json["recently_graded_assignments"] == null
            ? []
            : List<RecentlyGradedAssignment>.from(json["recently_graded_assignments"]!
                .map((x) => RecentlyGradedAssignment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "recently_graded_assignments": recentlyGradedAssignments == null
            ? []
            : List<dynamic>.from(recentlyGradedAssignments!.map((x) => x.toJson())),
      };
}

// Recently Graded Assignment model
class RecentlyGradedAssignment {
  final String? assignmentId;
  final String? gradedDate;
  final int? studentCount;

  RecentlyGradedAssignment({
    this.assignmentId,
    this.gradedDate,
    this.studentCount,
  });

  factory RecentlyGradedAssignment.fromJson(Map<String, dynamic> json) =>
      RecentlyGradedAssignment(
        assignmentId: json["assignment_id"],
        gradedDate: json["graded_date"],
        studentCount: json["student_count"],
      );

  Map<String, dynamic> toJson() => {
        "assignment_id": assignmentId,
        "graded_date": gradedDate,
        "student_count": studentCount,
      };
}

// Active Students for Teacher model
class ActiveStudentsTeacher {
  final int? totalCount;
  final List<TeacherGradeWiseBreakdown>? gradeWiseBreakdown;

  ActiveStudentsTeacher({
    this.totalCount,
    this.gradeWiseBreakdown,
  });

  factory ActiveStudentsTeacher.fromJson(Map<String, dynamic> json) => ActiveStudentsTeacher(
        totalCount: json["total_count"],
        gradeWiseBreakdown: json["grade_wise_breakdown"] == null
            ? []
            : List<TeacherGradeWiseBreakdown>.from(json["grade_wise_breakdown"]!
                .map((x) => TeacherGradeWiseBreakdown.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total_count": totalCount,
        "grade_wise_breakdown": gradeWiseBreakdown == null
            ? []
            : List<dynamic>.from(gradeWiseBreakdown!.map((x) => x.toJson())),
      };
}

// Teacher Grade-wise breakdown model
class TeacherGradeWiseBreakdown {
  final String? gradeName;
  final int? studentCount;

  TeacherGradeWiseBreakdown({
    this.gradeName,
    this.studentCount,
  });

  factory TeacherGradeWiseBreakdown.fromJson(Map<String, dynamic> json) =>
      TeacherGradeWiseBreakdown(
        gradeName: json["grade_name"],
        studentCount: json["student_count"],
      );

  Map<String, dynamic> toJson() => {
        "grade_name": gradeName,
        "student_count": studentCount,
      };
}
