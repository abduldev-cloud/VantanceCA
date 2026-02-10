import 'dart:convert';

/// Converts JSON string to TeachersAssignmentsModel
TeachersAssignmentsModel teachersAssignmentsModelFromJson(String str) =>
    TeachersAssignmentsModel.fromJson(json.decode(str));

/// Converts TeachersAssignmentsModel to JSON string
String teachersAssignmentsModelToJson(TeachersAssignmentsModel data) =>
    json.encode(data.toJson());

class TeachersAssignmentsModel {
  final List<TaskCount> taskCounts;
  final List<TaskSummary> taskSummary;

  TeachersAssignmentsModel({
    required this.taskCounts,
    required this.taskSummary,
  });

  /// ✅ Added getter so old code using `.assignmentOverview` still works
  List<TaskSummary> get assignmentOverview => taskSummary;

  factory TeachersAssignmentsModel.fromJson(Map<String, dynamic> json) =>
      TeachersAssignmentsModel(
        taskCounts: json["task_counts"] == null
            ? []
            : List<TaskCount>.from(
                json["task_counts"].map((x) => TaskCount.fromJson(x))),
        taskSummary: json["task_summary"] == null
            ? []
            : List<TaskSummary>.from(
                json["task_summary"].map((x) => TaskSummary.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "task_counts": List<dynamic>.from(taskCounts.map((x) => x.toJson())),
        "task_summary": List<dynamic>.from(taskSummary.map((x) => x.toJson())),
      };
}

class TaskCount {
  final int draftTasks;
  final int scheduledTasks;
  final int activeTasks;

  TaskCount({
    required this.draftTasks,
    required this.scheduledTasks,
    required this.activeTasks,
  });

  factory TaskCount.fromJson(Map<String, dynamic> json) => TaskCount(
        draftTasks: json["draft_tasks"] ?? 0,
        scheduledTasks: json["scheduled_tasks"] ?? 0,
        activeTasks: json["active_tasks"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "draft_tasks": draftTasks,
        "scheduled_tasks": scheduledTasks,
        "active_tasks": activeTasks,
      };
}

class TaskSummary {
  final String taskId;
  final String taskTitle;
  final int submittedCount;
  final int totalLearners;
  final String className;
  final String gradeName;
  final String dueDate;
  final String status;

  TaskSummary({
    required this.taskId,
    required this.taskTitle,
    required this.submittedCount,
    required this.totalLearners,
    required this.className,
    required this.gradeName,
    required this.dueDate,
    required this.status,
  });

  factory TaskSummary.fromJson(Map<String, dynamic> json) => TaskSummary(
        taskId: json["task_id"] ?? '',
        taskTitle: json["task_title"] ?? '',
        submittedCount: json["submitted_count"] ?? 0,
        totalLearners: json["total_learners"] ?? 0,
        className: json["class_name"] ?? '',
        gradeName: json["grade_name"] ?? '',
        dueDate: json["due_date"] ?? '',
        status: json["status"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "task_id": taskId,
        "task_title": taskTitle,
        "submitted_count": submittedCount,
        "total_learners": totalLearners,
        "class_name": className,
        "grade_name": gradeName,
        "due_date": dueDate,
        "status": status,
      };
}
