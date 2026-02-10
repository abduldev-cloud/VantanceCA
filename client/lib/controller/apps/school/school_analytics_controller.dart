import 'package:binary_success/helpers/logger/logger.dart';
import 'package:binary_success/models/teacher_classes_model_analytics.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:binary_success/controller/my_controller.dart';
import 'package:binary_success/helpers/services/school_analytics_service.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:binary_success/models/school_dashboard_analytics_model.dart';
import 'package:get/get.dart';

// Import AI usage model
import 'package:binary_success/models/ai_usage_overview_model.dart';

class SchoolAnalyticsController extends MyController {
  // Loading states
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = "".obs;

  // AI Usage Overview data
  Rx<AiUsageOverviewModel?> aiUsageOverview = Rx<AiUsageOverviewModel?>(null);
  final Rx<ApiResponse?> fullApiResponse = Rx<ApiResponse?>(null);
  // Performance metrics data (from new endpoint)
  RxDouble avgGrade = 0.0.obs;
  RxDouble avgAssignmentTimeHours = 0.0.obs;
  RxString averageGradeTrend = "".obs;
  RxString averageAssignmentTimeTrend = "".obs;
  RxBool hasLoadedPerformanceMetrics = false.obs;

  // Time range for analytics (default 30 days)
  RxInt timeRangeDays = 30.obs;

  // Filter properties for school analytics
  RxString selectedDepartment = "All".obs;
  RxString selectedTeacher = "All".obs;
  RxString selectedClass = "All".obs;
  RxString selectedGrade = "All".obs;
  RxString selectedTimeRange = "30 days".obs;
  RxString selectedGradeId = "".obs;
  Map<String, String> gradeNameIdMap = {};

  // Class data for filtering
  RxList<TeacherClassModel> teacherClassList = <TeacherClassModel>[].obs;
  //RxString selectedClass = "All".obs;
  RxString selectedClassId = "".obs;
  //RxString selectedGrade = "All".obs;
  final RxString selectedTerm = 'All'.obs; // Initialize with 'All'
  RxString selectedPeriodBucket =
      'year'.obs; // for 'year', 'month', 'week' selection

  // Dropdown data lists
  final RxList<String> termList = <String>[].obs;
  final RxList<TeacherClassModel> classList = <TeacherClassModel>[].obs;
  final RxList<String> gradeList = <String>[].obs;
  RxList<String> termDropdownItems = <String>[].obs;
  final selectedTeacherId =
      RxString(""); // For storing currently-selected teacherId
  Map<String, String> teacherNameIdMap = {}; // Map teacher name to teacherId
  final teacherList = RxList<String>([]);
  void updateSelectedTerm(String value) => selectedTerm.value = value;

  // Dynamic filter options from database
  final RxList<String> _departmentOptions = <String>["All"].obs;
  final RxList<String> _teacherOptions = <String>["All"].obs;
  final RxList<String> _classOptions = <String>["All"].obs;
  final RxList<String> _gradeOptions = <String>["All"].obs;

  // Filter options getters
  List<String> get departmentOptions => _departmentOptions.value;
  List<String> get teacherOptions => _teacherOptions.value;
  List<String> get classOptions => _classOptions.value;
  List<String> get gradeOptions => _gradeOptions.value;
  List<String> get timeRangeOptions => ["7d", "14d", "30d", "Term 1"];
  final double width = 7;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: Colors.purple,
          width: width,
        ),
        BarChartRodData(
          toY: y2,
          color: Colors.redAccent,
          width: width,
        ),
      ],
    );
  }

  @override
  void onInit() {
    super.onInit();

    /// Bar Chart 1

    final barGroup1 = makeGroupData(0, 5, 12);
    final barGroup2 = makeGroupData(1, 16, 12);
    final barGroup3 = makeGroupData(2, 18, 5);
    final barGroup4 = makeGroupData(3, 20, 16);
    final barGroup5 = makeGroupData(4, 17, 6);
    final barGroup6 = makeGroupData(5, 19, 1.5);
    final barGroup7 = makeGroupData(6, 10, 1.5);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
      barGroup7,
    ];

    rawBarGroups = items;

    showingBarGroups = rawBarGroups;

    // Fetch analytics data using new API pattern
    fetchAiUsageOverview();
    fetchPerformanceMetrics();
    fetchSchoolClassFilters();
  }

