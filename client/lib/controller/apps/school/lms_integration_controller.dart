import 'package:vantanceCA/controller/my_controller.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'package:vantanceCA/helpers/utils/app_snakbar.dart';
import 'package:vantanceCA/models/integration_log_model.dart';
import 'package:vantanceCA/models/integration_mode_model.dart';
import 'package:vantanceCA/models/lms_integration_model.dart';
import 'package:vantanceCA/helpers/services/integration_service.dart';
import 'package:vantanceCA/models/middleware_assignment_model.dart';
import 'package:vantanceCA/models/middleware_class_model.dart';
import 'package:vantanceCA/models/middleware_enrollments_model.dart';
import 'package:vantanceCA/models/middleware_grade_model.dart';
import 'package:vantanceCA/models/middleware_student_model.dart';
import 'package:vantanceCA/models/middleware_teacher_model.dart';
import 'package:vantanceCA/models/paginated_data_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';

class LmsIntegrationController extends MyController {
  RxBool showTokenView = false.obs;
  RxBool showEditView = false.obs;
  Rx<LmsIntegrationData?> integrationData = Rx<LmsIntegrationData?>(null);
  RxList<LmsIntegrationData> connections = <LmsIntegrationData>[].obs;
  RxString platform = "".obs;
  Rx<PaginatedResponse<MiddlewareClass>?> middlewareClasses =
      Rx<PaginatedResponse<MiddlewareClass>?>(null);
  Rx<PaginatedResponse<MiddlewareStudent>?> middlewareStudents =
      Rx<PaginatedResponse<MiddlewareStudent>?>(null);
  Rx<PaginatedResponse<MiddlewareTeacher>?> middlewareTeachers =
      Rx<PaginatedResponse<MiddlewareTeacher>?>(null);
  Rx<PaginatedResponse<MiddlewareAssignment>?> middlewareAssignments =
      Rx<PaginatedResponse<MiddlewareAssignment>?>(null);
  Rx<PaginatedResponse<MiddlewareGrade>?> middlewareGrades =
      Rx<PaginatedResponse<MiddlewareGrade>?>(null);
  Rx<PaginatedResponse<IntegrationLog>?> middlewareLogs =
      Rx<PaginatedResponse<IntegrationLog>?>(null);
  Rx<PaginatedResponse<MiddlewareEnrollments>?> studentEnrollments =
      Rx<PaginatedResponse<MiddlewareEnrollments>?>(null);
  Rx<PaginatedResponse<MiddlewareEnrollments>?> teacherEnrollments =
      Rx<PaginatedResponse<MiddlewareEnrollments>?>(null);
  Rx<IntegrationMode?> integrationMode = Rx<IntegrationMode?>(null);

  // Separate loaders
  RxBool isConnectingLms = false.obs;
  RxBool isFetchingConnections = false.obs;
  RxBool isSyncingData = false.obs;
  RxBool isFetchingClasses = false.obs;
  RxBool isFetchingStudents = false.obs;
  RxBool isFetchingTeachers = false.obs;
  RxBool isFetchingStudentEnrollments = false.obs;
  RxBool isFetchingTeacherEnrollments = false.obs;
  RxBool isFetchingAssignments = false.obs;
  RxBool isFetchingGrades = false.obs;
  RxBool isDeletingToken = false.obs;
  RxBool isFetchingStatus = false.obs;
  RxBool isFetchingLogs = false.obs;
  RxBool isTogglingIntegrationMode = false.obs;
  RxBool isCheckingIntegrationMode = false.obs;
  RxBool isUpdatingTokenDetails = false.obs;

  RxBool isIntegrationModeOn = false.obs;

