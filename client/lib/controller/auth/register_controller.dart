import 'package:vantanceCA/controller/my_controller.dart';
import 'package:vantanceCA/helpers/constant/app_constant.dart';
import 'package:vantanceCA/helpers/services/auth_services.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'package:vantanceCA/helpers/widgets/my_form_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum RegisterRole { student, teacher }

class RegisterController extends MyController {
  MyFormValidator basicValidator = MyFormValidator();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController schoolEmail = TextEditingController();
  TextEditingController schoolMobileNo = TextEditingController();
  TextEditingController schoolName = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPasswords = TextEditingController();

  bool showPassword = true, confirmPassword = true, loading = false;
  RxBool isCheck = false.obs;
  RxBool isLoginLoading = false.obs;
  GlobalKey<FormState> formKey = GlobalKey();
  GlobalKey<FormState> formKeyTwo = GlobalKey();
  PageController pageController = PageController();
  RxInt selectedIndex = 0.obs;
  Rx<RegisterRole> selectedRole = RegisterRole.student.obs;

  Future<void> onSignUp(
      {required String email,
      required String fName,
      required String lastName,
      required String phoneNo,
      required String passwrod}) async {
    Map<String, dynamic>? response = await AuthService.getAdminToken({
      'grant_type': 'client_credentials',
      'client_id': AppConstant.clientID,
      'client_secret': AppConstant.clientSecret
    });
    if (response != null) {
      print("Response===${response["access_token"]}");
      LocalStorage.setAuthToken(response["access_token"]);

      // LocalStorage.setRefreshToken(response["refresh_token"]);
      bool isUserCreated = await AuthService.signInAPI({
        "username": email,
        "email": email,
        "enabled": true,
        "firstName": fName,
        "lastName": lastName,
        "attributes": {
          "phone_number": ["+1$phoneNo"],
        },
        "credentials": [
          {"type": "password", "value": passwrod, "temporary": false}
        ]
      });

      if (isUserCreated) {
        final getUserData = await AuthService.getUserAPI(email);

        if (getUserData != null) {
          LocalStorage.setUserName(
              "${getUserData[0]["firstName"]} ${getUserData[0]["lastName"]}");
          LocalStorage.setUserID(getUserData[0]["id"].toString());
          selectedIndex.value++;
          pageController.nextPage(
              duration: Duration(microseconds: 500), curve: Curves.easeIn);
        }
      }
    }
  }

  Future<void> userRoleUpdate({
    required String userID,
    required String role,
  }) async {
    Map<String, dynamic>? getUserRoleDetails =
        await AuthService.getRoleDetails(role);
    if (getUserRoleDetails != null) {
      bool updateUserRole = await AuthService.updateUserRole(userID, [
        {"id": "${getUserRoleDetails["id"]}", "name": role}
      ]);
      if (updateUserRole) {
        LocalStorage.setUserRole(role);
        Get.offAllNamed("/auth/login");
      }
    }
  }

  void onChangeShowPassword() {
    showPassword = !showPassword;
    update();
  }

  void onConfirmChangeShowPassword() {
    confirmPassword = !confirmPassword;
    update();
  }

  void gotoLogin() {
    Get.toNamed('/auth/login');
  }
}
