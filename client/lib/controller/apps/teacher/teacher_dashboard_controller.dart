import 'package:binary_success/controller/my_controller.dart';
import 'package:binary_success/helpers/logger/logger.dart';
import 'package:binary_success/helpers/services/teacher_service.dart';
import 'package:binary_success/helpers/services/school_analytics_service.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:binary_success/models/teacher_classes_model_analytics.dart';
import 'package:binary_success/models/teachers_dashboard_model.dart';
import 'package:binary_success/models/teacher_dashboard_analytics_model.dart';
import 'package:binary_success/models/teacher_dashboard_model.dart';
import 'package:binary_success/models/ai_usage_overview_model.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get.dart';

class TeacherDashboardController extends MyController {
  RxInt selectedIndex = 1.obs;

  RxList<TeachersDashboardModel> teacherClassList =
      <TeachersDashboardModel>[].obs;
  RxList<WritingFingerprintAlert> writingFingerprintAlerts =
      <WritingFingerprintAlert>[].obs;

  // Loading states
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = "".obs;

  // AI Usage Overview data
  Rx<AiUsageOverviewModel?> aiUsageOverview = Rx<AiUsageOverviewModel?>(null);
  RxBool isAiUsageLoading = false.obs;
  RxBool hasAiUsageError = false.obs;
  RxString aiUsageErrorMessage = "".obs;
  RxString selectedPeriodBucket =
      'year'.obs; // for 'year', 'month', 'week' selection
  // Teacher Dashboard Analytics data
  Rx<TeacherDashboardAnalyticsModel?> teacherAnalytics =
      Rx<TeacherDashboardAnalyticsModel?>(null);
  RxBool isAnalyticsLoading = false.obs;
  RxBool hasAnalyticsError = false.obs;
  RxString analyticsErrorMessage = "".obs;

  // New Teacher Dashboard data (from new endpoint)
  Rx<TeacherDashboardModel?> teacherDashboard =
      Rx<TeacherDashboardModel?>(null);
  RxBool isDashboardLoading = false.obs;
  RxBool hasDashboardError = false.obs;
  RxString dashboardErrorMessage = "".obs;

  // Time range for analytics (default 30 days)
  RxInt timeRangeDays = 30.obs;
  RxString selectedTimeRange = "30d".obs;
  final RxList<TeacherClassModel> classList = <TeacherClassModel>[].obs;
  final Rx<ApiResponse?> fullApiResponse = Rx<ApiResponse?>(null);

  RxString selectedClass = "All".obs;
  RxString selectedClassId = "".obs;

// Fetch API and populate class dropdown only
  Future<void> fetchClassFilters() async {
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
      );

