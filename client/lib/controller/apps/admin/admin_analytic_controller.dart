import 'package:binary_success/models/teacher_classes_model_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:binary_success/controller/my_controller.dart';
import 'package:binary_success/helpers/services/school_analytics_service.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:binary_success/helpers/constant/app_constant.dart';
import 'package:binary_success/models/ai_usage_overview_model.dart';
import 'package:binary_success/models/school_performance_metrics_model.dart';
import 'package:collection/collection.dart';

class AdminAnalyticController extends MyController {
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

  Rx<ApiResponse?> fullApiResponse = Rx<ApiResponse?>(null);

  // Performance metrics reactive variables (for platform admin)
  double _avgGrade = 0.0;
  double _avgAssignmentTimeHours = 0.0;
  bool _hasLoadedPerformanceMetrics = false;

  // Time range for analytics (default 30 days)
  RxInt timeRangeDays = 30.obs;

  // Custom date range properties
  RxBool isCustomDateRange = false.obs;
  Rx<DateTime?> customStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> customEndDate = Rx<DateTime?>(null);

  // Filter properties
  RxString selectedInstitute = 'All'.obs;
  RxString selectedTeacher = "All".obs;
  RxString selectedClass = "All".obs;
  RxString selectedGrade = "All".obs;
  RxString selectedGradeId = "All".obs;
  RxString selectedTimeRange = "30d".obs;
  RxString selectedClassId = "".obs;
  RxString selectedPeriodBucket = 'year'.obs;
  final selectedTeacherId = RxString("");

// Reactive dropdown option lists
  final RxList<String> schoolList = <String>['All'].obs;
  final RxList<String> teacherList = <String>['All'].obs;
  final RxList<TeacherClassModel> classList = <TeacherClassModel>[].obs;
  final RxList<String> gradeList = <String>['All'].obs;

  // Dynamic filter options from database
  final RxList<String> _classOptions = <String>["All"].obs;
  final RxList<String> _teacherOptions = <String>["All"].obs;
  final RxList<String> _gradeOptions = <String>["All"].obs;
  final RxList<String> _schoolOptions = <String>["All"].obs;

  // Maps to store name to ID mappings if needed
  Map<String, String> instituteNameIdMap = {};
  Map<String, String> teacherNameIdMap = {};
  Map<String, String> gradeNameIdMap = {};

  // Filter options getters
  List<String> get schoolOptions => _schoolOptions.toList();
  List<String> get teacherOptions => _teacherOptions.value;
  List<String> get classOptions => _classOptions.value;
  List<String> get gradeOptions => _gradeOptions.value;
  List<String> get timeRangeOptions => ["7d", "14d", "30d", "Term 1"];

  @override
  void onInit() {
    super.onInit();
    // Fetch data on initialization
    fetchAiUsageOverview();
    fetchPerformanceMetrics();
    fetchAllFilterOptions();
    fetchadminClassFilters();
  }

