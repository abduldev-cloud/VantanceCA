import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vantanceCA/controller/my_controller.dart';
import 'package:vantanceCA/helpers/logger/logger.dart';
import 'package:vantanceCA/helpers/services/school_analytics_service.dart';
import 'package:vantanceCA/helpers/services/teacher_service.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'package:vantanceCA/models/ai_usage_overview_model.dart';
import 'package:vantanceCA/models/school_performance_metrics_model.dart';
import 'package:vantanceCA/models/teacher_classes_model_analytics.dart';

class TeacherAbnalyticsController extends MyController {
  RxInt selectedIndex = 1.obs;
  PageController pageController = PageController();

  // Loading states
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = "".obs;

  // AI Usage Overview data
  Rx<AiUsageOverviewModel?> aiUsageOverview = Rx<AiUsageOverviewModel?>(null);

  // Performance Metrics data
  Rx<SchoolPerformanceMetricsModel?> performanceMetrics =
      Rx<SchoolPerformanceMetricsModel?>(null);

  // Time range for analytics (default 30 days)
  RxInt timeRangeDays = 30.obs;
  RxString selectedTimeRange = "30d".obs;

  // Custom date range properties
  RxBool isCustomDateRange = false.obs;
  Rx<DateTime?> customStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> customEndDate = Rx<DateTime?>(null);
  final Rx<ApiResponse?> fullApiResponse = Rx<ApiResponse?>(null);

  // Class data for filtering
  RxList<TeacherClassModel> teacherClassList = <TeacherClassModel>[].obs;
  RxString selectedClass = "All".obs;
  RxString selectedClassId = "".obs;
  RxString selectedGrade = "All".obs;
  final RxString selectedTerm = 'All'.obs; // Initialize with 'All'
  RxString selectedPeriodBucket =
      'year'.obs; // for 'year', 'month', 'week' selection

  // Dropdown data lists
  final RxList<String> termList = <String>[].obs;
  final RxList<TeacherClassModel> classList = <TeacherClassModel>[].obs;
  final RxList<String> gradeList = <String>[].obs;
  RxList<String> termDropdownItems = <String>[].obs;

  List<String> get timeRangeOptions => ["7d", "14d", "30d", "Term 1"];
  void updateSelectedTerm(String value) => selectedTerm.value = value;

  // Performance metrics data (from new endpoint)
  RxDouble avgGrade = 0.0.obs;
  RxString averageGradeTrend = "".obs;
  RxDouble avgAssignmentTimeHours = 0.0.obs;
  RxString averageAssignmentTimeTrend = "".obs;
  RxBool hasLoadedPerformanceMetrics = false.obs;

  // RxString writingFingerprintAverageDeviationTrend = "stable".obs;
  // RxString writingFingerprintTotalTrend = "stable".obs;

  // RxString aiPromptUsageAverageTrend = "stable".obs;
  // RxString aiPromptUsageTotalTrend = "stable".obs;

  // Add these
  RxString selectedGradeId = "".obs;
  Map<String, String> gradeNameIdMap = {};

  @override
  void onInit() {
    super.onInit();
    // Fetch class data first, then analytics data
    // fetchTeacherClasses(); // Removed: Data consolidated in fetchTeacherClassFilters
    fetchAiUsageOverview();
    fetchPerformanceMetrics();
    fetchTeacherClassFilters();
  }

// Fetch API and populate dropdowns
  Future<void> fetchTeacherClassFilters() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final teacherId = LocalStorage.getDBEntityID();
      if (teacherId == null || teacherId.isEmpty) {
        _handleError("Teacher ID not found. Please log in again.");
        return;
      }

      final response = await TeacherService.getTeacherClassFilters(
        teacherId: teacherId,
        className: selectedClass.value != "All" ? selectedClass.value : null,
        gradeId:
            selectedGradeId.value.isNotEmpty && selectedGradeId.value != "All"
                ? selectedGradeId.value
                : null,
        term: selectedTerm.value != "All" ? selectedTerm.value : null,
      );

