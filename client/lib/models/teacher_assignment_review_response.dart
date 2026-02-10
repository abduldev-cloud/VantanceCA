import 'dart:convert';

TeacherAssignmentReviewResponse teacherAssignmentReviewResponseFromJson(String str) =>
    TeacherAssignmentReviewResponse.fromJson(json.decode(str));

String teacherAssignmentReviewResponseToJson(TeacherAssignmentReviewResponse data) =>
    json.encode(data.toJson());

class TeacherAssignmentReviewResponse {
  final List<RubricModel> rubrics;
  final List<AIPromptModel> aiPrompts;
  final LearnerTaskSummary learnerTaskSummary;
  final String outStatus;

  TeacherAssignmentReviewResponse({
    required this.rubrics,
    required this.aiPrompts,
    required this.learnerTaskSummary,
    required this.outStatus,
  });

  factory TeacherAssignmentReviewResponse.fromJson(Map<String, dynamic> json) => TeacherAssignmentReviewResponse(
      rubrics: json["rubrics"] == null
          ? []
          : List<RubricModel>.from(json["rubrics"].map((x) => RubricModel.fromJson(x))),
      aiPrompts: json["ai_prompts"] == null
          ? []
          : List<AIPromptModel>.from(json["ai_prompts"].map((x) => AIPromptModel.fromJson(x))),
      learnerTaskSummary: json["task_summary"] != null && (json["task_summary"] as List).isNotEmpty
          ? LearnerTaskSummary.fromJson(json["task_summary"][0])
          : LearnerTaskSummary.empty(),
      outStatus: json["out_status"] ?? "",
  );

  Map<String, dynamic> toJson() => {
        "rubrics": List<dynamic>.from(rubrics.map((x) => x.toJson())),
        "ai_prompts": List<dynamic>.from(aiPrompts.map((x) => x.toJson())),
        "task_summary": [learnerTaskSummary.toJson()],
        "out_status": outStatus,
      };
}

class RubricModel {
  final String rubricId;
  final String rubricTitle;
  final int maxPoints;
  final String rubricCreatedAt;
  final String criterionId;
  final String criteriaDesc;
  final String criterionCreatedAt;
  final String criterionType;
  final String criterionDisplayColorCd;

  RubricModel({
    required this.rubricId,
    required this.rubricTitle,
    required this.maxPoints,
    required this.rubricCreatedAt,
    required this.criterionId,
    required this.criteriaDesc,
    required this.criterionCreatedAt,
    required this.criterionType,
    required this.criterionDisplayColorCd,
  });

  factory RubricModel.fromJson(Map<String, dynamic> json) => RubricModel(
        rubricId: json["rubric_id"] ?? "",
        rubricTitle: json["rubric_title"] ?? "",
        maxPoints: json["max_points"] ?? 0,
        rubricCreatedAt: json["rubric_created_at"] ?? "",
        criterionId: json["criterion_id"] ?? "",
        criteriaDesc: json["criteria_desc"] ?? "",
        criterionCreatedAt: json["criterion_created_at"] ?? "",
        criterionType: json["criterion_type"] ?? "",
        criterionDisplayColorCd: json["criterion_display_color_cd"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "rubric_id": rubricId,
        "rubric_title": rubricTitle,
        "max_points": maxPoints,
        "rubric_created_at": rubricCreatedAt,
        "criterion_id": criterionId,
        "criteria_desc": criteriaDesc,
        "criterion_created_at": criterionCreatedAt,
        "criterion_type": criterionType,
        "criterion_display_color_cd": criterionDisplayColorCd,
      };
}

class AIPromptModel {
  final String aiPromptId;
  final String aiUsageId;
  final String promptText;
  final String aiResponse;
  final String createdAt;

  AIPromptModel({
    required this.aiPromptId,
    required this.aiUsageId,
    required this.promptText,
    required this.aiResponse,
    required this.createdAt,
  });

