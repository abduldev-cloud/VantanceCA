import 'package:vantanceCA/helpers/constant/app_constant.dart';
import 'package:vantanceCA/helpers/network/api_service.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'package:vantanceCA/models/integration_log_model.dart';
import 'package:vantanceCA/models/integration_mode_model.dart';
import 'package:vantanceCA/models/lms_integration_model.dart';
import 'package:vantanceCA/models/middleware_assignment_model.dart';
import 'package:vantanceCA/models/middleware_class_model.dart';
import 'package:vantanceCA/models/middleware_enrollments_model.dart';
import 'package:vantanceCA/models/middleware_grade_model.dart';
import 'package:vantanceCA/models/middleware_student_model.dart';
import 'package:vantanceCA/models/middleware_teacher_model.dart';
import 'package:vantanceCA/models/paginated_data_model.dart';
import 'package:dio/dio.dart';

class IntegrationService {
  static Future<LmsIntegrationData?> connectLms(
      Map<String, dynamic> data) async {
    final Response response = await APIService.postWithoutAth(
      path: "/connect_lms",
      mapData: data,
      forcedBaseUrl: API.integrationBaseURl,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return LmsIntegrationData.fromJson(response.data['data']);
    }
    return null;
  }

  static Future<List<LmsIntegrationData>> getConnections() async {
    final String? adminId = LocalStorage.getDBUserID();
    final Response response = await APIService.get(
      path: "/connections/$adminId",
      forcedBaseUrl: API.integrationBaseURl,
    );

    print("CONNECTIONS RESPONSE = ${response.data}");

    return (response.data as List)
        .map((connection) => LmsIntegrationData.fromJson(connection))
        .toList();
  }

  static Future<dynamic> syncData(String middlewareId) async {
    final Response response = await APIService.post(
      path: "/sync_data/$middlewareId",
      forcedBaseUrl: API.integrationBaseURl,
    );

    return response.data;
  }

  static Future<PaginatedResponse<MiddlewareClass>> getMiddlewareClasses(
      String middlewareId, int page,
      {String query = ""}) async {
    final Response response = await APIService.get(
      path:
          "/get_middleware_classes/$middlewareId?page=$page&page_limit=${AppConstant.defaultPageSize}&query=$query",
      forcedBaseUrl: API.integrationBaseURl,
    );
    return PaginatedResponse.fromJson(
        response.data, (json) => MiddlewareClass.fromJson(json));
  }

  static Future<PaginatedResponse<MiddlewareStudent>> getMiddlewareStudents(
      String middlewareId, int page,
      {String query = ""}) async {
    final Response response = await APIService.get(
      path:
          "/get_middleware_students/$middlewareId?page=$page&page_limit=${AppConstant.defaultPageSize}&query=$query",
      forcedBaseUrl: API.integrationBaseURl,
    );
    return PaginatedResponse.fromJson(
        response.data, (json) => MiddlewareStudent.fromJson(json));
  }

  static Future<PaginatedResponse<MiddlewareTeacher>> getMiddlewareTeachers(
      String middlewareId, int page,
      {String query = ""}) async {
    final Response response = await APIService.get(
      path:
          "/get_middleware_teachers/$middlewareId?page=$page&page_limit=${AppConstant.defaultPageSize}&query=$query",
      forcedBaseUrl: API.integrationBaseURl,
    );
    return PaginatedResponse.fromJson(
      response.data,
      (json) => MiddlewareTeacher.fromJson(json),
    );
  }

  static Future<PaginatedResponse<MiddlewareAssignment>>
      getMiddlewareAssignments(String instituteId, int page,
          {String query = ""}) async {
    final Response response = await APIService.get(
      path:
          "/get_middleware_assignments/$instituteId?page=$page&page_limit=${AppConstant.defaultPageSize}&query=$query",
      forcedBaseUrl: API.integrationBaseURl,
    );
    return PaginatedResponse.fromJson(
      response.data,
      (json) => MiddlewareAssignment.fromJson(json),
    );
  }

