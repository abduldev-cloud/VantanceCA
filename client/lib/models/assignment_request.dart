class AssignmentRequest {
  final String instituteId;
  final String classId;
  final String teacherId;
  final String taskTypeId;
  final String title;
  final String prompt;
  final String dueDate;
  final int targetWordCount;
  final String createdBy;
  final List<Rubric> rubrics;
  final List<Example> examples; // newly added field

  AssignmentRequest({
    required this.instituteId,
    required this.classId,
    required this.teacherId,
    required this.taskTypeId,
    required this.title,
    required this.prompt,
    required this.dueDate,
    required this.targetWordCount,
    required this.createdBy,
    required this.rubrics,
    required this.examples, // new parameter
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
      'rubrics': rubrics.map((rubric) => rubric.toJson()).toList(),
      'examples': examples.map((example) => example.toJson()).toList(), // serialize examples
    };
  }
}


class Example {
  final String criterionType;
  final String exampleThesis;
  final String exampleReason;

  Example({
    required this.criterionType,
    required this.exampleThesis,
    required this.exampleReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'criterion_type': criterionType,
      'example_thesis': exampleThesis,
      'example_reason': exampleReason,
    };
  }
}


class Rubric {
  final String rubricTitle;
  final int maxPoints;
  final List<Criterion> criteria;

  Rubric({
    required this.rubricTitle,
    required this.maxPoints,
    required this.criteria,
  });

  Map<String, dynamic> toJson() {
    return {
      'rubric_title': rubricTitle,
      'max_points': maxPoints,
      'criteria': criteria.map((criterion) => criterion.toJson()).toList(),
    };
  }
}


class Criterion {
  final String criterionTypeId;
  final String criteriaDesc;

  Criterion({
    required this.criterionTypeId,
    required this.criteriaDesc,
  });

  Map<String, dynamic> toJson() {
    return {
      'criterion_type': criterionTypeId,
      'criteria_desc': criteriaDesc,
    };
  }
}


class CreateAssignmentAlfrescoRequest {
  final String siteId;
  final String alfrescoClassId;
  final String alfrescoUserId;
  final String workflowDefinition;
  final String folderPath;
  final String title;
  final String description;
  final String dueDate;
  final String taskId;

  CreateAssignmentAlfrescoRequest({
    required this.siteId,
    required this.alfrescoClassId,
    required this.alfrescoUserId,
    required this.workflowDefinition,
    required this.folderPath,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.taskId,
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
      'task_id': taskId,
    };
  }
}


class CreateAssignmentAlfrescoResponse {
  final bool success;
  final String? message;
  final String? taskId;

  CreateAssignmentAlfrescoResponse({
    required this.success,
    this.message,
    this.taskId,
  });

  factory CreateAssignmentAlfrescoResponse.fromJson(Map<String, dynamic> json) {
    return CreateAssignmentAlfrescoResponse(
      success: json['success'] ?? false,
      message: json['out_status'],
      taskId: json['out_task_id'],
    );
  }
}


class AssignmentLMSRequests {
  final String binarySuccess_assignment_id;
  final String binarySuccess_class_id;
  final String binarySuccess_teacher_id;
  final String name;
  final String description;
  final String due_at;

  AssignmentLMSRequests({
    required this.binarySuccess_assignment_id,
    required this.binarySuccess_class_id,
    required this.binarySuccess_teacher_id,
    required this.name,
    required this.description,
    required this.due_at,
  });

  Map<String, dynamic> toJson() {
    return {
      'binarySuccess_assignment_id': binarySuccess_assignment_id,
      'binarySuccess_class_id': binarySuccess_class_id,
      'binarySuccess_teacher_id': binarySuccess_teacher_id,
      'name': name,
      'description': description,
      'due_at': due_at,
    };
  }
}


class AssignmentLMSRequestsResponse {
  final bool success;
  final String? message;
  final String? taskId;

  AssignmentLMSRequestsResponse({
    required this.success,
    this.message,
    this.taskId,
  });

  factory AssignmentLMSRequestsResponse.fromJson(Map<String, dynamic> json) {
    return AssignmentLMSRequestsResponse(
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

  AssignmentNotificationResponse({
    required this.success,
    this.message,
  });

  factory AssignmentNotificationResponse.fromJson(Map<String, dynamic> json) {
    return AssignmentNotificationResponse(
      success: json['success'] ?? false,
      message: json['out_status'],
    );
  }
}
