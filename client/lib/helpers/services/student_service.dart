import 'package:vantanceCA/helpers/logger/logger.dart';
import 'package:vantanceCA/helpers/network/api_service.dart';
import 'package:dio/dio.dart';

class StudentService {
  /// Fetch all classes for a student by learner ID
  static Future<dynamic> getStudentClassAPI({required String learnerId}) async {
    try {
      final response = await APIService.get(
        path: "/db/learner/get_class_summary/",
        params: {"learner_id": learnerId},
      );

      return response.statusCode == 200 ? response : null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  /// View class details for a student
  static Future<dynamic> getStudentViewClassAPI({
    required String learnerId,
    required String classId,
  }) async {
    try {
      final response = await APIService.get(
        path: "/db/learner/get_class_tasks/",
        params: {
          "learner_id": learnerId,
          "class_id": classId,
        },
      );

      return response.statusCode == 200 ? response : null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  /// Get all assignments for a student
  static Future<dynamic> getStudentAssignmentAPI({
    required String learnerId,
    required String status, // "active", "pending_review", "graded"
    required String taskType, // "assignment" or "fingerprint"
  }) async {
    try {
      final response = await APIService.get(
        path: "/db/learner/get_class_tasks_by_status/",
        params: {
          "learner_id": learnerId,
          "status": status,
          "task_type": taskType,
        },
      );
      return response.statusCode == 200 ? response : null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  /// Get all assignments for a student
  static Future<dynamic> getStudentOverallAssignmentAPI({
    required String learnerId,
  }) async {
    try {
      final response = await APIService.get(
        path: "/db/learner/get_class_tasks_by_status/",
        params: {"learner_id": learnerId},
      );

      return response.statusCode == 200 ? response : null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  static Future<String?> fetchLearnerHtmlResponse({
    required String siteId,
    required String folderPath,
    required String taskId,
  }) async {
    try {
      // 🔹 Add log before API call
      print("📡 Fetching learner HTML with params => "
          "site_id: $siteId, folder_path: $folderPath, task_id: $taskId");

      final response = await APIService.get(
        path: "/alfresco/student-task-content",
        params: {
          "site_id": siteId,
          "folder_path": folderPath,
          "task_id": taskId,
        },
      );

      // 🔹 Log response for debugging
      print("✅ Response status: ${response.statusCode}");
      print("✅ Response data: ${response.data}");

      if (response.statusCode == 200) {
        if (response.data is String) {
          return response.data;
        } else if (response.data is Map<String, dynamic> &&
            response.data['content'] != null) {
          return response.data['content'];
        }
      }
      return null;
    } on DioException catch (e) {
      logE("❌ Error fetching learner HTML: ${e.message}");
      return null;
    }
  }

/*  /// Get writing pad data
  static Future<dynamic> getWritingPadAPI({required String id}) async {
    try {
      final response = await APIService.get(
        path: "/db/learner/writing_pad",
        params: {"student_id": id},
      );

      return response.statusCode == 200 ? response : null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }*/

  /*/// Get student calendar
  static Future<dynamic> getStudentCalendarAPI() async {
    try {
      final response = await APIService.get(
        path: "/db/learner/calendar",
      );

      return response.statusCode == 200 ? response : null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }*/

  /// Send a message to Sage AI (Streaming API)
  static Future<dynamic> sendMessageSageAI({
    Map<String, dynamic>? mapData,
  }) async {
    try {
      final response = await APIService.postWithoutAth(
        path: "/stream/chat",
        headers: {
          "Auth": "Bearer YKP510G-HGGMNNJ-JHPB9RA-D3Q4WPQ",
          "accept": "text/event-stream",
        },
        mapData: mapData, // ✅ Accepts Map or FormData
      );

      return response.statusCode == 200 ? response : null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  /// Get Writing Pad page data
  static Future<dynamic> getWritingPageDataAPI({
    required String studentID,
    required String assignmentID,
  }) async {
    try {
      final response = await APIService.postWithoutAth(
        path: "/db/learner/writingpad/task_details/$studentID/$assignmentID",
        data: null, // ✅ Explicit null for POST without body
      );

      return response.statusCode == 200 ? response : null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  static Future<dynamic> getWritingPadAPI(
      {required String learnerId, required String id}) async {
    try {
      final response = await APIService.get(
        path: "/db/writingpad/get_taskdetails/",
        params: {"learner_id": learnerId, "task_id": id},
      );

      return response.statusCode == 200 ? response : null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  /// Get student calendar
  static Future<dynamic> getStudentCalendarAPI(
      {required String learnerId,
      required int taskMonth,
      required int taskYear}) async {
    try {
      final response = await APIService.get(
        path: "/db/learner/get_tasks_by_month_year/",
        params: {
          "learner_id": learnerId,
          "task_month": taskMonth,
          "task_year": taskYear
        },
      );

      return response.statusCode == 200 ? response : null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }
}
