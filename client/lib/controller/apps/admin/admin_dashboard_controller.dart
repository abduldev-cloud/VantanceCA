import 'package:vantanceCA/helpers/services/platform_service.dart';
import 'package:vantanceCA/models/teacher_classes_model_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vantanceCA/controller/my_controller.dart';
import 'package:vantanceCA/helpers/services/school_analytics_service.dart';
import 'package:vantanceCA/helpers/services/admin_dashboard_service.dart';
import 'package:vantanceCA/helpers/network/api_service.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'package:vantanceCA/helpers/logger/logger.dart';
import 'package:vantanceCA/models/ai_usage_overview_model.dart';
import 'package:vantanceCA/models/admin_dashboard_statistics_model.dart';
import 'package:vantanceCA/models/platform_ticket_model.dart';

class AdminDashboardController extends MyController {
  RxInt selectedIndex = 1.obs;
  PageController pageController = PageController();

  // Loading states
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  RxString aiUsageErrorMessage = "".obs;
  RxString errorMessage = "".obs;
  final RxList<TeacherClassModel> classList = <TeacherClassModel>[].obs;

  RxString selectedPeriodBucket = 'year'.obs;
  RxString selectedClassId = "".obs;
  // AI Usage Overview data
  Rx<AiUsageOverviewModel?> aiUsageOverview = Rx<AiUsageOverviewModel?>(null);

  final Rx<ApiResponse?> fullApiResponse = Rx<ApiResponse?>(null);

  // Platform Dashboard Statistics data
  Rx<AdminDashboardStatisticsModel?> platformStatistics =
      Rx<AdminDashboardStatisticsModel?>(null);

  // Platform dashboard loading states
  RxBool isPlatformLoading = false.obs;
  RxBool hasPlatformError = false.obs;
  RxString platformErrorMessage = "".obs;

  // Support Tickets data
  Rx<Map<String, dynamic>?> supportTickets = Rx<Map<String, dynamic>?>(null);
  RxList<PlatformSupportTicket> supportTicketsList =
      <PlatformSupportTicket>[].obs;

  RxList<PlatformSupportTicket> supportTicketsLists =
      <PlatformSupportTicket>[].obs;

  // Support tickets loading states
  RxBool isSupportTicketsLoading = false.obs;
  RxBool hasSupportTicketsError = false.obs;
  RxString supportTicketsErrorMessage = "".obs;

  // Time range for analytics (default 30 days)
  RxInt timeRangeDays = 30.obs;

  // Filter properties for dashboard
  RxString selectedTimeRange = "30d".obs;
  RxString selectedClass = "All Classes".obs;
  RxString selectedChartPeriod = "Month".obs;

  // Dynamic filter options from database
  final RxList<String> _classOptions = <String>["All Classes"].obs;

  // Filter options
  List<String> get timeRangeOptions => ["7d", "14d", "30d", "Term 1"];

  List<String> get classOptions => _classOptions.value;

  List<String> get chartPeriodOptions => ["Month", "Week", "Year"];

  @override
  void onInit() {
    super.onInit();
    // Fetch all data on initialization (support tickets loaded once on login)
    fetchAiUsageOverview();
    fetchPlatformStatistics();
    fetchSupportTickets();
    fetchClassOptions();
    fetchadminClassFilters();
  }

