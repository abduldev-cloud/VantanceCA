class CreateTaskRequest {
  final String instituteId;
  final String classId;
  final String teacherId;
  final String taskTypeId;
  final String title;
  final String prompt;
  final String dueDate;
  final int targetWordCount;
  final String createdBy;

  CreateTaskRequest({
    required this.instituteId,
    required this.classId,
    required this.teacherId,
    required this.taskTypeId,
    required this.title,
    required this.prompt,
    required this.dueDate,
    required this.targetWordCount,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'institute_id': instituteId,
      'class_id': classId,
      'teacher_id': teacherId,
      'task_type': taskTypeId,
      'title': title,
      'prompt': prompt,
      'due_date': dueDate,
      'target_word_count': targetWordCount,
      'created_by': createdBy,
    };
  }
}

class CreateTaskResponse {
  final bool success;
  final String? message;
  final String? taskId;

  CreateTaskResponse({
    required this.success,
    this.message,
    this.taskId,
  });

  factory CreateTaskResponse.fromJson(Map<String, dynamic> json) {
    return CreateTaskResponse(
      success: json['success'] ?? false,
      message: json['out_status'],
      taskId: json['out_task_id'],
    );
  }
}

class CreateTaskAlfrescoRequest {
  final String siteId;
  final String alfrescoClassId;
  final String alfrescoUserId;
  final String workflowDefinition;
  final String folderPath;
  final String title;
  final String description;
  final String dueDate;
  final String taskID;

  CreateTaskAlfrescoRequest({
    required this.siteId,
    required this.alfrescoClassId,
    required this.alfrescoUserId,
    required this.workflowDefinition,
    required this.folderPath,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.taskID,
  });

  Map<String, dynamic> toJson() {
    return {
      'site_id': siteId,
      'class_id': alfrescoClassId,
      'teacher_id': alfrescoUserId,
      'workflow_definition': workflowDefinition,
      'folder_path': folderPath,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'task_id': taskID,
    };
  }
}

class CreateTaskAlfrescoResponse {
  final bool success;
  final String? message;
  final String? taskId;

  CreateTaskAlfrescoResponse({
    required this.success,
    this.message,
    this.taskId,
  });

  factory CreateTaskAlfrescoResponse.fromJson(Map<String, dynamic> json) {
    return CreateTaskAlfrescoResponse(
      success: json['success'] ?? false,
      message: json['out_status'],
      taskId: json['out_task_id'],
    );
  }
}

class AssignmentNotificationRequests {
  final String class_id;
  final String teacher_id;
  final String task_type;

  AssignmentNotificationRequests({
    required this.class_id,
    required this.teacher_id,
    required this.task_type,
  });

  Map<String, dynamic> toJson() {
    return {
      'class_id': class_id,
      'teacher_id': teacher_id,
      'task_type': task_type,
    };
  }
}

class AssignmentNotificationResponse {
  final bool success;
  final String? message;
  //final String? taskId;

  AssignmentNotificationResponse({
    required this.success,
    this.message,
    //this.taskId,
  });

  factory AssignmentNotificationResponse.fromJson(Map<String, dynamic> json) {
    return AssignmentNotificationResponse(
      success: json['success'] ?? false,
      message: json['out_status'],
      //taskId: json['out_task_id'],
    );
  }
}