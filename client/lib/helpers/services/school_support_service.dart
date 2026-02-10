import 'dart:io';
import 'dart:convert'; // ✅ for jsonDecode
import 'package:binary_success/helpers/constant/app_constant.dart';
import 'package:dio/dio.dart';
import 'package:binary_success/models/school_support_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:binary_success/helpers/storage/local_storage.dart';

class SchoolSupportService {
  static final Dio _dio = Dio();
  static final String _baseUrl = "${API.baseURl}/crm/tickets";
  static final String baseUrl = API.baseURl;

  //static const String baseUrl1 = "http://localhost:8000";

  static Future<Map<String, dynamic>?> createTicketWithDetails({
    required String ticketType,
    required String subject,
    required String description,
    required String priority,
    String ownerId = "",
    File? file,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final uri = Uri.parse("$baseUrl/crm/tickets/create-with-details");

    final contactId = LocalStorage.getCRMContactId() ?? "";
    final accountId = LocalStorage.getCRMAccountId() ?? "";

    final ticketData = jsonEncode({
      "ticket_type": ticketType,
      "description": description,
      "priority": priority,
      "subject": subject,
      "status": "Open",
      "account_id": accountId,
      "contact_id": contactId,
      "owner_id": ownerId,
    });

    var request = http.MultipartRequest("POST", uri)
      ..fields['ticket_data'] = ticketData;

    if (file != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType('application', 'pdf'),
        ),
      );
    }

    if (fileBytes != null && fileName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
          contentType: MediaType('application', 'octet-stream'),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      debugPrint(
          "❌ Ticket creation failed: ${response.statusCode} ${response.body}");
      return null;
    }
  }

  /// ✅ Fetch ticket details by record ID
  static Future<SupportModel?> getTicketById(String recordId) async {
    try {
      final response = await _dio.get(
        "$_baseUrl/$recordId",
        options: Options(
          headers: {"accept": "application/json"},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data["response"] ?? response.data;
        return SupportModel.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      print("❌ getTicketById Error: ${e.response?.data ?? e.message}");
      return null;
    }
  }

  /// ✅ Fetch tickets (all or paginated)
  static Future<SupportListResponse?> getSupportCases({
    //String accountId = "461326519613026307",
    int? pageNumber, // optional for unlimited
    int? pageSize, // optional for unlimited
    String? status,
  }) async {
    try {
      // ✅ Get accountId dynamically from LocalStorage
      final accountId = LocalStorage.getCRMAccountId() ?? "";
      if (accountId.isEmpty) {
        debugPrint("❌ No accountId found in LocalStorage");
        return null;
      }

      final queryParams = <String, String>{};

      // 🔹 Add pagination params if provided
      if (pageSize != null && pageSize > 0) {
        final offset = ((pageNumber ?? 1) - 1) * pageSize;
        queryParams["limit"] = pageSize.toString();
        queryParams["offset"] = offset.toString();
      }

      // 🔹 Add status if provided
      if (status != null && status.isNotEmpty) {
        queryParams["status"] = status;
      }

      final response = await _dio.get(
        "$baseUrl/crm/accounts/$accountId/records",
        queryParameters: queryParams.isEmpty ? null : queryParams,
        options: Options(headers: {"accept": "application/json"}),
      );

      if (response.statusCode == 200 && response.data != null) {
        return SupportListResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      debugPrint("❌ getSupportCases failed: ${e.response?.data ?? e.message}");
      return null;
    }
  }

  /// Close ticket by ID
  static Future<bool> closeTicket(String ticketId) async {
    final url = "${API.baseURl}/crm/tickets/$ticketId/status?status=Closed";

    try {
      final response = await _dio.post(url,
          options: Options(
            headers: {'accept': 'application/json'},
          ));

      if (response.statusCode == 200) {
        print("✅ Ticket closed successfully");
        return true;
      }
    } catch (e) {
      print("❌ Failed to close ticket: $e");
    }
    return false;
  }

  /// ✅ Reply to a ticket as Support Team
  /// ✅ Reply to a ticket using recordId (not case number)
  static Future<Map<String, dynamic>?> replyToTicket({
    required String caseId, // recordID
    required String message,
  }) async {
    final url = "${API.baseURl}/crm/tickets/reply/support";

    try {
      final response = await Dio().post(
        url,
        queryParameters: {
          "case_id": caseId, // recordID
          "description": message,
        },
        options: Options(
          headers: {
            "accept": "application/json",
            "content-type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data["response"]);
      }
      return null;
    } on DioException catch (e) {
      debugPrint("❌ replyToTicket error: ${e.message}");
      return null;
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

  /// ✅ Fetch ticket history
  static Future<List<SupportHistoryModel>> getTicketHistory(
      String caseId) async {
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
}
