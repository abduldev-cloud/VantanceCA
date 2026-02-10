import 'dart:convert';

WritingPadModel writingPadModelFromJson(String str) => WritingPadModel.fromJson(json.decode(str));
String writingPadModelToJson(WritingPadModel data) => json.encode(data.toJson());

class WritingPadModel {
  List<Rubric>? rubrics;
  List<Example>? examples;
  List<dynamic>? comments;
  String? outStatus;
  List<AiPrompt>? aiPrompts;
  List<TaskSummary>? taskSummary;

  WritingPadModel({
    this.rubrics,
    this.examples,
    this.comments,
    this.outStatus,
    this.aiPrompts,
    this.taskSummary,
  });

  factory WritingPadModel.fromJson(Map<String, dynamic> json) => WritingPadModel(
    rubrics: json["rubrics"] == null ? [] : List<Rubric>.from(json["rubrics"].map((x) => Rubric.fromJson(x))),
    examples: json["examples"] == null ? [] : List<Example>.from(json["examples"].map((x) => Example.fromJson(x))),
    comments: json["comments"] == null ? [] : List<dynamic>.from(json["comments"].map((x) => x)),
    outStatus: json["out_status"],
    aiPrompts: json["ai_prompts"] == null ? [] : List<AiPrompt>.from(json["ai_prompts"].map((x) => AiPrompt.fromJson(x))),
    taskSummary: json["task_summary"] == null ? [] : List<TaskSummary>.from(json["task_summary"].map((x) => TaskSummary.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "rubrics": rubrics == null ? [] : List<dynamic>.from(rubrics!.map((x) => x.toJson())),
    "examples": examples == null ? [] : List<dynamic>.from(examples!.map((x) => x.toJson())),
    "comments": comments == null ? [] : List<dynamic>.from(comments!.map((x) => x)),
    "out_status": outStatus,
    "ai_prompts": aiPrompts == null ? [] : List<dynamic>.from(aiPrompts!.map((x) => x.toJson())),
    "task_summary": taskSummary == null ? [] : List<dynamic>.from(taskSummary!.map((x) => x.toJson())),
  };
}

class AiPrompt {
  String? aiPromptId;
  String? aiUsageId;
  String? promptText;
  String? aiResponse;
  DateTime? createdAt;

  AiPrompt({
    this.aiPromptId,
    this.aiUsageId,
    this.promptText,
    this.aiResponse,
    this.createdAt,
  });

  factory AiPrompt.fromJson(Map<String, dynamic> json) => AiPrompt(
    aiPromptId: json["ai_prompt_id"],
    aiUsageId: json["ai_usage_id"],
    promptText: json["prompt_text"],
    aiResponse: json["ai_response"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "ai_prompt_id": aiPromptId,
    "ai_usage_id": aiUsageId,
    "prompt_text": promptText,
    "ai_response": aiResponse,
    "created_at": createdAt?.toIso8601String(),
  };
}

class Example {
  String? exampleId;
  String? criterionType;
  String? exampleThesis;
  String? exampleReason;
  DateTime? createdAt;

  Example({
    this.exampleId,
    this.criterionType,
    this.exampleThesis,
    this.exampleReason,
    this.createdAt,
  });

  factory Example.fromJson(Map<String, dynamic> json) => Example(
    exampleId: json["example_id"],
    criterionType: json["criterion_type"],
    exampleThesis: json["example_thesis"],
    exampleReason: json["example_reason"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "example_id": exampleId,
    "criterion_type": criterionType,
    "example_thesis": exampleThesis,
    "example_reason": exampleReason,
    "created_at": createdAt?.toIso8601String(),
  };
}

class Rubric {
  String? rubricId;
  String? rubricTitle;
  int? maxPoints;
  DateTime? rubricCreatedAt;
  String? criterionId;
  String? criteriaDesc;
  DateTime? criterionCreatedAt;
  String? criterionType;
  String? criterionDisplayColorCd;

  Rubric({
    this.rubricId,
    this.rubricTitle,
    this.maxPoints,
    this.rubricCreatedAt,
    this.criterionId,
    this.criteriaDesc,
    this.criterionCreatedAt,
    this.criterionType,
    this.criterionDisplayColorCd,
  });

  factory Rubric.fromJson(Map<String, dynamic> json) => Rubric(
    rubricId: json["rubric_id"],
    rubricTitle: json["rubric_title"],
    maxPoints: json["max_points"],
    rubricCreatedAt: json["rubric_created_at"] == null ? null : DateTime.parse(json["rubric_created_at"]),
    criterionId: json["criterion_id"],
    criteriaDesc: json["criteria_desc"],
    criterionCreatedAt: json["criterion_created_at"] == null ? null : DateTime.parse(json["criterion_created_at"]),
    criterionType: json["criterion_type"],
    criterionDisplayColorCd: json["criterion_display_color_cd"],
  );

  Map<String, dynamic> toJson() => {
    "rubric_id": rubricId,
    "rubric_title": rubricTitle,
    "max_points": maxPoints,
    "rubric_created_at": rubricCreatedAt?.toIso8601String(),
    "criterion_id": criterionId,
    "criteria_desc": criteriaDesc,
    "criterion_created_at": criterionCreatedAt?.toIso8601String(),
    "criterion_type": criterionType,
    "criterion_display_color_cd": criterionDisplayColorCd,
  };
}

class TaskSummary {
  String? learnerId;
  String? learnerSalutation;
  String? learnerFirstName;
  String? learnerLastName;
  String? className;
  String? gradeName;
  String? instituteId;
  String? term;
  int? academicYear;
  String? taskId;
  String? taskTitle;
  String? taskPrompt;
  DateTime? dueDate;
  int? targetWordCount;
  int? maxAiPromptsAllowed;
  String? taskType;
  String? teacherId;
  String? teacherSalutation;
  String? teacherFirstName;
  String? teacherLastName;
  String? learnerTaskId;
  String? taskStatus;
  String? fileName;
  int? submittedWordCount;
  String? aiGrade;
  int? teacherGrade;
  int? totalPoints;
  DateTime? assignedAt;
  DateTime? draftStartedAt;
  DateTime? draftUpdatedAt;
  DateTime? submittedAt;
  DateTime? inReviewAt;
  DateTime? gradedAt;
  DateTime? reviewedAt;
  String? alfrescoSiteId;
  String? alfrescoTaskId;
  String? alfrescoLearnerId;
  String? alfrescoFolderPath;
  String? alfrescoTeacherId;
  String? llmSessionId;
  double? deviationPercentage;
  String? deviationReason;


  TaskSummary({
    this.learnerId,
    this.learnerSalutation,
    this.learnerFirstName,
    this.learnerLastName,
    this.className,
    this.gradeName,
    this.instituteId,
    this.term,
    this.academicYear,
    this.taskId,
    this.taskTitle,
    this.taskPrompt,
    this.dueDate,
    this.targetWordCount,
    this.maxAiPromptsAllowed,
    this.taskType,
    this.teacherId,
    this.teacherSalutation,
    this.teacherFirstName,
    this.teacherLastName,
    this.learnerTaskId,
    this.taskStatus,
    this.fileName,
    this.submittedWordCount,
    this.aiGrade,
    this.teacherGrade,
    this.totalPoints,
    this.assignedAt,
    this.draftStartedAt,
    this.draftUpdatedAt,
    this.submittedAt,
    this.inReviewAt,
    this.gradedAt,
    this.reviewedAt,
    this.alfrescoSiteId,
    this.alfrescoTaskId,
    this.alfrescoLearnerId,
    this.alfrescoFolderPath,
    this.alfrescoTeacherId,
    this.llmSessionId,
    this.deviationPercentage,
    this.deviationReason,
  });

  factory TaskSummary.fromJson(Map<String, dynamic> json) => TaskSummary(
    learnerId: json["learner_id"],
    learnerSalutation: json["learner_salutation"],
    learnerFirstName: json["learner_first_name"],
    learnerLastName: json["learner_last_name"],
    className: json["class_name"],
    gradeName: json["grade_name"],
    instituteId: json["institute_id"],
    term: json["term"],
    academicYear: json["academic_year"],
    taskId: json["task_id"],
    taskTitle: json["task_title"],
    taskPrompt: json["task_prompt"],
    dueDate: json["due_date"] == null ? null : DateTime.parse(json["due_date"]),
    targetWordCount: json["target_word_count"],
    maxAiPromptsAllowed: json["max_ai_prompts_allowed"],
    taskType: json["task_type"],
    teacherId: json["teacher_id"],
    teacherSalutation: json["teacher_salutation"],
    teacherFirstName: json["teacher_first_name"],
    teacherLastName: json["teacher_last_name"],
    learnerTaskId: json["learner_task_id"],
    taskStatus: json["task_status"],
    fileName: json["file_name"],
    submittedWordCount: json["submitted_word_count"],
    aiGrade: json["ai_grade"]?.toString(),
    teacherGrade: json["teacher_grade"],
    totalPoints: json["total_points"],
    assignedAt: json["assigned_at"] == null ? null : DateTime.parse(json["assigned_at"]),
    draftStartedAt: json["draft_started_at"] == null ? null : DateTime.parse(json["draft_started_at"]),
    draftUpdatedAt: json["draft_updated_at"] == null ? null : DateTime.parse(json["draft_updated_at"]),
    submittedAt: json["submitted_at"] == null ? null : DateTime.parse(json["submitted_at"]),
    inReviewAt: json["in_review_at"] == null ? null : DateTime.parse(json["in_review_at"]),
    gradedAt: json["graded_at"] == null ? null : DateTime.parse(json["graded_at"]),
    reviewedAt: json["reviewed_at"] == null ? null : DateTime.parse(json["reviewed_at"]),
    alfrescoSiteId: json["alfresco_site_id"],
    alfrescoTaskId: json["alfresco_task_id"]?.toString(),
    alfrescoLearnerId: json["alfresco_learner_id"],
    alfrescoFolderPath: json["alfresco_folder_path"],
    alfrescoTeacherId: json["alfresco_teacher_id"],
    llmSessionId: json["llm_session_id"],
    deviationPercentage: json["deviation_percentage"] != null ? double.tryParse(json["deviation_percentage"].toString()) : null,
    deviationReason: json["deviation_reason"],
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
    "due_date": dueDate?.toIso8601String(),
    "target_word_count": targetWordCount,
    "max_ai_prompts_allowed": maxAiPromptsAllowed,
    "task_type": taskType,
    "teacher_id": teacherId,
    "teacher_salutation": teacherSalutation,
    "teacher_first_name": teacherFirstName,
    "teacher_last_name": teacherLastName,
    "learner_task_id": learnerTaskId,
    "task_status": taskStatus,
    "file_name": fileName,
    "submitted_word_count": submittedWordCount,
    "ai_grade": aiGrade,
    "teacher_grade": teacherGrade,
    "total_points": totalPoints,
    "assigned_at": assignedAt?.toIso8601String(),
    "draft_started_at": draftStartedAt?.toIso8601String(),
    "draft_updated_at": draftUpdatedAt?.toIso8601String(),
    "submitted_at": submittedAt?.toIso8601String(),
    "in_review_at": inReviewAt?.toIso8601String(),
    "graded_at": gradedAt?.toIso8601String(),
    "reviewed_at": reviewedAt?.toIso8601String(),
    "alfresco_site_id": alfrescoSiteId,
    "alfresco_task_id": alfrescoTaskId,
    "alfresco_learner_id": alfrescoLearnerId,
    "alfresco_folder_path": alfrescoFolderPath,
    "alfresco_teacher_id": alfrescoTeacherId,
    "llm_session_id": llmSessionId,
    "deviation_percentage": deviationPercentage,
    "deviation_reason": deviationReason,
  };
}