      if (response != null && response.success && response.data.isNotEmpty) {
        fullApiResponse.value = response;
        final teacher = response.data[0].teachers[0];

        // Populate terms with "All" on top
        termList.assignAll(['All', ...teacher.terms]);
        if (!termList.contains(selectedTerm.value)) selectedTerm.value = 'All';

        // Populate grades with "All" on top
        gradeList.assignAll(['All', ...teacher.grades.map((g) => g.gradeName)]);
        gradeNameIdMap = {for (var g in teacher.grades) g.gradeName: g.gradeId};
        if (!gradeList.contains(selectedGrade.value))
          selectedGrade.value = 'All';

        // Populate classes with "All" on top
        classList.value = [
          TeacherClassModel(classId: '', className: 'All', gradeName: 'All'),
          ...teacher.classes.map((cls) {
            return TeacherClassModel(
              classId: cls.classId,
              className: cls.className,
              gradeId: cls.gradeId,
              gradeName: teacher.grades
                  .firstWhere((g) => g.gradeId == cls.gradeId,
                      orElse: () => GradeModel(gradeId: '', gradeName: 'N/A'))
                  .gradeName,
            );
          })
        ];
        if (!classList.any((c) => c.className == selectedClass.value)) {
          selectedClass.value = 'All';
          selectedClassId.value = '';
        }

        isLoading.value = false;
      } else {
        _handleError('No data available or API success false.');
      }
    } catch (e) {
      _handleError('Failed to load filters: $e');
    }
  }

// Apply filters
  void applyFilters() {
    if (fullApiResponse.value == null) return;
    final teacher = fullApiResponse.value!.data[0].teachers[0];

    List<TeacherClassModel> filtered = teacher.classes.map((cls) {
      final gradeName = teacher.grades
          .firstWhere((g) => g.gradeId == cls.gradeId,
              orElse: () => GradeModel(gradeId: '', gradeName: 'N/A'))
          .gradeName;
      return TeacherClassModel(
        classId: cls.classId,
        className: cls.className,
        gradeId: cls.gradeId,
        gradeName: gradeName,
      );
    }).toList();

    if (selectedGrade.value != 'All') {
      filtered =
          filtered.where((c) => c.gradeName == selectedGrade.value).toList();
    }

    if (selectedTerm.value != 'All') {
      // Since API doesn’t return term in ClassLightModel, we skip term filter here
      // or implement term filter if your API provides term per class
    }

    classList.value = [
      TeacherClassModel(classId: '', className: 'All', gradeName: 'All'),
      ...filtered
    ];

    // Reset selectedClass if not in filtered
    if (!classList.any((c) => c.className == selectedClass.value)) {
      selectedClass.value = 'All';
      selectedClassId.value = '';
    }
  }

// Class change handler
  Future<void> onClassChanged(String clsName) async {
    selectedClass.value = clsName;

    final cls = classList.firstWhere((c) => c.className == clsName,
        orElse: () => TeacherClassModel());
    selectedClassId.value = cls.classId ?? '';

    // Call API with updated filters
    await fetchTeacherClassFilters();

    // Fetch analytics overview filtered by new selections
    await fetchAiUsageOverview();
  }

// Grade change handler
  Future<void> onGradeChanged(String grade) async {
    selectedGrade.value = grade;
    selectedGradeId.value = gradeNameIdMap[grade] ?? '';

    // Call API with updated filters
    await fetchTeacherClassFilters();

    // Fetch analytics overview filtered by new selections
    await fetchAiUsageOverview();
  }

// Term change handler
  Future<void> onTermChanged(String term) async {
    selectedTerm.value = term;

    // Call API with updated filters
    await fetchTeacherClassFilters();

    // Fetch analytics overview filtered by new selections
    await fetchAiUsageOverview();
  }

