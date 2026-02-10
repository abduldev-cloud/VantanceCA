import 'package:binary_success/controller/my_controller.dart';
import 'package:binary_success/helpers/services/school_analytics_service.dart';
import 'package:binary_success/helpers/services/notification_service.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:binary_success/helpers/network/api_service.dart';
import 'package:binary_success/helpers/constant/app_constant.dart';
import 'package:binary_success/models/school_dashboard_analytics_model.dart';
import 'package:binary_success/models/ai_usage_overview_model.dart';
import 'package:binary_success/models/notification_model.dart';
import 'package:binary_success/models/school_class_model.dart';
import 'package:binary_success/models/teacher_classes_model_analytics.dart';
import 'package:get/get.dart';

class SchoolDashboardController extends MyController {
  // Loading states
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = "".obs;
  RxString selectedPeriodBucket = 'year'.obs;
  // Analytics data
  Rx<SchoolDashboardAnalyticsModel?> analyticsData =
      Rx<SchoolDashboardAnalyticsModel?>(null);
  final Rx<ApiResponse?> fullApiResponse = Rx<ApiResponse?>(null);

  // Individual data sections for easy access
  Rx<Assignments?> assignments = Rx<Assignments?>(null);
  Rx<ActiveTeachers?> activeTeachers = Rx<ActiveTeachers?>(null);
  Rx<ActiveStudents?> activeStudents = Rx<ActiveStudents?>(null);

  // New analytics data from our endpoints
  RxString instituteId = "".obs;
  RxInt totalStudents = 0.obs;
  RxInt totalTeachers = 0.obs;
  RxInt totalAssignmentSubmissions = 0.obs;
  RxInt gradedAssignments = 0.obs;
  RxInt inReviewAssignments = 0.obs;

  // AI Usage Overview data
  Rx<AiUsageOverviewModel?> aiUsageOverview = Rx<AiUsageOverviewModel?>(null);

  // Performance metrics data (from new endpoint)
  RxDouble avgGrade = 0.0.obs;
  RxDouble avgAssignmentTimeHours = 0.0.obs;
  RxBool hasLoadedPerformanceMetrics = false.obs;

  // Notifications data
  RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  RxBool isLoadingNotifications = false.obs;

  // School classes data
  RxList<SchoolClassModel> schoolClasses = <SchoolClassModel>[].obs;
  RxBool isLoadingClasses = false.obs;

  // Configuration
  RxInt timeRangeDays = 30.obs;
  RxString selectedClassId = "".obs;
  RxString selectedClassName = "All Classes".obs;
  RxString selectedTimeRange = "Last 30 days".obs;

  final RxList<TeacherClassModel> classList = <TeacherClassModel>[].obs;
  RxString selectedClass = "All".obs;
  // Filter options
  List<String> get timeRangeOptions => ["7d", "14d", "30d", "Term 1"];

  @override
  void onInit() {
    super.onInit();
    fetchNewSchoolAnalytics(); // Use new analytics endpoints
    fetchSchoolClasses();
    fetchAiUsageOverview(); // Fetch AI usage data
    fetchPerformanceMetrics(); // Fetch performance metrics
    fetchNotifications();
    fetchSchoolClassFilters(); // Fetch notifications
  }

