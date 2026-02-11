import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vantanceCA/controller/my_controller.dart';
import 'package:vantanceCA/helpers/services/auth_services.dart';
import 'package:vantanceCA/helpers/widgets/my_form_validator.dart';
import 'package:vantanceCA/helpers/widgets/my_validators.dart';

class ForgotPassword2Controller extends MyController {
  MyFormValidator basicValidator = MyFormValidator();
  bool showPassword = false, loading = false;

  @override
  void onInit() {
    super.onInit();
    basicValidator.addField(
      'email',
      required: true,
      label: "Email",
      validators: [MyEmailValidator()],
      controller: TextEditingController(),
    );
  }

  Future<void> onLogin() async {
    if (basicValidator.validateForm()) {
      loading = true;
      update();
      var errors = await AuthService.loginUser(basicValidator.getData());
      if (errors != null) {
        basicValidator.validateForm();
        basicValidator.clearErrors();
      }
      Get.toNamed('/auth/reset_password');
      loading = false;
      update();
    }
  }

  void gotoLogIn() {
    Get.toNamed('/auth/login1');
  }
}