// Fetch analytics overview based on current selections
  Future<void> fetchAiUsageOverview() async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage("");

      final userEmail = LocalStorage.getUserEmail();
      if (userEmail == null || userEmail.isEmpty) {
        _handleError("User email not found. Please log in again.");
        return;
      }

      final result = await SchoolAnalyticsService.getAiUsageOverviewByEmail(
        email: userEmail,
        timeRangeDays: timeRangeDays.value,
        bucket: selectedPeriodBucket.value,
        classId:
            selectedClassId.value.isNotEmpty ? selectedClassId.value : null,
        gradeLevelId:
            selectedGradeId.value.isNotEmpty ? selectedGradeId.value : null,
        term: selectedTerm.value != 'All' ? selectedTerm.value : null,
        //academicYear: selectedAcademicYear.value != 'All' ? selectedAcademicYear.value : null,
      );

      if (result != null) {
        aiUsageOverview(result);
        hasError(false);
        errorMessage("");
      } else {
        _handleError("Failed to fetch AI usage data for email: $userEmail");
      }
    } catch (e) {
      _handleError("Error fetching AI usage data: $e");
    } finally {
      isLoading(false);
    }
  }

  /// Handle errors
  void _handleError(String message) {
    logE("Error: $message"); // Log the error
    hasError(true);
    errorMessage(message);
    isLoading(false);
  }

  /// Fetch performance metrics data for teacher (using email-based lookup)
  Future<void> fetchPerformanceMetrics() async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage("");

      // Get user email from local storage
      final userEmail = LocalStorage.getUserEmail();

      if (userEmail == null || userEmail.isEmpty) {
        _handleError("User email not found. Please log in again.");
        return;
      }

      // Fetch performance metrics using the new email-based endpoint
      final result = await SchoolAnalyticsService.getPerformanceMetricsByEmail(
        email: userEmail,
        timeRangeDays: timeRangeDays.value,
        classId: selectedClassId.value.isEmpty ? null : selectedClassId.value,
      );

      print("Raw API Result: $result"); // Debug raw response

      if (result != null && result['success'] == true) {
        // Extract performance metrics from the new response format
        final data = result['data'];
        final performanceMetricsData = data?['performance_metrics'];

        if (performanceMetricsData != null) {
          // Extract values
          final avgGrade =
              performanceMetricsData['avg_grade']?.toDouble() ?? 0.0;
          final avgGradeTrend =
              performanceMetricsData['avg_grade_trend']?.toString() ?? "";
          final avgTimeHours =
              performanceMetricsData['avg_assignment_time_hours']?.toDouble() ??
                  0.0;
          final avgAssignmentTimeTrend =
              performanceMetricsData['avg_assignment_time_trend']?.toString() ??
                  "";

          // Debug print extracted trend values
          print("Avg Grade Trend: $avgGradeTrend");
          print("Avg Assignment Time Trend: $avgAssignmentTimeTrend");

          // Store the values for reactive getters
          this.avgGrade(avgGrade);
          averageGradeTrend(
              avgGradeTrend.trim().toLowerCase()); // normalize string
          avgAssignmentTimeHours(avgTimeHours);
          averageAssignmentTimeTrend(
              avgAssignmentTimeTrend.trim().toLowerCase());
          hasLoadedPerformanceMetrics(true);

          logI(
              "✅ Performance metrics updated: Grade=$avgGrade, Time=${avgTimeHours}h");
          hasError(false);
          errorMessage("");
          isLoading(false);
        } else {
          _handleError("Invalid performance metrics data format");
        }
      } else {
        _handleError(
            "Failed to fetch performance metrics for email: $userEmail");
      }
    } catch (e) {
      _handleError("Error fetching performance metrics: $e");
    } finally {
      isLoading(false); // Ensure loading is set to false after the operation
    }
  }

  var isAiUsageLoading = false.obs; // Add this

  /// Refresh AI usage data
  Future<void> refreshAiUsageData() async {
    try {
      isAiUsageLoading.value = true; // Start loading
      await fetchAiUsageOverview();
      await fetchPerformanceMetrics();
      await fetchTeacherClassFilters();
    } finally {
      isAiUsageLoading.value = false; // End loading
    }
  }

  void updateTimeRangeFilter(String timeRange) {
    selectedTimeRange(timeRange);

    // Convert time range to days
    switch (timeRange) {
      case "7d":
        timeRangeDays(7);
        break;
      case "14d":
        timeRangeDays(14);
        break;
      case "30d":
        timeRangeDays(30);
        break;
      case "Term 1":
        // Term 1: Aug 1st - Dec 31st (hard coded)
        // Calculate days from Aug 1st to Dec 31st
        final now = DateTime.now();
        final currentYear = now.year;
        final term1Start = DateTime(currentYear, 8, 1); // Aug 1st
        final term1End = DateTime(currentYear, 12, 31); // Dec 31st

        // If we're past Dec 31st, use previous year's term
        final termStart = now.isAfter(term1End)
            ? DateTime(currentYear, 8, 1)
            : DateTime(currentYear, 8, 1);
        final daysSinceTerm1Start = now.difference(termStart).inDays;

        // Use the actual days since Term 1 started, max 153 days (Aug 1 to Dec 31)
        timeRangeDays(daysSinceTerm1Start > 153 ? 153 : daysSinceTerm1Start);
        break;
      default:
        timeRangeDays(30);
    }

    fetchAiUsageOverview(); // Refresh data with new time range
    fetchPerformanceMetrics(); // Refresh performance metrics
  }

  /// Update custom date range
  void updateCustomDateRange(DateTime? startDate, DateTime? endDate) {
    customStartDate(startDate);
    customEndDate(endDate);

    if (startDate != null && endDate != null) {
      // Calculate days between start and end date
      final difference = endDate.difference(startDate).inDays;
      timeRangeDays(difference > 0 ? difference : 1);
    }

    refreshAiUsageData();
  }

  /// Get formatted custom date range string
  String get customDateRangeString {
    if (customStartDate.value == null || customEndDate.value == null) {
      return "Select dates";
    }

    final start = customStartDate.value!;
    final end = customEndDate.value!;

    // Use compact format with abbreviated month names: MMM d, yyyy - MMM d, yyyy
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final startMonth = months[start.month - 1];
    final endMonth = months[end.month - 1];

    return "$startMonth ${start.day}, ${start.year} - $endMonth ${end.day}, ${end.year}";
  }

  /// Get writing fingerprint average deviation
  double get writingFingerprintAverageDeviation =>
      aiUsageOverview.value?.writingFingerprintAnalytics?.averageDeviation ??
      0.0;

  /// Get writing fingerprint total
  int get writingFingerprintTotal =>
      aiUsageOverview.value?.writingFingerprintAnalytics?.totalCount ?? 0;

  /// Get AI prompt usage average
  double get aiPromptUsageAverage =>
      aiUsageOverview.value?.aiPromptUsage?.averageUsage ?? 0.0;

  /// Get AI prompt usage total
  int get aiPromptUsageTotal =>
      aiUsageOverview.value?.aiPromptUsage?.totalCount ?? 0;
  String get writingFingerprintAverageDeviationTrend {
    final value = aiUsageOverview
            .value?.writingFingerprintAnalytics?.averageDeviationTrend ??
        "stable";
    print("writingFingerprintAverageDeviationTrend: $value");
    return value;
  }

  String get writingFingerprintTotalTrend {
    final value =
        aiUsageOverview.value?.writingFingerprintAnalytics?.totalCountTrend ??
            "stable";
    print("writingFingerprintTotalTrend: $value");
    return value;
  }

  String get aiPromptUsageAverageTrend {
    final value =
        aiUsageOverview.value?.aiPromptUsage?.averageUsageTrend ?? "stable";
    print("aiPromptUsageAverageTrend: $value");
    return value;
  }

  String get aiPromptUsageTotalTrend {
    final value =
        aiUsageOverview.value?.aiPromptUsage?.totalCountAiTrend ?? "stable";
    print("aiPromptUsageTotalTrend: $value");
    return value;
  }

  /// Format number with commas
  String formatNumberWithCommas(int number) {
    return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]},');
  }

  /// Get formatted AI prompt usage total
  String get formattedAiPromptUsageTotal =>
      formatNumberWithCommas(aiPromptUsageTotal);

  /// Check if AI usage data is available
  bool get hasAiUsageData => aiUsageOverview.value != null;

  /// Check if performance metrics data is available
  bool get hasPerformanceMetricsData => hasLoadedPerformanceMetrics.value;

  /// Fetch teacher class data from backend
  Future<void> fetchTeacherClasses() async {
    try {
      isLoading(true);
      final response = await TeacherService.getTeacherClassAnalyticsAPI();
      if (response != null &&
          response.data != null &&
          response.data["items"] != null) {
        teacherClassList(List<TeacherClassModel>.from(
            response.data["items"].map((x) => TeacherClassModel.fromJson(x))));
        logI("Fetched ${teacherClassList.length} classes for teacher");
      } else {
        logE("No class data received from API");
        teacherClassList.clear();
      }
    } catch (e) {
      logE("Error fetching teacher classes: $e");
      teacherClassList.clear();
    } finally {
      isLoading(false);
    }
  }

  /// Get list of class names for dropdown
  List<String> get classDropdownItems {
    List<String> items = ["All"];
    items.addAll(teacherClassList
        .map((classItem) => classItem.className ?? "Unknown")
        .toList());
    return items;
  }

  /// Get list of unique grade names for dropdown
  List<String> get gradeDropdownItems {
    List<String> items = ["All"];
    Set<String> uniqueGrades = {};
    for (var classItem in teacherClassList) {
      if (classItem.gradeName != null && classItem.gradeName!.isNotEmpty) {
        uniqueGrades.add(classItem.gradeName!);
      }
    }
    items.addAll(uniqueGrades.toList()..sort());
    return items;
  }

  // /// Update selected class and refresh filtered data & analytics
  // Future<void> updateSelectedClass(String className) async {
  //   selectedClass.value = className;

  //   final selectedClassItem = classList.firstWhere(
  //       (c) => c.className == className,
  //       orElse: () => TeacherClassModel()
  //   );
  //   selectedClassId.value = selectedClassItem.classId ?? "";

  //   await fetchTeacherClassFilters(); // Refresh
  // }

  // Future<void> updateSelectedGrade(String gradeName) async {
  //   selectedGrade.value = gradeName;
  //   selectedGradeId.value = gradeNameIdMap[gradeName] ?? "";

  //   await fetchTeacherClassFilters(); // Refresh
  // }

  // Future<void> updateSelectedTermValue(String term) async {
  //   selectedTerm.value = term;
  //   await fetchTeacherClassFilters();
  // }

  /// Get average grade percentage across classes
  double get averageGradePercentage => avgGrade.value;

  /// Get average assignment time in hours
  double get averageAssignmentTimeHours => avgAssignmentTimeHours.value;

  /// Get monthly writing dashboard data for bar chart
  List<int> get monthlyWritingData =>
      aiUsageOverview.value?.monthlyWritingDashboard?.monthlyDataList ??
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  /// Get writing fingerprint alerts
  List<WritingFingerprintAlert> get writingFingerprintAlerts =>
      aiUsageOverview.value?.writingFingerprintAlerts ?? [];

  /// Check if there are any writing fingerprint alerts
  bool get hasWritingFingerprintAlerts => writingFingerprintAlerts.isNotEmpty;

  /// Get high priority alerts (high deviation)
  List<WritingFingerprintAlert> get highPriorityAlerts =>
      writingFingerprintAlerts
          .where((alert) => alert.alertLevel == 'high')
          .toList();

  /// Get writing fingerprint trend data
  WritingFingerprintTrend? get writingFingerprintTrend =>
      aiUsageOverview.value?.writingFingerprintTrend;

  /// Get trend data points for chart
  List<TrendDataPoint> get trendDataPoints =>
      writingFingerprintTrend?.series ?? [];

  /// Get monthly writing fingerprint alerts data for charts
  /// This simulates alert data based on writing activity with a typical alert rate
  List<int> get monthlyAlertsData {
    final writingData = monthlyWritingData;

    // Calculate alerts as approximately 15-25% of writing activity
    // This simulates realistic alert patterns based on writing fingerprint deviations
    const alertRate = 0.20; // 20% alert rate

    return writingData.map((count) => (count * alertRate).round()).toList();
  }
}