  Future<void> fetchadminClassFilters({String? skipReset}) async {
    print("fetchadminClassFilters called for platform admin");
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // Prepare className param properly excluding "All" or "All Classes"
      String? classNameParam;
      final selected = selectedClass.value.trim().toLowerCase();
      if (selected.isNotEmpty &&
          selected != 'all' &&
          selected != 'all classes') {
        classNameParam = selectedClass.value;
      } else {
        classNameParam = null; // omit param to avoid sending the invalid filter
      }

      final response = await SchoolAnalyticsService.getAdminClassFilters(
        className: classNameParam,
      );

      if (response != null && response.success && response.data.isNotEmpty) {
        fullApiResponse.value = response;
        final data = response.data;

        Set<String> classNames = {'All'};

        // Collect all class names safely
        for (var inst in data) {
          for (var teacher in inst.teachers) {
            for (var cls in teacher.classes) {
              if (cls.className.isNotEmpty) {
                classNames.add(cls.className);
              }
            }
          }
        }

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
                    gradeName: '',
                  )),
        ];

        print("classList length: ${classList.length}");
        print("classList items: ${classList.map((c) => c.className).toList()}");

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

  Future<void> fetchSupportTickets() async {
    isSupportTicketsLoading.value = true;
    hasSupportTicketsError.value = false;
    supportTicketsErrorMessage.value = '';

    try {
      final PlatformSupportListResponse? response =
          await SupportService.getPlatformAdminTickets();
      print('Fetched support tickets: $response');
      if (response != null && response.tickets.isNotEmpty) {
        supportTicketsList.value = response.tickets;
      } else {
        supportTicketsList.clear();
      }
    } catch (e) {
      hasSupportTicketsError.value = true;
      supportTicketsErrorMessage.value = e.toString();
      supportTicketsList.clear();
    } finally {
      isSupportTicketsLoading.value = false;
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

  Future<void> fetchAiUsageOverview() async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage("");

      print(
          "🔄 AdminAnalyticController: Fetching AI usage overview for platform admin...");
      print("📊 Using timeRangeDays: ${timeRangeDays.value}");
      print("📊 Current selectedPeriodBucket: ${selectedPeriodBucket.value}");

      final result =
          await SchoolAnalyticsService.getAiUsageOverviewForPlatformAdmin(
        timeRangeDays: timeRangeDays.value,
        bucket: selectedPeriodBucket.value,
        classId:
            selectedClassId.value.isNotEmpty ? selectedClassId.value : null,
      );

      print(
          "📊 AI Usage API call completed with timeRangeDays: ${timeRangeDays.value}");

      if (result != null) {
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

  // Platform Dashboard Statistics Methods

  /// Fetch platform-wide dashboard statistics
  Future<void> fetchPlatformStatistics() async {
    try {
      isPlatformLoading(true);
      hasPlatformError(false);
      platformErrorMessage("");

      // Test the API service first
      await AdminDashboardService.testAPIService();

      // Try main endpoint first, then fallback to platform dashboard endpoint
      final result =
          await AdminDashboardService.refreshAdminDashboardStatistics();

      if (result != null) {
        platformStatistics(result);
        isPlatformLoading(false);
      } else {
        _handlePlatformError(
            "Failed to fetch platform statistics from both endpoints");
      }
    } catch (e) {
      _handlePlatformError("Error fetching platform statistics: $e");
    }
  }

  /// Handle platform statistics errors
  void _handlePlatformError(String message) {
    hasPlatformError(true);
    platformErrorMessage(message);
    isPlatformLoading(false);
  }

  /// Refresh platform dashboard statistics
  Future<void> refreshPlatformDashboard() async {
    await fetchPlatformStatistics();
  }

  /// Handle support tickets errors
  void _handleSupportTicketsError(String message) {
    logE("❌ [AdminDashboard] Support tickets error: $message");
    hasSupportTicketsError(true);
    supportTicketsErrorMessage(message);
    isSupportTicketsLoading(false);
  }

  /// Refresh support tickets data (manual refresh only - not called automatically)
  // Future<void> refreshSupportTickets() async {
  //   await fetchSupportTickets();
  // }

  /// Refresh all data (AI usage and platform statistics only - support tickets loaded on login)
  Future<void> refreshAllData() async {
    await Future.wait([
      fetchAiUsageOverview(),
      fetchPlatformStatistics(),
      fetchClassOptions(),
    ]);
  }

  /// Fetch class options from database
  Future<void> fetchClassOptions() async {
    try {
      print(
          "🔄 AdminDashboardController: Fetching class options from database...");

      final classes = await SchoolAnalyticsService.getAllClassesForAnalytics();

      // Replace "All" with "All Classes" for dashboard consistency
      final dashboardClasses = classes
          .map((className) => className == "All" ? "All Classes" : className)
          .toList();

      _classOptions.value = dashboardClasses;
      print(
          "✅ Dashboard class options updated from backend: ${dashboardClasses.length} classes found");
      print("📋 Classes: ${dashboardClasses.join(', ')}");

      if (dashboardClasses.length == 1 &&
          dashboardClasses[0] == "All Classes") {
        print(
            "⚠️ Dashboard: Only 'All Classes' option available - no database data found");
      }
    } catch (e) {
      print("❌ Error fetching class options for dashboard: $e");
      // Set to minimal options on error - no hardcoded fallbacks
      _classOptions.value = ["All Classes"];
      print("🚨 Dashboard class options reset to minimal state due to error");
    }
  }

  // /// Get support tickets count
  // int get supportTicketsCount {
  //   final count = supportTicketsList.length;
  //   logI("📊 [AdminDashboard] Support tickets count: $count");
  //   return count;
  // }

  // /// Get support tickets list
  // List<Map<String, dynamic>> get supportTicketsData {
  //   final data = supportTicketsList.toList();
  //   logI("📊 [AdminDashboard] Support tickets data requested: ${data.length} items");
  //   return data;
  // }

  // /// Check if support tickets data is available
  // bool get hasSupportTicketsData {
  //   final hasData = supportTicketsList.isNotEmpty;
  //   logI("📊 [AdminDashboard] Has support tickets data: $hasData");
  //   return hasData;
  // }

  // /// Get support ticket by index (for display in dashboard)
  // Map<String, dynamic>? getSupportTicketByIndex(int index) {
  //   if (index >= 0 && index < supportTicketsList.length) {
  //     return supportTicketsList[index];
  //   }
  //   return null;
  // }

  /// Get ticket number from support ticket data
  String getTicketNumber(Map<String, dynamic> ticket) {
    final ticketNumber = ticket['ticket_number'] ??
        ticket['ticket_id'] ??
        ticket['id'] ??
        ticket['number'] ??
        'ST-${DateTime.now().millisecondsSinceEpoch}';
    logI(
        "📋 [AdminDashboard] Getting ticket number: $ticketNumber from ticket: $ticket");
    return ticketNumber;
  }

  /// Get user name from support ticket data
  String getUserName(Map<String, dynamic> ticket) {
    final userName = ticket['user_name'] ??
        ticket['user'] ??
        ticket['customer_name'] ??
        ticket['name'] ??
        'Unknown User';
    logI(
        "📋 [AdminDashboard] Getting user name: $userName from ticket: $ticket");
    return userName;
  }

  /// Get priority from support ticket data
  String getPriority(Map<String, dynamic> ticket) {
    final priority =
        ticket['priority'] ?? ticket['severity'] ?? ticket['level'] ?? 'P3';
    logI(
        "📋 [AdminDashboard] Getting priority: $priority from ticket: $ticket");
    return priority;
  }

  /// Get status from support ticket data
  String getStatus(Map<String, dynamic> ticket) {
    final status = ticket['status'] ?? ticket['state'] ?? 'Open';
    logI("📋 [AdminDashboard] Getting status: $status from ticket: $ticket");
    return status;
  }

  // Filter update methods
  void updateTimeRange(String? timeRange) {
    if (timeRange != null) {
      selectedTimeRange(timeRange);

      // Update timeRangeDays based on selection
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
          timeRangeDays(153); // Aug 1st to Dec 31st (153 days)
          break;
        default:
          timeRangeDays(30);
      }

      // Refresh AI usage and platform data with new time range (support tickets remain static)
      refreshAllData();
    }
  }

  void updateClassFilter(String? classValue) {
    if (classValue != null) {
      selectedClass(classValue);
      // Refresh AI usage and platform data with new class filter (support tickets remain static)
      refreshAllData();
    }
  }

  void updateChartPeriod(String? period) {
    if (period != null) {
      selectedChartPeriod(period);
      // Update chart display period
      update();
    }
  }

  // Platform Statistics Getters

  /// Get total active schools count
  int get activeSchoolsCount =>
      platformStatistics.value?.totalSchools.active ?? 0;

  /// Get total inactive schools count
  int get inactiveSchoolsCount =>
      platformStatistics.value?.totalSchools.inactive ?? 0;

  /// Get total active users count
  int get activeUsersCount => platformStatistics.value?.totalUsers.active ?? 0;

  /// Get total inactive users count
  int get inactiveUsersCount =>
      platformStatistics.value?.totalUsers.inactive ?? 0;

  /// Get total active students in last 24 hours
  int get activeStudents24hr =>
      platformStatistics.value?.totalStudents.active ?? 0;

  /// Get grade-wise breakdown for students
  GradeBreakdown? get gradeWiseBreakdown =>
      platformStatistics.value?.totalStudents.gradeBreakdown;

  /// Check if any data is loading
  bool get isAnyDataLoading =>
      isLoading.value ||
      isPlatformLoading.value ||
      isSupportTicketsLoading.value;

  /// Check if any data has errors (only if corresponding data is missing)
  bool get hasAnyError => ((hasError.value && aiUsageOverview.value == null) ||
      (hasPlatformError.value && platformStatistics.value == null) ||
      (hasSupportTicketsError.value && supportTicketsList.isEmpty));

  /// Get combined error message
  String get combinedErrorMessage {
    List<String> errors = [];
    if (hasError.value &&
        errorMessage.value.isNotEmpty &&
        aiUsageOverview.value == null) {
      errors.add("AI Usage: ${errorMessage.value}");
    }
    if (hasPlatformError.value &&
        platformErrorMessage.value.isNotEmpty &&
        platformStatistics.value == null) {
      errors.add("Platform Stats: ${platformErrorMessage.value}");
    }
    if (hasSupportTicketsError.value &&
        supportTicketsErrorMessage.value.isNotEmpty &&
        supportTicketsList.isEmpty) {
      errors.add("Support Tickets: ${supportTicketsErrorMessage.value}");
    }
    return errors.join("\n");
  }

  /// Check if platform statistics data is available
  bool get hasPlatformData => platformStatistics.value != null;

  /// Transform external service ticket format to our expected format
  Map<String, dynamic> _transformExternalTicket(
      Map<String, dynamic> externalTicket) {
    logI("🔄 [AdminDashboard] Transforming external ticket: $externalTicket");

    // Extract values from the external service format
    final values = externalTicket['values'] as List? ?? [];
    Map<String, dynamic> ticketData = {};

    logI("🔄 [AdminDashboard] External ticket values: $values");

    // Convert the values array to a map for easier access
    for (var value in values) {
      if (value is Map<String, dynamic>) {
        final name = value['name'] as String?;
        final val = value['value'];
        if (name != null) {
          ticketData[name] = val;
        }
      }
    }

    logI("🔄 [AdminDashboard] Extracted ticket data: $ticketData");

    // Transform to our expected format with proper field mapping
    final transformedTicket = {
      'ticket_number':
          'ST-${ticketData['CaseNumber'] ?? externalTicket['recordID'] ?? DateTime.now().millisecondsSinceEpoch}',
      'user_name': ticketData['SuppliedName'] ??
          ticketData['SuppliedEmail'] ??
          'Unknown User',
      'priority': ticketData['Priority'] ?? 'P3',
      'status': ticketData['Status'] ?? 'Open',
      'subject': ticketData['Subject'] ?? 'No Subject',
      'description': ticketData['Description'] ?? '',
      'email': ticketData['SuppliedEmail'] ?? '',
      'solution_name': ticketData['SolutionName'] ?? '',
      'solution_note': ticketData['SolutionNote'] ?? '',
      'created_at':
          externalTicket['createdAt'] ?? DateTime.now().toIso8601String(),
      'updated_at':
          externalTicket['updatedAt'] ?? DateTime.now().toIso8601String(),
    };

    logI("🔄 [AdminDashboard] Transformed ticket: $transformedTicket");
    return transformedTicket;
  }

  /// Refresh all analytics data
  Future<void> refreshAllAnalytics() async {
    await Future.wait([
      fetchAiUsageOverview(),
    ]);
  }
}