  static Future<PaginatedResponse<MiddlewareGrade>> getMiddlewareGrades(
      String instituteId, int page,
      {String query = ""}) async {
    final Response response = await APIService.get(
      path:
          "/get_middleware_grades/$instituteId?page=$page&page_limit=${AppConstant.defaultPageSize}&query=$query",
      forcedBaseUrl: API.integrationBaseURl,
    );
    return PaginatedResponse.fromJson(
      response.data,
      (json) => MiddlewareGrade.fromJson(json),
    );
  }

  static Future<PaginatedResponse<MiddlewareEnrollments>> getTeacherEnrollments(
      String middlewareId, int page,
      {String query = ""}) async {
    final Response response = await APIService.get(
      path:
          "/get_teacher_enrollments/$middlewareId?page=$page&page_limit=${AppConstant.defaultPageSize}&query=$query",
      forcedBaseUrl: API.integrationBaseURl,
    );
    return PaginatedResponse.fromJson(
        response.data, (json) => MiddlewareEnrollments.fromJson(json));
  }

  static Future<PaginatedResponse<MiddlewareEnrollments>> getStudentEnrollments(
      String middlewareId, int page,
      {String query = ""}) async {
    final Response response = await APIService.get(
      path:
          "/get_student_enrollments/$middlewareId?page=$page&page_limit=${AppConstant.defaultPageSize}&query=$query",
      forcedBaseUrl: API.integrationBaseURl,
    );
    return PaginatedResponse.fromJson(
        response.data, (json) => MiddlewareEnrollments.fromJson(json));
  }

  static Future<bool> deleteToken(String middlewareId) async {
    final Response response = await APIService.delete(
      path: "/delete_token/$middlewareId",
      forcedBaseUrl: API.integrationBaseURl,
    );
    return response.statusCode == 200;
  }

  static Future<LmsIntegrationData?> getConnectionStatus({
    required String adminId,
    required String platform,
  }) async {
    final Response response = await APIService.get(
      path: "/connection_status/$adminId?platform=$platform",
      forcedBaseUrl: API.integrationBaseURl,
    );

    if (response.statusCode == 200 && response.data != null) {
      return LmsIntegrationData.fromJson(response.data);
    }
    return null;
  }

  static Future<PaginatedResponse<IntegrationLog>> getLogs(String middlewareId,
      {String source = "middleware",
      required int page,
      String query = "",
      int pageLimit = 10}) async {
    final Response response = await APIService.get(
      path:
          "/get_logs/$middlewareId?source=$source&page=$page&limit=$pageLimit&query=$query",
      forcedBaseUrl: API.integrationBaseURl,
    );

    return PaginatedResponse.fromJson(
        response.data, (json) => IntegrationLog.fromJson(json));
  }

  static Future<bool> toggleIntegrationMode(String instituteId) async {
    final Response? response = await APIService.patch(
      path: "/toggle_integration_mode/$instituteId",
      forcedBaseUrl: API.integrationBaseURl,
    );

    if (response != null && response.statusCode == 200) {
      return true;
    }
    return false;
  }

  static Future<IntegrationMode?> checkIntegrationMode(
      String instituteId) async {
    final Response response = await APIService.get(
      path: "/check_integration_mode/$instituteId",
      forcedBaseUrl: API.integrationBaseURl,
    );

    if (response.statusCode == 200 && response.data != null) {
      return IntegrationMode.fromJson(response.data);
    }
    return null;
  }

  static Future<bool> updatePlatform({
    required String instituteId,
    required String platform,
  }) async {
    try {
      final Response? response = await APIService.patch(
          path: "/update_platform/$instituteId",
          params: {"platform": platform},
          forcedBaseUrl: API.integrationBaseURl);

      if (response != null && response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("Error updating platform: $e");
      return false;
    }
  }

  static Future<bool> updateTokenDetails({
    required String middlewareId,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['middleware_id'] = middlewareId;

      final Response response = await APIService.postWithoutAth(
        path: "/connect_lms",
        mapData: data,
        forcedBaseUrl: API.integrationBaseURl,
      );

      if (response.statusCode == 200) {
        print("Token update response data: ${response.data}");
        return true;
      }
      print(
          "Failed to update token details: ${response.statusCode} ${response.data}");
      return false;
    } catch (e) {
      print("Error updating token details: $e");
      return false;
    }
  }
}