      if (response != null && response.success && response.data.isNotEmpty) {
        fullApiResponse.value = response;
        final teacher = response.data[0].teachers[0];

        // Populate classes with "All" on top
        classList.value = [
          TeacherClassModel(classId: '', className: 'All', gradeName: 'All'),
          ...teacher.classes.map((cls) {
            return TeacherClassModel(
              classId: cls.classId,
              className: cls.className,
              gradeId: cls.gradeId,
              gradeName: '',
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

// Apply filter (class only)
  void applyClassFilter() {
    if (fullApiResponse.value == null) return;
    final teacher = fullApiResponse.value!.data[0].teachers[0];

    List<TeacherClassModel> filtered = teacher.classes.map((cls) {
      return TeacherClassModel(
        classId: cls.classId,
        className: cls.className,
        gradeId: cls.gradeId,
        gradeName: '',
      );
    }).toList();

    classList.value = [
      TeacherClassModel(classId: '', className: 'All', gradeName: 'All'),
      ...filtered
    ];

    if (!classList.any((c) => c.className == selectedClass.value)) {
      selectedClass.value = 'All';
      selectedClassId.value = '';
    }
  }

  /// Handle errors
  void _handleError(String message) {
    logE("Error: $message"); // Log the error
    hasError(true);
    errorMessage(message);
    isLoading(false);
  }

// Class change handler
  Future<void> onClassChanged(String clsName) async {
    selectedClass.value = clsName;

    final cls = classList.firstWhere((c) => c.className == clsName,
        orElse: () => TeacherClassModel());
    selectedClassId.value = cls.classId ?? '';

    // Call API with updated filters
    await fetchClassFilters();

    // Fetch analytics overview filtered by new selections
    await fetchAiUsageOverview();
  }

  Future<void> getTeacherClassData() async {
    isLoading(true);
    final response = await TeacherService.getTeacherDashboardAPI();
    if (response != null) {
      teacherClassList(List<TeachersDashboardModel>.from(response.data["items"]
          .map((x) => TeachersDashboardModel.fromJson(x))));
    }
    isLoading(false);
  }

  /// Fetch AI usage overview data for teacher using email-based lookup
  Future<void> fetchAiUsageOverview() async {
    try {
      isAiUsageLoading(true);
      hasAiUsageError(false);
      aiUsageErrorMessage("");

      final userEmail = LocalStorage.getUserEmail();

      if (userEmail == null || userEmail.isEmpty) {
        _handleAiUsageError("User email not found. Please log in again.");
        return;
      }

      final result = await SchoolAnalyticsService.getAiUsageOverviewByEmail(
        email: userEmail,
        timeRangeDays: timeRangeDays.value,
        bucket: selectedPeriodBucket.value,
        classId:
            selectedClassId.value.isNotEmpty ? selectedClassId.value : null,
      );

      if (result != null) {
        aiUsageOverview(result);

        // After updating overview, fetch alerts using scopeId
        await fetchWritingFingerprintAlerts();

        isAiUsageLoading(false);
      } else {
        _handleAiUsageError(
            "Failed to fetch AI usage data for email: $userEmail");
      }
    } catch (e) {
      _handleAiUsageError("Error fetching AI usage data: $e");
    }
  }

  /// Handle AI usage errors
  void _handleAiUsageError(String message) {
    hasAiUsageError(true);
    aiUsageErrorMessage(message);
    isAiUsageLoading(false);
  }

  Future<void> fetchWritingFingerprintAlerts() async {
    final scopeId = aiUsageOverview.value?.scopeInfo?.scopeId ?? "";
    if (scopeId.isNotEmpty) {
      writingFingerprintAlerts.value =
          await TeacherService.getWritingFingerprintAlerts(teacherId: scopeId);
    }
  }

  /// Refresh AI usage data
  Future<void> refreshAiUsageData() async {
    await fetchAiUsageOverview();
  }

  /// Fetch teacher dashboard analytics data using email-based lookup
  Future<void> fetchTeacherAnalytics() async {
    try {
      isAnalyticsLoading(true);
      hasAnalyticsError(false);
      analyticsErrorMessage("");

      // Get user email from local storage
      final userEmail = LocalStorage.getUserEmail();

      if (userEmail == null || userEmail.isEmpty) {
        _handleAnalyticsError("User email not found. Please log in again.");
        return;
      }

      // Fetch teacher dashboard analytics data using email-based lookup
      final result = await TeacherService.getTeacherDashboardAnalyticsByEmail(
        email: userEmail,
        timeRangeDays: timeRangeDays.value,
        classId: null, // No class filter for teacher dashboard
      );

      if (result != null) {
        // Update teacher analytics data
        teacherAnalytics(result);
        isAnalyticsLoading(false);
      } else {
        _handleAnalyticsError("Failed to fetch teacher dashboard analytics");
      }
    } catch (e) {
      _handleAnalyticsError("Error fetching teacher analytics data: $e");
    }
  }

  /// Handle analytics errors
  void _handleAnalyticsError(String message) {
    hasAnalyticsError(true);
    analyticsErrorMessage(message);
    isAnalyticsLoading(false);
  }

  /// Refresh analytics data
  Future<void> refreshAnalyticsData() async {
    await fetchTeacherAnalytics();
  }

  /// Fetch teacher dashboard data using email-based lookup (new endpoint)
  Future<void> fetchTeacherDashboard() async {
    try {
      isDashboardLoading(true);
      hasDashboardError(false);
      dashboardErrorMessage("");

      // Get user email from local storage
      final userEmail = LocalStorage.getUserEmail();

      if (userEmail == null || userEmail.isEmpty) {
        _handleDashboardError("User email not found. Please log in again.");
        return;
      }

      // Fetch teacher dashboard data using the new endpoint
      final result = await TeacherService.getTeacherDashboardByEmail(
        email: userEmail,
      );

      if (result != null && result.success == true) {
        // Update teacher dashboard data
        teacherDashboard(result);
        isDashboardLoading(false);
      } else {
        _handleDashboardError("Failed to fetch teacher dashboard data");
      }
    } catch (e) {
      _handleDashboardError("Error fetching teacher dashboard data: $e");
    }
  }

  /// Handle dashboard errors
  void _handleDashboardError(String message) {
    hasDashboardError(true);
    dashboardErrorMessage(message);
    isDashboardLoading(false);
  }

  /// Refresh dashboard data
  Future<void> refreshDashboardData() async {
    await fetchTeacherDashboard();
  }

  /// Refresh all dashboard data
  Future<void> refreshAllData() async {
    await Future.wait([
      fetchTeacherDashboard(),
      fetchAiUsageOverview(),
      fetchTeacherAnalytics(),
    ]);
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

  String get writingFingerprintAverageDeviationTrendValue {
    final value = aiUsageOverview
            .value?.writingFingerprintAnalytics?.averageDeviationTrend ??
        "stable";
    print('Writing Fingerprint Average Deviation Trend: $value');
    return value.trim().toLowerCase();
  }

  String get writingFingerprintTotalTrendValue {
    final value =
        aiUsageOverview.value?.writingFingerprintAnalytics?.totalCountTrend ??
            "stable";
    print('Writing Fingerprint Total Trend: $value');
    return value.trim().toLowerCase();
  }

  String get aiPromptUsageAverageTrendValue {
    final value =
        aiUsageOverview.value?.aiPromptUsage?.averageUsageTrend ?? "stable";
    print('AI Prompt Usage Average Trend: $value');
    return value.trim().toLowerCase();
  }

  String get aiPromptUsageTotalTrendValue {
    final value =
        aiUsageOverview.value?.aiPromptUsage?.totalCountAiTrend ?? "stable";
    print('AI Prompt Usage Total Trend: $value');
    return value.trim().toLowerCase();
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

  /// Get monthly writing dashboard data for bar chart
  List<int> get monthlyWritingData =>
      aiUsageOverview.value?.monthlyWritingDashboard?.monthlyDataList ??
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  /// Get writing fingerprint alerts

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

  // Teacher Analytics Getters (using new endpoint data)

  /// Get pending submissions count (in review)
  int get pendingSubmissionsCount =>
      teacherDashboard.value?.data?.assignments?.inReviewCount ?? 0;

  /// Check if there are pending submissions awaiting review
  bool get hasPendingSubmissions => pendingSubmissionsCount > 0;

  /// Get graded this week count (total graded assignments)
  int get gradedThisWeekCount =>
      teacherDashboard.value?.data?.assignments?.gradedCount ?? 0;

  /// Get recently graded assignments (keeping empty list for compatibility)
  List<RecentlyGradedAssignment> get recentlyGradedAssignments => [];

  /// Get active students total count
  int get activeStudentsCount =>
      teacherDashboard.value?.data?.students?.totalStudents ?? 0;

  /// Get student grade-wise breakdown (keeping empty list for compatibility)
  List<TeacherGradeWiseBreakdown> get studentGradeBreakdown => [];

  /// Check if analytics data is available
  bool get hasAnalyticsData => teacherAnalytics.value != null;

  // New Teacher Dashboard Getters

  /// Get total assignments count
  int get totalAssignmentsCount =>
      teacherDashboard.value?.data?.assignments?.totalAssignments ?? 0;

  /// Get graded assignments count
  int get gradedAssignmentsCount =>
      teacherDashboard.value?.data?.assignments?.gradedCount ?? 0;

  /// Get assignments in review count
  int get inReviewAssignmentsCount =>
      teacherDashboard.value?.data?.assignments?.inReviewCount ?? 0;

  /// Get total students count
  int get totalStudentsCount =>
      teacherDashboard.value?.data?.students?.totalStudents ?? 0;

  /// Check if dashboard data is available
  bool get hasDashboardData => teacherDashboard.value != null;

  /// Get teacher email from dashboard data
  String get teacherEmail => teacherDashboard.value?.data?.teacherEmail ?? "";

  /// Update time range and refresh data
  Future<void> updateTimeRange(String timeRangeText) async {
    selectedTimeRange(timeRangeText);

    // Convert time range text to days
    switch (timeRangeText) {
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

    // Refresh data with new time range
    await fetchAiUsageOverview();
    await fetchTeacherAnalytics();
    await fetchTeacherDashboard();
  }

  @override
  void onInit() {
    fetchClassFilters(); // Fetch class filters on initialization
    getTeacherClassData();
    fetchAiUsageOverview(); // Fetch AI usage data on initialization
    fetchTeacherAnalytics(); // Fetch teacher analytics data on initialization
    fetchTeacherDashboard(); // Fetch teacher dashboard data on initialization
    super.onInit();
  }
}