  Future<void> fetchadminClassFilters({String? skipReset}) async {
    print("fetchadminClassFilters called for platform admin");
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // Pass selected filters to API as you already do

      final response = await SchoolAnalyticsService.getAdminClassFilters(
        gradeId:
            selectedGradeId.value.isNotEmpty && selectedGradeId.value != 'All'
                ? selectedGradeId.value
                : null,
        instituteId: instituteNameIdMap[selectedInstitute.value],
        teacherId: teacherNameIdMap[selectedTeacher.value],
        className: selectedClass.value != "All" ? selectedClass.value : null,
      );

      if (response != null && response.success && response.data.isNotEmpty) {
        fullApiResponse.value = response;
        final data = response.data;

        Set<String> instituteNames = {'All'};
        Map<String, String> instNameIdMapLocal = {};
        Set<String> teacherNames = {'All'};
        Map<String, String> teacherNameIdMapLocal = {};
        Set<String> gradeNames = {'All'};
        Map<String, String> gradeNameIdMapLocal = {};
        Set<String> classNames = {'All'};

        for (var inst in data) {
          if (selectedInstitute.value == 'All' ||
              inst.instituteName == selectedInstitute.value) {
            instituteNames.add(inst.instituteName);
            instNameIdMapLocal[inst.instituteName] = inst.instituteId;

            for (var teacher in inst.teachers) {
              if (selectedTeacher.value == 'All' ||
                  teacher.teacherName == selectedTeacher.value) {
                teacherNames.add(teacher.teacherName);
                teacherNameIdMapLocal[teacher.teacherName] = teacher.teacherId;

                for (var grade in teacher.grades) {
                  if (selectedGrade.value == 'All' ||
                      grade.gradeName == selectedGrade.value) {
                    gradeNames.add(grade.gradeName);
                    gradeNameIdMapLocal[grade.gradeName] = grade.gradeId;
                  }
                }

                for (var cls in teacher.classes) {
                  if (selectedClass.value == 'All' ||
                      cls.className == selectedClass.value) {
                    classNames.add(cls.className);
                  }
                }
              }
            }
          }
        }

        _schoolOptions.assignAll(instituteNames.toList());
        schoolList.assignAll(instituteNames.toList());
        instituteNameIdMap = instNameIdMapLocal;

        teacherList.assignAll(teacherNames.toList());
        teacherNameIdMap = teacherNameIdMapLocal;

        gradeList.assignAll(gradeNames.toList());
        gradeNameIdMap = gradeNameIdMapLocal;

        classList.value = [
          TeacherClassModel(classId: '', className: 'All', gradeName: 'All'),
          ...data
              .expand((inst) => inst.teachers)
              .expand((t) => t.classes)
              .where((cls) => classNames.contains(cls.className))
              .map((cls) => TeacherClassModel(
                    classId: cls.classId,
                    className: cls.className,
                    gradeId: cls.gradeId,
                    gradeName: '', // optional
                  )),
        ];

        // Reset selections if current selected value for dropdown NOT equal to skipReset is invalid
        if (skipReset != 'institute' &&
            !schoolList.contains(selectedInstitute.value)) {
          selectedInstitute.value = 'All';
        }
        if (skipReset != 'teacher' &&
            !teacherList.contains(selectedTeacher.value)) {
          selectedTeacher.value = 'All';
        }
        if (skipReset != 'grade' && !gradeList.contains(selectedGrade.value)) {
          selectedGrade.value = 'All';
        }
        if (skipReset != 'class' &&
            !classList.any((c) => c.className == selectedClass.value)) {
          selectedClass.value = 'All';
        }

        isLoading.value = false;
      } else {
        _handleError("No data returned or API failure.");
        isLoading.value = false;
      }
    } catch (e) {
      _handleError("Failed to load filters: $e");
      isLoading.value = false;
    }
  }