// Fetch API and populate dropdowns (reuse teacher filter API and model)

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
        teacherId: selectedTeacherId.value.isNotEmpty &&
                selectedTeacherId.value != "All"
            ? selectedTeacherId.value
            : null,
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

        final allTeachers = response.data[0].teachers;
        List<String> teacherNames = ["All"];
        Map<String, String> teacherNameIdMap = {};
        Set<String> allGradeNames = {};
        Set<String> allTerms = {};
        Set<String> allClassNames = {};
        Map<String, String> gradeNameIdMapLocal = {};

        if (selectedTeacher.value != "All") {
          final TeacherModel? selectedTeacherData =
              allTeachers.firstWhereOrNull(
            (teacher) => teacher.teacherName == selectedTeacher.value,
          );

          if (selectedTeacherData != null) {
            // use selectedTeacherData safely
          } else {
            // handle null case (e.g., reset to default)
          }

          if (selectedTeacherData != null) {
            teacherNames = [selectedTeacherData.teacherName];
            teacherNameIdMap = {
              selectedTeacherData.teacherName: selectedTeacherData.teacherId
            };

            allGradeNames =
                selectedTeacherData.grades.map((g) => g.gradeName).toSet();
            gradeNameIdMapLocal = {
              for (var g in selectedTeacherData.grades) g.gradeName: g.gradeId
            };

            allTerms = selectedTeacherData.terms.toSet();
            allClassNames =
                selectedTeacherData.classes.map((cls) => cls.className).toSet();
          } else {
            teacherNames = ["All"];
            teacherNameIdMap = {};
            allGradeNames = {};
            gradeNameIdMapLocal = {};
            allTerms = {};
            allClassNames = {};
          }
        } else {
          for (var teacher in allTeachers) {
            teacherNames.add(teacher.teacherName);
            teacherNameIdMap[teacher.teacherName] = teacher.teacherId;
            for (var g in teacher.grades) {
              allGradeNames.add(g.gradeName);
              gradeNameIdMapLocal[g.gradeName] = g.gradeId;
            }
            allTerms.addAll(teacher.terms);
            for (var cls in teacher.classes) {
              allClassNames.add(cls.className);
            }
          }
        }

        teacherList.assignAll(teacherNames);
        this.teacherNameIdMap = teacherNameIdMap;
        gradeList.assignAll(["All", ...allGradeNames]);
        termList.assignAll(["All", ...allTerms]);
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
        gradeNameIdMap = gradeNameIdMapLocal;

        print("Teachers from API: $teacherNames");
        print("Grades: $allGradeNames");
        print("Terms: $allTerms");
        print("Classes: $allClassNames");

        if (!teacherList.contains(selectedTeacher.value))
          selectedTeacher.value = "All";
        if (!gradeList.contains(selectedGrade.value))
          selectedGrade.value = "All";
        if (!termList.contains(selectedTerm.value)) selectedTerm.value = "All";
        if (!classList.any((c) => c.className == selectedClass.value))
          selectedClass.value = "All";

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

// Teacher change handler
  Future<void> onTeacherChanged(String teacher) async {
    selectedTeacher.value = teacher;
    selectedTeacherId.value = teacherNameIdMap[teacher] ?? '';
    await fetchSchoolClassFilters();
    await fetchAiUsageOverview();
  }

// Grade change handler
  Future<void> onGradeChanged(String grade) async {
    selectedGrade.value = grade;
    selectedGradeId.value = gradeNameIdMap[grade] ?? '';
    await fetchSchoolClassFilters();
    await fetchAiUsageOverview();
  }

// Term change handler
  Future<void> onTermChanged(String term) async {
    selectedTerm.value = term;
    await fetchSchoolClassFilters();
    await fetchAiUsageOverview();
  }

// Class change handler
  Future<void> onClassChanged(String clsName) async {
    selectedClass.value = clsName;
    final cls = classList.firstWhere((c) => c.className == clsName,
        orElse: () => TeacherClassModel());
    selectedClassId.value = cls.classId ?? '';
    await fetchSchoolClassFilters();
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

        gradeLevelId:
            selectedGradeId.value.isNotEmpty ? selectedGradeId.value : null,
        term: selectedTerm.value != 'All' ? selectedTerm.value : null,
        // Pass the teacherId here:
        teacherId: selectedTeacherId.value.isNotEmpty &&
                selectedTeacherId.value != "All"
            ? selectedTeacherId.value
            : null,
        // academicYear: selectedAcademicYear.value != 'All' ? selectedAcademicYear.value : null,
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
      final result =
          await SchoolAnalyticsService.get1SchoolPerformanceMetricsByEmail(
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

  /// Handle errors
  void _handleError(String message) {
    hasError(true);
    errorMessage(message);
    isLoading(false);
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

  /// AI usage functionality removed - all analytics now come from school-analytics endpoint

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

  String formatNumberWithCommas(int number) {
    return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]},');
  }

  String get formattedAiPromptUsageTotal =>
      formatNumberWithCommas(aiPromptUsageTotal);

  /// Check if AI usage data is available
  bool get hasAiUsageData => aiUsageOverview.value != null;

  /// Get average grade percentage across classes
  double get averageGradePercentage => avgGrade.value;

  /// Get average assignment time in hours
  double get averageAssignmentTimeHours => avgAssignmentTimeHours.value;

  /// Check if performance metrics data is available
  bool get hasPerformanceMetricsData => hasLoadedPerformanceMetrics.value;
}