  /// Fetch school analytics using simple two-step API flow
  Future<void> fetchNewSchoolAnalytics() async {
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

      print("🔄 Fetching school analytics for email: $userEmail");

      // STEP 1: Get institute ID by email
      print("📧 Step 1: Getting institute ID for email: $userEmail");
      final encodedEmail = Uri.encodeComponent(userEmail);
      final instituteResponse = await APIService.get(
        path: "/analytics/institute-by-email/$encodedEmail",
        forcedBaseUrl: API.baseURl,
        withOutAuth: true,
      );

      if (instituteResponse == null ||
          instituteResponse.statusCode != 200 ||
          instituteResponse.data == null ||
          instituteResponse.data['success'] != true) {
        _handleError("Could not find institute for email: $userEmail");
        return;
      }

      final instituteId = instituteResponse.data['data']['institute_id'];
      print("✅ Found institute ID: $instituteId");

      // STEP 2: Get school analytics by institute ID
      print("🏫 Step 2: Getting school analytics for institute: $instituteId");
      final analyticsResponse = await APIService.get(
        path: "/analytics/school-analytics/$instituteId",
        forcedBaseUrl: API.baseURl,
        withOutAuth: true,
      );

      // Print raw backend response
      print("═══════════════════════════════════════════════════════════════");
      print(
          "🔍 RAW BACKEND RESPONSE from /analytics/school-analytics/$instituteId:");
      print("Response Type: ${analyticsResponse.runtimeType}");
      print("Response: ${analyticsResponse.data}");
      print("═══════════════════════════════════════════════════════════════");

      if (analyticsResponse == null ||
          analyticsResponse.statusCode != 200 ||
          analyticsResponse.data == null ||
          analyticsResponse.data['success'] != true) {
        _handleError("Could not fetch analytics for institute: $instituteId");
        return;
      }

      // Update the analytics data
      final data = analyticsResponse.data['data'];
      print("📊 Parsed Analytics data: $data");

      this.instituteId(data['institute_id'] ?? "");
      totalStudents(data['total_students'] ?? 0);
      totalTeachers(data['total_teachers'] ?? 0);

      // Update assignment data
      final assignmentsData = data['assignments'];
      if (assignmentsData != null) {
        totalAssignmentSubmissions(assignmentsData['total_submissions'] ?? 0);

        final statusBreakdown = assignmentsData['status_breakdown'];
        if (statusBreakdown != null) {
          gradedAssignments(statusBreakdown['GRADED'] ?? 0);
          inReviewAssignments(statusBreakdown['IN_REVIEW'] ?? 0);
        }
      }

      hasError(false);
      print("✅ Successfully loaded analytics data");
      update();
    } catch (e) {
      print("❌ Error loading analytics: $e");
      _handleError("Error loading analytics: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshAiUsageData() async {
    await fetchAiUsageOverview();
  }

  Future<void> fetchSchoolClassFilters() async {
    print("fetchSchoolClassFilters called");
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final instituteId = LocalStorage.getDBInstituteID() ?? '';
      print("Institute ID from LocalStorage: $instituteId");

      if (instituteId.isEmpty) {
        _handleError("Institute ID not found. Please log in again.");
        return;
      }

      final response = await SchoolAnalyticsService.getSchoolClassFilters(
        instituteId: instituteId,
        className: selectedClass.value != "All" ? selectedClass.value : null,
      );

      if (response != null && response.success && response.data.isNotEmpty) {
        fullApiResponse.value = response;

        List<TeacherClassModel> classes = [];

        // Extract classId and className properly for each class from all teachers
        for (var teacher in response.data[0].teachers) {
          for (var cls in teacher.classes) {
            if (cls.className != null) {
              classes.add(TeacherClassModel(
                classId: cls.classId,
                className: cls.className,
                gradeName: null,
              ));
            }
          }
        }

        // Assign distinct classes avoiding duplicates by classId
        final uniqueClasses = <String, TeacherClassModel>{};
        for (var c in classes) {
          uniqueClasses[c.classId!] = c;
        }
        classList.assignAll(uniqueClasses.values.toList());

        print(
            "Classes: ${uniqueClasses.values.map((c) => c.className).toList()}");

        if (!classList.any((c) => c.className == selectedClass.value)) {
          selectedClass.value = "All";
          selectedClassId.value = '';
        } else {
          final selected =
              classList.firstWhere((c) => c.className == selectedClass.value);
          selectedClassId.value = selected.classId ?? '';
        }

        isLoading.value = false;
      } else {
        _handleError('No data available or API success false.');
      }
    } catch (e) {
      _handleError('Failed to load filters: $e');
    }
  }

  Future<void> onClassChanged(String clsName) async {
    selectedClass.value = clsName;
    final cls = classList.firstWhere(
      (c) => c.className == clsName,
      orElse: () => TeacherClassModel(classId: '', className: 'All'),
    );
    selectedClassId.value = cls.classId ?? '';

    await fetchAiUsageOverview();
  }

  /// Fetch AI usage overview using email-based lookup
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

