import 'package:binary_success/helpers/services/teacher_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:binary_success/controller/my_controller.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:binary_success/models/teachers_grading_model.dart';

class TeacherGradingController extends MyController {
  /// 🔹 Tabs: 0 = Submitted, 1 = Graded, 2 = All
  final RxInt selectedTabIndex = 0.obs;
  late final PageController pageController;

  /// 🔹 State
  final RxBool isLoading = false.obs;

  /// 🔹 Data lists
  final RxList<TeachersGradingModel> allTasks = <TeachersGradingModel>[].obs;
  final RxList<TeachersGradingModel> submittedTasks = <TeachersGradingModel>[].obs;
  final RxList<TeachersGradingModel> gradedTasks = <TeachersGradingModel>[].obs;
  final RxList<TeachersGradingModel> reviewData= <TeachersGradingModel>[].obs;
  /// 🔹 Counts
  final RxInt totalCount = 0.obs;
  final RxInt submittedCount = 0.obs;
  final RxInt gradedCount = 0.obs;

  /// 🔹 Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final int pageSize = 10;

  /// 🔹 Current filter
  String? _teacherId;
  String currentStatus = "submitted"; // default tab
  String currentSearch = "";
  String currentSort = "Oldest";

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
    _loadTeacherIdAndFetchData();
  }

  Future<void> _loadTeacherIdAndFetchData() async {
    _teacherId = LocalStorage.getDBEntityID();
    if (_teacherId == null || _teacherId!.isEmpty) {
      debugPrint("❌ No teacherId found in LocalStorage");
      _clearData();
      return;
    }
    await fetchGradingData(status: currentStatus, pageNumber: 1);
  }

  /// 🔹 Fetch grading data with pagination, search & sort
  Future<void> fetchGradingData({
    String? status,
    int pageNumber = 1,
    int? pageSize,
  }) async {
    final idToUse = _teacherId;
    if (idToUse == null || idToUse.isEmpty) {
      debugPrint("❌ fetchGradingData() called without teacherId");
      _clearData();
      return;
    }

    try {
      isLoading.value = true;


final response = await TeacherGradingService.getTeacherGradingTasks(
  teacherId: idToUse,
  taskStatus: (status ?? "").toUpperCase(), // 🔹 fix here
  pageNumber: pageNumber,
  pageSize: pageSize ?? this.pageSize,
);


      if (response == null) {
        _clearData();
        return;
      }

      /// ✅ Assign all tasks
      allTasks.assignAll(response.learnerTasks);

      /// ✅ Categorize
      String normalize(String? s) => (s ?? "").trim().toUpperCase();
      submittedTasks.assignAll(allTasks.where((t) => normalize(t.status) == "SUBMITTED"));
      gradedTasks.assignAll(allTasks.where((t) => normalize(t.status) == "GRADED"));

      currentStatus = status ?? "";
      currentPage.value = pageNumber;

      /// ✅ Update counts from API summary
      if (response.taskSummary.isNotEmpty) {
        final summary = response.taskSummary.first;
        gradedCount.value = summary.gradedCount;
        submittedCount.value = summary.pendingGradingCount;
        totalCount.value = summary.totalTasksCount;
      } else {
        submittedCount.value = submittedTasks.length;
        gradedCount.value = gradedTasks.length;
        totalCount.value = allTasks.length;
      }

      /// ✅ Pagination calculation
      totalPages.value = _calculateTotalPages(currentStatus);
    } catch (e, s) {
      debugPrint("❌ fetchGradingData error: $e");
      debugPrintStack(stackTrace: s);
      _clearData();
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Calculate total pages safely
  int _calculateTotalPages(String status) {
    int count = status == "submitted"
        ? submittedCount.value
        : status == "graded"
            ? gradedCount.value
            : totalCount.value;
    return ((count / pageSize).ceil()).clamp(1, 9999);
  }

  /// 🔹 Switch tabs and reload data
  Future<void> switchTab(int index) async {
    selectedTabIndex.value = index;

    String status;
    if (index == 0) {
      status = "submitted";
    } else if (index == 1) {
      status = "graded";
    } else {
      status = ""; // All
    }

    await fetchGradingData(status: status, pageNumber: 1);

    if (pageController.hasClients) {
      pageController.jumpToPage(index);
    }
  }

  /// 🔹 Pagination navigation
  void goToPage(int page) {
    if (page < 1 || page > totalPages.value) return;
    currentPage.value = page;
    fetchGradingData(status: currentStatus, pageNumber: page);
  }

  /// 🔹 Apply filters (search + sort)
  void applyFilters(String search, String sort) {
  currentSearch = search;
  currentSort = sort;

  String status;
  if (selectedTabIndex.value == 0) {
    status = "SUBMITTED";
  } else if (selectedTabIndex.value == 1) {
    status = "GRADED";
  } else {
    status = ""; // All
  }

  fetchGradingData(status: status, pageNumber: 1);
}



  /// 🔹 Reset state
  void _clearData() {
    allTasks.clear();
    submittedTasks.clear();
    gradedTasks.clear();

    totalCount.value = 0;
    submittedCount.value = 0;
    gradedCount.value = 0;
    currentPage.value = 1;
    totalPages.value = 1;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
