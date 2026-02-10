import 'package:get/get.dart';
import 'package:binary_success/helpers/services/teacher_service.dart';
import 'package:binary_success/models/teachers_assignments_model.dart';
import 'package:binary_success/models/teacher_assignment_detail_model.dart';
import 'package:binary_success/models/teacher_assignment_review_response.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';

class TeacherAssignmentsController extends GetxController {
  // ===== Assignment tabs: 0 = Active, 1 = Scheduled, 2 = Draft
  final RxInt selectedIndex = 0.obs;

  // ===== Review Page TabBar index (AI Chat Log / Rubric)
  final RxInt selectedTabIndex = 0.obs;

  void changeReviewTab(int index) {
    selectedTabIndex.value = index;
  }

  // ===== Overview assignment data
  final Rx<TeachersAssignmentsModel?> assignmentsData =
      Rx<TeachersAssignmentsModel?>(null);
  final RxBool isLoading = false.obs;

  // ===== Detail page: Stats and student data
  final Rx<TaskStats?> taskStats = Rx<TaskStats?>(null);

  /// Full unfiltered list of students for searching
  final RxList<Learner> allStudents = <Learner>[].obs;

  /// List filtered by search and sort criteria for display
  final RxList<Learner> students = <Learner>[].obs;

  final RxBool isDetailLoading = false.obs;
  final RxString detailError = ''.obs;

  // ===== Currently selected Task ID
  String? currentTaskId = '';

  // ===== Review page: Teacher Assignment Review details
  final Rx<TeacherAssignmentReviewResponse?> reviewData =
      Rx<TeacherAssignmentReviewResponse?>(null);
  final RxBool isReviewLoading = false.obs;
  final RxString reviewError = ''.obs;

  // ===== Learner HTML content from Alfresco for review page
  final RxString learnerHtmlContent = ''.obs; // Holds fetched HTML

  // ===== Sorting options
  final List<String> sortOptions = [
    'Year',
    'Class',
    'Assignment',
    'Alphabetical (A-Z)',
    'Alphabetical (Z-A)',
    'Chronological (Latest First)',
    'Chronological (Oldest First)',
  ];
  final RxString selectedSort = 'Year'.obs;

  late final String? _teacherId;

  @override
  void onInit() {
    super.onInit();

    // ✅ Auto-register this controller if not already registered
    if (!Get.isRegistered<TeacherAssignmentsController>()) {
      Get.put(this, permanent: false);
    }

    _teacherId = LocalStorage.getDBEntityID();
    if (_teacherId == null || _teacherId!.isEmpty) {
      return;
    }
    getTeacherAssignmentData();
  }