      final result =
          await SchoolAnalyticsService.getAiUsageOverviewForInstituteAdmin(
        email: userEmail,
        timeRangeDays: timeRangeDays.value,
        bucket: selectedPeriodBucket.value,
        classId:
            selectedClassId.value.isNotEmpty ? selectedClassId.value : null,
        // other filters can be added here
      );

      print("Selected Class ID: ${selectedClassId.value}");

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

  /// Fetch school dashboard analytics data using email-based lookup (legacy method)
  Future<void> fetchSchoolDashboardAnalytics() async {
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

      // Fetch analytics data using email-based lookup
      final result =
          await SchoolAnalyticsService.getSchoolDashboardAnalyticsByEmail(
        email: userEmail,
        timeRangeDays: timeRangeDays.value,
        classId: selectedClassId.value.isEmpty ? null : selectedClassId.value,
      );

      if (result != null) {
        // Update analytics data
        analyticsData(result);

        // Update individual sections for easy access
        assignments(result.assignments);
        activeTeachers(result.activeTeachers);
        activeStudents(result.activeStudents);

        hasError(false);
      } else {
        _handleError("Failed to load analytics data for email: $userEmail");
      }
    } catch (e) {
      _handleError("Error loading analytics: $e");
    } finally {
      isLoading(false);
    }
  }

  /// AI usage functionality removed - all analytics now come from school-analytics endpoint

  /// Handle errors
  void _handleError(String message) {
    hasError(true);
    errorMessage(message); // Use the specific error message directly

    // Set default empty data
    analyticsData(null);
    assignments(null);
    activeTeachers(null);
    activeStudents(null);
  }

  /// Refresh analytics data
  Future<void> refreshAnalytics() async {
    await fetchNewSchoolAnalytics(); // Use new analytics method
  }

  /// Fetch school classes for dropdown using simple API calls
  Future<void> fetchSchoolClasses() async {
    try {
      isLoadingClasses(true);

      final userEmail = LocalStorage.getUserEmail();
      if (userEmail == null || userEmail.isEmpty) {
        print("No user email found - school classes will not be available");
        return;
      }

      print("🔄 Fetching school classes for email: $userEmail");

      // STEP 1: Get institute ID by email
      final encodedEmail = Uri.encodeComponent(userEmail);
      final instituteResponse = await APIService.get(
        path: "/analytics/institute-by-email/$encodedEmail",
        forcedBaseUrl: API.baseURl,
        withOutAuth: true,
      );

      if (instituteResponse == null || instituteResponse['success'] != true) {
        print("Could not find institute for classes");
        return;
      }

      final instituteId = instituteResponse['data']['institute_id'];
      print("✅ Found institute ID for classes: $instituteId");

      // STEP 2: Fetch classes using the service (this part can stay as is)
      final classes = await SchoolAnalyticsService.getSchoolClasses(
        schoolId: instituteId,
      );

      schoolClasses(classes);
      print("✅ Successfully fetched ${classes.length} school classes");
    } catch (e) {
      print("⚠️ Error fetching school classes: $e");
    } finally {
      isLoadingClasses(false);
    }
  }

  /// AI usage overview functionality removed

  /// Update class filter and refresh data
  void updateClassFilter(String classId, String className) {
    if (classId != selectedClassId.value) {
      selectedClassId(classId);
      selectedClassName(className);
      fetchNewSchoolAnalytics(); // Use new analytics method
    }
  }

  /// Clear class filter
  void clearClassFilter() {
    updateClassFilter("", "All Classes");
  }

  /// Get class dropdown options
  List<String> get classDropdownOptions {
    List<String> options = ["All Classes"];
    options
        .addAll(schoolClasses.map((cls) => cls.className ?? "Unknown Class"));
    return options;
  }

  /// Get class ID by class name
  String getClassIdByName(String className) {
    if (className == "All Classes") return "";

    final selectedClass = schoolClasses.firstWhere(
      (cls) => cls.className == className,
      orElse: () => SchoolClassModel(),
    );

    return selectedClass.classId ?? "";
  }

  /// Get assignments pending review count (use new data if available, fallback to legacy)
  int get pendingReviewCount => inReviewAssignments.value > 0
      ? inReviewAssignments.value
      : assignments.value?.pendingReviewCount ?? 0;

  /// Get assignments graded count (use new data if available, fallback to legacy)
  int get gradedCount => gradedAssignments.value > 0
      ? gradedAssignments.value
      : assignments.value?.gradedCount ?? 0;

  /// Get active teachers total count (use new data if available, fallback to legacy)
  int get activeTeachersCount => totalTeachers.value > 0
      ? totalTeachers.value
      : activeTeachers.value?.totalCount ?? 0;

  /// Get active students total count (use new data if available, fallback to legacy)
  int get activeStudentsCount => totalStudents.value > 0
      ? totalStudents.value
      : activeStudents.value?.totalCount ?? 0;

  /// Get teacher grade-wise breakdown
  List<TeacherGradeWiseBreakdown> get teacherGradeBreakdown =>
      activeTeachers.value?.gradeWiseBreakdown ?? [];

  /// Get student grade-wise breakdown
  List<GradeWiseBreakdown> get studentGradeBreakdown =>
      activeStudents.value?.gradeWiseBreakdown ?? [];

  /// Check if data is available
  bool get hasData => analyticsData.value != null;

  /// Check if any section has data
  bool get hasAnyData =>
      assignments.value != null ||
      activeTeachers.value != null ||
      activeStudents.value != null;

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

  /// Fetch performance metrics data for institute admin
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

      // Fetch performance metrics using the institute admin endpoint
      final result =
          await SchoolAnalyticsService.getPerformanceMetricsForInstituteAdmin(
        email: userEmail,
        timeRangeDays: timeRangeDays.value,
        classId: selectedClassId.value.isEmpty ? null : selectedClassId.value,
      );

      if (result != null && result['success'] == true) {
        // Extract performance metrics from the new response format
        final data = result['data'];
        final performanceMetricsData = data?['performance_metrics'];

        if (performanceMetricsData != null) {
          final avgGradeValue =
              performanceMetricsData['avg_grade']?.toDouble() ?? 0.0;
          final avgTimeHours =
              performanceMetricsData['avg_assignment_time_hours']?.toDouble() ??
                  0.0;

          // Store the values for reactive getters
          avgGrade(avgGradeValue);
          avgAssignmentTimeHours(avgTimeHours);
          hasLoadedPerformanceMetrics(true);

          print(
              "✅ Performance metrics updated: Grade=$avgGradeValue, Time=${avgTimeHours}h");
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
    }
  }

  /// Get average grade percentage
  double get averageGradePercentage => avgGrade.value;

  /// Get average assignment time in hours
  double get averageAssignmentTimeHours => avgAssignmentTimeHours.value;

  /// Check if performance metrics data is available
  bool get hasPerformanceMetricsData => hasLoadedPerformanceMetrics.value;

  /// Get monthly writing dashboard data for bar chart
  List<int> get monthlyWritingData =>
      aiUsageOverview.value?.monthlyWritingDashboard?.monthlyDataList ??
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

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
  }

  /// Fetch notifications for the current user
  Future<void> fetchNotifications() async {
    try {
      isLoadingNotifications(true);

      // Get user email from local storage
      final userEmail = LocalStorage.getUserEmail();
      if (userEmail == null || userEmail.isEmpty) {
        print("No user email found - notifications will not be available");
        return;
      }

      print("🔄 Fetching notifications for email: $userEmail");

      // Use the notification service to fetch notifications by email
      final notificationService = NotificationService();
      final notificationsList =
          await notificationService.fetchNotificationsByEmail(
        email: userEmail,
      );

      notifications(notificationsList);
      print("✅ Successfully fetched ${notificationsList.length} notifications");
    } catch (e) {
      print("❌ Error fetching notifications: $e");
      notifications.clear();
    } finally {
      isLoadingNotifications(false);
    }
  }

  /// Refresh all analytics data
  Future<void> refreshAllAnalytics() async {
    await Future.wait([
      fetchNewSchoolAnalytics(),
      fetchAiUsageOverview(),
      fetchPerformanceMetrics(),
      fetchNotifications(),
    ]);
  }
}
