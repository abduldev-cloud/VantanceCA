import 'package:binary_success/helpers/constant/app_constant.dart';
import 'package:binary_success/helpers/validators/basic_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

class CreateNewPasswordController extends GetxController {
  final BasicValidator basicValidator = BasicValidator(fields: ['newPassword', 'confirmPassword']);
  final RxBool isLoading = false.obs;

  TextEditingController get newPasswordCtrl => basicValidator.getController('newPassword');
  TextEditingController get confirmPasswordCtrl => basicValidator.getController('confirmPassword');

  String get newPassword => newPasswordCtrl.text.trim();
  String get confirmPassword => confirmPasswordCtrl.text.trim();

  /// Call this on submit, passing the token received via email/link
  Future<void> onCreateNewPassword({required String resetToken}) async {
    if (!basicValidator.formKey.currentState!.validate()) return;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await Dio().post(
  "${API.baseURl}/users/reset-password",
  data: {
    'token': resetToken,
    'new_password': newPassword,
  },


        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      // Success: statusCode 200, use the message from API
      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          response.data['message'] ?? 'Password updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100
        );
        Get.offAllNamed('/auth/login');
      } else {
        final errorMsg = response.data['message'] ?? response.data['detail'] ?? 'Failed to reset password';
        Get.snackbar(
          'Error',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100
        );
      }

    } on DioException catch (e) {
      String message = "Server error occurred.";
      if (e.response != null && e.response?.data != null) {
        if (e.response?.data is Map && e.response?.data['detail'] != null) {
          message = e.response?.data['detail'];
        } else if (e.response?.data is Map && e.response?.data['message'] != null) {
          message = e.response?.data['message'];
        } else if (e.response?.data is String) {
          message = e.response?.data;
        }
      } else if (e.message != null) {
        message = "Something went wrong: ${e.message}";
      }
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        "Something went wrong: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    try {
      newPasswordCtrl.dispose();
      confirmPasswordCtrl.dispose();
    } catch (_) {}
    super.onClose();
  }
}
