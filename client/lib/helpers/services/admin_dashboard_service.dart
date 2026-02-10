import 'package:binary_success/helpers/logger/logger.dart';
import 'package:binary_success/helpers/network/api_service.dart';
import 'package:binary_success/helpers/constant/app_constant.dart';
import 'package:binary_success/models/admin_dashboard_statistics_model.dart';
import 'package:dio/dio.dart';

class AdminDashboardService {
  /// Get platform-wide admin dashboard statistics
  ///
  /// Returns comprehensive statistics including:
  /// - Total Users (with active/inactive breakdown and role distribution)
  /// - Total Students (with active/inactive breakdown and grade distribution)
  /// - Total Schools (with active/inactive breakdown)
  ///
  /// Requires admin authentication (school-admin or product-owner role)
  static Future<AdminDashboardStatisticsModel?> getAdminDashboardStatistics() async {
    try {
      logI("🚀 Fetching admin dashboard statistics from backend");
      logI("🔍 Using base URL: ${API.baseURl}");

      // Make API call to the platform admin user counts endpoint
      final response = await APIService.get(
        path: "/analytics/platform-admin/user-counts",
        withOutAuth: true,
        forcedBaseUrl: API.baseURl, // Ensure we use the local analytics URL
      );

      logI("🔍 API status: ${response.statusCode}");
      logI("🔍 API data: ${response.data}");

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data is Map<String, dynamic> &&
          response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;

        // Transform the response to match the expected AdminDashboardStatisticsModel format
        final transformedData = _transformUserCountsResponse(data);

        if (transformedData != null) {
          final model = AdminDashboardStatisticsModel.fromJson(transformedData);
          logI("📊 Real statistics returned:");
          logI("   👥 Total Users: ${model.totalUsers.total} (Active: ${model.totalUsers.active})");
          logI("   🎓 Total Students: ${model.totalStudents.total} (Active: ${model.totalStudents.active})");
          logI("   🏫 Total Schools: ${model.totalSchools.total} (Active: ${model.totalSchools.active})");
          return model;
        }
      }
      
      logE("❌ Failed to fetch or transform admin dashboard statistics");
      return null;
    } catch (e) {
      logE("❌ Error in getAdminDashboardStatistics: $e");
      logE("❌ Error type: ${e.runtimeType}");
      if (e is DioException) {
        logE("❌ DioException details: ${e.message}");
        logE("❌ DioException response: ${e.response?.data}");
        logE("❌ DioException status: ${e.response?.statusCode}");
      }
      return null;
    }
  }

  /// Transform user counts response to admin dashboard model format
  static Map<String, dynamic>? _transformUserCountsResponse(Map<String, dynamic> data) {
    try {
      final totalSchools = data['total_schools'] ?? 0;
      final totalUsers = data['total_users'] ?? 0;
      final totalStudents = data['total_students'] ?? 0;
      final totalTeachers = data['total_teachers'] ?? 0;
      final userCountsByRole = data['user_counts_by_role'] ?? {};

      // Extract role counts
      final platformAdmins = userCountsByRole['PLATFORM_ADMIN'] ?? 0;
      final instituteAdmins = userCountsByRole['INSTITUTE_ADMIN'] ?? 0;
      final learners = userCountsByRole['LEARNER'] ?? 0;
      final teachers = userCountsByRole['TEACHER'] ?? 0;

      // Calculate active users (assuming all users are active for now)
      final activeUsers = totalUsers;
      final inactiveUsers = 0;

      // Transform to admin dashboard format
      return {
        'totalUsers': {
          'total': totalUsers,
          'active': activeUsers,
          'inactive': inactiveUsers,
          'roleBreakdown': {
            'admins': platformAdmins + instituteAdmins,
            'teachers': teachers,
            'students': learners
          }
        },
        'totalStudents': {
          'total': totalStudents,
          'active': totalStudents, // Assuming all students are active
          'inactive': 0,
          'gradeBreakdown': {
            'grade_9': 0,
            'grade_10': 0,
            'grade_11': 0,
            'grade_12': 0
          }
        },
        'totalSchools': {
          'total': totalSchools,
          'active': totalSchools, // Assuming all schools are active
          'inactive': 0
        }
      };
    } catch (e) {
      logE("❌ Error transforming user counts response: $e");
      return null;
    }
  }

  /// Get platform dashboard statistics using alternative endpoint
  ///
  /// This method uses the /analytics/platform-dashboard endpoint as a fallback
  /// when the main admin dashboard statistics endpoint is not available
  static Future<AdminDashboardStatisticsModel?> getPlatformDashboardStatistics() async {
    try {
      logI("🚀 Fetching platform dashboard statistics (alternative endpoint)");

      // Make API call to the platform dashboard endpoint
      logI("🚀 Making API call to platform dashboard endpoint");
      final response = await APIService.get(
        path: "/analytics/platform-dashboard",
        params: {
          'time_range_days': 30,
        },
        withOutAuth: true,
        forcedBaseUrl: API.baseURl, // Ensure we use the local analytics URL
      );

      logI("🔍 Platform Dashboard API status: ${response.statusCode}");
      logI("🔍 Platform Dashboard API data: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('total_schools') ||
            responseData.containsKey('total_users') ||
            responseData.containsKey('active_students_24hr')) {
          final transformedData = _transformPlatformDashboardResponse(responseData);
          if (transformedData != null) {
            final model = AdminDashboardStatisticsModel.fromJson(transformedData);
            logI("📊 Platform dashboard statistics returned:");
            logI("   👥 Total Users: ${model.totalUsers.total} (Active: ${model.totalUsers.active})");
            logI("   🎓 Total Students: ${model.totalStudents.total} (Active: ${model.totalStudents.active})");
            logI("   🏫 Total Schools: ${model.totalSchools.total} (Active: ${model.totalSchools.active})");
            return model;
          }
        } else {
          logE("❌ Response does not have expected structure: $responseData");
        }
      }
      
      logE("❌ Failed to fetch or transform platform dashboard statistics");
      return null;
    } catch (e) {
      logE("❌ Error in getPlatformDashboardStatistics: $e");
      logE("❌ Error type: ${e.runtimeType}");
      if (e is DioException) {
        logE("❌ DioException details: ${e.message}");
        logE("❌ DioException response: ${e.response?.data}");
        logE("❌ DioException status: ${e.response?.statusCode}");
      }
      return null;
    }
  }

  /// Transform platform dashboard response to admin dashboard model format
  static Map<String, dynamic>? _transformPlatformDashboardResponse(Map<String, dynamic> data) {
    try {
      // Extract data from platform dashboard response
      final totalSchools = Map<String, dynamic>.from(data['total_schools'] ?? {});
      final totalUsers = Map<String, dynamic>.from(data['total_users'] ?? {});
      final activeStudents24hr = data['active_students_24hr'] ?? {};

      // Transform grade breakdown from array format to object format
      Map<String, int> gradeBreakdown = {
        'grade_9': 0,
        'grade_10': 0,
        'grade_11': 0,
        'grade_12': 0,
      };

      // Process grade_wise_breakdown array from platform dashboard
      final gradeWiseBreakdown = activeStudents24hr['grade_wise_breakdown'] as List<dynamic>?;
      if (gradeWiseBreakdown != null) {
        for (final gradeData in gradeWiseBreakdown) {
          if (gradeData is Map<String, dynamic>) {
            final gradeName = gradeData['grade_name'] as String?;
            final studentCount = gradeData['student_count'] as int? ?? 0;

            // Convert grade name to the expected format
            if (gradeName != null) {
              // Handle different grade name formats
              String gradeKey;
              if (gradeName.toLowerCase().contains('grade')) {
                // Extract number from "Grade 9", "Grade 10", etc.
                final gradeNumber = gradeName.replaceAll(RegExp(r'[^0-9]'), '');
                gradeKey = 'grade_$gradeNumber';
              } else {
                // Fallback to original logic
                gradeKey = gradeName.toLowerCase().replaceAll(' ', '_');
              }
              
              logI("🎯 Converting grade '$gradeName' to key '$gradeKey'");
              if (gradeBreakdown.containsKey(gradeKey)) {
                gradeBreakdown[gradeKey] = studentCount;
              } else {
                logW("⚠️ Grade key '$gradeKey' not found in expected breakdown keys: ${gradeBreakdown.keys.toList()}");
              }
            }
          }
        }
      }

      logI("🎯 Transformed grade breakdown: $gradeBreakdown");

      // Fallback logic: if API doesn't provide active/inactive but provides total,
      // mark all as active to ensure the UI shows meaningful numbers like students card.
      int schoolsTotal = (totalSchools['total'] ?? 0) as int;
      int schoolsActive = (totalSchools['active'] ?? 0) as int;
      int schoolsInactive = (totalSchools['inactive'] ?? 0) as int;
      if (schoolsTotal > 0 && schoolsActive == 0 && schoolsInactive == 0) {
        schoolsActive = schoolsTotal;
      }

      int usersTotal = (totalUsers['total'] ?? 0) as int;
      int usersActive = (totalUsers['active'] ?? 0) as int;
      int usersInactive = (totalUsers['inactive'] ?? 0) as int;
      if (usersTotal > 0 && usersActive == 0 && usersInactive == 0) {
        usersActive = usersTotal;
      }

      // Transform to admin dashboard format
      return {
        'totalUsers': {
          'total': usersTotal,
          'active': usersActive,
          'inactive': usersInactive,
          'roleBreakdown': {
            'admins': 0, // Not available in platform dashboard
            'teachers': 0, // Not available in platform dashboard
            'students': activeStudents24hr['total_count'] ?? 0,
          }
        },
        'totalStudents': {
          'total': activeStudents24hr['total_count'] ?? 0,
          'active': activeStudents24hr['total_count'] ?? 0,
          'inactive': 0, // Not available in platform dashboard
          'gradeBreakdown': {
            'grade_9': gradeBreakdown['grade_9'] ?? 0,
            'grade_10': gradeBreakdown['grade_10'] ?? 0,
            'grade_11': gradeBreakdown['grade_11'] ?? 0,
            'grade_12': gradeBreakdown['grade_12'] ?? 0
          },
        },
        'totalSchools': {
          'total': schoolsTotal,
          'active': schoolsActive,
          'inactive': schoolsInactive,
        }
      };
    } catch (e) {
      logE("❌ Error transforming platform dashboard response: $e");
      return null;
    }
  }

  /// Refresh admin dashboard statistics
  ///
  /// This method tries the main endpoint first, then falls back to platform dashboard
  static Future<AdminDashboardStatisticsModel?> refreshAdminDashboardStatistics() async {
    logI("🔄 Refreshing admin dashboard statistics");

    // Try platform dashboard endpoint first (since we know it's working)
    var result = await getPlatformDashboardStatistics();
    
    if (result != null) {
      logI("✅ Platform dashboard endpoint succeeded");
      return result;
    }

    // If platform dashboard fails, try main endpoint
    logI("🔄 Platform dashboard failed, trying main endpoint");
    result = await getAdminDashboardStatistics();

    return result;
  }

  /// Test method to verify API service is working
  static Future<void> testAPIService() async {
    try {
      logI("🧪 Testing API service...");
      
      final response = await APIService.get(
        path: "/analytics/platform-dashboard",
        params: {'time_range_days': 30},
        withOutAuth: true,
        forcedBaseUrl: API.baseURl,
      );
      
      logI("🧪 Test response status: ${response.statusCode}");
      logI("🧪 Test response data: ${response.data}");
      
    } catch (e) {
      logE("🧪 Test failed: $e");
    }
  }
}
