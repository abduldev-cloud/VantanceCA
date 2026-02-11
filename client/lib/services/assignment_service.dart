import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/assignment_request.dart';
import 'package:vantanceCA/helpers/network/api_service.dart';
import 'package:vantanceCA/helpers/constant/app_constant.dart';
import 'package:vantanceCA/models/submit_draft_model.dart';

class AssignmentService {
  static final String baseUrl = "${API.apiURL}/teacher";

  late Dio _dio;

  AssignmentService() {
    _dio = Dio();

    // Add logging interceptor
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: false,
      requestBody: false,
      responseBody: false,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));

    // Set default headers
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<Map<String, dynamic>> createAssignment(
      AssignmentRequest request) async {
    try {
      final response = await APIService.post(
        mapData: request.toJson(),
        forcedBaseUrl: API.apiURL,
        path: "admin/teacher/create_task/",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Assignment created successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create assignment: ${response.statusCode}',
          'data': null,
        };
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to create assignment';

      if (e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server timeout. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage =
            'Connection error. Please check your internet connection.';
      }

      return {
        'success': false,
        'message': errorMessage,
        'data': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
        'data': null,
      };
    }
  }

  static Future<CreateAssignmentAlfrescoResponse?> createAssignmentAlfrescoAPI(
      CreateAssignmentAlfrescoRequest request) async {
    try {
      final response = await APIService.post(
        mapData: request.toJson(),
        forcedBaseUrl: API.alfrescoBaseURL,
        path: "assign-workflow/by-teacher",
      );

      print("Create Alfresco Task Response==$response");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CreateAssignmentAlfrescoResponse.fromJson(response.data);
      }
      return null;
    } on DioException {
      //logE("Error in creating alfresco task: ${e.message}");
      return null;
    }
  }

  Future<Map<String, dynamic>> LMSPushAssignment(
      AssignmentLMSRequests request) async {
    try {
      final response = await APIService.post(
        mapData: request.toJson(),
        forcedBaseUrl: API.integrationBaseURl,
        path: "/push_assignment",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Assignment created successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create assignment: ${response.statusCode}',
          'data': null,
        };
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to create assignment';

      if (e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server timeout. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage =
            'Connection error. Please check your internet connection.';
      }

      return {
        'success': false,
        'message': errorMessage,
        'data': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>> AssignmentNotification(
      AssignmentNotificationRequests request) async {
    try {
      final response = await APIService.post(
        mapData: request.toJson(),
        forcedBaseUrl: API.baseURl, // base URL from .env
        path: "/notification/notify_all_learners_in_class", // endpoint
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Assignment notification sent successfully',
        };
      } else {
        return {
          'success': false,
          'message':
              'Failed to sent assignment notification: ${response.statusCode}',
          'data': null,
        };
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to sent assignment notification';

      if (e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server timeout. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage =
            'Connection error. Please check your internet connection.';
      }

      return {
        'success': false,
        'message': errorMessage,
        'data': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
        'data': null,
      };
    }
  }

  static Future<Map<String, dynamic>?> checkIntegrationModeAPI(
      {required String instituteId}) async {
    try {
      final response = await APIService.get(
        forcedBaseUrl: API.integrationBaseURl,
        path: "/check_integration_mode/$instituteId",
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException {
      return null;
    }
  }
}