// Now update each onChange handler to tell fetchadminClassFilters which dropdown triggered reset skipping

  Future<void> onTeacherChanged(String teacher) async {
    selectedTeacher.value = teacher;
    selectedTeacherId.value = teacherNameIdMap[teacher] ?? '';
    await fetchadminClassFilters(skipReset: 'teacher');
    await fetchAiUsageOverview();
  }

  Future<void> onGradeChanged(String grade) async {
    selectedGrade.value = grade;
    selectedGradeId.value = gradeNameIdMap[grade] ?? '';
    await fetchadminClassFilters(skipReset: 'grade');
    await fetchAiUsageOverview();
  }

  Future<void> onInstituteChanged(String institute) async {
    selectedInstitute.value = institute;
    await fetchadminClassFilters(skipReset: 'institute');
    await fetchAiUsageOverview();
  }

  Future<void> onClassChanged(String className) async {
    selectedClass.value = className;
    final cls = classList.firstWhereOrNull((c) => c.className == className);
    selectedClassId.value = cls?.classId ?? '';
    await fetchadminClassFilters(skipReset: 'class');
    await fetchAiUsageOverview();
  }

  /// Fetch AI usage overview data for platform admin (platform-wide data)
  Future<void> fetchAiUsageOverview() async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage("");

      print(
          "🔄 AdminAnalyticController: Fetching AI usage overview for platform admin...");
      print("📊 Using timeRangeDays: ${timeRangeDays.value}");
      print("📊 Current selectedTimeRange: ${selectedTimeRange.value}");

      // Fetch platform-wide AI usage overview data using the correct platform admin method
      final result =
          await SchoolAnalyticsService.getAiUsageOverviewForPlatformAdmin(
        timeRangeDays: timeRangeDays.value,
        bucket: selectedPeriodBucket.value,
        classId:
            selectedClassId.value.isNotEmpty ? selectedClassId.value : null,
        gradeLevelId:
            selectedGradeId.value.isNotEmpty ? selectedGradeId.value : null,
        teacherId: selectedTeacherId.value.isNotEmpty &&
                selectedTeacherId.value != "All"
            ? selectedTeacherId.value
            : null,
        instituteId:
            instituteNameIdMap[selectedInstitute.value]?.isNotEmpty == true
                ? instituteNameIdMap[selectedInstitute.value]
                : null,
      );

      print(
          "📊 AI Usage API call completed with timeRangeDays: ${timeRangeDays.value}");

      if (result != null) {
        // Update AI usage overview data
        aiUsageOverview(result);
        print("✅ Admin AI usage overview updated successfully!");
        isLoading(false);
        update(); // Trigger UI rebuild
      } else {
        _handleError("Failed to fetch platform AI usage data");
      }
    } catch (e) {
      _handleError("Error fetching AI usage data: $e");
    }
  }

  /// Fetch performance metrics data for platform admin
  Future<void> fetchPerformanceMetrics() async {
    try {
      print(
          "🔄 AdminAnalyticController: Starting fetchPerformanceMetrics for platform admin...");
      print("📊 Using timeRangeDays: ${timeRangeDays.value}");

      print(
          "📊 Admin calling SchoolAnalyticsService.getPerformanceMetricsForPlatformAdmin...");
      // Fetch performance metrics data using platform admin endpoint
      final result =
          await SchoolAnalyticsService.getPerformanceMetricsForPlatformAdmin(
        timeRangeDays: timeRangeDays.value,
      );

      if (result != null && result['success'] == true) {
        // Extract performance metrics from the response
        final data = result['data'];
        final performanceMetricsData = data?['performance_metrics'];

        if (performanceMetricsData != null) {
          // Create a simple performance metrics model for compatibility
          final avgGrade =
              performanceMetricsData['avg_grade']?.toDouble() ?? 0.0;
          final avgTimeHours =
              performanceMetricsData['avg_assignment_time_hours']?.toDouble() ??
                  0.0;

          print("✅ Admin performance metrics updated successfully!");
          print("📈 Admin Grade Average: $avgGrade");
          print("⏱️  Admin Assignment Time: ${avgTimeHours}h");

          // Store the values for reactive getters
          _avgGrade = avgGrade;
          _avgAssignmentTimeHours = avgTimeHours;
          _hasLoadedPerformanceMetrics = true;
          update(); // Trigger UI rebuild
        } else {
          print("❌ Invalid performance metrics data format");
        }
      } else {
        print("❌ Failed to fetch performance metrics for platform admin");
      }
    } catch (e) {
      print("💥 Admin error fetching performance metrics: $e");
    }
  }

  /// Handle errors
  void _handleError(String message) {
    hasError(true);
    errorMessage(message);
    isLoading(false);
  }

  /// Refresh AI usage data
  Future<void> refreshAiUsageData() async {
    await fetchAiUsageOverview();
  }

  /// Refresh performance metrics data
  Future<void> refreshPerformanceMetrics() async {
    await fetchPerformanceMetrics();
  }

  /// Fetch all filter options from database using the combined endpoint
  Future<void> fetchAllFilterOptions() async {
    try {
      print(
          "🔄 AdminAnalyticController: Fetching all filter options from database...");

      // Use the new combined endpoint for better performance (single API call)
      final filterOptions =
          await SchoolAnalyticsService.getAllFilterOptionsForAnalytics();

      final classes = filterOptions['classes'] ?? ['All'];
      final teachers = filterOptions['teachers'] ?? ['All'];
      final grades = filterOptions['grades'] ?? ['All'];
      final schools = filterOptions['schools'] ?? ['All'];

      // Update all filter options - always use backend data, no fallback logic
      _classOptions.value = classes;
      _teacherOptions.value = teachers;
      _gradeOptions.value = grades;
      _schoolOptions.value = schools;

      print("✅ All filter options updated from backend:");
      print("📋 Classes: ${classes.length} items - ${classes.join(', ')}");
      print("📋 Teachers: ${teachers.length} items - ${teachers.join(', ')}");
      print("📋 Grades: ${grades.length} items - ${grades.join(', ')}");
      print("📋 Schools: ${schools.length} items - ${schools.join(', ')}");

      if (classes.length == 1 && classes[0] == "All") {
        print(
            "⚠️ Classes: Only 'All' option available - no database data found");
      }
      if (teachers.length == 1 && teachers[0] == "All") {
        print(
            "⚠️ Teachers: Only 'All' option available - no database data found");
      }
      if (grades.length == 1 && grades[0] == "All") {
        print(
            "⚠️ Grades: Only 'All' option available - no database data found");
      }
      if (schools.length == 1 && schools[0] == "All") {
        print(
            "⚠️ Schools: Only 'All' option available - no database data found");
      }
    } catch (e) {
      print("❌ Error fetching filter options: $e");
      // Set to minimal options on error - no hardcoded fallbacks
      _classOptions.value = ["All"];
      _teacherOptions.value = ["All"];
      _gradeOptions.value = ["All"];
      _schoolOptions.value = ["All"];
      print("🚨 Filter options reset to minimal state due to error");
    }
  }

  /// Refresh all analytics data
  Future<void> refreshAllData() async {
    await fetchAiUsageOverview();
    await fetchPerformanceMetrics();
    await fetchAllFilterOptions();
  }

  /// Manual method to test and refresh only filter options
  Future<void> testAndRefreshFilters() async {
    print("🧪 Testing filter options manually...");
    print("🔗 Using API base URL: ${API.baseURl}");
    await fetchAllFilterOptions();
    print("🧪 Filter options test completed");
    print("📋 Current school options: $schoolOptions");
    print("📋 Current teacher options: $teacherOptions");
    print("📋 Current class options: $classOptions");
    print("📋 Current grade options: $gradeOptions");
  }

  /// Force refresh all filters (can be called from UI)
  void forceRefreshFilters() {
    print("🔄 Force refreshing all filters...");
    fetchAllFilterOptions();
  }

  // // Filter update methods
  // void updateSchoolFilter(String school) {
  //   selectedInstitute(school);
  //   _applyFiltersAndRefresh();
  // }

  // void updateTeacherFilter(String teacher) {
  //   selectedTeacher(teacher);
  //   _applyFiltersAndRefresh();
  // }

  // void updateClassFilter(String classValue) {
  //   selectedClass(classValue);
  //   _applyFiltersAndRefresh();
  // }

  // void updateGradeFilter(String grade) {
  //   selectedGrade(grade);
  //   _applyFiltersAndRefresh();
  // }

  void updateTimeRangeFilter(String timeRange) {
    print(
        "🔄 AdminAnalyticController: updateTimeRangeFilter called with: $timeRange");
    print("📊 Previous timeRangeDays: ${timeRangeDays.value}");
    print("📊 Previous selectedTimeRange: ${selectedTimeRange.value}");

    selectedTimeRange(timeRange);

    // Update timeRangeDays based on selection
    switch (timeRange) {
      case "7d":
        timeRangeDays(7);
        isCustomDateRange(false);
        print("📅 Set time range to 7 days");
        break;
      case "14d":
        timeRangeDays(14);
        isCustomDateRange(false);
        print("📅 Set time range to 14 days");
        break;
      case "30d":
        timeRangeDays(30);
        isCustomDateRange(false);
        print("📅 Set time range to 30 days");
        break;
      case "Term 1":
        // Hard code Term 1: Aug 1st - Dec 31st (approximately 153 days)
        timeRangeDays(153);
        isCustomDateRange(false);
        print("📅 Set time range to Term 1 (153 days)");
        break;
      default:
        timeRangeDays(30);
        isCustomDateRange(false);
        print("📅 Set time range to default 30 days");
    }

    print("📊 New timeRangeDays: ${timeRangeDays.value}");
    print("📊 New selectedTimeRange: ${selectedTimeRange.value}");
    print("🔄 Calling _applyFiltersAndRefresh()...");

    // Force UI update to show the time range change
    update();

    _applyFiltersAndRefresh();
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

    _applyFiltersAndRefresh();
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

  /// Apply current filters and refresh data
  void _applyFiltersAndRefresh() {
    print("🔄 AdminAnalyticController: _applyFiltersAndRefresh() called");
    print("📊 Current timeRangeDays: ${timeRangeDays.value}");
    print("📊 Current selectedTimeRange: ${selectedTimeRange.value}");

    // Clear old data first to show loading state
    aiUsageOverview(null);
    _hasLoadedPerformanceMetrics = false;
    _avgGrade = 0.0;
    _avgAssignmentTimeHours = 0.0;

    // Force UI update to show cleared state
    update();

    print(
        "🔄 Starting data refresh with timeRangeDays: ${timeRangeDays.value}");

    // Refresh data with current filters
    fetchAiUsageOverview();
    fetchPerformanceMetrics();
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

  /// Get current time range display string
  String get currentTimeRangeDisplay =>
      "${selectedTimeRange.value} (${timeRangeDays.value} days)";

  /// Get time range text for KPI cards
  String get timeRangeTextForKPIs {
    switch (selectedTimeRange.value) {
      case "7d":
        return "last 7 days";
      case "14d":
        return "last 14 days";
      case "30d":
        return "last 30 days";
      case "Term 1":
        return "Term 1";
      default:
        return "last 30 days";
    }
  }

  /// Get overall grade average as percentage (from performance metrics)
  double get gradeAveragePercentage => _avgGrade;

  /// Get assignment time average in hours (from performance metrics)
  double get assignmentTimeAverageHours => _avgAssignmentTimeHours;

  /// Check if performance metrics data is available
  bool get hasPerformanceMetricsData => _hasLoadedPerformanceMetrics;

  /// Get monthly writing data for charts
  List<int> get monthlyWritingData {
    final monthlyData = aiUsageOverview.value?.monthlyWritingDashboard;
    if (monthlyData == null) return List.filled(12, 0);

    return List.generate(
      12,
      (index) => monthlyData.monthlyDataList.length > index
          ? monthlyData.monthlyDataList[index]
          : 0,
    );
  }

  /// Get monthly writing fingerprint alerts data for charts
  /// This simulates alert data based on writing activity with a typical alert rate
  List<int> get monthlyAlertsData {
    final monthlyData = aiUsageOverview.value?.monthlyWritingDashboard;
    if (monthlyData == null) return List.filled(12, 0);

    // Calculate alerts as approximately 15-25% of writing activity
    // This simulates realistic alert patterns based on writing fingerprint deviations
    const alertRate = 0.20; // 20% alert rate

    return List.generate(
      12,
      (index) => monthlyData.monthlyDataList.length > index
          ? (monthlyData.monthlyDataList[index] * alertRate).round()
          : 0,
    );
  }
}