  factory AIPromptModel.fromJson(Map<String, dynamic> json) => AIPromptModel(
        aiPromptId: json["ai_prompt_id"] ?? "",
        aiUsageId: json["ai_usage_id"] ?? "",
        promptText: json["prompt_text"] ?? "",
        aiResponse: json["ai_response"] ?? "",
        createdAt: json["created_at"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "ai_prompt_id": aiPromptId,
        "ai_usage_id": aiUsageId,
        "prompt_text": promptText,
        "ai_response": aiResponse,
        "created_at": createdAt,
      };
}

class LearnerTaskSummary {
  final String learnerId;
  final String learnerSalutation;
  final String learnerFirstName;
  final String learnerLastName;
  final String className;
  final String gradeName;
  final String instituteId;
  final String term;
  final int academicYear;
  final String taskId;
  final String taskTitle;
  final String taskPrompt;
  final String dueDate;
  final int targetWordCount;
  final int maxAiPrompts;
  final String taskType;
  final String teacherId;
  final String teacherSalutation;
  final String teacherFirstName;
  final String teacherLastName;
  final String learnerTaskId;
  final String taskStatus;
  final String fileName;
  
  final int? aiGrade;
  final int? teacherGrade;
  final String assignedAt;
  final String draftStartedAt;
  final String submittedAt;
  final String? inReviewAt;
  final String? gradedAt;
  final String? reviewedAt;
  final double? deviationPercentage;
  final String? deviationReason;
  final int? llmSessionId;

  final String alfrescoSiteId;
  final dynamic alfrescoTaskId;    // can be int or string
  final String alfrescoLearnerId;
  final String? alfrescoFolderPath;

  LearnerTaskSummary({
    required this.learnerId,
    required this.learnerSalutation,
    required this.learnerFirstName,
    required this.learnerLastName,
    required this.className,
    required this.gradeName,
    required this.instituteId,
    required this.term,
    required this.academicYear,
    required this.taskId,
    required this.taskTitle,
    required this.taskPrompt,
    required this.dueDate,
    required this.targetWordCount,
    required this.maxAiPrompts,
    required this.taskType,
    required this.teacherId,
    required this.teacherSalutation,
    required this.teacherFirstName,
    required this.teacherLastName,
    required this.learnerTaskId,
    required this.taskStatus,
    required this.fileName,

    this.aiGrade,
    this.teacherGrade,
    required this.assignedAt,
    required this.draftStartedAt,
    required this.submittedAt,
    this.inReviewAt,
    this.gradedAt,
    this.reviewedAt,
    this.deviationPercentage,
    this.deviationReason,
    this.llmSessionId,
    required this.alfrescoSiteId,
    this.alfrescoTaskId,
    required this.alfrescoLearnerId,
    this.alfrescoFolderPath,
  });