  //Query observers
  RxString classesQuery = "".obs;
  RxString teachersQuery = "".obs;
  RxString teacherEnrollmentsQuery = "".obs;
  RxString studentsQuery = "".obs;
  RxString studentEnrollmentsQuery = "".obs;
  RxString assignmentsQuery = "".obs;
  RxString gradesQuery = "".obs;
  @override
  void onInit() {
    super.onInit();
    // Load integration data JSON and connected status from local storage
    String? integrationJson = LocalStorage.getIntegrationData();
    bool connected = LocalStorage.getIntegrationConnected();

    if (integrationJson != null && connected) {
      integrationData.value =
          LmsIntegrationData.fromJson(jsonDecode(integrationJson));
      platform.value = integrationData.value?.platform ?? "";
    } else {
      integrationData.value = null;
      platform.value = ""; // user must re-select or connect
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (connections.isEmpty) {
      checkIntegrationMode().then((_) {
        fetchConnectionStatus(platform.value);
      });
    }
  }

  void updatePlatform(String newPlatform) {
    platform.value = newPlatform;
    update();
  }

  void updateTokenView(bool tokenView) {
    showTokenView.value = tokenView;
    update();
  }

  Future<void> connectLms(Map<String, dynamic> data) async {
    try {
      isConnectingLms.value = true;
      update();

      // Log payload before request
      print("Controller.connectLms - sending data: $data");

      final result = await IntegrationService.connectLms(data);

      // Log result after request
      print("Controller.connectLms - received: $result");

      if (result != null) {
        integrationData.value = result;
        showTokenView.value = true;
        await checkIntegrationMode();
        await fetchConnectionStatus(platform.value);
        updateTokenView(true);
        appSnackbar(message: "LMS integration created successfully");
      } else {
        appSnackbar(message: "Failed to connect LMS");
      }
    } on DioException catch (e) {
      String message = "Failed to connect LMS";
      final data = e.response?.data;

      if (data is Map && data['detail'] != null) {
        message = data['detail'].toString();
      }
      print("Controller.connectLms - DioException: $message, details: $data");

      appSnackbar(
        message: message,
        snackbarState: SnackbarState.danger,
      );
      rethrow;
    } catch (e) {
      print("Controller.connectLms - Generic error: $e");
      appSnackbar(message: "Failed to connect LMS");
      rethrow;
    } finally {
      isConnectingLms.value = false;
      update();
    }
  }

  /// Get LMS connections by admin ID
  Future<void> fetchConnections() async {
    try {
      isFetchingConnections.value = true;
      update();

      final result = await IntegrationService.getConnections();
      if (result.isNotEmpty) {
        connections.assignAll(result);
        showTokenView.value = true;
      } else {
        appSnackbar(message: "Failed to load connections");
      }
    } catch (e) {
      appSnackbar(message: "Error loading connections");
    } finally {
      isFetchingConnections.value = false;
      update();
    }
  }

  /// Sync data
  Future<void> syncData(String middlewareId) async {
    try {
      isSyncingData.value = true;
      update();

      final result = await IntegrationService.syncData(middlewareId);
      if (result != null && !(result["error"] != null)) {
        await fetchAllMiddlewareData(middlewareId);
        await fetchMiddlewareLogs(middlewareId, 1);
        checkIntegrationMode();
        appSnackbar(message: "Data sync successful");
      } else {
        appSnackbar(message: result["error"] ?? "Data sync failed");
      }
    } on DioException catch (e) {
      appSnackbar(
          message: e.response?.data is Map<String, dynamic>
              ? (e.response?.data['detail'] ?? "Data sync failed")
              : "Data sync failed",
          snackbarState: SnackbarState.danger);
    } finally {
      isSyncingData.value = false;
      update();
    }
  }

  /// Fetch middleware classes
  Future<void> fetchMiddlewareClasses(String middlewareId, int page,
      {String query = "", bool isPageChange = false}) async {
    try {
      if (!isPageChange) {
        isFetchingClasses.value = true;
        update();
      }

      final result = await IntegrationService.getMiddlewareClasses(
          middlewareId, page,
          query: query);
      middlewareClasses.value = result;
      if (result.data.isNotEmpty) {
      } else {
        // appSnackbar(message: "Failed to load classes");
      }
    } catch (e) {
      appSnackbar(message: "Error loading classes");
    } finally {
      if (!isPageChange) {
        isFetchingClasses.value = false;
      }
      update();
    }
  }

  /// Fetch middleware students
  Future<void> fetchMiddlewareStudents(String middlewareId, int page,
      {String query = "", bool isPageChange = false}) async {
    try {
      if (!isPageChange) {
        isFetchingStudents.value = true;
        update();
      }

      final result = await IntegrationService.getMiddlewareStudents(
          middlewareId, page,
          query: query);
      middlewareStudents.value = result;
      if (result.data.isNotEmpty) {}
    } catch (e) {
      appSnackbar(message: "Error loading students");
    } finally {
      if (!isPageChange) {
        isFetchingStudents.value = false;
      }
      update();
    }
  }

  /// Fetch middleware teachers
  Future<void> fetchMiddlewareTeachers(String middlewareId, int page,
      {String query = "", bool isPageChange = false}) async {
    try {
      if (!isPageChange) {
        isFetchingTeachers.value = true;
        update();
      }

      final result = await IntegrationService.getMiddlewareTeachers(
          middlewareId, page,
          query: query);

      // Always update middlewareTeachers with the result
      middlewareTeachers.value = result;

      if (result.data.isEmpty) {
        // optional: appSnackbar(message: "No teachers found");
      }
    } catch (e, stacktrace) {
      print("ERROR IS $e $stacktrace");
      appSnackbar(message: "Error loading teachers");
    } finally {
      if (!isPageChange) {
        isFetchingTeachers.value = false;
      }
      update();
    }
  }

  Future<void> fetchStudentEnrollments(String middlewareId, int page,
      {String query = "", bool isPageChange = false}) async {
    try {
      if (!isPageChange) {
        isFetchingStudentEnrollments.value = true;
        update();
      }

      final result = await IntegrationService.getStudentEnrollments(
          middlewareId, page,
          query: query);
      studentEnrollments.value = result;
      if (result.data.isNotEmpty) {}
    } catch (e) {
      appSnackbar(message: "Error loading student enrollments");
    } finally {
      if (!isPageChange) {
        isFetchingStudentEnrollments.value = false;
      }
      update();
    }
  }

  Future<void> fetchTeacherEnrollments(String middlewareId, int page,
      {String query = "", bool isPageChange = false}) async {
    try {
      if (!isPageChange) {
        isFetchingTeacherEnrollments.value = true;
        update();
      }

      final result = await IntegrationService.getTeacherEnrollments(
          middlewareId, page,
          query: query);
      teacherEnrollments.value = result;
      if (result.data.isNotEmpty) {
      } else {
        // You can log or show a snackbar if needed
        // appSnackbar(message: "No teacher enrollments found");
      }
    } catch (e) {
      appSnackbar(message: "Error loading teacher enrollments");
    } finally {
      if (!isPageChange) {
        isFetchingTeacherEnrollments.value = false;
      }
      update();
    }
  }

  /// Delete LMS token
  Future<void> deleteToken(String middlewareId) async {
    try {
      isDeletingToken.value = true;
      integrationData.value = null;
      update();

      final success = await IntegrationService.deleteToken(middlewareId);
      if (success) {
        if (connections.isEmpty) {
          updateTokenView(false);
        }
        integrationData.value = null;
        middlewareClasses.value = null;
        middlewareStudents.value = null;
        middlewareTeachers.value = null;
        teacherEnrollments.value = null;
        studentEnrollments.value = null;
        middlewareAssignments.value = null;
        middlewareGrades.value = null;
        middlewareLogs.value = null;
        await checkIntegrationMode();
        appSnackbar(message: "Token deleted successfully");
      } else {
        appSnackbar(message: "Failed to delete token");
      }
    } catch (e) {
      appSnackbar(message: "Error deleting token");
    } finally {
      isDeletingToken.value = false;
      update();
    }
  }

  Future<void> fetchAllMiddlewareData(String middlewareId) async {
    try {
      await fetchMiddlewareTeachers(middlewareId, 1);
      await fetchMiddlewareStudents(middlewareId, 1);
      await fetchMiddlewareClasses(middlewareId, 1);
      await fetchMiddlewareAssignments(1);
      await fetchMiddlewareGrades(1);
      await fetchStudentEnrollments(middlewareId, 1);
      await fetchTeacherEnrollments(middlewareId, 1);
    } on DioException {
      appSnackbar(message: "Could not fetch middleware data");
    }
  }

  Future<void> fetchConnectionStatus(String platform) async {
    try {
      isFetchingStatus.value = true;
      update();

      final String? adminId = LocalStorage.getDBUserID();
      if (adminId == null) {
        appSnackbar(message: "Admin ID not found");
        return;
      }

      final result = await IntegrationService.getConnectionStatus(
        adminId: adminId,
        platform: platform,
      );

      if (result != null) {
        integrationData.value = result;
        await fetchAllMiddlewareData(integrationData.value!.id);
        fetchMiddlewareLogs(integrationData.value!.id, 1);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching connection status $e");
      }
    } finally {
      isFetchingStatus.value = false;
      update();
    }
  }

  Future<void> fetchMiddlewareLogs(String middlewareId, int page,
      {String query = "", bool isPageChange = false}) async {
    try {
      if (!isPageChange) {
        isFetchingLogs.value = true;
        update();
      }

      final result = await IntegrationService.getLogs(middlewareId,
          page: page, query: query);
      if (result.data.isNotEmpty) {
        middlewareLogs.value = result;
      } else {
        print("No logs found");
      }
    } catch (e) {
      print("Error fetching logs $e");
    } finally {
      if (!isPageChange) {
        isFetchingLogs.value = false;
      }
      update();
    }
  }

  Future<void> toggleIntegrationMode() async {
    try {
      isTogglingIntegrationMode.value = true;
      isIntegrationModeOn.value = !isIntegrationModeOn.value;
      update();

      final String instituteId = LocalStorage.getDBInstituteID() ?? "";

      final success =
          await IntegrationService.toggleIntegrationMode(instituteId);
      if (success) {
        await checkIntegrationMode();
      } else {
        appSnackbar(message: "Failed to toggle integration mode");
      }
    } catch (e) {
      appSnackbar(message: "Error toggling integration mode");
    } finally {
      isTogglingIntegrationMode.value = false;
      update();
    }
  }

  Future<void> checkIntegrationMode() async {
    try {
      isCheckingIntegrationMode.value = true;
      update();

      final String instituteId = LocalStorage.getDBInstituteID() ?? "";

      final result = await IntegrationService.checkIntegrationMode(instituteId);
      if (result != null) {
        integrationMode.value = result;
        updatePlatform(result.integrationType.toString());
        isIntegrationModeOn.value =
            integrationMode.value!.integrationMode == "ON";
        String? alfrescoSiteId = LocalStorage.getAlfrescoSiteID();

        final newBulkUploadId = result.bulkUploadId;
        if (newBulkUploadId != null) {
          LocalStorage.setBulkUploadID(newBulkUploadId);
        }

        final newAlfrescoSiteId = result.alfrescoSiteId;
        if ((alfrescoSiteId == null || alfrescoSiteId.isEmpty) &&
            newAlfrescoSiteId != null) {
          LocalStorage.setAlfrescoSiteID(newAlfrescoSiteId);
        }
      } else {
        appSnackbar(message: "No integration mode found");
      }
    } catch (e) {
      appSnackbar(message: "Error checking integration mode");
    } finally {
      isCheckingIntegrationMode.value = false;
      update();
    }
  }

  /// Update integration platform
  Future<void> updateIntegrationPlatform(String newPlatform) async {
    try {
      platform.value = newPlatform;
      update();

      final String instituteId = LocalStorage.getDBInstituteID() ?? "";
      if (instituteId.isEmpty) {
        appSnackbar(message: "Institute ID not found");
        return;
      }

      final success = await IntegrationService.updatePlatform(
        instituteId: instituteId,
        platform: newPlatform,
      );

      if (success) {
        await checkIntegrationMode();
        await fetchConnectionStatus(newPlatform);
      } else {
        appSnackbar(message: "Failed to update platform");
      }
    } catch (e) {
      appSnackbar(message: "Error updating platform: $e");
    }
  }

  Future<void> updateTokenDetails({
    required String middlewareId,
    required Map<String, dynamic> data,
  }) async {
    // Remove null or empty string entries from data map
    data.removeWhere(
        (key, value) => value == null || (value is String && value.isEmpty));

    // Add or override required keys for API validation
    data['middleware_id'] = middlewareId;
    data['school_admin_id'] = LocalStorage.getDBUserID();
    data['platform'] =
        platform.value.isNotEmpty ? platform.value : LocalStorage.getPlatform();

    try {
      isUpdatingTokenDetails.value = true;
      update();

      print("Updating token details, middlewareId: $middlewareId, data: $data");

      final success = await IntegrationService.updateTokenDetails(
        middlewareId: middlewareId,
        data: data,
      );

      if (success) {
        final String? platformValue = platform.value.isNotEmpty
            ? platform.value
            : LocalStorage.getPlatform();
        if (platformValue == null || platformValue.isEmpty) {
          appSnackbar(message: "Platform is not set!");
        } else {
          await fetchConnectionStatus(platformValue);
        }

        updateTokenView(true);
        appSnackbar(message: "Token details updated successfully");
      } else {
        appSnackbar(message: "Failed to update token details");
      }
    } catch (e) {
      appSnackbar(message: "Error updating token details: $e");
    } finally {
      isUpdatingTokenDetails.value = false;
      update();
    }
  }

  Future<void> fetchMiddlewareAssignments(int page,
      {String query = "", bool isPageChange = false}) async {
    try {
      if (!isPageChange) {
        isFetchingAssignments.value = true;
        update();
      }

      final String instituteId = LocalStorage.getDBInstituteID() ?? "";

      final result = await IntegrationService.getMiddlewareAssignments(
        instituteId,
        page,
        query: query,
      );

      // Always update middlewareAssignments with the result to reflect current data,
      // whether data is empty or not.
      middlewareAssignments.value = result;

      if (result.data.isEmpty) {
        // Optional: show snackbar or log for no data found
        // appSnackbar(message: "No assignments found");
      }
    } catch (e) {
      appSnackbar(message: "Error loading assignments");
    } finally {
      if (!isPageChange) {
        isFetchingAssignments.value = false;
      }
      update();
    }
  }

  Future<void> fetchMiddlewareGrades(int page,
      {String query = "", bool isPageChange = false}) async {
    try {
      if (!isPageChange) {
        isFetchingGrades.value = true;
        update();
      }

      final String instituteId = LocalStorage.getDBInstituteID() ?? "";

      if (instituteId.isEmpty) {
        appSnackbar(message: "Institute ID not found");
        return;
      }

      final result = await IntegrationService.getMiddlewareGrades(
          instituteId, page,
          query: query);

      // Only changed here: always update even if empty
      middlewareGrades.value = result;

      if (result.data.isEmpty) {
        if (page == 1 && query.isEmpty) {
          debugPrint("No grades available");
        }
        debugPrint("No grades found for page $page");
      } else {
        debugPrint("Grades fetched: ${result.data.length} items on page $page");
      }
    } catch (e) {
      debugPrint("Error loading grades: $e");
      appSnackbar(message: "Error loading grades: ${e.toString()}");
    } finally {
      if (!isPageChange) {
        isFetchingGrades.value = false;
      }
      update();
    }
  }
}
