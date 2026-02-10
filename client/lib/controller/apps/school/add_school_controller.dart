import 'package:binary_success/helpers/services/school_service.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:binary_success/models/add_school_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:binary_success/widgets/common_status_dialog.dart';

class AddSchoolController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final domainController = TextEditingController();
  final districtController = TextEditingController();
  RxBool isLoading = false.obs;

  //Added for Demo toggle button state
  var isDemoSchool = false.obs;

  //Added for Institution type Implementation
  Map<String, String> instituteTypeIdByName = {};
  RxString selectedType = "".obs;
  RxString selectedTypeId = "".obs;
  RxList<String> instituteTypes = <String>[].obs;

  RxString selectedState = "".obs;
  RxString selectedDistrict = "".obs;

  RxList<String> schoolStates = <String>[].obs;
  RxList<String> schoolDistricts = <String>[].obs;

  final SchoolService _service = SchoolService();

  // Internal maps
  Map<String, String> stateIdByName = {}; // "California" -> "3CFFDFC..."
  Map<String, List<Map<String, String>>> districtsByState = {};
  // "California" -> [{id:"..", name:"Los Angeles Unified"}, ...]

  /// Fetch states + districts from API
  Future<void> fetchDistricts() async {
    try {
      isLoading.value = true;

      final response = await SchoolService.getStatesAndDistricts();
      // Make sure your service returns Map<String,dynamic> parsed JSON

      if (response != null && response["out_status"] == "SUCCESS") {
        final states = response["states_list"] ?? [];
        final districts = response["state_district_list"] ?? [];

        // Build states
        stateIdByName.clear();
        schoolStates.clear();
        for (var s in states) {
          final stateName = s["institute_state"] ?? "";
          final stateId = s["institute_state_id"] ?? "";
          if (stateName.isNotEmpty) {
            schoolStates.add(stateName);
            stateIdByName[stateName] = stateId;
          }
        }

        // Build districts mapping
        districtsByState.clear();
        for (var d in districts) {
          final stateName = d["institute_state"] ?? "";
          final districtName = d["institute_district"] ?? "";
          final districtId = d["institute_district_id"] ?? "";

          if (stateName.isNotEmpty && districtName.isNotEmpty) {
            districtsByState.putIfAbsent(stateName, () => []);
            districtsByState[stateName]!.add({
              "id": districtId,
              "name": districtName,
            });
          }
        }

        // Initialize selection defaults
        if (schoolStates.isNotEmpty) {
          selectedState.value = schoolStates.first;
          filterDistrictsByState(selectedState.value);
        }
      }
    } catch (e) {
      debugPrint("Error fetching states/districts: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter districts when state changes
  void filterDistrictsByState(String stateName) {
    final list = districtsByState[stateName] ?? [];
    schoolDistricts.value = list.map((d) => d["name"]!).toList();

    if (schoolDistricts.isNotEmpty) {
      selectedDistrict.value = schoolDistricts.first;
    } else {
      selectedDistrict.value = "";
    }
  }
  //Fetching the Institute type values
  Future<void> fetchInstituteTypes() async {
    try {
      isLoading.value = true;
      final response = await SchoolService.getInstituteTypes();

      if (response != null && response["out_status"] == "SUCCESS") {
        final types = response["institute_type_list"] ?? [];
        instituteTypes.clear();
        instituteTypeIdByName.clear();

        for (var t in types) {
          final typeName = t["institute_type_name"] ?? "";
          final typeId = t["institute_type_id"] ?? "";
          if (typeName.isNotEmpty && typeId.isNotEmpty) {
            instituteTypes.add(typeName);
            instituteTypeIdByName[typeName] = typeId;
          }
        }

        if (instituteTypes.isNotEmpty) {
          selectedType.value = instituteTypes.first;
          selectedTypeId.value =
              instituteTypeIdByName[selectedType.value] ?? "";
        }
      }
    } catch (e) {
      debugPrint("Error fetching institute types: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Clear controllers when the dialog is closed
  void clearControllers() {
    nameController.clear();
    emailController.clear();
    domainController.clear();
    districtController.clear();
    selectedType.value = "Public";
    selectedState.value = schoolStates.isNotEmpty ? schoolStates.first : "";
    selectedDistrict.value =
        schoolDistricts.isNotEmpty ? schoolDistricts.first : "";
  }

  Future<void> addSchool() async {
    final userID = LocalStorage.getDBUserID();
    if (userID == null || userID.isEmpty) {
      Get.snackbar("Error", "User not logged in");
      return;
    }
    final model = AddSchoolModel(
      schoolName: nameController.text.trim(),
      schoolType: selectedTypeId.value,
      schoolDistrict: selectedDistrict.value,
      adminEmail: emailController.text.trim(),
      emailDomain: domainController.text.trim(),
      createdBy: userID,
      
    );

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        domainController.text.isEmpty ||
        selectedState.value.isEmpty ||
        selectedDistrict.value.isEmpty) {
      Get.snackbar("Error", "Please fill all fields", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    } else if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar("Error", "Please enter a valid email", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final districtId = districtsByState[selectedState.value]?.firstWhere(
            (d) => d["name"] == selectedDistrict.value,
            orElse: () => {"id": ""},
          )["id"] ??
          "";

      final model = AddSchoolModel(
        schoolName: nameController.text.trim(),
        schoolType: selectedType.value,
        schoolDistrict: selectedDistrict.value,
        adminEmail: emailController.text.trim(),
        emailDomain: domainController.text.trim(),
        createdBy: userID,
        isDemoSchool: isDemoSchool.value,
      );
        print("AddSchoolModel isDemoSchool: ${model.isDemoSchool}");
        print("Submitting payload: ${model.toJson()}");

      final response = await _service.submitSchool(model);
      print("statusCode recevied: $response");
      if (response == null) {
        Get.snackbar("Error", "Failed to send invite", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (response == false) {
        StatusDialog.show(
          isSuccess: false,
          message: "something went wrong.",
        );
        return;
      }
      //Updated Dio response(below is the default code)
      // if (response.statusCode == 200) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        clearControllers();
        Get.back(); // Close dialog
        StatusDialog.show(
          isSuccess: true,
          message: "Invite sent successfully",
          autoCloseSeconds: 2, // auto close
          onClose: () {
            Get.back();
          },
        );

        //Get.snackbar("Success", "Invite sent successfully", backgroundColor: Colors.green, colorText: Colors.white);
      } else if (response.statusCode == 409) {
        StatusDialog.show(
          isSuccess: false,
          message: "Invite already sent to this email",
        );
//        Get.snackbar("Error", "Invite already sent to this email",backgroundColor: Colors.red, colorText: Colors.white);
        clearControllers();
      } else if (response.statusCode == 400) {
        StatusDialog.show(
          isSuccess: false,
          message: "User is already active. Cannot resend invite.",
        );
//        Get.snackbar("Error", "Invite already sent to this email",backgroundColor: Colors.red, colorText: Colors.white);
        clearControllers();
      } else {
        StatusDialog.show(
          isSuccess: false,
          message: "Failed to send invite",
        );
//        Get.snackbar("Error", "Failed to send invite",backgroundColor: Colors.red, colorText: Colors.white);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    domainController.dispose();
    super.onClose();
  }
}
