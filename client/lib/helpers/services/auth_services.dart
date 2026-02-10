import 'package:binary_success/helpers/constant/app_constant.dart';
import 'package:binary_success/helpers/logger/logger.dart';
import 'package:binary_success/helpers/network/api_service.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:binary_success/helpers/utils/app_snakbar.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static bool isLoggedIn = false;

  static Future<Map<String, String>?> loginUser(
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(Duration(seconds: 1));
    // if (data['email'] != dummyUser.email) {
    //   return {"email": "This email is not registered"};
    // } else if (data['password'] != "1234567") {
    //   return {"password": "Password is incorrect"};
    // }

    isLoggedIn = true;
    await LocalStorage.setLoggedInUser(true);
    return null;
  }

  static Future<void> intitTokeCheck() async {
    if (LocalStorage.getAuthToken()?.isNotEmpty ?? false) {
      bool isTokenExpired = JwtDecoder.isExpired(
        LocalStorage.getAuthToken() ?? "",
      );
      print("Token ${LocalStorage.getAuthToken() ?? ""}");
      print("Refresh Token ${LocalStorage.getRefreshTokenn() ?? ""}");
      print("Is expired: $isTokenExpired");
      DateTime expirationDate = JwtDecoder.getExpirationDate(
        LocalStorage.getAuthToken() ?? "",
      );
      print("Expires at: $expirationDate");
      if (isTokenExpired) {
        // await refreshTokenAPI(
        //     {"refresh_token": LocalStorage.getRefreshTokenn()??});
      }
    }
  }

  static Future<bool> signInAPI(Map<String, dynamic> data) async {
    try {
      final path =
          "${API.admin}/${API.realms}/${API.binarysuccess}/${API.users}";
      print("👤 Creating user at: ${API.baseURl}/$path");
      print("👤 User data: $data");

      final Response<dynamic> response = await APIService.post(
        path: path,
        mapData: data,
      );

      print("👤 Response status: ${response.statusCode}");
      print("👤 Response data: ${response.data}");

      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("❌ DioException in signInAPI:");
      print("   Type: ${e.type}");
      print("   Message: ${e.message}");
      print("   Response: ${e.response?.data}");
      print("   Status Code: ${e.response?.statusCode}");
      print("   Request URL: ${e.requestOptions.uri}");

      final errorMessage = e.response?.data?["errorMessage"] ??
          e.message ??
          "Failed to create user";
      appSnackbar(message: errorMessage);
      return false;
    } catch (e) {
      print("❌ Unknown error in signInAPI: $e");
      return false;
    }
  }

  static Future<bool> refreshTokenAPI(Map<String, dynamic> data) async {
    try {
      final Response<dynamic> response = await APIService.post(
        path: "/users/refresh-token",
        mapData: data,
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      appSnackbar(message: e.response?.data["errorMessage"]);
      return false;
    }
  }

  static Future<bool> signInGoogleAPI(Map<String, dynamic> data) async {
    try {
      final Response<dynamic> response = await APIService.post(
        path: "/users/login",
        mapData: data,
      );

      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      appSnackbar(message: e.response?.data["errorMessage"]);
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getUserSession(
    Map<String, dynamic> data,
  ) async {
    try {
      final Response<dynamic> response = await APIService.postWithoutAth(
        headers: {'Content-Type': 'application/json'},
        path: '/users/login',
        mapData: data,
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      logE(e.message);
      rethrow;
      // appSnackbar(message: e.response?.data["error_description"]);
      return null;
    }
  }

  static Future<void> userSessionLogout(Map<String, dynamic> data) async {
    try {
      final Response<dynamic> response = await APIService.post(
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        path: "/users/logout",
        mapData: data,
      );
      if (response.statusCode == 204) {
        // return response.data;
      }
    } on DioException catch (e) {
      logE(e.message);
      // return null;
    }
  }

  static Future<Map<String, dynamic>?> getAdminToken(
    Map<String, dynamic> data,
  ) async {
    try {
      final path =
          "${API.realms}/${API.binarysuccess}/${API.protocol}/${API.openid}/${API.token}";
      print("🔑 Getting admin token from: ${API.baseURl}/$path");
      print("🔑 Request data: $data");

      final Response<dynamic> response = await APIService.postWithoutAth(
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        path: path,
        mapData: data,
      );

      print("🔑 Response status: ${response.statusCode}");
      print("🔑 Response data: ${response.data}");

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      print("❌ DioException in getAdminToken:");
      print("   Type: ${e.type}");
      print("   Message: ${e.message}");
      print("   Response: ${e.response?.data}");
      print("   Status Code: ${e.response?.statusCode}");
      print("   Request URL: ${e.requestOptions.uri}");
      logE(e.message);
      return null;
    } catch (e) {
      print("❌ Unknown error in getAdminToken: $e");
      return null;
    }
  }

  static Future<dynamic> getUserAPI(String userEmail) async {
    try {
      Response<dynamic> response = await APIService.get(
        params: {"email": userEmail},
        path: "${API.admin}/${API.realms}/${API.binarysuccess}/${API.users}",
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  static Future<bool> updateUserRole(String userID, Object? data) async {
    try {
      final Response<dynamic> response = await APIService.post(
        mapData: data,
        path:
            "${API.admin}/${API.realms}/${API.binarysuccess}/${API.users}/$userID/${API.roleMappings}/${API.clients}/${AppConstant.clientIDs}",
      );
      if (response.statusCode == 204) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      logE(e.message);
      return false;
    }
  }

  static Future<dynamic> getUserRole(String userID) async {
    try {
      final response = await APIService.get(
        path:
            "${API.admin}/${API.realms}/${API.binarysuccess}/${API.users}/$userID/${API.roleMappings}/${API.clients}/${AppConstant.clientIDs}",
      );
      print("Response==${response.data}");
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  static Future<dynamic> submitAffescoAPI(Object? mapData) async {
    try {
      final response = await APIService.post(
        mapData: mapData,
        forcedBaseUrl: API.affrescoSubmitUrl,
        path: "",
      );
      print("Response==${response.data}");
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserRoleDetails(String userID) async {
    try {
      final Response<dynamic> response = await APIService.get(
        path:
            "${API.admin}/${API.realms}/${API.binarysuccess}/${API.users}/$userID/${API.roleMappings}/${API.clients}/69aa196c-c762-43a4-b198-3d73f46e4317",
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getRoleDetails(String roleName) async {
    try {
      final Response<dynamic> response = await APIService.get(
        path:
            "${API.admin}/${API.realms}/${API.binarysuccess}/${API.clients}/69aa196c-c762-43a4-b198-3d73f46e4317/${API.roles}/$roleName",
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      logE(e.message);
      return null;
    }
  }

  static Future<bool> login(String userID, Object? data) async {
    try {
      final Response<dynamic> response = await APIService.post(
        mapData: data,
        path:
            "${API.admin}/${API.realms}/${API.binarysuccess}/${API.users}/$userID/${API.roleMappings}/${API.clients}/${AppConstant.clientIDs}",
      );
      if (response.statusCode == 204) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      logE(e.message);
      return false;
    }
  }
}
