import 'dart:async';

import 'package:vantanceCA/controller/my_controller.dart';
import 'package:vantanceCA/helpers/constant/app_constant.dart';
import 'package:vantanceCA/helpers/logger/logger.dart';
import 'package:vantanceCA/helpers/services/auth_services.dart';
import 'package:vantanceCA/helpers/services/user_services.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'package:vantanceCA/helpers/utils/utils.dart';
import 'package:vantanceCA/helpers/widgets/my_form_validator.dart';
import 'package:vantanceCA/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

class LoginController extends MyController {
  MyFormValidator basicValidator = MyFormValidator();

  bool showPassword = false, loading = false, isChecked = false;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();
  RxBool isLoginLoading = false.obs;

  Future<void> getInit() async {
    platform.authenticationEvents?.listen(
      (AuthenticationEvent authEvent) async {
        if (authEvent is AuthenticationEventSignIn) {
          Map<String, dynamic>? response = await AuthService.getAdminToken({
            'grant_type': 'client_credentials',
            'client_id': AppConstant.clientID,
            'client_secret': AppConstant.clientSecret
          });
          LocalStorage.setAuthToken(response?["access_token"]);
          await AuthService.signInGoogleAPI({
            "grant_type": "urn:ietf:params:oauth:grant-type:token-exchange",
            "subject_token_type":
                "urn:ietf:params:oauth:token-type:access_token",
            "client_id": AppConstant.clientID,
            "subject_issuer": "google",
            "subject_token": authEvent.authenticationTokens.idToken,
            "scope": "openid profile email",
            "client_secret": AppConstant.clientSecret
          });
        }
      },
    );
  }

  Future<void> login(String email, String password) async {
    Map<String, dynamic>? response = await AuthService.getUserSession({
      "username": email,
      "password": password,
    });

    if (response != null) {
      final accessToken = response["access_token"];
      final refreshToken = response["refresh_token"];
      LocalStorage.setAuthToken(accessToken);
      LocalStorage.setRefreshToken(refreshToken);

      final userData = parseAccessToken(accessToken);
      if (userData.isEmpty) return;

      final userId = userData["sub"];
      final email = userData["email"];
      final displayName = getDisplayName(userData);
      final displayRoleName = await UserServices.getDisplayRoleNameAPI(userId);
      LocalStorage.setDBDisplayRoleName(displayRoleName);
      LocalStorage.setUserName(displayName);
      LocalStorage.setUserID(userId);
      LocalStorage.setUserEmail(email);
      final res = await UserServices.getUserIdAPI(userId);
      if (res.isNotEmpty) {
        LocalStorage.setDBUserID(res);
      } else {
        logE("User ID not found in the database.");
        LocalStorage.erase();
        throw Exception("User ID not found in the database.");
      }

      final entity = await UserServices.getEntityIdAPI(userId);
      if (entity.isNotEmpty) {
        LocalStorage.setDBEntityID(entity);
      } /*else {
        logE("User ID not found in the database.");
        LocalStorage.erase();
        throw Exception("User ID not found in the database.");
      }*/

      // *** Added institute ID fetching and storing ***
      final instituteId = await UserServices.getInstituteIdAPI(userId);
      if (instituteId.isNotEmpty) {
        await LocalStorage.setDBInstituteID(instituteId);
      } else {
        logE("Institute ID not found in the database.");
        // Optionally handle error or clear storage here
      }
      // *** End addition ***

      // ! demo school id fetch and store
      final demoSchoolId = await UserServices.getDemoSchoolId(userId);
      if (demoSchoolId.isNotEmpty) {
        await LocalStorage.setIsDemoSchool(demoSchoolId);
      } else {
        logE("Demo School ID not found in the database.");
        // Optionally handle error or clear storage here
      }

      await UserServices.fetchAndStoreCrmDetails(userId, accessToken);

      final role = RoleUtils.getHighestPriorityRole(userData);
      if (role != null) {
        LocalStorage.setUserRole(role.toUpperCase());

        switch (role) {
          case "teacher":
            Get.offNamed("/teacher/dashboard");
            break;
          case "institute_admin":
            Get.offNamed("/school/dashboard");
            break;
          case "learner":
            Get.offNamed("/student/class");
            break;
          default:
            Get.offNamed("/admin/dashboard");
        }
      } else {
        logE("No valid role found in token.");
      }
    } else {
      throw "";
    }
  }

  void onChangeShowPassword() {
    showPassword = !showPassword;
    update();
  }

  void onChangeCheckBox(bool? value) {
    isChecked = value ?? isChecked;
    update();
  }

  Future<void> onLogin() async {
    if (basicValidator.validateForm()) {
      loading = true;
      update();
      var errors = await AuthService.loginUser(basicValidator.getData());
      if (errors != null) {
        basicValidator.addErrors(errors);
        basicValidator.validateForm();
        basicValidator.clearErrors();
      } else {
        String nextUrl =
            Uri.parse(ModalRoute.of(Get.context!)?.settings.name ?? "")
                    .queryParameters['next'] ??
                "/dashboard";
        Get.toNamed(
          nextUrl,
        );
      }
      loading = false;
      update();
    }
  }

  void goToForgotPassword() {
    Get.toNamed('/auth/forgot_password');
  }

  void gotoRegister() {
    Get.offAndToNamed('/auth/register');
  }

  @override
  void onInit() {
    getInit();
    super.onInit();
  }
}
