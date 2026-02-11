import 'package:vantanceCA/helpers/validators/basic_validator.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  var isLoading = false.obs;
  var isSuccess = false.obs; // RxBool for UI
  String sentEmail = ''; // Stores last email sent

  final basicValidator = BasicValidator(fields: ['email']);

  String get email => basicValidator.getController("email").text;

  Future<void> onForgotPassword() async {
    if (!basicValidator.formKey.currentState!.validate()) return;

    isLoading.value = true;

    // MOCKING SUCCESS as requested
    await Future.delayed(const Duration(seconds: 5));
    sentEmail = email;
    isSuccess.value = true;
    isLoading.value = false;

    /* RE-ENABLE THIS FOR REAL API CALL
    try {
      final response = await Dio().post(
  "${API.baseURl}/users/forgot-password",
  data: {'email': email},
  options: Options(
    headers: {
      'accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    contentType: Headers.formUrlEncodedContentType,
  ),
);


      final message = response.data['message'] ?? response.data['detail'] ?? '';
      
      if (response.statusCode == 200) {
        sentEmail = email;
        isSuccess.value = true;
        Get.snackbar(
          "Success",
          message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
        );
        // Optionally trigger confirmation page/UI here
      } else {
        isSuccess.value = false;
        Get.snackbar(
          "Error",
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
        );
      }
    } on DioException catch (e) {
      isSuccess.value = false;
      String message = '';
      if (e.response != null && e.response?.data != null) {
        if (e.response?.data is Map && e.response?.data['detail'] != null) {
          message = e.response?.data['detail'];
        } else if (e.response?.data is Map && e.response?.data['message'] != null) {
          message = e.response?.data['message'];
        } else if (e.response?.data is String) {
          message = e.response?.data;
        }
      } else if (e.message != null) {
        message = e.message ?? '';
      }
      Get.snackbar(
        "Error",
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } catch (e) {
      isSuccess.value = false;
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isLoading.value = false;
    }
    */
  }

  void gotoLogIn() {
    Get.toNamed("/auth/login");
  }
}
