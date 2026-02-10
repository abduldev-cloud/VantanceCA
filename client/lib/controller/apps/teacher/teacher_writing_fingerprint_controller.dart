import 'package:binary_success/helpers/services/teacher_service.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:binary_success/models/teacher_fingerprint_model.dart';
import 'package:binary_success/models/teacher_fingerprint_detail_model.dart';
import 'package:binary_success/models/Teacher_Fingerprint_Review_Model.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:binary_success/controller/my_controller.dart';

class TeacherWritingFingerprintController extends MyController {
  // ===== UI State =====
  RxInt selectedIndex = 1.obs;
  PageController pageController = PageController();

  RxInt currentPage = 1.obs;
  final int pageSize = 10;

  // ===== Overview Page Data =====
  RxList<TeachersFingerPrintModel> teacherFingerPrintList =
      <TeachersFingerPrintModel>[].obs;

  // ===== Details Page Data =====
  Rxn<WritingFingerprintViewDetailsResponse> taskDetails =
      Rxn<WritingFingerprintViewDetailsResponse>();

  // ===== Fingerprint Review Details Data =====
  Rxn<TeacherFingerprintReviewModel> fingerprintReviewDetails =
      Rxn<TeacherFingerprintReviewModel>();
  RxString fingerprintHtmlContent = ''.obs; // HTML content

  // ===== Loading and Error State =====
  RxBool isLoading = false.obs;
  RxString reviewError = ''.obs;

  // ===== NEW: Search and Sort Properties =====
  var searchQuery = ''.obs;
  var sortBy = 'Recent'.obs;
  var originalStudentsList = <TaskDetailsPerStudent>[].obs;
  var filteredStudentsList = <TaskDetailsPerStudent>[].obs;

  // Available sort options matching your UI
  List<String> sortOptions = [
    'Students [A-Z]',
    'Students [Z-A]',
    'Active',
    'Inactive'
  ];

  // ===== NEW: Search and Sort Methods =====

  // Search method - call this from TextFormField onChanged
  void searchStudents(String query) {
    searchQuery.value = query.toLowerCase();
    _applyFiltersAndSort();
  }

  // Sort method - call this from PopupMenuButton onSelected
  void setSortBy(String sortValue) {
    sortBy.value = sortValue;
    _applyFiltersAndSort();
    update();
  }

  // Apply search and sort filters
  void _applyFiltersAndSort() {
    List<TaskDetailsPerStudent> filtered =
        originalStudentsList.where((student) {
      if (searchQuery.value.isEmpty) return true;

      // Use correct model properties
      String studentName =
          '${student.firstName} ${student.lastName}'.toLowerCase();
      String email = student.email.toLowerCase();
      String status = student.learnerStatus.toLowerCase();

      return studentName.contains(searchQuery.value) ||
          email.contains(searchQuery.value) ||
          status.contains(searchQuery.value);
    }).toList();

    // Apply sorting based on selected option
    filtered.sort((a, b) {
      switch (sortBy.value) {
        case 'Students [A-Z]':
          String nameA = '${a.firstName} ${a.lastName}'.toLowerCase();
          String nameB = '${b.firstName} ${b.lastName}'.toLowerCase();
          return nameA.compareTo(nameB);

        case 'Students [Z-A]':
          String nameA = '${a.firstName} ${a.lastName}'.toLowerCase();
          String nameB = '${b.firstName} ${b.lastName}'.toLowerCase();
          return nameB.compareTo(nameA);

        case 'Active':
          bool activeA = a.learnerStatus.toLowerCase() == 'active';
          bool activeB = b.learnerStatus.toLowerCase() == 'active';
          if (activeA && !activeB) return -1;
          if (!activeA && activeB) return 1;
          return 0;

        case 'Inactive':
          bool idleA = a.learnerStatus.toLowerCase() == 'inactive';
          bool idleB = b.learnerStatus.toLowerCase() == 'inactive';
          if (idleA && !idleB) return -1;
          if (!idleA && idleB) return 1;
          return 0;

        default:
          return 0;
      }
    });

    filteredStudentsList.value = filtered;
    update();
  }

  // Clear search
  void clearSearch() {
    searchQuery.value = '';
    _applyFiltersAndSort();
  }

  // Get current sort display text
  String get currentSortText => sortBy.value;

  // Helper method to get full student name
  String getStudentFullName(TaskDetailsPerStudent student) {
    return '${student.salutation} ${student.firstName} ${student.lastName}'
        .trim();
  }

  // Helper method to get status display
  // String getStatusDisplay(TaskDetailsPerStudent student) {
  //   return student.hasFingerprintSubmitted.toLowerCase() == 'y' ? 'active' : 'inactive';
  // }

  // ===== END NEW: Search and Sort Methods =====

