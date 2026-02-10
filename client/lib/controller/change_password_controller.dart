import 'dart:convert';

import 'package:binary_success/helpers/constant/app_constant.dart';
import 'package:http/http.dart' as http;

import 'package:binary_success/models/change_password_model.dart';

class PasswordChangeController {
  static  String baseUrl = API.baseURl;

 
  static String? validatePasswords(String newPassword, String confirmPassword) {
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      return 'Please fill in all fields';
    }
    
    if (newPassword != confirmPassword) {
      return 'Passwords do not match';
    }
    
    if (newPassword.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    return null; 
  }


  static Future<PasswordChangeResponse> changePassword(PasswordChangeRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/change-password'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: request.toMap(),
      );

      if (response.statusCode == 200) {
        return PasswordChangeResponse.success(
          'Password changed successfully',
          data: json.decode(response.body),
        );
      } else {
        return PasswordChangeResponse.error(
          'Failed to change password. Status: ${response.statusCode}',
          error: response.body,
        );
      }
    } catch (e) {
      return PasswordChangeResponse.error(
        'Network error occurred',
        error: e.toString(),
      );
    }
  }
}