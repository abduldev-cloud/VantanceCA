// To parse this JSON data, do
//
//     final teachersDashboardModel = teachersDashboardModelFromJson(jsonString);

import 'dart:convert';

TeachersDashboardModel teachersDashboardModelFromJson(String str) =>
    TeachersDashboardModel.fromJson(json.decode(str));

String teachersDashboardModelToJson(TeachersDashboardModel data) =>
    json.encode(data.toJson());

class TeachersDashboardModel {
  final String? teacherId;
  final String? teacherName;
  final int? pendingReviewCount;
  final int? gradedThisWeekCount;
  final int? activeStudents24H;
  final int? grade9Count;
  final int? grade10Count;
  final int? grade11Count;
  final double? writingFingerprintDeviationAvg;
  final int? writingFingerprintTotal;
  final int? aiPromptUsedAvg;
  final int? aiPromptUsedTotal;
  final int? authorshipAnomalyAlerts;

  TeachersDashboardModel({
    this.teacherId,
    this.teacherName,
    this.pendingReviewCount,
    this.gradedThisWeekCount,
    this.activeStudents24H,
    this.grade9Count,
    this.grade10Count,
    this.grade11Count,
    this.writingFingerprintDeviationAvg,
    this.writingFingerprintTotal,
    this.aiPromptUsedAvg,
    this.aiPromptUsedTotal,
    this.authorshipAnomalyAlerts,
  });

  factory TeachersDashboardModel.fromJson(Map<String, dynamic> json) =>
      TeachersDashboardModel(
        teacherId: json["teacher_id"],
        teacherName: json["teacher_name"],
        pendingReviewCount: json["pending_review_count"],
        gradedThisWeekCount: json["graded_this_week_count"],
        activeStudents24H: json["active_students_24h"],
        grade9Count: json["grade_9_count"],
        grade10Count: json["grade_10_count"],
        grade11Count: json["grade_11_count"],
        writingFingerprintDeviationAvg:
            json["writing_fingerprint_deviation_avg"]?.toDouble(),
        writingFingerprintTotal: json["writing_fingerprint_total"],
        aiPromptUsedAvg: json["ai_prompt_used_avg"],
        aiPromptUsedTotal: json["ai_prompt_used_total"],
        authorshipAnomalyAlerts: json["authorship_anomaly_alerts"],
      );

  Map<String, dynamic> toJson() => {
        "teacher_id": teacherId,
        "teacher_name": teacherName,
        "pending_review_count": pendingReviewCount,
        "graded_this_week_count": gradedThisWeekCount,
        "active_students_24h": activeStudents24H,
        "grade_9_count": grade9Count,
        "grade_10_count": grade10Count,
        "grade_11_count": grade11Count,
        "writing_fingerprint_deviation_avg": writingFingerprintDeviationAvg,
        "writing_fingerprint_total": writingFingerprintTotal,
        "ai_prompt_used_avg": aiPromptUsedAvg,
        "ai_prompt_used_total": aiPromptUsedTotal,
        "authorship_anomaly_alerts": authorshipAnomalyAlerts,
      };
}
