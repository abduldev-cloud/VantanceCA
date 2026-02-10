import 'package:intl/intl.dart';

class StudentAssignmentModel {
  List<LearnerSummary>? learnerSummary;
  List<TaskStatusCount>? taskStatusCount;
  List<AssignmentTask>? tasksDetails;
  String? outStatus;

  StudentAssignmentModel({
    this.learnerSummary,
    this.taskStatusCount,
    this.tasksDetails,
    this.outStatus,
  });

  factory StudentAssignmentModel.fromJson(Map<String, dynamic> json) =>
      StudentAssignmentModel(
        learnerSummary: json["learner_summary"] == null
            ? []
            : List<LearnerSummary>.from(
                json["learner_summary"].map((x) => LearnerSummary.fromJson(x))),
        taskStatusCount: json["task_status_count"] == null
            ? []
            : List<TaskStatusCount>.from(
                json["task_status_count"].map((x) => TaskStatusCount.fromJson(x))),
        tasksDetails: json["tasks_details"] == null
            ? []
            : List<AssignmentTask>.from(
                json["tasks_details"].map((x) => AssignmentTask.fromJson(x))),
        outStatus: json["out_status"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "learner_summary": learnerSummary == null
            ? []
            : List<dynamic>.from(learnerSummary!.map((x) => x.toJson())),
        "task_status_count": taskStatusCount == null
            ? []
            : List<dynamic>.from(taskStatusCount!.map((x) => x.toJson())),
        "tasks_details": tasksDetails == null
            ? []
            : List<dynamic>.from(tasksDetails!.map((x) => x.toJson())),
        "out_status": outStatus,
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
        learnerId: json["learner_id"] ?? "",
        firstName: json["first_name"] ?? "",
        lastName: json["last_name"] ?? "",
        gradeName: json["grade_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "learner_id": learnerId,
        "first_name": firstName,
        "last_name": lastName,
        "grade_name": gradeName,
      };
}

class TaskStatusCount {
  int? activeTasks;
  int? pending;
  int? graded;
  int? fingerprintTasks;

  TaskStatusCount({
    this.activeTasks,
    this.pending,
    this.graded,
    this.fingerprintTasks,
  });

  factory TaskStatusCount.fromJson(Map<String, dynamic> json) => TaskStatusCount(
        activeTasks: json["active_tasks"] ?? 0,
        pending: json["pending"] ?? 0,
        graded: json["graded"] ?? 0,
        fingerprintTasks: json["fingerprint_tasks"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "active_tasks": activeTasks,
        "pending": pending,
        "graded": graded,
        "fingerprint_tasks": fingerprintTasks,
      };
}

class AssignmentTask {
  String? classId;
  String? className;
  String? taskId;
  String? taskTitle;
  String? taskDescription;
  String? dueDate;
  String? dueTime;
  String? classGrade;
  String? taskType;
  String? taskStatus;
  DateTime? submittedAt; // ✅ Changed from String? to DateTime?

  AssignmentTask({
    this.classId,
    this.className,
    this.taskId,
    this.taskTitle,
    this.taskDescription,
    this.dueDate,
    this.dueTime,
    this.classGrade,
    this.taskType,
    this.taskStatus,
    this.submittedAt,
  });

  factory AssignmentTask.fromJson(Map<String, dynamic> json) => AssignmentTask(
        classId: json["class_id"] ?? "",
        className: json["class_name"] ?? "",
        taskId: json["task_id"] ?? "",
        taskTitle: json["task_title"] ?? "",
        taskDescription: json["task_description"] ?? "",
        dueDate: json["due_date"] ?? "",
        dueTime: json["due_time"] ?? "",
        classGrade: json["class_grade"] ?? "",
        taskType: json["task_type"] ?? "",
        taskStatus: json["task_status"] ?? "",
        submittedAt: json["submitted_at"] != null && json["submitted_at"] != ""
            ? DateTime.tryParse(json["submitted_at"])
            : null, // ✅ Parse safely
      );

  Map<String, dynamic> toJson() => {
        "class_id": classId,
        "class_name": className,
        "task_id": taskId,
        "task_title": taskTitle,
        "task_description": taskDescription,
        "due_date": dueDate,
        "due_time": dueTime,
        "class_grade": classGrade,
        "task_type": taskType,
        "task_status": taskStatus,
        "submitted_at": submittedAt?.toIso8601String(),
      };

  /// Parse full due datetime from dueDate and dueTime strings, handling extra spaces
  DateTime get dueDateTime {
    try {
      final dateStr = (dueDate ?? "").replaceAll(RegExp(r'\s+'), ' ').trim();
      final timeStr = (dueTime ?? "11:59:59 PM").trim();
      final combined = "$dateStr $timeStr";
      return DateFormat("MMMM d, yyyy hh:mm:ss a").parse(combined);
    } catch (e) {
      return DateTime(9999);
    }
  }
}
