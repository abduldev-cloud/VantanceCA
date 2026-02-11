import 'package:vantanceCA/helpers/logger/logger.dart';
import 'package:vantanceCA/helpers/network/api_service.dart';
import 'package:vantanceCA/helpers/constant/app_constant.dart';
import 'package:vantanceCA/models/school_dashboard_analytics_model.dart';
import 'package:vantanceCA/models/ai_usage_overview_model.dart';
import 'package:vantanceCA/models/school_class_model.dart';
import 'package:vantanceCA/models/school_performance_metrics_model.dart';
import 'package:vantanceCA/models/teacher_classes_model_analytics.dart'
    show ApiResponse;
import 'package:dio/dio.dart';

class SchoolAnalyticsService {
  /// Get institute ID by admin email
  static Future<String?> getInstituteIdByEmail({required String email}) async {
    try {
      if (email.isEmpty) {
        logE("Email is required for institute lookup");
        return null;
      }

      logI("Fetching institute ID for admin email: $email");

      // Use the EXACT working endpoint: /analytics/institute-by-email/{email}
      final encodedEmail = Uri.encodeComponent(email);
      final response = await APIService.get(
        path: "/analytics/institute-by-email/$encodedEmail",
        forcedBaseUrl: API.baseURl,
        withOutAuth: true,
      );

      logI("Raw institute lookup response: ${response.data}");
      logI("Response status: ${response.statusCode}");

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data['institute_id'] != null) {
          final instituteId = data['institute_id'] as String?;
          logI("Found institute ID: $instituteId for email: $email");
          return instituteId;
        }
      }

