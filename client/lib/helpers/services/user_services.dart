import 'package:vantanceCA/helpers/network/api_service.dart';
import 'package:dio/dio.dart';
import 'package:vantanceCA/models/user_model.dart';
import 'package:vantanceCA/helpers/constant/app_constant.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';

class UserServices {

  static final Dio _dio = Dio();
  static  final String _baseUrl = "${API.apiURL}/admin";

  static Future<String> getUserIdAPI(String keycloakId) async {
    try {
      final response = await APIService.get(
        path: "/db/users/get_user_entity_details/$keycloakId",
      );

      final items = response.data['items'];
      if (items is List && items.isNotEmpty) {
        final userId = items[0]['user_id'];
        return userId is String ? userId : '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  static Future<String> getEntityIdAPI(String keycloakId) async {
    try {
      final response = await APIService.get(
        path: "/db/users/get_user_entity_details/$keycloakId",
      );

      final items = response.data['items'];
      if (items is List && items.isNotEmpty) {
        final entityId = items[0]['role_entity_id'];
        return entityId is String ? entityId : '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  // ✅ Added method to get institute ID
  static Future<String> getInstituteIdAPI(String keycloakId) async {
    try {
      final response = await APIService.get(
        path: "/db/users/get_user_entity_details/$keycloakId",
      );

      final items = response.data['items'];
      if (items is List && items.isNotEmpty) {
        final instituteId = items[0]['institute_id'];
        return instituteId is String ? instituteId : '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }
  //! Added method to get demo school ID
    static Future<String> getDemoSchoolId(String keycloakId) async {
    try {
      final response = await APIService.get(
        path: "/db/users/get_user_entity_details/$keycloakId",
      );

      final items = response.data['items'];
      if (items is List && items.isNotEmpty) {
        final demoSchoolId = items[0]['is_demo_school'];
        return demoSchoolId is String ? demoSchoolId : '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  static Future<String> getDisplayRoleNameAPI(String keycloakId) async {
    try {
      final response = await APIService.get(
        path: "/db/users/get_user_entity_details/$keycloakId",
      );

      final items = response.data['items'];
      if (items is List && items.isNotEmpty) {
        final displayRoleName = items[0]['role_display_name'];
        return displayRoleName is String ? displayRoleName : '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }
  /// Fetch and store CRM contact & account IDs
  static Future<void> fetchAndStoreCrmDetails(String keycloakId, String token) async {
  try {
    final dio = Dio();
    dio.options.headers = {
      "accept": "application/json",
      "authorization": "Bearer $token",
    };

   final response = await dio.get(
  "${API.baseURl}/db/users/get_user_entity_details/$keycloakId",
);


    if (response.statusCode == 200 && response.data["items"] != null) {
      final items = response.data["items"] as List<dynamic>;
      if (items.isNotEmpty) {
        final item = items.first as Map<String, dynamic>;
        final contactId = item["crm_contact_id"]?.toString() ?? "";
        final accountId = item["crm_account_id"]?.toString() ?? "";

        await LocalStorage.setCRMContactId(contactId);
        await LocalStorage.setCRMAccountId(accountId);

        print("✅ CRM IDs saved locally: Contact=$contactId, Account=$accountId");
      } else {
        print("⚠️ No user data found in response");
      }
    } else {
      print("⚠️ Unexpected response fetching CRM details: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Error fetching CRM details: $e");
  }
}

}

// ===================================================================
// Platform Admin User Services
// ===================================================================
class PlatformAdminService {
  static final Dio _dio = Dio();
  static String get _baseUrl => "${API.apiURL}admin/platform_admin";

  /// ✅ Fetch total/active/inactive user counts
  static Future<List<UserCount>> getPlatformUserCounts() async {
    try {
    final url = "$_baseUrl/get_all_platform_users/?page_number=1&page_size=1";

      final response = await _dio.get(url);

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data["user_counts"] != null) {
        return (response.data["user_counts"] as List)
            .map((e) => UserCount.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print("❌ getPlatformUserCounts: ${e.message}");
      return [];
    }
  }

  static Future<ApiResponse?> getPlatformUsers({
  String status = "",
  int pageNumber = 1,
  int pageSize = 10,
  String search = "",
  String sort = "",
}) async {
  try {
 final buffer = StringBuffer("$_baseUrl/get_all_platform_users/?");
buffer.write("page_number=$pageNumber&page_size=$pageSize");
if (status.isNotEmpty) buffer.write("&user_status=$status");
final response = await _dio.get(buffer.toString());


    if (response.statusCode == 200 && response.data != null) {
      return ApiResponse.fromJson(response.data);
    }
    return null;
  } on DioException catch (e) {
    print("❌ getPlatformUsers: ${e.message}");
    return null;
  }
}

}