  factory LearnerTaskSummary.fromJson(Map<String, dynamic> json) =>
      LearnerTaskSummary(
        learnerId: json["learner_id"] ?? "",
        learnerSalutation: json["learner_salutation"] ?? "",
        learnerFirstName: json["learner_first_name"] ?? "",
        learnerLastName: json["learner_last_name"] ?? "",
        className: json["class_name"] ?? "",
        gradeName: json["grade_name"] ?? "",
        instituteId: json["institute_id"] ?? "",
        term: json["term"] ?? "",
        academicYear: json["academic_year"] ?? 0,
        taskId: json["task_id"] ?? "",
        taskTitle: json["task_title"] ?? "",
        taskPrompt: json["task_prompt"] ?? "",
        dueDate: json["due_date"] ?? "",
        targetWordCount: json["target_word_count"] ?? 0,
        maxAiPrompts: json["max_ai_prompts_allowed"] ?? 0,
        taskType: json["task_type"] ?? "",
        teacherId: json["teacher_id"] ?? "",
        teacherSalutation: json["teacher_salutation"] ?? "",
        teacherFirstName: json["teacher_first_name"] ?? "",
        teacherLastName: json["teacher_last_name"] ?? "",
        learnerTaskId: json["learner_task_id"] ?? "",
        taskStatus: json["task_status"] ?? "",
        fileName: json["file_name"] ?? "",
        
        aiGrade: json["ai_grade"],
        teacherGrade: json["teacher_grade"],
        assignedAt: json["assigned_at"] ?? "",
        draftStartedAt: json["draft_started_at"] ?? "",
        submittedAt: json["submitted_at"] ?? "",
        inReviewAt: json["in_review_at"],
        gradedAt: json["graded_at"],
        reviewedAt: json["reviewed_at"],
        deviationPercentage: (json["deviation_percentage"] != null)
            ? (json["deviation_percentage"] is int
                ? (json["deviation_percentage"] as int).toDouble()
                : json["deviation_percentage"])
            : null,
        deviationReason: json["deviation_reason"],
        llmSessionId: json["llm_session_id"],
        alfrescoSiteId: json["alfresco_site_id"] ?? "",
        alfrescoTaskId: json["alfresco_task_id"],
        alfrescoLearnerId: json["alfresco_learner_id"] ?? "",
        alfrescoFolderPath: json["alfresco_folder_path"],
      );

  Map<String, dynamic> toJson() => {
        "learner_id": learnerId,
        "learner_salutation": learnerSalutation,
        "learner_first_name": learnerFirstName,
        "learner_last_name": learnerLastName,
        "class_name": className,
        "grade_name": gradeName,
        "institute_id": instituteId,
        "term": term,
        "academic_year": academicYear,
        "task_id": taskId,
        "task_title": taskTitle,
        "task_prompt": taskPrompt,
        "due_date": dueDate,
        "target_word_count": targetWordCount,
        "max_ai_prompts_allowed": maxAiPrompts,
        "task_type": taskType,
        "teacher_id": teacherId,
        "teacher_salutation": teacherSalutation,
        "teacher_first_name": teacherFirstName,
        "teacher_last_name": teacherLastName,
        "learner_task_id": learnerTaskId,
        "task_status": taskStatus,
        "file_name": fileName,
        
        "ai_grade": aiGrade,
        "teacher_grade": teacherGrade,
        "assigned_at": assignedAt,
        "draft_started_at": draftStartedAt,
        "submitted_at": submittedAt,
        "in_review_at": inReviewAt,
        "graded_at": gradedAt,
        "reviewed_at": reviewedAt,
        "deviation_percentage": deviationPercentage,
        "deviation_reason": deviationReason,
        "llm_session_id": llmSessionId,
        "alfresco_site_id": alfrescoSiteId,
        "alfresco_task_id": alfrescoTaskId,
        "alfresco_learner_id": alfrescoLearnerId,
        "alfresco_folder_path": alfrescoFolderPath,
      };

  factory LearnerTaskSummary.empty() => LearnerTaskSummary(
        learnerId: "",
        learnerSalutation: "",
        learnerFirstName: "",
        learnerLastName: "",
        className: "",
        gradeName: "",
        instituteId: "",
        term: "",
        academicYear: 0,
        taskId: "",
        taskTitle: "",
        taskPrompt: "",
        dueDate: "",
        targetWordCount: 0,
        maxAiPrompts: 0,
        taskType: "",
        teacherId: "",
        teacherSalutation: "",
        teacherFirstName: "",
        teacherLastName: "",
        learnerTaskId: "",
        taskStatus: "",
        fileName: "",
        aiGrade: null,
        teacherGrade: null,
        assignedAt: "",
        draftStartedAt: "",
        submittedAt: "",
        inReviewAt: null,
        gradedAt: null,
        reviewedAt: null,
        deviationPercentage: null,
        deviationReason: null,
        llmSessionId: null,
        alfrescoSiteId: "",
        alfrescoTaskId: null,
        alfrescoLearnerId: "",
        alfrescoFolderPath: "",
      );
}
