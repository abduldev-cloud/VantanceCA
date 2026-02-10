import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class DraftAssignmentAlfrescoRequest {
  final String siteId;
  final String folderPath;
  final String alfrescoTaskId;
  final String alfrescoStudentID;
  final String? alfrescoTeacherId;
  final Uint8List htmlBytes;
  final String fileName;

  DraftAssignmentAlfrescoRequest({
    required this.siteId,
    required this.folderPath,
    required this.alfrescoTaskId,
    required this.alfrescoStudentID,
    this.alfrescoTeacherId,
    required this.htmlBytes,
    required this.fileName,
  });

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      "site_id": siteId,
      "folder_path": folderPath,
      "task_id": alfrescoTaskId,
      "student_id": alfrescoStudentID,
      "file": MultipartFile.fromBytes(
        htmlBytes,
        filename: fileName,
        contentType: MediaType("text", "html"),
      ),
    });
  }
  
  Future<FormData> toFormDataSubmit() async {
    return FormData.fromMap({
      "site_id": siteId,
      "folder_path": folderPath,
      "task_id": alfrescoTaskId,
      "student_id": alfrescoStudentID,
      "teacher_id": alfrescoTeacherId,
      "file": MultipartFile.fromBytes(
        htmlBytes,
        filename: fileName,
        contentType: MediaType("text", "html"),
      ),
    });
  }
}

class DraftAssignmentAlfrescoResponse {
  final bool success;
  final String? message;
  final String? taskId;

  DraftAssignmentAlfrescoResponse({
    required this.success,
    this.message,
    this.taskId,
  });

  factory DraftAssignmentAlfrescoResponse.fromJson(Map<String, dynamic> json) {
    return DraftAssignmentAlfrescoResponse(
      success: json['success'] ?? false,
      message: json['out_status'],
      taskId: json['out_task_id'],
    );
  }
}

class DraftAssignmentDBRequest {
  final String taskId;
  final String learnerId;
  final String wordCount;
  final String fileName;

  DraftAssignmentDBRequest({
    required this.taskId,
    required this.learnerId,
    required this.wordCount,
    required this.fileName,
  });

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'learner_id': learnerId,
      'word_count': wordCount,
      'file_name': fileName,
    };
  }
}


class DraftAssignmentDBResponse {
  final bool success;
  final String? message;
  final String? taskId;

  DraftAssignmentDBResponse({
    required this.success,
    this.message,
    this.taskId,
  });

  factory DraftAssignmentDBResponse.fromJson(Map<String, dynamic> json) {
    return DraftAssignmentDBResponse(
      success: json['success'] ?? false,
      message: json['out_status'],
      taskId: json['out_task_id'],
    );
  }
}

class DraftAssignmentNotificationRequest {
  final String learnerId;
  final String title;
  final String message;
  final String noticeType;

  DraftAssignmentNotificationRequest({
    required this.learnerId,
    required this.title,
    required this.message,
    required this.noticeType,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': learnerId,
      'title': title,
      'message': message,
      'notif_type': noticeType,
    };
  }
}


class DraftAssignmentNotificationResponse {
  final bool success;
  final String? message;
  final String? taskId;

  DraftAssignmentNotificationResponse({
    required this.success,
    this.message,
    this.taskId,
  });

  factory DraftAssignmentNotificationResponse.fromJson(Map<String, dynamic> json) {
    return DraftAssignmentNotificationResponse(
      success: json['success'] ?? false,
      message: json['out_status'],
      taskId: json['out_task_id'],
    );
  }
}