  // Fetch Teacher FingerPrint Overview List (class_details)
  Future<void> getTeacherFingerPrintData() async {
    try {
      isLoading.value = true;
      reviewError.value = '';

      final entityId = LocalStorage.getDBEntityID();
      if (entityId == null || entityId.trim().isEmpty) {
        teacherFingerPrintList.clear();
        reviewError.value = "Teacher entity ID not found.";
        return;
      }

      final response = await TeacherService.getTeacherFingerPrintAPI(
        teacherId: entityId,
        taskType: "FINGERPRINT",
      );

      if (response != null && response.data != null) {
        final data = response.data;
        if (data.containsKey("class_details") &&
            data["class_details"] is List) {
          final List classDetails = data["class_details"];
          teacherFingerPrintList.value = classDetails
              .map((x) => TeachersFingerPrintModel.fromJson(x))
              .toList();
        } else {
          teacherFingerPrintList.clear();
          reviewError.value = "No classes found in response.";
        }
      } else {
        teacherFingerPrintList.clear();
        reviewError.value = "Empty response from server.";
      }
    } catch (e) {
      teacherFingerPrintList.clear();
      reviewError.value = 'Failed to fetch fingerprint overview data.';
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Details Page: Fetch students and task stats
  Future<void> getTaskStatsAndStudents(String taskId) async {
    try {
      isLoading.value = true;
      reviewError.value = '';
      final data =
          await TeacherService.getWritingFingerprintViewDetailsAPI(taskId);

      if (data != null) {
        taskDetails.value = data;

        // ===== NEW: Update search/sort lists =====
        originalStudentsList.value = data.taskDetailsPerStudent;
        _applyFiltersAndSort(); // This will populate filteredStudentsList
        // ===== END NEW =====
      } else {
        taskDetails.value = null;
        reviewError.value = 'No task details found.';
      }
    } catch (e) {
      taskDetails.value = null;
      reviewError.value = 'Failed to fetch task details.';
    } finally {
      isLoading.value = false;
      update();
    }
  }

  String preprocessHtml(String html) {
    return html
        .replaceAll('\u0019', "'")
        .replaceAll('\u2019', "'")
        .replaceAll('\u2018', "'")
        .replaceAll('\u201C', '"')
        .replaceAll('\u201D', '"');
  }

  // Fetch Fingerprint Review Details + HTML for a specific learner and task
  Future<void> getFingerprintReviewDetails({
    required String learnerId,
    required String taskId,
  }) async {
    try {
      fingerprintHtmlContent.value = '';
      fingerprintReviewDetails.value = null;
      reviewError.value = '';
      isLoading.value = true;
      update();

      final data = await TeacherService.getTeacherAssignmentReviewAPI(
        learnerId: learnerId.trim(),
        taskId: taskId.trim(),
      );

      if (data != null) {
        final model = TeacherFingerprintReviewModel.fromJson(data);

        if (model.studentFullName == null || model.studentFullName!.isEmpty) {
          fingerprintReviewDetails.value = null;
          reviewError.value =
              "No fingerprint review data available for this submission.";
        } else {
          fingerprintReviewDetails.value = model;

          // ===== Alfresco HTML Fetch Logic =====
          // final alfrescoTaskId = model.alfrescoTaskId.toString();
          final fileNameNoExt = model.fileName?.replaceAll('.html', '') ?? '';
          //   final customTaskId = '${alfrescoTaskId}_$fileNameNoExt';
          final html = await TeacherService.fetchLearnerHtmlResponse(
            siteId: model.alfrescoSiteId ?? '',
            folderPath: model.alfrescoFolderPath ?? '',
            taskId: fileNameNoExt,
          );
          fingerprintHtmlContent.value = preprocessHtml(html ?? '');

          // ===== End HTML Fetch Logic =====
        }
      } else {
        fingerprintReviewDetails.value = null;
        reviewError.value = 'No fingerprint review data found.';
      }
    } catch (e) {
      fingerprintReviewDetails.value = null;
      fingerprintHtmlContent.value = '';
      reviewError.value = 'Failed to fetch fingerprint review details.';
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // ===== UPDATED: Pagination Support (now uses filtered list) =====
  List<TaskDetailsPerStudent> get pagedStudents {
    final allStudents = filteredStudentsList.isNotEmpty
        ? filteredStudentsList
        : taskDetails.value?.taskDetailsPerStudent ?? [];
    final startIndex = (currentPage.value - 1) * pageSize;
    if (startIndex >= allStudents.length) return [];
    return allStudents.skip(startIndex).take(pageSize).toList();
  }

  void goToPage(int page) {
    final totalPages = ((filteredStudentsList.isNotEmpty
                ? filteredStudentsList.length
                : taskDetails.value?.taskDetailsPerStudent.length ?? 0) /
            pageSize)
        .ceil();
    if (page < 1 || page > totalPages) return;
    currentPage.value = page;
    update();
  }

  void nextPage() => goToPage(currentPage.value + 1);
  void previousPage() => goToPage(currentPage.value - 1);

  @override
  void onInit() {
    super.onInit();
    getTeacherFingerPrintData();
  }
}
