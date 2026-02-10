/*
// To parse this JSON data, do
//
//     final studentCalendarModel = studentCalendarModelFromJson(jsonString);

import 'dart:convert';

StudentCalendarModel studentCalendarModelFromJson(String str) =>
    StudentCalendarModel.fromJson(json.decode(str));

String studentCalendarModelToJson(StudentCalendarModel data) =>
    json.encode(data.toJson());

class StudentCalendarModel {
  final String? studentId;
  final String? studentName;
  final String? classId;
  final String? className;
  final String? gradeName;
  final String? taskId;
  final String? assignmentPrompt;
  final DateTime? dueDate;
  final String? submissionStatus;

  StudentCalendarModel({
    this.studentId,
    this.studentName,
    this.classId,
    this.className,
    this.gradeName,
    this.taskId,
    this.assignmentPrompt,
    this.dueDate,
    this.submissionStatus,
  });

  factory StudentCalendarModel.fromJson(Map<String, dynamic> json) =>
      StudentCalendarModel(
        studentId: json["student_id"],
        studentName: json["student_name"],
        classId: json["class_id"],
        className: json["class_name"],
        gradeName: json["grade_name"],
        taskId: json["task_id"],
        assignmentPrompt: json["assignment_prompt"],
        dueDate:
            json["due_date"] == null ? null : DateTime.parse(json["due_date"]),
        submissionStatus: json["submission_status"],
      );

  Map<String, dynamic> toJson() => {
        "student_id": studentId,
        "student_name": studentName,
        "class_id": classId,
        "class_name": className,
        "grade_name": gradeName,
        "task_id": taskId,
        "assignment_prompt": assignmentPrompt,
        "due_date": dueDate?.toIso8601String(),
        "submission_status": submissionStatus,
      };
}
*/

// To parse this JSON data, do
//
//     final studentCalendarModel = studentCalendarModelFromJson(jsonString);

import 'dart:convert';

StudentCalendarModel studentCalendarModelFromJson(String str) => StudentCalendarModel.fromJson(json.decode(str));

String studentCalendarModelToJson(StudentCalendarModel data) => json.encode(data.toJson());

class StudentCalendarModel {
  String? outStatus;
  List<LearnerSummary>? learnerSummary;
  List<TasksDueSummary>? tasksDueSummary;

  StudentCalendarModel({
    this.outStatus,
    this.learnerSummary,
    this.tasksDueSummary,
  });

  factory StudentCalendarModel.fromJson(Map<String, dynamic> json) => StudentCalendarModel(
    outStatus: json["out_status"],
    learnerSummary: json["learner_summary"] == null ? [] : List<LearnerSummary>.from(json["learner_summary"]!.map((x) => LearnerSummary.fromJson(x))),
    tasksDueSummary: json["tasks_due_summary"] == null ? [] : List<TasksDueSummary>.from(json["tasks_due_summary"]!.map((x) => TasksDueSummary.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "out_status": outStatus,
    "learner_summary": learnerSummary == null ? [] : List<dynamic>.from(learnerSummary!.map((x) => x.toJson())),
    "tasks_due_summary": tasksDueSummary == null ? [] : List<dynamic>.from(tasksDueSummary!.map((x) => x.toJson())),
  };
}

class LearnerSummary {
  String? learnerId;
  String? firstName;
  String? lastName;
  String? gradeName;

  LearnerSummary({
    this.learnerId,
    this.firstName,
    this.lastName,
    this.gradeName,
  });

  factory LearnerSummary.fromJson(Map<String, dynamic> json) => LearnerSummary(
    learnerId: json["learner_id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    gradeName: json["grade_name"],
  );

  Map<String, dynamic> toJson() => {
    "learner_id": learnerId,
    "first_name": firstName,
    "last_name": lastName,
    "grade_name": gradeName,
  };
}

class TasksDueSummary {
  String? taskId;
  String? learnerId;
  String? taskTitle;
  String? className;
  DateTime? dueDate;
  String? taskType;

  TasksDueSummary({
    this.taskId,
    this.learnerId,
    this.taskTitle,
    this.className,
    this.dueDate,
    this.taskType,
  });

  factory TasksDueSummary.fromJson(Map<String, dynamic> json) => TasksDueSummary(
    taskId: json["task_id"],
    learnerId: json["learner_id"],
    taskTitle: json["task_title"],
    className: json["class_name"],
    dueDate: json["due_date"] == null ? null : DateTime.parse(json["due_date"]),
    taskType: json["task_type"],
  );

  Map<String, dynamic> toJson() => {
    "task_id": taskId,
    "learner_id": learnerId,
    "task_title": taskTitle,
    "class_name": className,
    "due_date": dueDate?.toIso8601String(),
    "task_type": taskType,
  };
}