      logE("Invalid response format for institute lookup");
      logE("Response data: ${response.data}");
      throw Exception("Invalid response format from server");
    } catch (e) {
      logE("Error in getInstituteIdByEmail: $e");
      logE("Error type: ${e.runtimeType}");

      // Handle different types of errors
      if (e is DioException) {
        logE("DioException: ${e.message}");
        if (e.response?.statusCode == 404) {
          logE("Institute not found for email: $email");
          throw Exception("No institute found for admin email: $email");
        } else if (e.response?.statusCode == 400) {
          throw Exception("Invalid email format: $email");
        } else {
          throw Exception(
            "Network error while fetching institute ID: ${e.message}",
          );
        }
      } else {
        logE("Unexpected error in getInstituteIdByEmail: $e");
        throw Exception("Unexpected error: $e");
      }
    }
  }

  /// Get school analytics by institute ID
  static Future<Map<String, dynamic>?> getSchoolAnalyticsByInstituteId({
    required String instituteId,
  }) async {
    try {
      if (instituteId.isEmpty) {
        logE("Institute ID is required for school analytics");
        return null;
      }

      logI("Fetching school analytics for institute: $instituteId");

      // Use the EXACT working endpoint: /analytics/school-analytics/{institute_id}
      final response = await APIService.get(
        path: "/analytics/school-analytics/$instituteId",
        forcedBaseUrl: API.baseURl,
        withOutAuth: true,
      );

      logI("Raw school analytics response: ${response.data}");
      logI("Response status: ${response.statusCode}");

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        logI("Successfully fetched school analytics: $data");
        logI("Data type: ${data.runtimeType}");
        logI("Data keys: ${data.keys.toList()}");
        return data;
      } else {
        logE("Invalid response format for school analytics");
        logE("Response data: ${response.data}");
        throw Exception("Invalid response format from server");
      }
    } catch (e) {
      logE("Error in getSchoolAnalyticsByInstituteId: $e");
      logE("Error type: ${e.runtimeType}");

      // Handle different types of errors
      if (e is DioException) {
        logE("DioException: ${e.message}");
        if (e.response?.statusCode == 404) {
          throw Exception(
            "School analytics not found for institute: $instituteId",
          );
        } else if (e.response?.statusCode == 400) {
          throw Exception("Invalid institute ID: $instituteId");
        } else {
          throw Exception(
            "Network error while fetching school analytics: ${e.message}",
          );
        }
      } else {
        logE("Unexpected error in getSchoolAnalyticsByInstituteId: $e");
        throw Exception("Unexpected error: $e");
      }
    }
  }

  /// Get school analytics by admin email (combines both calls)
  static Future<Map<String, dynamic>?> getSchoolAnalyticsByEmail({
    required String email,
  }) async {
    try {
      logI("Getting school analytics for admin email: $email");

      // Step 1: Get institute ID by email (with better error handling)
      String? instituteId;
      try {
        instituteId = await getInstituteIdByEmail(email: email);
      } catch (e) {
        logE("Error getting institute ID: $e");
        return null;
      }

      if (instituteId == null) {
        logE("Could not find institute for admin email: $email");
        return null;
      }

      logI("Found institute ID: $instituteId for email: $email");

      // Step 2: Get school analytics by institute ID (with better error handling)
      Map<String, dynamic>? analyticsData;
      try {
        analyticsData = await getSchoolAnalyticsByInstituteId(
          instituteId: instituteId,
        );
      } catch (e) {
        logE("Error getting analytics data: $e");
        return null;
      }

      if (analyticsData == null) {
        logE("Could not fetch analytics for institute: $instituteId");
        return null;
      }

      logI("Successfully fetched complete school analytics for email: $email");
      logI("Analytics data: $analyticsData");
      return analyticsData;
    } catch (e) {
      logE("Unexpected error in getSchoolAnalyticsByEmail: $e");
      return null;
    }
  }

  /// Get school dashboard analytics data
  ///
  /// [schoolId] - Required school ID parameter
  /// [timeRangeDays] - Optional time range in days (default: 30, max: 365)
  /// [classId] - Optional class ID filter
  static Future<SchoolDashboardAnalyticsModel?> getSchoolDashboardAnalytics({
    required String schoolId,
    int timeRangeDays = 30,
    String? classId,
  }) async {
    try {
      // Validate parameters
      if (schoolId.isEmpty) {
        logE("School ID is required for analytics");
        return null;
      }

      if (timeRangeDays < 1 || timeRangeDays > 365) {
        logE("Time range days must be between 1 and 365");
        return null;
      }

      // Build query parameters
      Map<String, dynamic> queryParams = {
        'school_id': schoolId,
        'time_range_days': timeRangeDays,
      };

      // Add optional class_id if provided
      if (classId != null && classId.isNotEmpty) {
        queryParams['class_id'] = classId;
      }

      logI("Fetching school dashboard analytics for school: $schoolId");
      logI("Query parameters: $queryParams");

      // Make API call
      final response = await APIService.get(
        path: "/analytics/school-dashboard",
        params: queryParams,
        forcedBaseUrl: API.baseURl, // Use local backend for analytics
      );

      // Check response status
      if (response.statusCode == 200) {
        logI("Successfully fetched school dashboard analytics");
        logI("Response status: ${response.statusCode}");
        logI("Response headers: ${response.headers}");

        // Parse response data
        final responseData = response.data;
        logI("Response data type: ${responseData.runtimeType}");
        logI("Response data: $responseData");

        if (responseData != null) {
          try {
            final model = SchoolDashboardAnalyticsModel.fromJson(responseData);
            logI("Successfully parsed analytics model");
            logI("Assignments: ${model.assignments?.toJson()}");
            logI("Active Teachers: ${model.activeTeachers?.toJson()}");
            logI("Active Students: ${model.activeStudents?.toJson()}");
            return model;
          } catch (parseError) {
            logE("Error parsing response data: $parseError");
            logE("Raw response data: $responseData");
            return null;
          }
        } else {
          logE("Response data is null");
          return null;
        }
      } else {
        logE(
          "Failed to fetch school dashboard analytics. Status: ${response.statusCode}",
        );
        logE("Response data: ${response.data}");
        return null;
      }
    } on DioException catch (e) {
      logE("DioException in getSchoolDashboardAnalytics: ${e.message}");

      // Handle specific error cases
      if (e.response?.statusCode == 404) {
        logE("School dashboard analytics endpoint not found");
      } else if (e.response?.statusCode == 400) {
        logE("Bad request - check parameters: ${e.response?.data}");
      } else if (e.response?.statusCode == 500) {
        logE("Server error while fetching analytics");
      }

      logE("DioException response data: ${e.response?.data}");
      return null;
    } catch (e) {
      logE("Unexpected error in getSchoolDashboardAnalytics: $e");
      return null;
    }
  }

  /// Validate school dashboard analytics response
  static bool isValidAnalyticsResponse(SchoolDashboardAnalyticsModel? model) {
    if (model == null) return false;

    // Check if at least one of the main sections has data
    bool hasAssignments = model.assignments != null;
    bool hasActiveTeachers = model.activeTeachers != null;
    bool hasActiveStudents = model.activeStudents != null;

    return hasAssignments || hasActiveTeachers || hasActiveStudents;
  }

  /// Get formatted error message for UI display
  static String getErrorMessage(String? error) {
    if (error == null || error.isEmpty) {
      return "Unable to load analytics data. Please try again.";
    }

    // Return user-friendly error messages
    if (error.contains("404")) {
      return "Analytics service is currently unavailable.";
    } else if (error.contains("400")) {
      return "Invalid request. Please check your parameters.";
    } else if (error.contains("500")) {
      return "Server error. Please try again later.";
    } else if (error.contains("network")) {
      return "Network error. Please check your connection.";
    }

    return "Unable to load analytics data. Please try again.";
  }

  /// Get AI usage overview analytics data
  ///
  /// [schoolId] - Required school ID parameter
  /// [timeRangeDays] - Optional time range in days (default: 30, max: 365)
  /// [classId] - Optional class ID filter
  static Future<AiUsageOverviewModel?> getAiUsageOverview({
    required String schoolId,
    int timeRangeDays = 30,
    String? classId,
  }) async {
    try {
      // Validate parameters
      if (schoolId.isEmpty) {
        logE("School ID is required for AI usage overview");
        return null;
      }

      if (timeRangeDays < 1 || timeRangeDays > 365) {
        logE("Time range days must be between 1 and 365");
        return null;
      }

      // Build query parameters
      Map<String, dynamic> queryParams = {
        'school_id': schoolId,
        'time_range_days': timeRangeDays,
      };

      // Add optional class_id if provided
      if (classId != null && classId.isNotEmpty) {
        queryParams['class_id'] = classId;
      }

      logI("Fetching AI usage overview for school: $schoolId");
      logI("Query parameters: $queryParams");

      logI(
        "AI usage overview endpoint removed - returning mock data for school: $schoolId",
      );

      // Return mock data since the endpoint has been removed
      return AiUsageOverviewModel(
        writingFingerprintAnalytics: WritingFingerprintAnalytics(
          averageDeviation: 0.0,
          totalCount: 0,
        ),
        aiPromptUsage: AiPromptUsage(averageUsage: 0.0, totalCount: 0),
        monthlyWritingDashboard: MonthlyWritingDashboard([
          0, // Jan
          0, // Feb
          0, // Mar
          0, // Apr
          0, // May
          0, // Jun
          0, // Jul
          0, // Aug
          0, // Sep
          0, // Oct
          0, // Nov
          0, // Dec
        ]),
        message: "Mock data - AI usage overview endpoint removed",
        timestamp: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      logE("Unexpected error in getAiUsageOverview: $e");
      return null;
    }
  }

  /// Get school ID by email address
  ///
  /// [email] - Required email address to lookup
  /// Returns a Map with school_id, school_name, user_type, and other details
  /// UPDATED: Now uses the new institute-by-email endpoint
  static Future<Map<String, dynamic>?> getSchoolIdByEmail({
    required String email,
  }) async {
    try {
      // Validate email format
      if (email.isEmpty || !email.contains('@')) {
        logE("Invalid email format: $email");
        return null;
      }

      logI("Looking up institute ID for email: $email (using new endpoint)");

      // Force use the new endpoint with direct path construction
      final encodedEmail = Uri.encodeComponent(email);
      final response = await APIService.get(
        path: "/analytics/institute-by-email/$encodedEmail",
        forcedBaseUrl: API.baseURl,
      );

      // Check response status
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['success'] == true) {
          final instituteId = responseData['data']['institute_id'] as String?;
          logI("Institute ID lookup successful for email: $email");
          logI("Institute ID: $instituteId");

          // Return in the format expected by existing code
          return {
            'school_id': instituteId,
            'school_name': 'Institute', // Placeholder
            'user_type': 'INSTITUTE_ADMIN',
          };
        } else {
          logE("Invalid response format for institute lookup");
          return null;
        }
      } else if (response.statusCode == 404) {
        logE("No institute found for admin email: $email");
        return null;
      } else {
        logE("Failed to lookup institute ID. Status: ${response.statusCode}");
        return null;
      }
    } on DioException catch (e) {
      logE("DioException in getSchoolIdByEmail: ${e.message}");

      // Handle specific error cases
      if (e.response?.statusCode == 404) {
        logE("Institute not found for email: $email");
        return null;
      } else if (e.response?.statusCode == 400) {
        logE("Bad request - check email format: $email");
        return null;
      } else if (e.response?.statusCode == 500) {
        logE("Server error while looking up institute ID");
        return null;
      }

      return null;
    } catch (e) {
      logE("Unexpected error in getSchoolIdByEmail: $e");
      return null;
    }
  }

  /// Get school dashboard analytics with email-based lookup
  ///
  /// [email] - Required email address to lookup school ID
  /// [timeRangeDays] - Optional time range in days (default: 30, max: 365)
  /// [classId] - Optional class ID filter
  static Future<SchoolDashboardAnalyticsModel?>
      getSchoolDashboardAnalyticsByEmail({
    required String email,
    int timeRangeDays = 30,
    String? classId,
  }) async {
    try {
      logI("Starting getSchoolDashboardAnalyticsByEmail for email: $email");
      logI("Parameters - timeRangeDays: $timeRangeDays, classId: $classId");

      // First, get the institute ID from email using our new method
      final instituteId = await getInstituteIdByEmail(email: email);
      logI("Institute lookup result: $instituteId");

      if (instituteId == null) {
        logE("Could not find institute ID for email: $email");
        logE("Institute lookup was null");
        return null;
      }
      logI("Found institute ID: $instituteId for email: $email");

      // Now fetch the dashboard analytics using the institute ID
      logI("Calling getSchoolDashboardAnalytics with schoolId: $instituteId");
      final result = await getSchoolDashboardAnalytics(
        schoolId: instituteId,
        timeRangeDays: timeRangeDays,
        classId: classId,
      );

      logI(
        "getSchoolDashboardAnalytics result: ${result != null ? 'SUCCESS' : 'NULL'}",
      );
      if (result != null) {
        logI("Result has assignments: ${result.assignments != null}");
        logI("Result has activeTeachers: ${result.activeTeachers != null}");
        logI("Result has activeStudents: ${result.activeStudents != null}");
      }

      return result;
    } catch (e) {
      logE("Error in getSchoolDashboardAnalyticsByEmail: $e");
      return null;
    }
  }

  /// Get AI usage overview with email-based lookup using new analytics endpoint

  /// [email] - Required email address to lookup user role and data
  /// [timeRangeDays] - Optional time range in days (default: 30, max: 365)
  /// [classId] - Optional class ID filter (not used in new endpoint)

  static Future<AiUsageOverviewModel?> getAiUsageOverviewByEmail({
    required String email,
    int timeRangeDays = 50,
    String? classId,
    String? gradeLevelId,
    String? term,
    String? academicYear,
    String bucket = 'month',
  }) async {
    try {
      logI(
        "🚀 Fetching AI usage analytics for email: $email, days_back: $timeRangeDays",
      );

      int periods;
      String actualBucket;

      // Map dropdown selection to API bucket and periods
      switch (bucket.toLowerCase()) {
        case 'week':
          actualBucket = 'day';
          periods = 7;
          break;
        case 'month':
          actualBucket = 'day';
          periods = 30;
          break;
        case 'year':
        default:
          actualBucket = 'month';
          periods = 12;
          break;
      }

      Map<String, dynamic> queryParams = {
        'user_email': email,
        'user_role': 'TEACHER',
        'days_back': timeRangeDays,
        'bucket': actualBucket,
        'periods': periods,
      };

      if (classId != null && classId.isNotEmpty) {
        queryParams['class_id'] = classId;
      }
      if (gradeLevelId != null && gradeLevelId.isNotEmpty) {
        queryParams['grade_level_id'] = gradeLevelId;
      }
      if (term != null && term.isNotEmpty) queryParams['term'] = term;
      if (academicYear != null && academicYear.isNotEmpty) {
        queryParams['academic_year'] = academicYear;
      }

      logI("Query parameters: $queryParams");

      final response = await APIService.get(
        path: "/analytics/ai-usage-analytics",
        params: queryParams,
        withOutAuth: true,
        forcedBaseUrl: API.baseURl,
      );

      logI("Raw AI usage analytics response: ${response.data}");
      logI("Response status: ${response.statusCode}");

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          logI("✅ Successfully received AI usage analytics data");

          final writingFingerprintAnalytics =
              data['writing_fingerprint_analytics'];
          final aiPromptUsage = data['ai_prompt_usage'];
          final trend = writingFingerprintAnalytics?['trend'];

          // Extract trend strings for required fields
          final averageDeviationTrend =
              writingFingerprintAnalytics?['average_deviation_trend']
                      as String? ??
                  "stable";
          final totalCountTrend =
              writingFingerprintAnalytics?['total_count_trend'] as String? ??
                  "stable";
          final aiPromptAverageUsageTrend =
              aiPromptUsage?['average_usage_trend'] as String? ?? "stable";
          final aiPromptTotalCountTrend =
              aiPromptUsage?['total_count_ai_trend'] as String? ?? "stable";

          final trendSeries = trend?['series'] as List<dynamic>? ?? [];

          // Convert trendSeries to List<int> for chart
          List<int> chartData = trendSeries.map<int>((point) {
            final avgDeviation = (point['avg_deviation'] ?? 0.0).toDouble();
            return avgDeviation.round();
          }).toList();

          // Pad chartData if periods > data points
          while (chartData.length < periods) {
            chartData.insert(0, 0);
          }

          final trendDataPoints = trendSeries
              .map<TrendDataPoint>(
                (point) => TrendDataPoint(
                  label: point['label'] as String?,
                  avgDeviation: (point['avg_deviation'] ?? 0.0).toDouble(),
                  startTs: point['start_ts'] as String?,
                ),
              )
              .toList();

          final writingFingerprintTrend = WritingFingerprintTrend(
            bucket: trend?['bucket'] as String?,
            periods: trend?['periods'] as int?,
            className: trend?['class_name'] as String?,
            series: trendDataPoints,
          );

          final writingFingerprintAlerts = <WritingFingerprintAlert>[];
          for (var point in trendSeries) {
            final deviation = (point['avg_deviation'] ?? 0.0).toDouble();
            if (deviation > 25.0) {
              writingFingerprintAlerts.add(
                WritingFingerprintAlert(
                  studentName: "Student ${writingFingerprintAlerts.length + 1}",
                  assignmentTitle: "Assignment for ${point['label']}",
                  deviationPercentage: deviation,
                  submissionDate: point['start_ts'] as String?,
                  alertLevel: deviation > 50.0 ? "high" : "medium",
                  description:
                      "Possible authorship anomaly detected - ${deviation.toStringAsFixed(1)}% deviation from baseline",
                ),
              );
            }
          }

          final scopeInfo = data['scope_info'] != null
              ? ScopeInfo.fromJson(data['scope_info'])
              : null;

          final userContext = data['user_context'] != null
              ? UserContext.fromJson(data['user_context'])
              : null;

          return AiUsageOverviewModel(
            monthlyWritingDashboard: MonthlyWritingDashboard.fromList(
              chartData,
            ),
            writingFingerprintTrend: writingFingerprintTrend,
            writingFingerprintAnalytics: WritingFingerprintAnalytics(
              averageDeviation:
                  (writingFingerprintAnalytics?['average_deviation'] ?? 0.0)
                      .toDouble(),
              totalCount: writingFingerprintAnalytics?['total_count'] ?? 0,
              averageDeviationTrend: averageDeviationTrend,
              totalCountTrend: totalCountTrend,
            ),
            aiPromptUsage: AiPromptUsage(
              averageUsage: (aiPromptUsage?['average_usage'] ?? 0.0).toDouble(),
              totalCount: aiPromptUsage?['total_count'] ?? 0,
              averageUsageTrend: aiPromptAverageUsageTrend,
              totalCountAiTrend: aiPromptTotalCountTrend,
            ),
            writingFingerprintAlerts: writingFingerprintAlerts,
            scopeInfo: scopeInfo,
            userContext: userContext,
            message: response.data['message'] ??
                "AI usage analytics retrieved successfully",
            timestamp:
                response.data['timestamp'] ?? DateTime.now().toIso8601String(),
          );
        }
      }

      logE("❌ Invalid response format for AI usage analytics");
      logE("Response data: ${response.data}");
      return null;
    } catch (e) {
      logE("❌ Error in getAiUsageOverviewByEmail: $e");
      return null;
    }
  }

  /// Get performance metrics by email (role-based)
  static Future<Map<String, dynamic>?> getPerformanceMetricsByEmail({
    required String email,
    required int timeRangeDays,
    String? classId,
  }) async {
    try {
      logI(
        "🚀 Fetching performance metrics for email: $email, days_back: $timeRangeDays",
      );

      // Build query parameters for the performance metrics endpoint
      Map<String, dynamic> queryParams = {
        'user_email': email,
        'user_role': 'TEACHER', // Default to TEACHER role for this service
        'days_back': timeRangeDays,
      };

      logI("Query parameters: $queryParams");

      // Make API call to the performance metrics endpoint
      final response = await APIService.get(
        path: "/analytics/performance-metrics",
        params: queryParams,
        withOutAuth: true,
        forcedBaseUrl: API.baseURl,
      );

      logI("Raw performance metrics response: ${response.data}");
      logI("Response status: ${response.statusCode}");

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          logI("✅ Successfully received performance metrics data");
          return response.data;
        }
      }

      logE("❌ Invalid response format for performance metrics");
      logE("Response data: ${response.data}");
      return null;
    } catch (e) {
      logE("❌ Error in getPerformanceMetricsByEmail: $e");
      return null;
    }
  }

  /// Get performance metrics by email (role-based)
  static Future<Map<String, dynamic>?> get1SchoolPerformanceMetricsByEmail({
    required String email,
    required int timeRangeDays,
    String? classId,
  }) async {
    try {
      logI(
        "🚀 Fetching performance metrics for email: $email, days_back: $timeRangeDays",
      );

      // Build query parameters for the performance metrics endpoint
      Map<String, dynamic> queryParams = {
        'user_email': email,
        'user_role':
            'PLATFORM_ADMIN', // Default to TEACHER role for this service
        'days_back': timeRangeDays,
      };

      logI("Query parameters: $queryParams");

      // Make API call to the performance metrics endpoint
      final response = await APIService.get(
        path: "/analytics/performance-metrics",
        params: queryParams,
        withOutAuth: true,
        forcedBaseUrl: API.baseURl,
      );

      logI("Raw performance metrics response: ${response.data}");
      logI("Response status: ${response.statusCode}");

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          logI("✅ Successfully received performance metrics data");
          return response.data;
        }
      }

      logE("❌ Invalid response format for performance metrics");
      logE("Response data: ${response.data}");
      return null;
    } catch (e) {
      logE("❌ Error in getPerformanceMetricsByEmail: $e");
      return null;
    }
  }

  static Future<ApiResponse?> getAdminClassFilters({
    String? instituteId,
    String? teacherId,
    String? className,
    String? gradeId,
    String? academicYear,
  }) async {
    try {
      final params = <String, String>{};
      // Only add parameters if they are non-null and non-empty
      if (instituteId != null && instituteId.isNotEmpty) {
        params['institute_id'] = instituteId;
      }
      if (teacherId != null && teacherId.isNotEmpty) {
        params['teacher_id'] = teacherId;
      }
      if (className != null && className.isNotEmpty) {
        params['class_name'] = className;
      }
      if (gradeId != null && gradeId.isNotEmpty) params['grade_id'] = gradeId;
      if (academicYear != null && academicYear.isNotEmpty) {
        params['academic_year'] = academicYear;
      }

      // Log the final params for debugging
      print("API params for getAdminClassFilters: $params");

      final response = await APIService.get(
        path: "/analytics/teacher-class-filters",
        params: params,
      );

      if (response.statusCode == 200 && response.data?['success'] == true) {
        final data = response.data?['data'];
        if (data != null) {
          print("API success - data received for filters."); // Debug log
          return ApiResponse.fromJson(response.data!);
        }
      } else {
        print("API failed or returned no data: ${response.data}");
      }
      return null;
    } on DioException catch (e) {
      logE("API getAdminClassFilters failed: ${e.message}");
      return null;
    } catch (e) {
      print("Unexpected error in getAdminClassFilters: $e");
      return null;
    }
  }

  static Future<ApiResponse?> getSchoolClassFilters({
    required String instituteId,
    String? teacherId,
    String? className,
    String? gradeId,
    String? term,
    String? academicYear,
  }) async {
    try {
      final params = <String, String>{
        'institute_id': instituteId,
        if (teacherId != null) 'teacher_id': teacherId,
        if (className != null) 'class_name': className,
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
          return ApiResponse.fromJson(response.data!);
        }
      }
      return null;
    } on DioException catch (e) {
      logE("API getSchoolClassFilters failed: ${e.message}");
      return null;
    }
  }

  /// Get AI usage overview for Institute Admin (role-based)
  static Future<AiUsageOverviewModel?> getAiUsageOverviewForInstituteAdmin({
    required String email,
    int timeRangeDays = 30,
    String? classId,
    String? teacherId,
    String? gradeLevelId,
    String? term,
    String? academicYear,
    String bucket = 'month',
  }) async {
    try {
      logI(
        "🚀 Fetching AI usage analytics for institute admin: $email, days_back: $timeRangeDays",
      );

      int periods;
      String actualBucket;

      // Map dropdown selection to API bucket and periods
      switch (bucket.toLowerCase()) {
        case 'week':
          actualBucket = 'day';
          periods = 7;
          break;
        case 'month':
          actualBucket = 'day';
          periods = 30;
          break;
        case 'year':
        default:
          actualBucket = 'month';
          periods = 12;
          break;
      }

      // Build query parameters
      Map<String, dynamic> queryParams = {
        'user_email': email,
        'user_role': 'INSTITUTE_ADMIN',
        'days_back': timeRangeDays,
        'bucket': actualBucket,
        'periods': periods,
      };

      if (classId != null && classId.isNotEmpty) {
        queryParams['class_id'] = classId;
      }
      if (teacherId != null && teacherId.isNotEmpty) {
        queryParams['teacher_id'] = teacherId;
      }
      if (gradeLevelId != null && gradeLevelId.isNotEmpty) {
        queryParams['grade_level_id'] = gradeLevelId;
      }
      if (term != null && term.isNotEmpty) queryParams['term'] = term;
      if (academicYear != null && academicYear.isNotEmpty) {
        queryParams['academic_year'] = academicYear;
      }

      logI("Query parameters: $queryParams");

      final response = await APIService.get(
        path: "/analytics/ai-usage-analytics",
        params: queryParams,
        withOutAuth: true,
        forcedBaseUrl: API.baseURl,
      );

      logI("Raw AI usage analytics response: ${response.data}");
      logI("Response status: ${response.statusCode}");

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          logI("✅ Successfully received AI usage analytics data");

          final writingFingerprintAnalytics =
              data['writing_fingerprint_analytics'];
          final aiPromptUsage = data['ai_prompt_usage'];
          final trend = writingFingerprintAnalytics?['trend'];

          // Extract trend strings
          final averageDeviationTrend =
              writingFingerprintAnalytics?['average_deviation_trend']
                      as String? ??
                  "stable";
          final totalCountTrend =
              writingFingerprintAnalytics?['total_count_trend'] as String? ??
                  "stable";
          final aiPromptAverageUsageTrend =
              aiPromptUsage?['average_usage_trend'] as String? ?? "stable";
          final aiPromptTotalCountTrend =
              aiPromptUsage?['total_count_ai_trend'] as String? ?? "stable";

          final trendSeries = trend?['series'] as List<dynamic>? ?? [];

          // Convert trendSeries to List<int> for chart
          List<int> chartData = trendSeries.map<int>((point) {
            final avgDeviation = (point['avg_deviation'] ?? 0.0).toDouble();
            return avgDeviation.round();
          }).toList();

          // Pad chartData if periods > data points
          while (chartData.length < periods) {
            chartData.insert(0, 0);
          }

          // Construct writingFingerprintTrend object
          final trendDataPoints = trendSeries
              .map<TrendDataPoint>(
                (point) => TrendDataPoint(
                  label: point['label'] as String?,
                  avgDeviation: (point['avg_deviation'] ?? 0.0).toDouble(),
                  startTs: point['start_ts'] as String?,
                ),
              )
              .toList();

          final writingFingerprintTrend = WritingFingerprintTrend(
            bucket: trend?['bucket'] as String?,
            periods: trend?['periods'] as int?,
            className: trend?['class_name'] as String?,
            series: trendDataPoints,
          );

          // Construct alerts
          final writingFingerprintAlerts = <WritingFingerprintAlert>[];
          for (var point in trendSeries) {
            final deviation = (point['avg_deviation'] ?? 0.0).toDouble();
            if (deviation > 25.0) {
              writingFingerprintAlerts.add(
                WritingFingerprintAlert(
                  studentName: "Student ${writingFingerprintAlerts.length + 1}",
                  assignmentTitle: "Assignment for ${point['label']}",
                  deviationPercentage: deviation,
                  submissionDate: point['start_ts'] as String?,
                  alertLevel: deviation > 50.0 ? "high" : "medium",
                  description:
                      "Possible authorship anomaly detected - ${deviation.toStringAsFixed(1)}% deviation from baseline",
                ),
              );
            }
          }

          final scopeInfo = data['scope_info'] != null
              ? ScopeInfo.fromJson(data['scope_info'])
              : null;
          final userContext = data['user_context'] != null
              ? UserContext.fromJson(data['user_context'])
              : null;

          return AiUsageOverviewModel(
            monthlyWritingDashboard: MonthlyWritingDashboard.fromList(
              chartData,
            ),
            writingFingerprintTrend: writingFingerprintTrend,
            writingFingerprintAnalytics: WritingFingerprintAnalytics(
              averageDeviation:
                  (writingFingerprintAnalytics?['average_deviation'] ?? 0.0)
                      .toDouble(),
              totalCount: writingFingerprintAnalytics?['total_count'] ?? 0,
              averageDeviationTrend: averageDeviationTrend,
              totalCountTrend: totalCountTrend,
            ),
            aiPromptUsage: AiPromptUsage(
              averageUsage: (aiPromptUsage?['average_usage'] ?? 0.0).toDouble(),
              totalCount: aiPromptUsage?['total_count'] ?? 0,
              averageUsageTrend: aiPromptAverageUsageTrend,
              totalCountAiTrend: aiPromptTotalCountTrend,
            ),
            writingFingerprintAlerts: writingFingerprintAlerts,
            scopeInfo: scopeInfo,
            userContext: userContext,
            message: response.data['message'] ??
                "AI usage analytics retrieved successfully",
            timestamp:
                response.data['timestamp'] ?? DateTime.now().toIso8601String(),
          );
        }
      }

      logE("❌ Invalid response format for AI usage analytics");
      logE("Response data: ${response.data}");
      return null;
    } catch (e) {
      logE("❌ Error in getAiUsageOverviewForInstituteAdmin: $e");
      return null;
    }
  }

  /// Get performance metrics for Institute Admin (role-based)
  static Future<Map<String, dynamic>?> getPerformanceMetricsForInstituteAdmin({
    required String email,
    required int timeRangeDays,
    String? classId,
  }) async {
    try {
      logI(
        "🚀 Fetching performance metrics for institute admin: $email, days_back: $timeRangeDays",
      );

      // Build query parameters for the performance metrics endpoint
      Map<String, dynamic> queryParams = {
        'user_email': email,
        'user_role': 'INSTITUTE_ADMIN',
        'days_back': timeRangeDays,
      };

      logI("Query parameters: $queryParams");

      // Make API call to the performance metrics endpoint
      final response = await APIService.get(
        path: "/analytics/performance-metrics",
        params: queryParams,
        withOutAuth: true,
        forcedBaseUrl: API.baseURl,
      );

      logI("Raw performance metrics response: ${response.data}");
      logI("Response status: ${response.statusCode}");

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          logI("✅ Successfully received performance metrics data");
          return response.data;
        }
      }

      logE("❌ Invalid response format for performance metrics");
      logE("Response data: ${response.data}");
      return null;
    } catch (e) {
      logE("❌ Error in getPerformanceMetricsForInstituteAdmin: $e");
      return null;
    }
  }

  /// Get AI usage overview for Platform Admin (role-based)
  static Future<AiUsageOverviewModel?> getAiUsageOverviewForPlatformAdmin({
    required int timeRangeDays,
    String? classId,
    String? teacherId,
    String? gradeLevelId,
    String? term,
    String? academicYear,
    String bucket = 'month',
    String? instituteId,
  }) async {
    try {
      logI(
        "🚀 Fetching AI usage analytics for platform admin, days_back: $timeRangeDays",
      );

      int periods;
      String actualBucket;

      // Map dropdown selection to API bucket and periods
      switch (bucket.toLowerCase()) {
        case 'week':
          actualBucket = 'day';
          periods = 7;
          break;
        case 'month':
          actualBucket = 'day';
          periods = 30;
          break;
        case 'year':
        default:
          actualBucket = 'month';
          periods = 12;
          break;
      }

      // Build query parameters for the AI usage analytics endpoint
      Map<String, dynamic> queryParams = {
        'user_role': 'PLATFORM_ADMIN',
        'days_back': timeRangeDays,
        'bucket': actualBucket,
        'periods': periods, // Get 12 months of data
      };

      if (classId != null && classId.isNotEmpty) {
        queryParams['class_id'] = classId;
      }
      if (teacherId != null && teacherId.isNotEmpty) {
        queryParams['teacher_id'] = teacherId;
      }
      if (gradeLevelId != null && gradeLevelId.isNotEmpty) {
        queryParams['grade_level_id'] = gradeLevelId;
      }
      if (term != null && term.isNotEmpty) queryParams['term'] = term;
      if (academicYear != null && academicYear.isNotEmpty) {
        queryParams['academic_year'] = academicYear;
      }
      if (instituteId != null && instituteId.isNotEmpty) {
        queryParams['institute_id'] = instituteId;
      }

      logI("Query parameters: $queryParams");
      logI("🔗 API URL: ${API.baseURl}/analytics/ai-usage-analytics");
      logI("📊 days_back parameter: $timeRangeDays");

      // Make API call to the AI usage analytics endpoint
      final response = await APIService.get(
        path: "/analytics/ai-usage-analytics",
        params: queryParams,
        withOutAuth: true,
        forcedBaseUrl: API.baseURl,
      );

      logI("Raw AI usage analytics response: ${response.data}");
      logI("Response status: ${response.statusCode}");

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          logI("✅ Successfully received AI usage analytics data");

          final writingFingerprintAnalytics =
              data['writing_fingerprint_analytics'];
          final aiPromptUsage = data['ai_prompt_usage'];
          final trend = writingFingerprintAnalytics?['trend'];

          // Extract trend strings
          final averageDeviationTrend =
              writingFingerprintAnalytics?['average_deviation_trend']
                      as String? ??
                  "stable";
          final totalCountTrend =
              writingFingerprintAnalytics?['total_count_trend'] as String? ??
                  "stable";
          final aiPromptAverageUsageTrend =
              aiPromptUsage?['average_usage_trend'] as String? ?? "stable";
          final aiPromptTotalCountTrend =
              aiPromptUsage?['total_count_ai_trend'] as String? ?? "stable";

          final trendSeries = trend?['series'] as List<dynamic>? ?? [];

          // Convert trendSeries to List<int> for chart
          List<int> chartData = trendSeries.map<int>((point) {
            final avgDeviation = (point['avg_deviation'] ?? 0.0).toDouble();
            return avgDeviation.round();
          }).toList();
          // Pad chartData if periods > data points
          while (chartData.length < periods) {
            chartData.insert(0, 0);
          }

          // Construct writingFingerprintTrend object
          final trendDataPoints = trendSeries
              .map<TrendDataPoint>(
                (point) => TrendDataPoint(
                  label: point['label'] as String?,
                  avgDeviation: (point['avg_deviation'] ?? 0.0).toDouble(),
                  startTs: point['start_ts'] as String?,
                ),
              )
              .toList();

          final writingFingerprintTrend = WritingFingerprintTrend(
            bucket: trend?['bucket'] as String?,
            periods: trend?['periods'] as int?,
            className: trend?['class_name'] as String?,
            series: trendDataPoints,
          );

          // Construct alerts
          final writingFingerprintAlerts = <WritingFingerprintAlert>[];
          for (var point in trendSeries) {
            final deviation = (point['avg_deviation'] ?? 0.0).toDouble();
            if (deviation > 25.0) {
              writingFingerprintAlerts.add(
                WritingFingerprintAlert(
                  studentName: "Student ${writingFingerprintAlerts.length + 1}",
                  assignmentTitle: "Assignment for ${point['label']}",
                  deviationPercentage: deviation,
                  submissionDate: point['start_ts'] as String?,
                  alertLevel: deviation > 50.0 ? "high" : "medium",
                  description:
                      "Possible authorship anomaly detected - ${deviation.toStringAsFixed(1)}% deviation from baseline",
                ),
              );
            }
          }

          final scopeInfo = data['scope_info'] != null
              ? ScopeInfo.fromJson(data['scope_info'])
              : null;
          final userContext = data['user_context'] != null
              ? UserContext.fromJson(data['user_context'])
              : null;

          return AiUsageOverviewModel(
            monthlyWritingDashboard: MonthlyWritingDashboard.fromList(
              chartData,
            ),
            writingFingerprintTrend: writingFingerprintTrend,
            writingFingerprintAnalytics: WritingFingerprintAnalytics(
              averageDeviation:
                  (writingFingerprintAnalytics?['average_deviation'] ?? 0.0)
                      .toDouble(),
              totalCount: writingFingerprintAnalytics?['total_count'] ?? 0,
              averageDeviationTrend: averageDeviationTrend,
              totalCountTrend: totalCountTrend,
            ),
            aiPromptUsage: AiPromptUsage(
              averageUsage: (aiPromptUsage?['average_usage'] ?? 0.0).toDouble(),
              totalCount: aiPromptUsage?['total_count'] ?? 0,
              averageUsageTrend: aiPromptAverageUsageTrend,
              totalCountAiTrend: aiPromptTotalCountTrend,
            ),
            writingFingerprintAlerts: writingFingerprintAlerts,
            scopeInfo: scopeInfo,
            userContext: userContext,
            message: response.data['message'] ??
                "AI usage analytics retrieved successfully",
            timestamp:
                response.data['timestamp'] ?? DateTime.now().toIso8601String(),
          );
        }
      }

      logE("❌ Invalid response format for AI usage analytics");
      logE("Response data: ${response.data}");
      return null;
    } catch (e) {
      logE("❌ Error in getAiUsageOverviewForInstituteAdmin: $e");
      return null;
    }
  }

  /// Get performance metrics for Platform Admin (role-based)
  static Future<Map<String, dynamic>?> getPerformanceMetricsForPlatformAdmin({
    required int timeRangeDays,
    String? classId,
  }) async {
    try {
      logI(
        "🚀 Fetching performance metrics for platform admin, days_back: $timeRangeDays",
      );

      // Build query parameters for the performance metrics endpoint
      Map<String, dynamic> queryParams = {
        'user_role': 'PLATFORM_ADMIN',
        'days_back': timeRangeDays,
      };

      logI("Query parameters: $queryParams");
      logI("🔗 API URL: ${API.baseURl}/analytics/performance-metrics");
      logI("📊 days_back parameter: $timeRangeDays");

      // Make API call to the performance metrics endpoint
      final response = await APIService.get(
        path: "/analytics/performance-metrics",
        params: queryParams,
        withOutAuth: true,
        forcedBaseUrl: API.baseURl,
      );

      logI("Raw performance metrics response: ${response.data}");
      logI("Response status: ${response.statusCode}");

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          logI("✅ Successfully received performance metrics data");
          return response.data as Map<String, dynamic>;
        }
      }

      logE("❌ Invalid response format for performance metrics");
      logE("Response data: ${response.data}");
      return null;
    } catch (e) {
      logE("❌ Error in getPerformanceMetricsForPlatformAdmin: $e");
      return null;
    }
  }

  /// Get AI usage overview data for platform admin (without school filtering)
  static Future<AiUsageOverviewModel?> getPlatformAiUsageOverview({
    int timeRangeDays = 30,
    String? courseId,
    String? departmentId,
  }) async {
    try {
      logI("🚀 Fetching platform AI usage overview");

      // Build query parameters
      Map<String, dynamic> queryParams = {'time_range_days': timeRangeDays};

      // Add optional course_id if provided
      if (courseId != null && courseId.isNotEmpty) {
        queryParams['course_id'] = courseId;
      }

      // Add optional department_id if provided
      if (departmentId != null &&
          departmentId.isNotEmpty &&
          departmentId != "All") {
        queryParams['department_id'] = departmentId;
      }

      logI("Platform AI usage overview query parameters: $queryParams");

      // Make API call to our updated endpoint
      final response = await APIService.get(
        path: "/analytics/ai-usage-overview",
        params: queryParams,
        forcedBaseUrl: API.baseURl, // Use local backend for analytics
      );

      logI("✅ Successfully fetched platform AI usage overview");
      logI("Response data: ${response.data}");

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true &&
          response.data['data'] != null) {
        try {
          // Use the new factory method to parse the API response
          final model = AiUsageOverviewModel.fromApiResponse(
            response.data as Map<String, dynamic>,
          );

          logI("✅ Successfully parsed AI usage overview model");
          logI(
            "Writing Fingerprint - Total Users: ${model.writingFingerprintAnalytics?.totalCount}, Average Deviation: ${model.writingFingerprintAnalytics?.averageDeviation}%",
          );
          logI(
            "AI Usage - Total Prompts: ${model.aiPromptUsage?.totalCount}, Average Usage: ${model.aiPromptUsage?.averageUsage}",
          );

          return model;
        } catch (parseError) {
          logE("❌ Error parsing response data: $parseError");
          logE("Raw response data: ${response.data}");
          return null;
        }
      } else {
        logE("❌ Invalid response structure: missing 'success' or 'data' field");
        return null;
      }
    } on DioException catch (e) {
      logE("❌ DioException in getPlatformAiUsageOverview: ${e.message}");

      // Handle specific error cases
      if (e.response?.statusCode == 404) {
        logE("Platform AI usage overview endpoint not found");
      } else if (e.response?.statusCode == 400) {
        logE("Bad request - check parameters: ${e.response?.data}");
      } else if (e.response?.statusCode == 500) {
        logE("Server error while fetching AI usage overview");
      }

      logE("DioException response data: ${e.response?.data}");
      return null;
    } catch (e) {
      logE("❌ Error in getPlatformAiUsageOverview: $e");
      return null;
    }
  }

  /// Get school performance metrics with email-based lookup
  ///
  /// [email] - Required email address to lookup school ID
  /// [timeRangeDays] - Optional time range in days (default: 30, max: 365)
  /// [classId] - Optional class ID filter
  /// [departmentId] - Optional department ID filter
  static Future<SchoolPerformanceMetricsModel?>
      getSchoolPerformanceMetricsByEmail({
    required String email,
    int timeRangeDays = 30,
    String? classId,
    String? departmentId,
  }) async {
    try {
      logI("Starting getSchoolPerformanceMetricsByEmail for email: $email");
      logI("Parameters - timeRangeDays: $timeRangeDays, classId: $classId");

      // First, get the institute ID from email using our new method
      final instituteId = await getInstituteIdByEmail(email: email);
      logI("Institute lookup result: $instituteId");

      if (instituteId == null) {
        logE("Could not find institute ID for email: $email");
        return null;
      }
      logI("Found institute ID: $instituteId for email: $email");

      // Now fetch performance metrics using the institute ID
      return await getSchoolPerformanceMetrics(
        schoolId: instituteId,
        timeRangeDays: timeRangeDays,
        classId: classId,
        departmentId: departmentId,
      );
    } catch (e) {
      logE("Error in getSchoolPerformanceMetricsByEmail: $e");
      return null;
    }
  }

  /// Get school performance metrics data
  ///
  /// [schoolId] - Required school ID parameter
  /// [timeRangeDays] - Optional time range in days (default: 30, max: 365)
  /// [classId] - Optional class ID filter
  /// [departmentId] - Optional department ID filter
  static Future<SchoolPerformanceMetricsModel?> getSchoolPerformanceMetrics({
    required String schoolId,
    int timeRangeDays = 30,
    String? classId,
    String? departmentId,
  }) async {
    try {
      // Validate parameters
      if (schoolId.isEmpty) {
        logE("School ID is required for performance metrics");
        return null;
      }

      if (timeRangeDays < 1 || timeRangeDays > 365) {
        logE("Time range days must be between 1 and 365");
        return null;
      }

      // Build query parameters
      Map<String, dynamic> queryParams = {
        'school_id': schoolId,
        'time_range_days': timeRangeDays,
      };

      // Add optional class_id if provided
      if (classId != null && classId.isNotEmpty) {
        queryParams['class_id'] = classId;
      }

      // Add optional department_id if provided
      if (departmentId != null &&
          departmentId.isNotEmpty &&
          departmentId != "All") {
        queryParams['department_id'] = departmentId;
      }

      logI("Fetching school performance metrics for school: $schoolId");
      logI("Query parameters: $queryParams");

      // Make API call
      final response = await APIService.get(
        path: "/analytics/school-performance-metrics",
        params: queryParams,
        forcedBaseUrl: API.baseURl, // Use local backend for analytics
      );

      if (response.statusCode == 200 && response.data != null) {
        logI("Successfully fetched performance metrics for school: $schoolId");
        return SchoolPerformanceMetricsModel.fromJson(response.data);
      } else {
        logE(
          "Failed to fetch performance metrics. Status: ${response.statusCode}",
        );
        return null;
      }
    } catch (e) {
      logE("Error fetching performance metrics: $e");
      return null;
    }
  }

  /// Get school classes for dropdown selection
  ///
  /// [schoolId] - Required school ID parameter
  static Future<List<SchoolClassModel>> getSchoolClasses({
    required String schoolId,
  }) async {
    try {
      // Validate parameters
      if (schoolId.isEmpty) {
        logE("School ID is required for fetching classes");
        return [];
      }

      // Try to fetch from database endpoint
      final response = await APIService.get(
        path: "/analytics/db/institute/get_classes",
        params: {'institute_id': schoolId},
        forcedBaseUrl: API.baseURl, // Use local backend for analytics
      );

      if (response.statusCode == 200 && response.data != null) {
        // Parse response data
        final responseData = response.data;
        if (responseData is List) {
          return responseData
              .map((classData) => SchoolClassModel.fromJson(classData))
              .toList();
        } else if (responseData is Map && responseData['classes'] != null) {
          return SchoolClassesResponse.fromJson(
            responseData.cast<String, dynamic>(),
          ).classes;
        }
      }

      // Return empty list if API fails - no fallback data
      logE("⚠️ API call failed, returning empty class list - no fallback data");
      return [];
    } on DioException catch (e) {
      logE("DioException in getSchoolClasses: ${e.message}");
      logE(
        "❌ DioException details: ${e.response?.statusCode} - ${e.response?.data}",
      );
      return [];
    } catch (e) {
      logE("Unexpected error in getSchoolClasses: $e");
      return [];
    }
  }

  /// Get all filter options from database in a single API call
  ///
  /// Returns all filter options (teachers, classes, schools, grades) from database
  static Future<Map<String, List<String>>>
      getAllFilterOptionsForAnalytics() async {
    try {
      logI("🚀 Fetching all filter options from database for analytics");

      // Make API call to the new combined filter options endpoint
      final response = await APIService.get(
        path: "/analytics/filter-options",
        forcedBaseUrl: API.baseURl, // Use local backend for analytics
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        logI("✅ Successfully fetched filter options from database");
        logI("📊 Filter options response data: $responseData");

        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];

          // Extract all filter options
          Map<String, List<String>> filterOptions = {};

          // Extract teachers
          final teachers = data['teachers'] as List? ?? [];
          List<String> teacherNames = ['All'];
          for (var teacherItem in teachers) {
            final teacherName = teacherItem['teacher_name'];
            if (teacherName != null && teacherName.toString().isNotEmpty) {
              teacherNames.add(teacherName.toString());
            }
          }
          filterOptions['teachers'] = teacherNames;

          // Extract classes
          final classes = data['classes'] as List? ?? [];
          List<String> classNames = ['All'];
          for (var classItem in classes) {
            final className = classItem['class_name'];
            if (className != null && className.toString().isNotEmpty) {
              classNames.add(className.toString());
            }
          }
          filterOptions['classes'] = classNames;

          // Extract schools
          final schools = data['schools'] as List? ?? [];
          List<String> schoolNames = ['All'];
          for (var schoolItem in schools) {
            final schoolName = schoolItem['school_name'];
            if (schoolName != null && schoolName.toString().isNotEmpty) {
              schoolNames.add(schoolName.toString());
            }
          }
          filterOptions['schools'] = schoolNames;

          // Extract grades
          final grades = data['grades'] as List? ?? [];
          List<String> gradeNames = ['All'];
          for (var gradeItem in grades) {
            final gradeName = gradeItem['grade_name'];
            if (gradeName != null && gradeName.toString().isNotEmpty) {
              gradeNames.add(gradeName.toString());
            }
          }
          filterOptions['grades'] = gradeNames;

          logI("✅ Found filter options:");
          logI("📋 Teachers: ${teacherNames.length - 1} items");
          logI("📋 Classes: ${classNames.length - 1} items");
          logI("📋 Schools: ${schoolNames.length - 1} items");
          logI("📋 Grades: ${gradeNames.length - 1} items");

          return filterOptions;
        } else {
          logE("❌ Invalid response structure for filter options");
          logE("📊 Response data: $responseData");
        }
      } else {
        logE("❌ Filter options API call returned null response");
      }

      // Don't use fallback - return empty lists to force database-only data
      logE("⚠️ API call failed, returning empty lists - no fallback data");
      return {
        'teachers': ['All'],
        'classes': ['All'],
        'schools': ['All'],
        'grades': ['All'],
      };
    } on DioException catch (e) {
      logE("❌ DioException in getAllFilterOptionsForAnalytics: ${e.message}");
      logE(
        "❌ DioException details: ${e.response?.statusCode} - ${e.response?.data}",
      );
      return {
        'teachers': ['All'],
        'classes': ['All'],
        'schools': ['All'],
        'grades': ['All'],
      };
    } catch (e) {
      logE("❌ Unexpected error in getAllFilterOptionsForAnalytics: $e");
      logE("❌ Error type: ${e.runtimeType}");
      return {
        'teachers': ['All'],
        'classes': ['All'],
        'schools': ['All'],
        'grades': ['All'],
      };
    }
  }

  /// Get all classes from database for platform admin analytics (uses individual endpoint)
  ///

  static Future<List<String>> getAllClassesForAnalytics() async {
    try {
      logI("🚀 Fetching all classes from database for analytics");

      // Make API call to the individual classes endpoint
      final response = await APIService.get(
        path: "/analytics/classes",
        forcedBaseUrl: API.baseURl, // Use local backend for analytics
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        logI("✅ Successfully fetched classes from database");

        if (responseData['success'] == true && responseData['data'] != null) {
          final classes = responseData['data']['classes'] as List;

          // Extract class names and add "All" option
          List<String> classNames = ['All'];
          for (var classItem in classes) {
            final className = classItem['class_name'];
            if (className != null && className.toString().isNotEmpty) {
              classNames.add(className.toString());
            }
          }

          logI("✅ Found ${classNames.length - 1} classes from database");
          return classNames;
        }
      }

      // Return empty list if API fails - no fallback data
      logE("⚠️ API call failed, returning empty list - no fallback data");
      return ["All"];
    } on DioException catch (e) {
      logE("❌ DioException in getAllClassesForAnalytics: ${e.message}");
      logE(
        "❌ DioException details: ${e.response?.statusCode} - ${e.response?.data}",
      );
      return ["All"];
    } catch (e) {
      logE("❌ Unexpected error in getAllClassesForAnalytics: $e");
      return ["All"];
    }
  }

  /// Get all teachers from database for platform admin analytics (uses individual endpoint)
  ///

  static Future<List<String>> getAllTeachersForAnalytics() async {
    try {
      logI("🚀 Fetching all teachers from database for analytics");

      // Make API call to the individual teachers endpoint
      final response = await APIService.get(
        path: "/analytics/teachers",
        forcedBaseUrl: API.baseURl, // Use local backend for analytics
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        logI("✅ Successfully fetched teachers from database");

        if (responseData['success'] == true && responseData['data'] != null) {
          final teachers = responseData['data']['teachers'] as List;

          // Extract teacher names and add "All" option
          List<String> teacherNames = ['All'];
          for (var teacherItem in teachers) {
            final teacherName = teacherItem['teacher_name'];
            if (teacherName != null && teacherName.toString().isNotEmpty) {
              teacherNames.add(teacherName.toString());
            }
          }

          logI("✅ Found ${teacherNames.length - 1} teachers from database");
          return teacherNames;
        }
      }

      // Return empty list if API fails - no fallback data
      logE("⚠️ API call failed, returning empty list - no fallback data");
      return ["All"];
    } on DioException catch (e) {
      logE("❌ DioException in getAllTeachersForAnalytics: ${e.message}");
      logE(
        "❌ DioException details: ${e.response?.statusCode} - ${e.response?.data}",
      );
      return ["All"];
    } catch (e) {
      logE("❌ Unexpected error in getAllTeachersForAnalytics: $e");
      return ["All"];
    }
  }

  /// Get all grades from database for platform admin analytics (uses individual endpoint)
  ///
  /// Returns all grades from BINARY_SUCCESS_GRADE_LEVELS table
  static Future<List<String>> getAllGradesForAnalytics() async {
    try {
      logI("🚀 Fetching all grades from database for analytics");

      // Make API call to the individual grades endpoint
      final response = await APIService.get(
        path: "/analytics/grades",
        forcedBaseUrl: API.baseURl, // Use local backend for analytics
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        logI("✅ Successfully fetched grades from database");

        if (responseData['success'] == true && responseData['data'] != null) {
          final grades = responseData['data']['grades'] as List;

          // Extract grade names and add "All" option
          List<String> gradeNames = ['All'];
          for (var gradeItem in grades) {
            final gradeName = gradeItem['grade_name'];
            if (gradeName != null && gradeName.toString().isNotEmpty) {
              gradeNames.add(gradeName.toString());
            }
          }

          logI("✅ Found ${gradeNames.length - 1} grades from database");
          return gradeNames;
        }
      }

      // Return empty list if API fails - no fallback data
      logE("⚠️ API call failed, returning empty list - no fallback data");
      return ["All"];
    } on DioException catch (e) {
      logE("❌ DioException in getAllGradesForAnalytics: ${e.message}");
      logE(
        "❌ DioException details: ${e.response?.statusCode} - ${e.response?.data}",
      );
      return ["All"];
    } catch (e) {
      logE("❌ Unexpected error in getAllGradesForAnalytics: $e");
      return ["All"];
    }
  }

  /// Get all schools from database for platform admin analytics (uses individual endpoint)
  ///
  /// Returns all schools from BINARY_SUCCESS_PLATFORM_INSTITUTES table
  static Future<List<String>> getAllSchoolsForAnalytics() async {
    try {
      logI("🚀 Fetching all schools from database for analytics");

      // Make API call to the individual schools endpoint
      final response = await APIService.get(
        path: "/analytics/schools",
        forcedBaseUrl: API.baseURl, // Use local backend for analytics
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        logI("✅ Successfully fetched schools from database");
        logI("📊 Schools response data: $responseData");

        if (responseData['success'] == true && responseData['data'] != null) {
          final schools = responseData['data']['schools'] as List;
          logI("📋 Schools list: $schools");

          // Extract school names and add "All" option
          List<String> schoolNames = ['All'];
          for (var schoolItem in schools) {
            final schoolName = schoolItem['school_name'];
            if (schoolName != null && schoolName.toString().isNotEmpty) {
              schoolNames.add(schoolName.toString());
            }
          }

          logI("✅ Found ${schoolNames.length - 1} schools from database");
          logI("📋 Final school names: $schoolNames");
          return schoolNames;
        } else {
          logE("❌ Invalid response structure for schools");
          logE("📊 Response data: $responseData");
        }
      } else {
        logE("❌ Schools API call returned null response");
      }

      // Return empty list if API fails - no fallback data
      logE("⚠️ API call failed, returning empty list - no fallback data");
      return ["All"];
    } on DioException catch (e) {
      logE("❌ DioException in getAllSchoolsForAnalytics: ${e.message}");
      logE(
        "❌ DioException details: ${e.response?.statusCode} - ${e.response?.data}",
      );
      return ["All"];
    } catch (e) {
      logE("❌ Unexpected error in getAllSchoolsForAnalytics: $e");
      return ["All"];
    }
  }
}
