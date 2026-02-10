// To parse this JSON data, do
//
//     final teacherCalendarModel = teacherCalendarModelFromJson(jsonString);

import 'dart:convert';

TeacherCalendarModel teacherCalendarModelFromJson(String str) => TeacherCalendarModel.fromJson(json.decode(str));

String teacherCalendarModelToJson(TeacherCalendarModel data) => json.encode(data.toJson());

class TeacherCalendarModel {
  List<TeacherSummary>? teacherSummary;
  List<TasksDueSummary>? tasksDueSummary;
  String? outStatus;

  TeacherCalendarModel({
    this.teacherSummary,
    this.tasksDueSummary,
    this.outStatus,
  });

  factory TeacherCalendarModel.fromJson(Map<String, dynamic> json) => TeacherCalendarModel(
    teacherSummary: json["teacher_summary"] == null ? [] : List<TeacherSummary>.from(json["teacher_summary"]!.map((x) => TeacherSummary.fromJson(x))),
    tasksDueSummary: json["tasks_due_summary"] == null ? [] : List<TasksDueSummary>.from(json["tasks_due_summary"]!.map((x) => TasksDueSummary.fromJson(x))),
    outStatus: json["out_status"],
  );

  Map<String, dynamic> toJson() => {
    "teacher_summary": teacherSummary == null ? [] : List<dynamic>.from(teacherSummary!.map((x) => x.toJson())),
    "tasks_due_summary": tasksDueSummary == null ? [] : List<dynamic>.from(tasksDueSummary!.map((x) => x.toJson())),
    "out_status": outStatus,
  };
}

class TasksDueSummary {
  String? taskId;
  String? teacherId;
  String? taskTitle;
  String? className;
  DateTime? dueDate;
  String? taskType;

  TasksDueSummary({
    this.taskId,
    this.teacherId,
    this.taskTitle,
    this.className,
    this.dueDate,
    this.taskType,
  });

  factory TasksDueSummary.fromJson(Map<String, dynamic> json) => TasksDueSummary(
    taskId: json["task_id"],
    teacherId: json["teacher_id"],
    taskTitle: json["task_title"],
    className: json["class_name"],
    dueDate: json["due_date"] == null ? null : DateTime.parse(json["due_date"]),
    taskType: json["task_type"],
  );

  Map<String, dynamic> toJson() => {
    "task_id": taskId,
    "teacher_id": teacherId,
    "task_title": taskTitle,
    "class_name": className,
    "due_date": dueDate?.toIso8601String(),
    "task_type": taskType,
  };
}

class TeacherSummary {
  String? teacherId;
  String? salutation;
  String? firstName;
  String? lastName;

  TeacherSummary({
    this.teacherId,
    this.salutation,
    this.firstName,
    this.lastName,
  });

  factory TeacherSummary.fromJson(Map<String, dynamic> json) => TeacherSummary(
    teacherId: json["teacher_id"],
    salutation: json["salutation"],
    firstName: json["first_name"],
    lastName: json["last_name"],
  );

  Map<String, dynamic> toJson() => {
    "teacher_id": teacherId,
    "salutation": salutation,
    "first_name": firstName,
    "last_name": lastName,
  };
}
