import 'dart:developer';

import 'package:vantanceCA/controller/my_controller.dart';
import 'package:vantanceCA/helpers/services/onboarding_services.dart';
import 'package:vantanceCA/helpers/widgets/my_form_validator.dart';
import 'package:vantanceCA/models/add_school_model.dart';
import 'package:flutter/widgets.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'package:get/get.dart';

const personaMap = {
  "institute_admin": "school",
  "teacher": "teacher",
  "learner": "student",
};

class OnboardingController extends MyController {
  final String persona;

  OnboardingController({required this.persona});
  MyFormValidator basicValidator = MyFormValidator();

  bool showPassword = false, loading = false, isChecked = false;
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController password = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();
  RxBool isLoading = false.obs;
  RxBool isAcceptLoading = false.obs;
  Rx<InviteSchoolModel?> partialSchoolModel = Rx<InviteSchoolModel?>(null);
  final OnboardingServices _service = OnboardingServices();
  RxBool isReadOnly = false.obs;
  String invitePersona = '';
  var isBasicPlanSelected = false.obs;
  @override
  void onInit() {
    super.onInit();
    final inviteCode = Get.parameters['invite_code'];
    if (inviteCode != null) {
      getSchoolDetails(inviteCode);
    }
  }

  void onChangeShowPassword() {
    showPassword = !showPassword;
    update();
  }

  Future<void> getSchoolDetails(String inviteCode) async {
    isLoading.value = true;
    update();

    try {
      final response = await _service.getOnboardingSchoolDetails(inviteCode);

      if (response == null) {
        _handleError("Failed to connect to server");
        return;
      }

      switch (response.statusCode) {
        case 200:
          final inviteData = response.data['invite'];
          final details = inviteData['additional_details'];
          log(details.toString());
          details['invite_code'] = inviteData['invite_code'];
          details['email'] = inviteData['email'];
          details['keycloak_user_id'] = inviteData['keycloak_user_id'];
          final model = InviteSchoolModel.fromJson(details);

          invitePersona = model.invitePersona;

          partialSchoolModel.value = model;

          if ((model.firstName.isNotEmpty) && (model.lastName.isNotEmpty)) {
            firstName.text = model.firstName;
            lastName.text = model.lastName;
            isReadOnly.value = true;
          } else {
            isReadOnly.value = false;
          }

          // ✅ Reroute logic
          final expectedPersona = personaMap[invitePersona];
          if (expectedPersona != null && expectedPersona != persona) {
            Get.offAllNamed(
              '/$expectedPersona/onboarding',
              parameters: {"invite_code": inviteCode},
            );
          }
          break;

        case 410:
          _handleError("This invite has expired. Please request a new one.",
              title: "Invite Expired");
          break;

        case 404:
          _handleError("No invite found with this code.", title: "Not Found");
          break;

        default:
          _handleError("Something went wrong. Please try again.");
          break;
      }
    } catch (e) {
      _handleError("Failed to fetch school details");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> acceptInvite() async {
    if (!formKey.currentState!.validate()) return;

    isAcceptLoading.value = true;
    update();

    final tempDetails = LocalStorage.getTemporaryUserDetails();

    final inviteRequestData = {
      "user_id": partialSchoolModel.value?.keycloakUserId,
      "password": tempDetails?["password"] ?? password.text,
      "first_name": tempDetails?["first_name"] ?? firstName.text,
      "last_name": tempDetails?["last_name"] ?? lastName.text,
      "email": tempDetails?["email"] ?? partialSchoolModel.value?.adminEmail,
      "invite_persona": partialSchoolModel.value?.invitePersona,
    };

    try {
      final response = await _service.acceptSchoolInvite(
        partialSchoolModel.value?.inviteCode ?? '',
        inviteRequestData,
      );

      if (response == null) {
        _handleError("Failed to connect to server");
        return;
      }

      switch (response.statusCode) {
        case 200:
          LocalStorage.clearTemporaryUserDetails();

          Get.snackbar(
            "Success",
            "Invite accepted successfully, Now you can login",
          );
          Get.offAllNamed('/auth/login');
          break;
        case 400:
          _handleError(response.data['message'] ?? "Invalid data");
          break;
        default:
          _handleError("Something went wrong. Please try again.");
          break;
      }
    } catch (e) {
      _handleError("Failed to accept invite");
    } finally {
      isAcceptLoading.value = false;
      update();
    }
  }

  Future<void> acceptInviteFromTempDetails(Map<String, String> details) async {
    try {
      isAcceptLoading.value = true;
      update();

      final inviteRequestData = {
        "user_id": details["keycloakUserId"],
        "first_name": details["first_name"],
        "last_name": details["last_name"],
        "email": details["email"],
        "password": details["password"],
        "invite_persona": "institute_admin"
      };

      debugPrint("Sending inviteRequestData: $inviteRequestData");

      final inviteCode = details["invite_code"] ?? partialSchoolModel.value?.inviteCode ?? '';
      debugPrint("Using inviteCode: $inviteCode");

      final response = await _service.acceptSchoolInvite(
        inviteCode,
        inviteRequestData,
      );


      if (response?.statusCode == 200) {
        await LocalStorage.clearTemporaryUserDetails();
        debugPrint("Invite accepted and temp details cleared");
        Get.snackbar("Success", "Invite accepted successfully, now you can login");
        Get.offAllNamed('/auth/login');
      } else {
        _handleError(response?.data['message'] ?? "Accept invite failed");
      }
    } catch (e) {
      _handleError("Accept invite failed: $e");
    } finally {
      isAcceptLoading.value = false;
      update();
    }
  }

  void saveTemporaryUserDetails() {
    LocalStorage.setTemporaryUserDetails({
      "first_name": firstName.text,
      "last_name": lastName.text,
      "email": partialSchoolModel.value?.adminEmail ?? '',
      "password": password.text,
      "keycloakUserId": partialSchoolModel.value?.keycloakUserId ?? '',
      "invite_code": partialSchoolModel.value?.inviteCode ?? ''
    });
  }

  void _handleError(String message, {String title = "Error"}) {
    Get.snackbar(title, message);
    Get.offAllNamed('/auth/login');
  }
}
