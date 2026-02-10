import 'dart:convert';
import 'package:intl/intl.dart';

// GradingViewApiResponse and related models

class GradingViewApiResponse {
  final List<Rubric> rubrics;
  final List<Example> examples;
  final List<dynamic> comments;
  final String outStatus;
  final List<AiPrompt> aiPrompts;
  final List<TaskSummaryItem> taskSummary;

  GradingViewApiResponse({
    required this.rubrics,
    required this.examples,
    required this.comments,
    required this.outStatus,
    required this.aiPrompts,
    required this.taskSummary,
  });

  factory GradingViewApiResponse.fromJson(Map<String, dynamic> json) {
    return GradingViewApiResponse(
      rubrics: (json['rubrics'] as List? ?? []).map((e) => Rubric.fromJson(e)).toList(),
      examples: (json['examples'] as List? ?? []).map((e) => Example.fromJson(e)).toList(),
      comments: json['comments'] ?? [],
      outStatus: json['out_status'] ?? '',
      aiPrompts: (json['ai_prompts'] as List? ?? []).map((e) => AiPrompt.fromJson(e)).toList(),
      taskSummary: (json['task_summary'] as List? ?? []).map((e) => TaskSummaryItem.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'rubrics': rubrics.map((e) => e.toJson()).toList(),
        'examples': examples.map((e) => e.toJson()).toList(),
        'comments': comments,
        'out_status': outStatus,
        'ai_prompts': aiPrompts.map((e) => e.toJson()).toList(),
        'task_summary': taskSummary.map((e) => e.toJson()).toList(),
      };
}

class Rubric {
  final String rubricId;
  final String rubricTitle;
  final int maxPoints;
  final String rubricCreatedAt;
  final String criterionId;
  final String criteriaDesc;
  final String criterionCreatedAt;
  final String criterionType;
  final String criterionDisplayColorCd;

  Rubric({
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

  factory Rubric.fromJson(Map<String, dynamic> json) {
    return Rubric(
      rubricId: json['rubric_id'] ?? '',
      rubricTitle: json['rubric_title'] ?? '',
      maxPoints: json['max_points'] ?? 0,
      rubricCreatedAt: json['rubric_created_at'] ?? '',
      criterionId: json['criterion_id'] ?? '',
      criteriaDesc: json['criteria_desc'] ?? '',
      criterionCreatedAt: json['criterion_created_at'] ?? '',
      criterionType: json['criterion_type'] ?? '',
      criterionDisplayColorCd: json['criterion_display_color_cd'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'rubric_id': rubricId,
        'rubric_title': rubricTitle,
        'max_points': maxPoints,
        'rubric_created_at': rubricCreatedAt,
        'criterion_id': criterionId,
        'criteria_desc': criteriaDesc,
        'criterion_created_at': criterionCreatedAt,
        'criterion_type': criterionType,
        'criterion_display_color_cd': criterionDisplayColorCd,
      };
}

class Example {
  final String exampleId;
  final String criterionType;
  final String exampleThesis;
  final String exampleReason;
  final String createdAt;

  Example({
    required this.exampleId,
    required this.criterionType,
    required this.exampleThesis,
    required this.exampleReason,
    required this.createdAt,
  });

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      exampleId: json['example_id'] ?? '',
      criterionType: json['criterion_type'] ?? '',
      exampleThesis: json['example_thesis'] ?? '',
      exampleReason: json['example_reason'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'example_id': exampleId,
        'criterion_type': criterionType,
        'example_thesis': exampleThesis,
        'example_reason': exampleReason,
        'created_at': createdAt,
      };
}

class AiPrompt {
  final String aiPromptId;
  final String aiUsageId;
  final String promptText;
  final String aiResponse;
  final String createdAt;

  AiPrompt({
    required this.aiPromptId,
    required this.aiUsageId,
    required this.promptText,
    required this.aiResponse,
    required this.createdAt,
  });

  factory AiPrompt.fromJson(Map<String, dynamic> json) {
    return AiPrompt(
      aiPromptId: json['ai_prompt_id'] ?? '',
      aiUsageId: json['ai_usage_id'] ?? '',
      promptText: json['prompt_text'] ?? '',
      aiResponse: json['ai_response'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'ai_prompt_id': aiPromptId,
        'ai_usage_id': aiUsageId,
        'prompt_text': promptText,
        'ai_response': aiResponse,
        'created_at': createdAt,
      };
}

class TaskSummaryItem {
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
  final int maxAiPromptsAllowed;
  final String taskType;
  final String teacherId;
  final String teacherSalutation;
  final String teacherFirstName;
  final String teacherLastName;
  final String learnerTaskId;
  final String taskStatus;
  final String? fileName;
  final dynamic aiGrade;
  final int teacherGrade;
  final String assignedAt;
  final String draftStartedAt;
  final String submittedAt;
  final String inReviewAt;
  final String? gradedAt;
  final String? reviewedAt;
  final int deviationPercentage;
  final String deviationReason;
  final dynamic llmSessionId;
  final int submittedWordCount;
  final String alfrescoSiteId;
  final dynamic alfrescoTaskId;
  final dynamic alfrescoLearnerId;
  final String alfrescoFolderPath;
  final dynamic alfrescoTeacherId;
  final String? integrationType;
  final String? classId;

  TaskSummaryItem({
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
    required this.maxAiPromptsAllowed,
    required this.taskType,
    required this.teacherId,
    required this.teacherSalutation,
    required this.teacherFirstName,
    required this.teacherLastName,
    required this.learnerTaskId,
    required this.taskStatus,
    this.fileName,
    this.aiGrade,
    required this.teacherGrade,
    required this.assignedAt,
    required this.draftStartedAt,
    required this.submittedAt,
    required this.inReviewAt,
    this.gradedAt,
    this.reviewedAt,
    required this.deviationPercentage,
    required this.deviationReason,
    this.llmSessionId,
    required this.submittedWordCount,
    required this.alfrescoSiteId,
    this.alfrescoTaskId,
    this.alfrescoLearnerId,
    required this.alfrescoFolderPath,
    this.alfrescoTeacherId,
    this.integrationType,
    this.classId,
  });

  factory TaskSummaryItem.fromJson(Map<String, dynamic> json) {
    return TaskSummaryItem(
      learnerId: json['learner_id'] ?? '',
      learnerSalutation: json['learner_salutation'] ?? '',
      learnerFirstName: json['learner_first_name'] ?? '',
      learnerLastName: json['learner_last_name'] ?? '',
      className: json['class_name'] ?? '',
      gradeName: json['grade_name'] ?? '',
      instituteId: json['institute_id'] ?? '',
      term: json['term'] ?? '',
      academicYear: json['academic_year'] ?? 0,
      taskId: json['task_id'] ?? '',
      taskTitle: json['task_title'] ?? '',
      taskPrompt: json['task_prompt'] ?? '',
      dueDate: json['due_date'] ?? '',
      targetWordCount: json['target_word_count'] ?? 0,
      maxAiPromptsAllowed: json['max_ai_prompts_allowed'] ?? 0,
      taskType: json['task_type'] ?? '',
      teacherId: json['teacher_id'] ?? '',
      teacherSalutation: json['teacher_salutation'] ?? '',
      teacherFirstName: json['teacher_first_name'] ?? '',
      teacherLastName: json['teacher_last_name'] ?? '',
      learnerTaskId: json['learner_task_id'] ?? '',
      taskStatus: json['task_status'] ?? '',
      fileName: json['file_name'],
      aiGrade: json['ai_grade'],
      teacherGrade: json['teacher_grade'] ?? 0,
      assignedAt: json['assigned_at'] ?? '',
      draftStartedAt: json['draft_started_at'] ?? '',
      submittedAt: json['submitted_at'] ?? '',
      inReviewAt: json['in_review_at'] ?? '',
      gradedAt: json['graded_at'],
      reviewedAt: json['reviewed_at'],
      deviationPercentage: json['deviation_percentage'] ?? 0,
      deviationReason: json['deviation_reason'] ?? '',
      llmSessionId: json['llm_session_id'],
      submittedWordCount: json['submitted_word_count'] ?? 0,
      alfrescoSiteId: json['alfresco_site_id'] ?? '',
      alfrescoTaskId: json['alfresco_task_id'],
      alfrescoLearnerId: json['alfresco_learner_id'],
      alfrescoFolderPath: json['alfresco_folder_path'] ?? '',
      alfrescoTeacherId: json['alfresco_teacher_id'],
      integrationType: json['integration_type'],
      classId: json['class_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'learner_id': learnerId,
        'learner_salutation': learnerSalutation,
        'learner_first_name': learnerFirstName,
        'learner_last_name': learnerLastName,
        'class_name': className,
        'grade_name': gradeName,
        'institute_id': instituteId,
        'term': term,
        'academic_year': academicYear,
        'task_id': taskId,
        'task_title': taskTitle,
        'task_prompt': taskPrompt,
        'due_date': dueDate,
        'target_word_count': targetWordCount,
        'max_ai_prompts_allowed': maxAiPromptsAllowed,
        'task_type': taskType,
        'teacher_id': teacherId,
        'teacher_salutation': teacherSalutation,
        'teacher_first_name': teacherFirstName,
        'teacher_last_name': teacherLastName,
        'learner_task_id': learnerTaskId,
        'task_status': taskStatus,
        'file_name': fileName,
        'ai_grade': aiGrade,
        'teacher_grade': teacherGrade,
        'assigned_at': assignedAt,
        'draft_started_at': draftStartedAt,
        'submitted_at': submittedAt,
        'in_review_at': inReviewAt,
        'graded_at': gradedAt,
        'reviewed_at': reviewedAt,
        'deviation_percentage': deviationPercentage,
        'deviation_reason': deviationReason,
        'llm_session_id': llmSessionId,
        'submitted_word_count': submittedWordCount,
        'alfresco_site_id': alfrescoSiteId,
        'alfresco_task_id': alfrescoTaskId,
        'alfresco_learner_id': alfrescoLearnerId,
        'alfresco_folder_path': alfrescoFolderPath,
        'alfresco_teacher_id': alfrescoTeacherId,
        'integration_type': integrationType,
        'class_id': classId,
      };
}

/// ===============================================================
/// JSON Helpers
/// ===============================================================
GradingApiResponse gradingApiResponseFromJson(String str) =>
    GradingApiResponse.fromJson(json.decode(str) as Map<String, dynamic>);

String gradingApiResponseToJson(GradingApiResponse data) =>
    json.encode(data.toJson());

/// ===============================================================
/// API Response Wrapper
/// ===============================================================
class GradingApiResponse {
  final String? outStatus;
  final List<TaskSummary> taskSummary;
  final List<TeachersGradingModel> learnerTasks;

  GradingApiResponse({
    this.outStatus,
    this.taskSummary = const [],
    this.learnerTasks = const [],
  });

  factory GradingApiResponse.fromJson(Map<String, dynamic> json) {
    return GradingApiResponse(
      outStatus: json["out_status"],
      taskSummary: (json["task_summary"] as List? ?? [])
          .map((e) => TaskSummary.fromJson(e))
          .toList(),
      learnerTasks: (json["learner_tasks_details"] as List? ?? [])
          .map((e) => TeachersGradingModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        "out_status": outStatus,
        "task_summary": taskSummary.map((e) => e.toJson()).toList(),
        "learner_tasks_details": learnerTasks.map((e) => e.toJson()).toList(),
      };
}

/// ===============================================================
/// Task Summary (Counts)
/// ===============================================================
class TaskSummary {
  final int pendingGradingCount;
  final int gradedCount;
  final int totalTasksCount;

  TaskSummary({
    required this.pendingGradingCount,
    required this.gradedCount,
    required this.totalTasksCount,
  });

  factory TaskSummary.fromJson(Map<String, dynamic> json) => TaskSummary(
        pendingGradingCount:
            int.tryParse((json["pending_grading_count"] ?? "0").toString()) ??
                0,
        gradedCount:
            int.tryParse((json["graded_count"] ?? "0").toString()) ?? 0,
        totalTasksCount:
            int.tryParse((json["total_tasks_count"] ?? "0").toString()) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "pending_grading_count": pendingGradingCount,
        "graded_count": gradedCount,
        "total_tasks_count": totalTasksCount,
      };
}

/// ===============================================================
/// Teachers Grading Model (Detailed Task)
/// ===============================================================
class TeachersGradingModel {
  final String learnerId;
  final String taskId;
  final String learnerFirstName;
  final String learnerLastName;
  final String classId;
  final String className;
  final String assignmentTitle;
  final String assignmentContent;
  final String dueDate; // ISO string
  final String submittedDate; // ISO string
  final int wordCount;
  final double? teacherGrade; // allow decimals; null = not graded
   final double? totalPoints; // NEW FIELD
  final bool hasFingerprint;
  final String status;
  final int? score;
  final String learnerName;
  final String? userId; // NEW
  final int? rn; // NEW

  TeachersGradingModel({
    required this.learnerId,
    required this.taskId,
    required this.learnerFirstName,
    required this.learnerLastName,
    required this.classId,
    required this.className,
    required this.assignmentTitle,
    required this.assignmentContent,
    required this.dueDate,
    required this.submittedDate,
    required this.wordCount,
    required this.teacherGrade,
required this.totalPoints,
    required this.hasFingerprint,
    required this.status,
    required this.score,
    required this.learnerName, 
    this.userId, // NEW
    this.rn, // NEW
    DateTime? submittedDateTime,
  });

  factory TeachersGradingModel.fromJson(Map<String, dynamic> json) {
    final content = (json["assignment_content"] ?? "").toString().trim();

    final submittedDate = (json["submitted_at"] ??
            json["submitted_date"] ??
            json["submission_date"] ??
            "")
        .toString()
        .trim();

    final parsedWordCount =
        int.tryParse((json["word_count"] ?? "").toString()) ??
            int.tryParse((json["submitted_word_count"] ?? "").toString()) ??
            _wc(content);

    final gradeRaw = json["teacher_grade"];
    final double? parsedGrade =
        gradeRaw == null ? null : double.tryParse(gradeRaw.toString());

 final totalPointsRaw = json["total_points"];
    final double? parsedTotalPoints =
        totalPointsRaw == null ? null : double.tryParse(totalPointsRaw.toString());

    return TeachersGradingModel(
      learnerId: (json["learner_id"] ?? "").toString().trim(),
      taskId: (json["task_id"] ?? "").toString().trim(),
      learnerFirstName: (json["learner_first_name"] ?? "").toString().trim(),
      learnerLastName: (json["learner_last_name"] ?? "").toString().trim(),
      classId: (json["class_id"] ?? "").toString().trim(),
      className: (json["class_name"] ?? "").toString().trim(),
      assignmentTitle: (json["assignment_title"] ?? "").toString().trim(),
      assignmentContent: content,
      dueDate: (json["due_date"] ?? "").toString().trim(),
      submittedDate: submittedDate,
      wordCount: parsedWordCount,
      teacherGrade: parsedGrade,
       totalPoints: parsedTotalPoints,
      hasFingerprint: _toBool(json["has_fingerprint_task"]),
      status: (json["status"] ?? "").toString().trim(),
      score: json["score"] != null
          ? int.tryParse(json["score"].toString())
          : null,
      learnerName: (json["learner_name"] ?? "").toString().trim(),
      userId: (json["user_id"] ?? "").toString().trim(), // NEW
      rn: json["rn"] != null ? int.tryParse(json["rn"].toString()) : null, // NEW
    );
  }

  Map<String, dynamic> toJson() => {
        "learner_id": learnerId,
        "task_id": taskId,
        "learner_first_name": learnerFirstName,
        "learner_last_name": learnerLastName,
        "class_id": classId,
        "class_name": className,
        "assignment_title": assignmentTitle,
        "assignment_content": assignmentContent,
        "due_date": dueDate,
        "submitted_at": submittedDate,
        "word_count": wordCount,
        "teacher_grade": teacherGrade,
         "total_points": totalPoints, // NEW
        "has_fingerprint_task": hasFingerprint ? "Y" : "N",
        "status": status,
        "score": score,
        "user_id": userId, // NEW
        "rn": rn, // NEW
      };
  
  /// ===========================
  /// Helpers
  /// ===========================
  String get fullName =>
      "$learnerFirstName $learnerLastName".replaceAll(RegExp(r'\s+'), ' ').trim();

  DateTime? get dueDateTime => _parseIsoToLocal(dueDate);
  DateTime? get submittedDateTime => _parseIsoToLocal(submittedDate);

  String get formattedSubmittedDateTime {
    final d = submittedDateTime;
    if (d == null) return submittedDate.isEmpty ? "-" : submittedDate;
    return DateFormat("MMMM d, yyyy, hh:mm a").format(d);
  }

  String get formattedWordCount {
    if (wordCount == 0) return "-";
    return NumberFormat.decimalPattern().format(wordCount);
  }

  String get formattedTeacherGrade {
    if (teacherGrade == null) return "-";
    final g = teacherGrade!;
    if (g % 1 == 0) return g.toInt().toString();
    return g.toStringAsFixed(1);
  }

  /// ===========================
  /// Internal Utils
  /// ===========================
  static DateTime? _parseIsoToLocal(String s) {
    if (s.trim().isEmpty) return null;
    try {
      final d = DateTime.parse(s);
      return d.isUtc ? d.toLocal() : d;
    } catch (_) {
      return DateTime.tryParse(s);
    }
  }

  static int _wc(String text) {
    final t = text.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).length;
  }

  static bool _toBool(dynamic v) {
    final s = v?.toString().toLowerCase().trim() ?? "";
    return s == "y" || s == "yes" || s == "true" || s == "1";
  }
}

class ContentWithGrade {
  final String studentId;
  final String taskId;
  final String contentHtml;
  final dynamic grade;
  final dynamic teacherId;
  final dynamic comments;

  ContentWithGrade({
    required this.studentId,
    required this.taskId,
    required this.contentHtml,
    this.grade,
    this.teacherId,
    this.comments,
  });

  /// Handles both JSON and raw HTML string
  factory ContentWithGrade.fromApi(dynamic data) {
    if (data is String) {
      // ✅ API returned raw HTML
      return ContentWithGrade(
        studentId: '',
        taskId: '',
        contentHtml: data,
      );
    } else if (data is Map<String, dynamic>) {
      // ✅ API returned JSON
      return ContentWithGrade(
        studentId: data['student_id'] ?? '',
        taskId: data['task_id'] ?? '',
        contentHtml: data['content_html'] ?? '',
        grade: data['grade'],
        teacherId: data['teacher_id'],
        comments: data['comments'],
      );
    } else {
      throw Exception("Unsupported response format for ContentWithGrade");
    }
  }

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'task_id': taskId,
        'content_html': contentHtml,
        'grade': grade,
        'teacher_id': teacherId,
        'comments': comments,
      };
}

