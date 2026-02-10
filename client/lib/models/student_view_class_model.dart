import 'dart:convert';

/// Convert JSON string to StudentViewClassModel object
StudentViewClassModel studentViewClassModelFromJson(String str) =>
    StudentViewClassModel.fromJson(json.decode(str));

/// Convert StudentViewClassModel object to JSON string
String studentViewClassModelToJson(StudentViewClassModel data) =>
    json.encode(data.toJson());

/// Model Class for Student View Class
class StudentViewClassModel {
  final String learnerId;
  final String firstName;
  final String lastName;
  final String classId;
  final String className;
  final String gradeName;
  final String taskId;
  final String assignmentTitle;
  final String assignmentDescription;
  final String dueDate;
  final String dueTime;
  final String assignmentStatus; // ✅ Used for button label logic
  final String taskType;

  StudentViewClassModel({
    required this.learnerId,
    required this.firstName,
    required this.lastName,
    required this.classId,
    required this.className,
    required this.gradeName,
    required this.taskId,
    required this.assignmentTitle,
    required this.assignmentDescription,
    required this.dueDate,
    required this.dueTime,
    required this.assignmentStatus,
    required this.taskType,
  });

  /// ✅ Create model from JSON
  factory StudentViewClassModel.fromJson(Map<String, dynamic> json) {
    return StudentViewClassModel(
      learnerId: json["learner_id"] ?? "",
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      classId: json["class_id"] ?? "",
      className: json["class_name"] ?? "",
      gradeName: json["class_grade"] ?? "",
      taskId: json["task_id"] ?? "",
      assignmentTitle: json["task_title"] ?? "",
      assignmentDescription: json["task_description"] ?? "",
      dueDate: json["due_date"] ?? "",
      dueTime: json["due_time"] ?? "",
      assignmentStatus: json["task_status"] ?? "", // ✅ from API
      taskType: json["task_type"] ?? "",
    );
  }

  /// ✅ Convert model to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      "learner_id": learnerId,
      "first_name": firstName,
      "last_name": lastName,
      "class_id": classId,
      "class_name": className,
      "class_grade": gradeName,
      "task_id": taskId,
      "task_title": assignmentTitle,
      "task_description": assignmentDescription,
      "due_date": dueDate,
      "due_time": dueTime,
      "task_status": assignmentStatus,
      "task_type": taskType,
    };
  }

  /// ✅ Helper: Get button label based on status
  String get actionButtonLabel {
    switch (assignmentStatus.toUpperCase()) {
      case "DRAFT":
        return "Resume Assignment";
      case "SUBMITTED":
        return "View Assignment";
      case "GRADED":
        return "View Assignment";
      default:
        return "Start Assignment";
    }
  }
}