  /// Loads assignment overview (by tab: active, scheduled, draft)
  Future<void> getTeacherAssignmentData() async {
    if (_teacherId == null || _teacherId!.isEmpty) {
      return;
    }

    isLoading.value = true;
    try {
      const statuses = ['active', 'scheduled', 'draft'];
      final status = statuses[selectedIndex.value];

      final response = await TeacherService.getTeacherAssignmentAPI(
        _teacherId!,
        taskStatus: status,
      );

      if (response != null && response is Map<String, dynamic>) {
        assignmentsData.value = TeachersAssignmentsModel.fromJson(response);
      } else {
        assignmentsData.value = null;
      }
    } catch (e) {
      assignmentsData.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch assignment detail (list of learners + stats)
  Future<void> getAssignmentDetail(String taskId) async {
    if (taskId.isEmpty) {
      detailError.value = 'Invalid task ID';
      return;
    }

    currentTaskId = taskId;
    isDetailLoading.value = true;
    detailError.value = '';

    try {
      final data = await TeacherService.getStatsAndLearnersForTask(taskId);

      if (data == null || data['out_status'] != 'SUCCESS') {
        detailError.value = 'Failed to load assignment details.';
        return;
      }

      final statsList = data['task_details_and_stats'];
      if (statsList is List && statsList.isNotEmpty) {
        taskStats.value = TaskStats.fromJson(statsList.first);
      } else {
        taskStats.value = null;
      }

      final studentsList = data['task_details_per_student'];
      if (studentsList is List) {
        final learners = studentsList.map((e) => Learner.fromJson(e)).toList();

        allStudents.assignAll(learners); // Store full unfiltered list
        students.assignAll(learners); // Displayed filtered/sorted list

        sortStudents(selectedSort.value);
      } else {
        allStudents.clear();
        students.clear();
      }
    } catch (e) {
      detailError.value = 'Error loading details: $e';
      taskStats.value = null;
      allStudents.clear();
      students.clear();
    } finally {
      isDetailLoading.value = false;
    }
  }

  /// Fetch Teacher Assignment Review (learner-specific review data)
  Future<void> getAssignmentReview(String learnerId, String taskId) async {
    final effectiveTaskId =
        (taskId.isNotEmpty) ? taskId : (currentTaskId ?? '');

    if (learnerId.isEmpty || effectiveTaskId.isEmpty) {
      reviewError.value = 'Invalid learner or task ID';
      return;
    }

    isReviewLoading.value = true;
    reviewError.value = '';

    try {
      final data = await TeacherService.getTeacherAssignmentReviewAPI(
        learnerId: learnerId,
        taskId: effectiveTaskId,
      );

      if (data == null || data['out_status'] != 'SUCCESS') {
        reviewError.value = 'Failed to load assignment review.';
        learnerHtmlContent.value = ''; // Clear HTML content on failure
        return;
      }

      reviewData.value = TeacherAssignmentReviewResponse.fromJson(data);

      // ===== LOGIC TO FETCH LEARNER HTML FROM ALFRESCO WITH CORRECT task_id =====
      final summary = reviewData.value?.learnerTaskSummary;
      if (summary != null) {
        try {
          // Compose the custom task_id as required by the API
          final alfrescoTaskId = summary.alfrescoTaskId.toString();
          final fileNameNoExt =
              summary.fileName.replaceAll('.html', ''); // remove ".html"
          final customTaskId = '${alfrescoTaskId}_$fileNameNoExt';

          print('site_id = ${summary.alfrescoSiteId}');
          print('folder_path = ${summary.alfrescoFolderPath}');
          print('task_id = $customTaskId'); // should match exactly!

          final html = await TeacherService.fetchLearnerHtmlResponse(
            siteId: summary.alfrescoSiteId,
            folderPath: summary.alfrescoFolderPath ?? '',
            taskId: customTaskId,
          );

          print('Alfresco HTML response: $html');
          learnerHtmlContent.value = html ?? '';
        } catch (e) {
          learnerHtmlContent.value = '';
          print('Error fetching or parsing learner HTML: $e'); // Debug
        }
      } else {
        learnerHtmlContent.value = '';
      }
      // ===== END LOGIC =====

      update();
    } catch (e) {
      reviewData.value = null;
      reviewError.value = 'Error loading review: $e';
      learnerHtmlContent.value = '';
    } finally {
      isReviewLoading.value = false;
    }
  }

  void refreshAssignments() async {
    await getTeacherAssignmentData();
  }

  void onTabChanged(int index) {
    if (selectedIndex.value != index) {
      selectedIndex.value = index;
      getTeacherAssignmentData();
    }
  }

  // ===== Sorting Support =====
  void changeSort(String sortOption) {
    selectedSort.value = sortOption;
    sortStudents(sortOption);
  }

  void sortStudents(String sortOption) {
    switch (sortOption) {
      case 'Year':
        students.sort((a, b) =>
            (a.submittedAt?.year ?? 0).compareTo(b.submittedAt?.year ?? 0));
        break;
      case 'Class':
        students.sort((a, b) => a.learnerStatus.compareTo(b.learnerStatus));
        break;
      case 'Assignment':
        students.sort((a, b) => (taskStats.value?.taskTitle ?? '')
            .compareTo(taskStats.value?.taskTitle ?? ''));
        break;
      case 'Alphabetical (A-Z)':
        students.sort((a, b) => a.firstName.compareTo(b.firstName));
        break;
      case 'Alphabetical (Z-A)':
        students.sort((a, b) => b.firstName.compareTo(a.firstName));
        break;
      case 'Chronological (Latest First)':
        students.sort((a, b) => (b.submittedAt ?? DateTime(1900))
            .compareTo(a.submittedAt ?? DateTime(1900)));
        break;
      case 'Chronological (Oldest First)':
        students.sort((a, b) => (a.submittedAt ?? DateTime(1900))
            .compareTo(b.submittedAt ?? DateTime(1900)));
        break;
      default:
        break;
    }
    students.refresh();
  }

  /// Filter students list by search query on full name
  void searchStudents(String query) {
    if (query.isEmpty) {
      students.assignAll(allStudents);
    } else {
      final lowerQuery = query.toLowerCase();
      students.assignAll(allStudents.where((learner) {
        final fullName =
            '${learner.salutation} ${learner.firstName} ${learner.lastName}'
                .toLowerCase();
        return fullName.contains(lowerQuery);
      }).toList());
    }
  }
}
