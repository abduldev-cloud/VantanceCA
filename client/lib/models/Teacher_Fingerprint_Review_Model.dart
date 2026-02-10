import 'dart:convert';

TeacherFingerprintReviewModel teacherFingerprintReviewModelFromJson(String str) =>
    TeacherFingerprintReviewModel.fromJson(json.decode(str));

String teacherFingerprintReviewModelToJson(TeacherFingerprintReviewModel data) =>
    json.encode(data.toJson());

class TeacherFingerprintReviewModel {
  final String? learnerId;
  final String? studentFullName;
  final String? className;
  final String? gradeName;
  final String? assignmentType;
  final DateTime? submittedAt;
  final int? wordCount;
  final int? submittedWordCount;   // New field
  final String? taskTitle;          // New field
  final String? essayText;

  // Alfresco fields
  final String? alfrescoSiteId;
  final dynamic alfrescoTaskId;
  final String? alfrescoFolderPath;
  final String? fileName;

  TeacherFingerprintReviewModel({
    this.learnerId,
    this.studentFullName,
    this.className,
    this.gradeName,
    this.assignmentType,
    this.submittedAt,
    this.wordCount,
    this.submittedWordCount,
    this.taskTitle,
    this.essayText,
    this.alfrescoSiteId,
    this.alfrescoTaskId,
    this.alfrescoFolderPath,
    this.fileName,
  });

  factory TeacherFingerprintReviewModel.fromJson(Map<String, dynamic> json) {
    final summaryList = (json['task_summary'] as List?) ?? [];
    final summary = summaryList.isNotEmpty ? summaryList.first as Map<String, dynamic> : {};

    String fullName = [
      summary['learner_salutation'] ?? '',
      summary['learner_first_name'] ?? '',
      summary['learner_last_name'] ?? '',
    ].where((x) => (x as String).trim().isNotEmpty).join(' ');

    final essayText = json['essay_text'] ?? '';

    int wc = 0;
    if (essayText.trim().isNotEmpty) {
      wc = essayText.trim().split(RegExp(r"\s+")).length;
    } else if (summary['word_count'] != null) {
      wc = int.tryParse(summary['word_count'].toString()) ?? 0;
    }

    int? swc;
    if (json['submitted_word_count'] != null) {
      swc = int.tryParse(json['submitted_word_count'].toString());
    } else if (summary['submitted_word_count'] != null) {
      swc = int.tryParse(summary['submitted_word_count'].toString());
    }

    return TeacherFingerprintReviewModel(
      learnerId: summary['learner_id'],
      studentFullName: fullName.isNotEmpty ? fullName : null,
      className: summary['class_name'],
      gradeName: summary['grade_name'],
      assignmentType: 'Writing Fingerprint',
      submittedAt: summary['submitted_at'] != null
          ? DateTime.tryParse(summary['submitted_at'])
          : null,
      wordCount: wc,
      submittedWordCount: swc,
      taskTitle: json['task_title'] ?? summary['task_title'],
      essayText: essayText,
      alfrescoSiteId: summary['alfresco_site_id'],
      alfrescoTaskId: summary['alfresco_task_id'],
      alfrescoFolderPath: summary['alfresco_folder_path'],
      fileName: summary['file_name'],
    );
  }

  Map<String, dynamic> toJson() => {
        "learner_id": learnerId,
        "student_full_name": studentFullName,
        "class_name": className,
        "grade_name": gradeName,
        "assignment_type": assignmentType,
        "submitted_at": submittedAt?.toIso8601String(),
        "word_count": wordCount,
        "submitted_word_count": submittedWordCount,
        "task_title": taskTitle,
        "essay_text": essayText,
        "alfresco_site_id": alfrescoSiteId,
        "alfresco_task_id": alfrescoTaskId,
        "alfresco_folder_path": alfrescoFolderPath,
        "file_name": fileName,
      };
}
