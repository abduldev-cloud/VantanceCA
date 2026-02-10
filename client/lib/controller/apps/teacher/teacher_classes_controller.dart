import 'package:binary_success/helpers/services/teacher_service.dart';
import 'package:binary_success/models/teacher_classes_model.dart';
import 'package:binary_success/models/create_class_model.dart';
import 'package:get/get.dart';
import 'package:binary_success/controller/my_controller.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:binary_success/widgets/common_status_dialog.dart';

class TeacherClassesController extends MyController {
  RxInt selectedIndex = 0.obs; // start with Active (0)
  PageController pageController = PageController(initialPage: 0);

  TextEditingController className = TextEditingController();
  TextEditingController classDescription = TextEditingController();
  TextEditingController classGrade = TextEditingController();
  TextEditingController classStudents = TextEditingController();
  TextEditingController maxLearners = TextEditingController();
  TextEditingController classInviteCode = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();

  RxList<ClassInfo> teacherActiveClassList = <ClassInfo>[].obs;
  RxList<ClassInfo> teacherArchivedClassList = <ClassInfo>[].obs;

  RxInt activeClassesCount = 0.obs;
  RxInt archivedClassesCount = 0.obs;
  RxInt totalCurrentStudents = 0.obs;
  RxList<ClassInfo> classList = <ClassInfo>[].obs;

  RxString selectedStatus = "Active".obs;
  RxBool isLoading = false.obs;

  List<ClassInfo> get displayedClasses {
    final status = selectedStatus.value.toLowerCase();
    if (status == "active") {
      return teacherActiveClassList;
    } else if (status == "archived") {
      return teacherArchivedClassList;
    }
    return [];
  }

  Future<void> getTeacherClassData() async {
    isLoading(true);
    try {
      final entityId = LocalStorage.getDBEntityID();
      if (entityId == null || entityId.isEmpty) return;

      final TeacherClassSummaryResponse? activeResp =
          await TeacherService.getTeacherClassAPI(
        teacherId: entityId,
        classStatus: "Active",
      );

      teacherActiveClassList.value = activeResp?.classDetails ?? [];
      activeClassesCount.value =
          activeResp?.classStatusCount?.first.activeClasses ?? 0;

      final TeacherClassSummaryResponse? archivedResp =
          await TeacherService.getTeacherClassAPI(
        teacherId: entityId,
        classStatus: "Archived",
      );

      teacherArchivedClassList.value = archivedResp?.classDetails ?? [];
      archivedClassesCount.value =
          archivedResp?.classStatusCount?.first.archivedClasses ?? 0;

      _updateDisplayedClassList();
      _updateTotalCurrentStudents(activeResp, archivedResp);
    } catch (e) {
      teacherActiveClassList.clear();
      teacherArchivedClassList.clear();
      classList.clear();
      activeClassesCount.value = 0;
      archivedClassesCount.value = 0;
      totalCurrentStudents.value = 0;
    } finally {
      isLoading(false);
    }
  }

  void _updateDisplayedClassList() {
    if (selectedStatus.value.toLowerCase() == "active") {
      classList.value = teacherActiveClassList;
    } else if (selectedStatus.value.toLowerCase() == "archived") {
      classList.value = teacherArchivedClassList;
    } else {
      classList.clear();
    }
  }

  void _updateTotalCurrentStudents(TeacherClassSummaryResponse? activeResp,
      TeacherClassSummaryResponse? archivedResp) {
    final total = activeResp?.teacherSummary?.first.totalLearners ??
        archivedResp?.teacherSummary?.first.totalLearners ??
        0;

    totalCurrentStudents.value = total;
  }

  void changeStatus(String newStatus) {
    selectedStatus.value = newStatus;
  }

  void onTab(int index) {
    selectedIndex.value = index;
    pageController.jumpToPage(index);
    if (index == 0) changeStatus("Active");
    if (index == 1) changeStatus("Archived");
    if (index == 2) changeStatus("Students");
  }

  /// Creates a new class using the new API structure
  Future<bool> createClass() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    if (className.text.isEmpty ||
        classDescription.text.isEmpty ||
        maxLearners.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    isLoading(true);
    try {
      final teacherId = LocalStorage.getDBEntityID();
      if (teacherId == null || teacherId.isEmpty) {
        print("❌ No teacher ID found in local storage");
        return false;
      }

      // Get institute ID from storage (you may need to adjust this based on your storage structure)
      final instituteId =
          LocalStorage.getDBEntityID() ?? teacherId; // Fallback to teacherId
      final createdBy = LocalStorage.getDBUserID() ?? teacherId;

      // Parse max learners from dropdown
      final maxLearners = int.tryParse(classStudents.text) ?? 40;

      // Create request
      final request = CreateClassRequest(
        instituteId: '3AD3B662A05D82C7E0631660000A4210',
        //instituteId: instituteId,
        teacherId: teacherId,
        className: className.text,
        maxLearners: maxLearners,
        gradeLevelId: classGrade.text.isNotEmpty
            ? classGrade.text
            : '', // Provide default
        description: classDescription.text,
        term: "", // need to replace this with a value
        createdBy: createdBy,
        inviteCode: classInviteCode.text.isNotEmpty ? classInviteCode.text : '',
      );

      final response = await TeacherService.createClassAPI(request);

      if (response != null && response.message == "SUCCESS") {
        final taskId = response.classId; // ✅ Extract classId

        //await getTeacherClassData();
        print("Class created : $taskId");
        StatusDialog.show(
          isSuccess: true,
          message: "Class created successfully!",
          autoCloseSeconds: 2, // auto close
          onClose: () {
            Get.back(); // Close dialog
            print("On success");
            // Get.toNamed(
            //   "/teacher/classesdetail",
            //   arguments: {
            //      "taskId": taskId,
            //   },
            // );
          },
        );

        return true;
      } else {
        String errorMessage = response?.error ??
            response?.message ??
            "Something went wrong. Please try again.";

        // ❌ Failure dialog
        StatusDialog.show(
          isSuccess: false,
          message: "Class creation failed. Please try again.",
        );
        return false;
      }
    } catch (e) {
      print("❌ Error creating class: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// Clears the form fields
  void clearForm() {
    className.clear();
    classDescription.clear();
    classGrade.clear();
    classStudents.clear();
    classInviteCode.clear();
  }

  @override
  void onInit() {
    super.onInit();
    getTeacherClassData();
  }
}
