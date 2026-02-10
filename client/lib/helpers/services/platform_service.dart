import 'package:binary_success/helpers/logger/logger.dart';
import 'package:binary_success/helpers/network/api_service.dart';
import 'package:binary_success/models/platform_ticket_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:binary_success/models/platform_admin_school_model.dart';
import 'package:binary_success/models/platform_support_model.dart';
import 'package:binary_success/helpers/constant/app_constant.dart';

class PlatformService {

  static Future<dynamic> getPlatfromSchoolAPI ({
    required int pageNumber,
    required pageSize,
   required String instituteStatus,
  }) async {
    try {
      final response = await APIService.get(
        path: "db/platform_admin/get_all_institute_summary/",
        params: {
          "institute_status": instituteStatus,
          "page_number": pageNumber.toString(),
          "page_size": pageSize.toString(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
  return InstituteListResponse.fromJson(response.data);
} else {
  return null;
}
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }
}

class SupportService {
  static final Dio _dio = Dio();

  //static const String _baseUrl = "http://localhost:8000/crm"; 
 static final String baseUrl = "${API.baseURl}/crm/tickets";

 /// ✅ Fetch all tickets across all accounts (unlimited if no pageSize given)
static Future<SupportListResponse?> getSupportCases({
  int? pageSize, // null means unlimited
  int offset = 0,
  String? status,
}) async {
  try {
    final queryParams = {
      "offset": offset.toString(),
    };

    // Only add limit if user wants pagination
    if (pageSize != null) {
      queryParams["limit"] = pageSize.toString();
    }

    if (status != null && status.isNotEmpty) {
      queryParams["status"] = status;
    }

    final response = await _dio.get(
  "${API.baseURl}/crm/records/all",
  queryParameters: queryParams,
  options: Options(headers: {"accept": "application/json"}),
);


    if (response.statusCode == 200 && response.data != null) {
      return SupportListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    return null;
  } on DioException catch (e) {
    debugPrint("❌ getSupportCases: ${e.response?.data ?? e.message}");
    return null;
  }
}

  static Future<bool> updateTicketPriority({
  required String ticketId,
  required String priority,
}) async {
  try {
    final url = "${API.baseURl}/crm/tickets/$ticketId/priority?priority=$priority";

    final response = await Dio().post(url);

    return response.statusCode == 200;
  } catch (e) {
    debugPrint("❌ Failed to update priority: $e");
    return false;
  }
}


/// ✅ Reply as Customer
  static Future<Map<String, dynamic>?> replyToCustomerTicket({
    required String caseId,
    required String description,
  }) async {
    try {
      final response = await _dio.post(
  "${API.baseURl}/crm/tickets/reply/customer",
  queryParameters: {
    "case_id": caseId,
    "description": description,
  },


        options: Options(headers: {"accept": "application/json"}),
        data: {}, // empty body
      );

      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data["response"]);
      }
      return null;
    } on DioException catch (e) {
      debugPrint("❌ replyToCustomerTicket error: ${e.message}");
      return null;
    }
  }

  /// ✅ Fetch ticket history
  static Future<List<SupportHistoryModel>> getTicketHistory(String caseId) async {
    try {
      final response = await _dio.get(
  "${API.baseURl}/crm/tickets/$caseId/replies",
  options: Options(headers: {"accept": "application/json"}),
);


      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> replies = response.data["replies"] ?? [];
        return replies.map((e) => SupportHistoryModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint("❌ getTicketHistory error: ${e.message}");
      return [];
    }
  }

  /// ✅ Fetch ticket files by record ID + module ID
static Future<List<SupportFile>> getTicketFiles({
  required String recordId,
  required String moduleId,
}) async {
  try {
   final response = await _dio.get(
  "${API.baseURl}/crm/records/$recordId/files",
  queryParameters: {"module_id": moduleId},
  options: Options(headers: {"accept": "application/json"}),
);


    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;

      // Since API returns a bare array
      final list = List<Map<String, dynamic>>.from(data);

      return list.map((json) => SupportFile.fromJson(json)).toList();
    }
    return [];
  } on DioException catch (e) {
    debugPrint("❌ getTicketFiles error: ${e.response?.data ?? e.message}");
    return [];
  }
}

/// ✅ Fetch Platform Admin Tickets -dashboard
static Future<PlatformSupportListResponse?> getPlatformAdminTickets() async {
  try {
   final response = await _dio.get(
  "${API.baseURl}/crm/tickets/platform-admin",
  options: Options(headers: {"accept": "application/json"}),
);

    print('API Response Status: ${response.statusCode}');
    print('API Response Data: ${response.data}');

    if (response.statusCode == 200 && response.data != null) {
      return PlatformSupportListResponse.fromJson(response.data as Map<String, dynamic>);
    }
    return null;
  } on DioException catch (e) {
    print("Error Occurred: ${e.response?.data ?? e.message}");
    return null;
  }
}



}

