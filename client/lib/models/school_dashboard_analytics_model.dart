import 'dart:convert';

// Main response model for school dashboard analytics
SchoolDashboardAnalyticsModel schoolDashboardAnalyticsModelFromJson(String str) =>
    SchoolDashboardAnalyticsModel.fromJson(json.decode(str));

String schoolDashboardAnalyticsModelToJson(SchoolDashboardAnalyticsModel data) =>
    json.encode(data.toJson());

class SchoolDashboardAnalyticsModel {
  final Assignments? assignments;
  final ActiveTeachers? activeTeachers;
  final ActiveStudents? activeStudents;
  final String? message;
  final String? timestamp;

  SchoolDashboardAnalyticsModel({
    this.assignments,
    this.activeTeachers,
    this.activeStudents,
    this.message,
    this.timestamp,
  });

  factory SchoolDashboardAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      SchoolDashboardAnalyticsModel(
        assignments: json["assignments"] == null
            ? null
            : Assignments.fromJson(json["assignments"]),
        activeTeachers: json["active_teachers"] == null
            ? null
            : ActiveTeachers.fromJson(json["active_teachers"]),
        activeStudents: json["active_students"] == null
            ? null
            : ActiveStudents.fromJson(json["active_students"]),
        message: json["message"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "assignments": assignments?.toJson(),
        "active_teachers": activeTeachers?.toJson(),
        "active_students": activeStudents?.toJson(),
        "message": message,
        "timestamp": timestamp,
      };
}

// Assignments model
class Assignments {
  final int? pendingReviewCount;
  final int? gradedCount;

  Assignments({
    this.pendingReviewCount,
    this.gradedCount,
  });

  factory Assignments.fromJson(Map<String, dynamic> json) => Assignments(
        pendingReviewCount: json["pending_review_count"],
        gradedCount: json["graded_count"],
      );

  Map<String, dynamic> toJson() => {
        "pending_review_count": pendingReviewCount,
        "graded_count": gradedCount,
      };
}

// Active Teachers model
class ActiveTeachers {
  final int? totalCount;
  final List<TeacherGradeWiseBreakdown>? gradeWiseBreakdown;

  ActiveTeachers({
    this.totalCount,
    this.gradeWiseBreakdown,
  });

  factory ActiveTeachers.fromJson(Map<String, dynamic> json) => ActiveTeachers(
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

// Teacher grade-wise breakdown model
class TeacherGradeWiseBreakdown {
  final String? gradeName;
  final int? teacherCount;

  TeacherGradeWiseBreakdown({
    this.gradeName,
    this.teacherCount,
  });

  factory TeacherGradeWiseBreakdown.fromJson(Map<String, dynamic> json) =>
      TeacherGradeWiseBreakdown(
        gradeName: json["grade_name"],
        teacherCount: json["teacher_count"],
      );

  Map<String, dynamic> toJson() => {
        "grade_name": gradeName,
        "teacher_count": teacherCount,
      };
}

// Active Students model
class ActiveStudents {
  final int? totalCount;
  final List<GradeWiseBreakdown>? gradeWiseBreakdown;

  ActiveStudents({
    this.totalCount,
    this.gradeWiseBreakdown,
  });

  factory ActiveStudents.fromJson(Map<String, dynamic> json) => ActiveStudents(
        totalCount: json["total_count"],
        gradeWiseBreakdown: json["grade_wise_breakdown"] == null
            ? []
            : List<GradeWiseBreakdown>.from(json["grade_wise_breakdown"]!
                .map((x) => GradeWiseBreakdown.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total_count": totalCount,
        "grade_wise_breakdown": gradeWiseBreakdown == null
            ? []
            : List<dynamic>.from(gradeWiseBreakdown!.map((x) => x.toJson())),
      };
}

// Grade-wise breakdown model
class GradeWiseBreakdown {
  final String? gradeName;
  final int? studentCount;

  GradeWiseBreakdown({
    this.gradeName,
    this.studentCount,
  });

  factory GradeWiseBreakdown.fromJson(Map<String, dynamic> json) =>
      GradeWiseBreakdown(
        gradeName: json["grade_name"],
        studentCount: json["student_count"],
      );

  Map<String, dynamic> toJson() => {
        "grade_name": gradeName,
        "student_count": studentCount,
      };
}
