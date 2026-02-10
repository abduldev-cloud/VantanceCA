import 'dart:convert';

// Main response model for teacher dashboard
TeacherDashboardModel teacherDashboardModelFromJson(String str) =>
    TeacherDashboardModel.fromJson(json.decode(str));

String teacherDashboardModelToJson(TeacherDashboardModel data) =>
    json.encode(data.toJson());

class TeacherDashboardModel {
  final bool? success;
  final TeacherDashboardData? data;
  final String? message;
  final String? timestamp;
  final String? source;
  final double? requestDurationSeconds;

  TeacherDashboardModel({
    this.success,
    this.data,
    this.message,
    this.timestamp,
    this.source,
    this.requestDurationSeconds,
  });

  factory TeacherDashboardModel.fromJson(Map<String, dynamic> json) =>
      TeacherDashboardModel(
        success: json["success"],
        data: json["data"] == null
            ? null
            : TeacherDashboardData.fromJson(json["data"]),
        message: json["message"],
        timestamp: json["timestamp"],
        source: json["source"],
        requestDurationSeconds: json["request_duration_seconds"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
        "timestamp": timestamp,
        "source": source,
        "request_duration_seconds": requestDurationSeconds,
      };
}

// Teacher dashboard data model
class TeacherDashboardData {
  final String? teacherEmail;
  final TeacherAssignments? assignments;
  final TeacherStudents? students;

  TeacherDashboardData({
    this.teacherEmail,
    this.assignments,
    this.students,
  });

  factory TeacherDashboardData.fromJson(Map<String, dynamic> json) =>
      TeacherDashboardData(
        teacherEmail: json["teacher_email"],
        assignments: json["assignments"] == null
            ? null
            : TeacherAssignments.fromJson(json["assignments"]),
        students: json["students"] == null
            ? null
            : TeacherStudents.fromJson(json["students"]),
      );

  Map<String, dynamic> toJson() => {
        "teacher_email": teacherEmail,
        "assignments": assignments?.toJson(),
        "students": students?.toJson(),
      };
}

// Teacher assignments model
class TeacherAssignments {
  final int? gradedCount;
  final int? inReviewCount;
  final int? totalAssignments;

  TeacherAssignments({
    this.gradedCount,
    this.inReviewCount,
    this.totalAssignments,
  });

  factory TeacherAssignments.fromJson(Map<String, dynamic> json) =>
      TeacherAssignments(
        gradedCount: json["graded_count"],
        inReviewCount: json["in_review_count"],
        totalAssignments: json["total_assignments"],
      );

  Map<String, dynamic> toJson() => {
        "graded_count": gradedCount,
        "in_review_count": inReviewCount,
        "total_assignments": totalAssignments,
      };
}

// Teacher students model
class TeacherStudents {
  final int? totalStudents;

  TeacherStudents({
    this.totalStudents,
  });

  factory TeacherStudents.fromJson(Map<String, dynamic> json) =>
      TeacherStudents(
        totalStudents: json["total_students"],
      );

  Map<String, dynamic> toJson() => {
        "total_students": totalStudents,
      };
}
