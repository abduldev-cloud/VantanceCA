import 'package:binary_success/helpers/constant/app_constant.dart';
import 'package:binary_success/helpers/logger/logger.dart';
import 'package:binary_success/helpers/network/api_service.dart';
import 'package:binary_success/models/ai_usage_overview_model.dart';
import 'package:binary_success/models/teacher_classes_model_analytics.dart';
import 'package:binary_success/widgets/common_status_dialog.dart';
import 'package:dio/dio.dart';
import 'package:binary_success/models/teachers_grading_model.dart';
import 'package:binary_success/models/teacher_classes_model.dart';
import 'package:binary_success/models/teacher_view_class_model.dart';
import 'package:binary_success/models/teacher_fingerprint_detail_model.dart';
import 'package:binary_success/models/create_class_model.dart';
import 'package:binary_success/models/create_task_model.dart';
import 'package:binary_success/models/teacher_dashboard_model.dart';
import 'package:binary_success/models/teacher_dashboard_analytics_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeacherService {
  /// ✅ Create Class API
  static Future<CreateClassResponse?> createClassAPI(
      CreateClassRequest request) async {
    try {
      final response = await APIService.post(
        mapData: request.toJson(),
        forcedBaseUrl: API.apiURL,
        path: "admin/teacher/create_class/",
      );

      print("Create Class Response==${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CreateClassResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      logE("Error creating class: ${e.message}");
      return null;
    }
  }

  static Future<List<WritingFingerprintAlert>> getWritingFingerprintAlerts(
      {required String teacherId}) async {
    try {
      final response = await APIService.get(
        path: "/analytics/get-learners-deviation",
        params: {"teacher_id": teacherId}, // pass teacherId as query param
      );

      if (response.statusCode == 200 && response.data?['success'] == true) {
        final data = response.data?['data'];
        if (data != null && data['learners'] != null) {
          final learners = data['learners'] as List;
          return learners
              .map((json) => WritingFingerprintAlert.fromJson(json))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      logE("API getLearnersDeviation failed: ${e.message}");
      return [];
    }
  }

  static Future<ApiResponse?> getTeacherClassFilters({
    required String teacherId,
    String? instituteId,
    String? className, // Pass className instead of classId
    String? gradeId,
    String? term,
    String? academicYear,
  }) async {
    try {
      final params = <String, String>{
        'teacher_id': teacherId,
        if (instituteId != null) 'institute_id': instituteId,
        if (className != null) 'class_name': className, // <-- updated
        if (gradeId != null) 'grade_id': gradeId,
        if (term != null) 'term': term,
        if (academicYear != null) 'academic_year': academicYear,
      };

      final response = await APIService.get(
        path: "/analytics/teacher-class-filters",
        params: params,
      );

      if (response.statusCode == 200 && response.data?['success'] == true) {
        final data = response.data?['data'];
        if (data != null) {
          // Parse entire response into ApiResponse model
          return ApiResponse.fromJson(response.data!);
        }
      }
      return null;
    } on DioException catch (e) {
      logE("API getTeacherClassFilters failed: ${e.message}");
      return null;
    }
  }

  /// ✅ Teacher Class Summary
  static Future<dynamic> getTeacherClassAPI({
    required String teacherId,
    required String classStatus,
  }) async {
    try {
      final response = await APIService.get(
        path: "/db/teacher/get_class_summary/",
        params: {"teacher_id": teacherId, "class_status": classStatus},
      );
      if (response.statusCode == 200 && response.data != null) {
        return TeacherClassSummaryResponse.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  static Future<dynamic> getTeacherClassAnalyticsAPI() async {
    try {
      final response = await APIService.get(
        withOutAuth: true,
        path: "",
        forcedBaseUrl:
            "${API.baseURl}binarysuccess/${API.teacherClasses}/TCH001",
      );

      if (response.statusCode == 200) {
        return response;
      }
      return null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  /// ✅ Teacher View Class
  static Future<ClassStudentsResponse?> getTeacherViewClassAPI({
    required String teacherId,
    required String classId,
  }) async {
    try {
      final response = await APIService.get(
        path: "/db/teacher/get_class_tasks_stats_and_learners/",
        params: {
          "teacher_id": teacherId,
          "class_id": classId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return ClassStudentsResponse.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  /// ✅ Teacher Dashboard
  static Future<dynamic> getTeacherDashboardAPI() async {
    try {
      final response = await APIService.get(
        withOutAuth: true,
        path: "", // 🔹 Added required path
        forcedBaseUrl:
            "${API.baseURl}binarysuccess/${API.teacherDashboard}/TCH001",
      );

      if (response.statusCode == 200) {
        // return TeacherClassModel.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  /// ✅ Teacher Fingerprint
  static Future<dynamic> getTeacherFingerPrintAPI({
    required String teacherId,
    required String taskType,
  }) async {
    try {
      final response = await APIService.get(
        path: "/db/teacher/get_class_summary/",
        params: {
          "teacher_id": teacherId,
          "task_type": taskType,
        },
      );

      if (response.statusCode == 200) {
        return response;
      }
      return null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  /// ✅ Writing Fingerprint Details
  static Future<WritingFingerprintViewDetailsResponse?>
      getWritingFingerprintViewDetailsAPI(String taskId) async {
    try {
      final response = await APIService.get(
        withOutAuth: true,
        path: "/db/teacher/get_stats_and_learners_for_task/",
        params: {"task_id": taskId},
      );
      if (response.statusCode == 200 && response.data != null) {
        return WritingFingerprintViewDetailsResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      logE("Error in getWritingFingerprintViewDetailsAPI: ${e.message}");
      return null;
    }
  }

  /// ✅ Fingerprint Review
  static Future<Map<String, dynamic>?> getTeacherFingerprintReviewAPI({
    required String learnerId,
    required String taskId,
  }) async {
    try {
      final response = await APIService.get(
        withOutAuth: true,
        path: "/db/writingpad/get_taskdetails",
        params: {
          "learner_id": learnerId,
          "task_id": taskId,
        },
      );

      if (response != null && response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      logE("Error in getTeacherFingerprintReviewAPI: ${e.message}");
      return null;
    }
  }

  /// ✅ Assignment Overview
  static Future<dynamic> getTeacherAssignmentAPI(
    String teacherId, {
    String? taskStatus, // optional filter
  }) async {
    try {
      String url =
          "${API.baseURl}/db/teacher/get_assignment_overview/?teacher_id=$teacherId";

      if (taskStatus != null && taskStatus.isNotEmpty) {
        url += "&task_status=$taskStatus";
      }

      final response = await APIService.get(
        withOutAuth: true,
        path: "", // 🔹 Added required path
        forcedBaseUrl: url,
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      logE("Error in getTeacherAssignmentAPI: ${e.message}");
      return null;
    }
  }

  /// ✅ Task Details
  static Future<Map<String, dynamic>?> getStatsAndLearnersForTask(
      String taskId) async {
    try {
      final response = await APIService.get(
        withOutAuth: true,
        path: "/db/teacher/get_stats_and_learners_for_task/?task_id=$taskId",
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      logE("Error fetching task details: ${e.message}");
      return null;
    }
  }

  /// ✅ Assignment Review
  static Future<Map<String, dynamic>?> getTeacherAssignmentReviewAPI({
    required String learnerId,
    required String taskId,
  }) async {
    try {
      final response = await APIService.get(
        withOutAuth: true,
        path:
            "/db/writingpad/get_taskdetails/?learner_id=$learnerId&task_id=$taskId",
      );

      if (response != null && response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      logE("Error in getTeacherAssignmentReviewAPI: ${e.message}");
      return null;
    }
  }

  static Future<String?> fetchLearnerHtmlResponse({
    required String siteId,
    required String folderPath,
    required String taskId,
  }) async {
    try {
      final url =
          "${API.baseURl}/alfresco/student-task-content?site_id=$siteId&folder_path=$folderPath&task_id=$taskId";
      print('Fetching learner HTML from URL: $url');
      final response = await Dio().get(url);

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
      logE("Error fetching learner HTML: ${e.message}");
      return null;
    }
  }

  /// ✅ Teacher Calendar
  static Future<dynamic> getTeacherCalendarAPI({
    required String teacherId,
    required int taskMonth,
    required int taskYear,
  }) async {
    try {
      final response = await APIService.get(
        path: "/db/teacher/get_tasks_by_month_year/",
        params: {
          "teacher_id": teacherId,
          "task_month": taskMonth,
          "task_year": taskYear,
        },
      );

      return response.statusCode == 200 ? response : null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  /// ✅ Rubric Details
  static Future<Map<String, dynamic>?> getRubricDetails(String taskId) async {
    try {
      final response = await APIService.get(
        withOutAuth: true,
        path: "", // 🔹 Added required path
        forcedBaseUrl:
            "${API.baseURl}/db/teacher/get_rubric_details/?task_id=$taskId",
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      logE("❌ getRubricDetails error: ${e.message}");
      return null;
    }
  }

  /// ✅ Create Task
  static Future<CreateTaskResponse?> createTaskAPI(
      CreateTaskRequest request) async {
    try {
      final response = await APIService.post(
        mapData: request.toJson(),
        forcedBaseUrl: API.apiURL,
        path: "admin/teacher/create_task/",
      );

      print("Create Task Response==${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CreateTaskResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      logE("Error creating task: ${e.message}");
      return null;
    }
  }

  static Future<CreateTaskAlfrescoResponse?> createTaskAlfrescoAPI(
      CreateTaskAlfrescoRequest request) async {
    try {
      final response = await APIService.post(
        mapData: request.toJson(),
        forcedBaseUrl: API.alfrescoBaseURL,
        path: "assign-workflow/by-teacher",
      );

      print("Create Alfresco Task Response==$response");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CreateTaskAlfrescoResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      logE("Error in creating alfresco task: ${e.message}");
      return null;
    }
  }

  /// ✅ Teacher SF Class
  static Future<dynamic> getTeacherSFClassAPI(
      {required String teacherId, required String classStatus}) async {
    try {
      final response = await APIService.get(
        path: "/db/teacher/get_class_summary/",
        params: {
          "teacher_id": teacherId,
          "class_status": classStatus,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return TeacherClassSummaryResponse.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  /// ✅ Get Teacher Classes by Class Name
  static Future<dynamic> getTeacherClassNameAPI({
    required String teacherId,
    required String className,
  }) async {
    try {
      final response = await APIService.get(
        path: "/teacher/get_teacher_classes_by_class_name/",
        params: {
          "teacher_id": teacherId,
          "class_name": className,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        return null;
      }
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  static Future<dynamic> getTeacherGradingAPI() async {
    try {
      final response = await APIService.get(
        withOutAuth: true,
        path: "",
        forcedBaseUrl:
            "${API.baseURl}binarysuccess/${API.teacherGrading}/TCH001",
      );

      if (response.statusCode == 200) {
        return response;
      }
      return null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  /// Get teacher ID by email lookup
  ///
  /// [email] - Required email address to lookup teacher ID
  static Future<Map<String, dynamic>?> getTeacherIdByEmail({
    required String email,
  }) async {
    try {
      logI("Looking up teacher ID for email: $email");

      // Build query parameters
      Map<String, dynamic> queryParams = {
        'email': email,
      };

      // Make API call to lookup teacher ID
      final response = await APIService.get(
        path: "/analytics/lookup/teacher-id",
        params: queryParams,
        withOutAuth: true, // Use without auth like other analytics endpoints
        forcedBaseUrl: API.baseURl, // Use local backend for analytics
      );

      if (response.statusCode == 200 && response.data != null) {
        logI("Successfully found teacher ID for email: $email");
        logI("Response data: ${response.data}");
        return response.data as Map<String, dynamic>;
      }
      logE("Teacher ID lookup failed with status: ${response.statusCode}");
      return null;
    } catch (e) {
      logE("Error looking up teacher ID for email $email: $e");
      return null;
    }
  }

  /// Get teacher dashboard analytics data
  ///
  /// [teacherId] - Required teacher ID parameter
  /// [timeRangeDays] - Optional time range in days (default: 30, max: 365)
  /// [classId] - Optional class ID filter

  static Future<TeacherDashboardAnalyticsModel?> getTeacherDashboardAnalytics({
    required String teacherId,
    int timeRangeDays = 30,
    String? classId,
  }) async {
    try {
      // Validate parameters
      if (teacherId.isEmpty) {
        logE("Teacher ID is required for analytics");
        return null;
      }

      if (timeRangeDays < 1 || timeRangeDays > 365) {
        logE("Time range days must be between 1 and 365");
        return null;
      }

      // Build query parameters
      Map<String, dynamic> queryParams = {
        'teacher_id': teacherId,
        'time_range_days': timeRangeDays,
      };

      // Add optional class_id if provided
      if (classId != null && classId.isNotEmpty) {
        queryParams['class_id'] = classId;
      }

      logI("Fetching teacher dashboard analytics for teacher: $teacherId");
      logI("Query parameters: $queryParams");

      // Make API call
      final response = await APIService.get(
        path: "/analytics/teacher-dashboard",
        params: queryParams,
        withOutAuth: true, // Use without auth like other analytics endpoints
        forcedBaseUrl: API.baseURl, // Use local backend for analytics
      );
      if (response.statusCode == 200 && response.data != null) {
        logI("Successfully fetched teacher dashboard analytics");
        try {
          final analyticsData =
              TeacherDashboardAnalyticsModel.fromJson(response.data);
          logI("Successfully parsed teacher dashboard analytics data");
          return analyticsData;
        } catch (parseError) {
          logE(
              "Error parsing teacher dashboard analytics response: $parseError");
          logE("Response data: ${response.data}");
          return null;
        }
      }
      logE(
          "Teacher dashboard analytics request failed with status: ${response.statusCode}");
      return null;
    } catch (e) {
      logE("Error fetching teacher dashboard analytics: $e");
      return null;
    }
  }

  /// Get teacher dashboard analytics with email-based lookup
  ///
  /// [email] - Required email address to lookup teacher ID
  /// [timeRangeDays] - Optional time range in days (default: 30, max: 365)
  /// [classId] - Optional class ID filter
  static Future<TeacherDashboardAnalyticsModel?>
      getTeacherDashboardAnalyticsByEmail({
    required String email,
    int timeRangeDays = 30,
    String? classId,
  }) async {
    try {
      logI("Starting getTeacherDashboardAnalyticsByEmail for email: $email");
      logI("Parameters - timeRangeDays: $timeRangeDays, classId: $classId");

      // First, get the teacher ID from email
      final teacherLookup = await getTeacherIdByEmail(email: email);
      logI("Teacher lookup result: $teacherLookup");

      if (teacherLookup == null || teacherLookup['teacher_id'] == null) {
        logE("Could not find teacher ID for email: $email");
        logE("Teacher lookup was null or missing teacher_id");
        return null;
      }

      final teacherId = teacherLookup['teacher_id'] as String;
      logI("Found teacher ID: $teacherId for email: $email");

      // Now fetch the dashboard analytics using the teacher ID
      logI("Calling getTeacherDashboardAnalytics with teacherId: $teacherId");
      final result = await getTeacherDashboardAnalytics(
        teacherId: teacherId,
        timeRangeDays: timeRangeDays,
        classId: classId,
      );

      logI(
          "getTeacherDashboardAnalytics result: ${result != null ? 'SUCCESS' : 'NULL'}");
      if (result != null) {
        logI(
            "Result has pendingSubmissions: ${result.pendingSubmissions != null}");
        logI("Result has gradedThisWeek: ${result.gradedThisWeek != null}");
        logI("Result has activeStudents: ${result.activeStudents != null}");
      }

      return result;
    } catch (e) {
      logE("Error in getTeacherDashboardAnalyticsByEmail: $e");
      return null;
    }
  }

  /// Get teacher dashboard data using email (new endpoint)
  ///
  /// [email] - Required teacher email address
  static Future<TeacherDashboardModel?> getTeacherDashboardByEmail({
    required String email,
  }) async {
    try {
      logI("Fetching teacher dashboard data for email: $email");

      // URL encode the email to handle special characters like @
      final encodedEmail = Uri.encodeComponent(email);

      // Make API call to the new teacher dashboard endpoint
      final response = await APIService.get(
        path: "/analytics/teacher-dashboard/$encodedEmail",
        withOutAuth: true, // Use without auth like other analytics endpoints
        forcedBaseUrl: API.baseURl, // Use local backend for analytics
      );
      if (response.statusCode == 200 && response.data != null) {
        logI("Successfully fetched teacher dashboard data for email: $email");
        try {
          final dashboardData = TeacherDashboardModel.fromJson(response.data);
          logI("Successfully parsed teacher dashboard data");
          logI(
              "Assignments - Graded: ${dashboardData.data?.assignments?.gradedCount}, In Review: ${dashboardData.data?.assignments?.inReviewCount}");
          logI(
              "Students - Total: ${dashboardData.data?.students?.totalStudents}");
          return dashboardData;
        } catch (parseError) {
          logE("Error parsing teacher dashboard response: $parseError");
          logE("Response data: ${response.data}");
          return null;
        }
      }
      logE(
          "Teacher dashboard request failed with status: ${response.statusCode}");
      return null;
    } catch (e) {
      logE("Error fetching teacher dashboard data for email $email: $e");
      return null;
    }
  }
}

class TeacherGradingService {
  static final Dio _dio = Dio();
  static String get _baseUrl => "${API.apiURL}admin/teacher";

  /// ✅ Fetch grading counts (pending, submitted, graded, etc.)
  ///
  static Future<List<TaskSummary>> getTeacherGradingCounts({
    required String teacherId,
    int pageNumber = AppConstant.defaultPageNumber,
    int pageSize = AppConstant.defaultPageSize,
  }) async {
    try {
      final buffer = StringBuffer(
          "$_baseUrl/get_grading_task_overview/?teacher_id=$teacherId");
      buffer.write("&page_number=$pageNumber&page_size=$pageSize");

      final response = await _dio.get(buffer.toString());

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data["grading_counts"] != null) {
        return (response.data["grading_counts"] as List)
            .map((e) => TaskSummary.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print("❌ getTeacherGradingCounts: ${e.message}");
      return [];
    }
  }

  /// Save learner task comments via API
  static Future<String?> saveLearnerTaskComments({
    required Map<String, dynamic> reviewComments,
  }) async {
    // final url = "${API.apiURL}admin/teacher/upsert_learner_task_comments/";
    // final body = {
    //   "review_comments": reviewComments,
    // };

    final url = "${API.apiURL}admin/teacher/upsert_learner_task_comment/";

    try {
      final response = await _dio.post(
        url,
        data: reviewComments,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map && data['out_status'] == 'SUCCESS') {
          return data['out_comment_id'];
        }
      } else {
        print(
            'Failed to save comments: \${response.statusCode} \${response.data}');
        return null;
      }
    } catch (e) {
      print('Error saving comments: \$e');
      return null;
    }
    return null;
  }

  /// ✅ Fetch paginated teacher grading tasks
  static Future<GradingApiResponse?> getTeacherGradingTasks({
    required String teacherId,
    String taskStatus = "",
    int pageNumber = AppConstant.defaultPageNumber,
    int pageSize = AppConstant.defaultPageSize,
  }) async {
    try {
      final buffer = StringBuffer(
          "$_baseUrl/get_grading_task_overview/?teacher_id=$teacherId");
      buffer.write("&page_number=$pageNumber&page_size=$pageSize");
      if (taskStatus.isNotEmpty) buffer.write("&task_status=$taskStatus");

      final response = await _dio.get(buffer.toString());

      if (response.statusCode == 200 && response.data != null) {
        return GradingApiResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      print("❌ getTeacherGradingTasks: ${e.message}");
      return null;
    }
  }

  /// ✅ Update teacher grade for learner task
  static Future<bool> updateTeacherGrade({
    required String taskId,
    required String learnerId,
    required String teacherGrade,
  }) async {
    try {
      final url =
          "${API.apiURL}admin/teacher/update_teacher_grade_for_learner_task/";
      final params = {
        'task_id': taskId,
        'learner_id': learnerId,
        'teacher_grade': teacherGrade,
      };
      final response = await _dio.post(
        url,
        queryParameters: params,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("❌ updateTeacherGrade: ${e.message}");
      return false;
    }
  }

  static Future<GradingViewApiResponse?> getTeacherGradingview(
      {required String task_id, String learner_id = ""}) async {
    try {
      final response = await APIService.get(
        withOutAuth: true,
        path: "/db/writingpad/get_taskdetails/",
        params: {
          "learner_id": learner_id,
          "task_id": task_id,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return GradingViewApiResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      print("❌ GradingViewApiResponse: ${e.message}");
      return null;
    }
  }

  static Future<ContentWithGrade?> getTeacherGradingContent({
    required String site_id,
    String folder_path = "",
    String student_id = "",
    String task_id = "",
    String file_name = "",
  }) async {
    try {
      final response = await APIService.get(
        withOutAuth: true,
        forcedBaseUrl: API.alfrescoBaseURL,
        path:
            "student-task-content?site_id=$site_id&folder_path=$folder_path&task_id=$file_name",
      );

      if (response.statusCode == 200 && response.data != null) {
        return ContentWithGrade.fromApi(response.data);
      }
      return null;
    } on DioException catch (e) {
      print("❌ ContentWithGrade: ${e.message}");
      return null;
    }
  }
}

class PushGradesService {
  static Future<bool> pushGrade({
    required String assignmentId,
    required String teacherId,
    required String classId,
    required String learnerId,
    required String comments,
    required String postedGrade,
  }) async {
    final url =
        "${API.integrationBaseURl}/push_grades?binary_success_assignment_id=$assignmentId&binary_success_teacher_id=$teacherId&binary_success_class_id=$classId";

    final body = [
      {
        "binary_success_learner_id": learnerId,
        "comments": comments,
        "posted_grade": postedGrade,
      }
    ];

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("PushGrades Success: ${response.body}");
        return true;
      } else {
        print("PushGrades failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("PushGrades exception: $e");
      return false;
    }
  }
}

class AssignmentAlfrescoDraftService {
  static final Dio _dio = Dio();
  static Future<bool> saveLearnerTaskAsDraft({
    required String taskId,
    required String learnerId,
    required String wordCount,
    required String fileName,
  }) async {
    try {
      final url = "${API.baseURl}/db/writingpad/save_learner_task_as_draft/";
      final params = <String, String>{
        'task_id': taskId,
        'learner_id': learnerId,
        'word_count': wordCount,
        'file_name': fileName,
      };

      // Send POST with query params (no request body).
      final response = await _dio.post(
        url,
        queryParameters: params,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("❌ AssignmentAlfrescoDraftService: ${e.message}");
      return false;
    }
  }
}
