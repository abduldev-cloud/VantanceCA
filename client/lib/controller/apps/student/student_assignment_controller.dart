import 'package:binary_success/helpers/constant/app_constant.dart';
import 'package:get/get.dart';
import 'package:binary_success/controller/my_controller.dart';
import 'package:binary_success/helpers/services/student_service.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:binary_success/models/student_assignment_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

enum SortOrder { earliest, latest }

class StudentAssignmentController extends MyController {
  RxInt selectedTabIndex = 0.obs;
  CalendarController calendarController = CalendarController();

  Rx<StudentAssignmentModel> studentAssignmentData =
      StudentAssignmentModel().obs;
  RxBool isLoading = false.obs;

  RxList<AssignmentTask> activeTasks = <AssignmentTask>[].obs;
  RxList<AssignmentTask> pendingReviewTasks = <AssignmentTask>[].obs;
  RxList<AssignmentTask> gradedTasks = <AssignmentTask>[].obs;
  RxList<AssignmentTask> fingerprintTasks = <AssignmentTask>[].obs;

  final RxInt _activeTasksCount = 0.obs;
  final RxInt _pendingReviewCount = 0.obs;
  final RxInt _gradedCount = 0.obs;
  final RxInt _fingerprintCount = 0.obs;
  final Dio _dio = Dio();

  final RxString _searchQuery = ''.obs;
  final Rx<SortOrder> _sortOrder = SortOrder.earliest.obs;

  int get activeTasksCount => _activeTasksCount.value;
  int get pendingReviewCount => _pendingReviewCount.value;
  int get gradedCount => _gradedCount.value;
  int get fingerprintCount => _fingerprintCount.value;

  String get learnerName {
    final learner = studentAssignmentData.value.learnerSummary;
    if (learner != null && learner.isNotEmpty) {
      final first = learner.first.firstName ?? '';
      final last = learner.first.lastName ?? '';
      return ('$first $last').trim();
    }
    return '';
  }

  List<AssignmentTask> get filteredTasks {
    List<AssignmentTask> base;
    switch (selectedTabIndex.value) {
      case 0:
        base = activeTasks;
        break;
      case 1:
        base = pendingReviewTasks;
        break;
      case 2:
        base = gradedTasks;
        break;
      case 3:
        base = fingerprintTasks;
        break;
      default:
        base = [];
    }

    final List<AssignmentTask> out = List<AssignmentTask>.from(base);

    final q = _searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      out.retainWhere((t) {
        final hay = [
          t.taskTitle ?? '',
          t.className ?? '',
          t.classGrade ?? '',
          t.taskDescription ?? '',
          t.taskStatus ?? '',
          t.taskType ?? '',
        ].join(' ').toLowerCase();
        return hay.contains(q);
      });
    }

    out.sort((a, b) {
      final da = _parseTaskDate(a, _sortOrder.value);
      final db = _parseTaskDate(b, _sortOrder.value);
      if (_sortOrder.value == SortOrder.earliest) {
        return da.compareTo(db);
      } else {
        return db.compareTo(da);
      }
    });

    return out;
  }

  /// ✅ Single asset for empty state
  String get emptyAsset => 'assets/icon/assignments.png';

  /// ✅ Provide a tab-specific empty message
  String get emptyMessage {
    switch (selectedTabIndex.value) {
      case 0:
        return "No active tasks found";
      case 1:
        return "No submitted tasks found";
      case 2:
        return "No graded tasks found";
      case 3:
        return "No writing fingerprints found";
      default:
        return "No data found";
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadAssignmentCounts();
    loadTasksForTab(0);
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
    loadTasksForTab(index);
  }

  void applySearch(String query) {
    _searchQuery.value = query;
  }

  void sortBy(String label) {
    final lower = (label ?? '').toLowerCase();
    if (lower.contains('latest')) {
      _sortOrder.value = SortOrder.latest;
    } else {
      _sortOrder.value = SortOrder.earliest;
    }
  }

  Future<void> startAssignment(AssignmentTask task) async {
    try {
      final learnerId =
          studentAssignmentData.value.learnerSummary?[0].learnerId ?? "";
      final taskId = task.taskId ?? "";

      if (learnerId.isEmpty || taskId.isEmpty) {
        print("❌ Missing learnerId or taskId");
        // Still redirect so flow continues
        Get.toNamed("/student/practice-session");
        return;
      }

      // Step 1: Call get_taskdetails API
      final taskDetailsUrl =
          "${API.baseURl}/db/writingpad/get_taskdetails/?learner_id=$learnerId&task_id=$taskId";

      final response = await http.get(Uri.parse(taskDetailsUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final taskSummary = (data["task_summary"] as List?)?.first;

        String? llmSessionId = taskSummary?["llm_session_id"];
        String? teacherId = taskSummary?["teacher_id"];

        if (llmSessionId != null && llmSessionId.isNotEmpty) {
          print("✅ Found existing session: $llmSessionId");
          Get.toNamed("/student/practice-session");
          return;
        }

        // Step 2: Call seed-data API
        final seedUrl = "${API.baseURl}/ai/seed-data";

        final seedResponse = await http.post(
          Uri.parse(seedUrl),
          headers: {
            "Authorization": "Bearer a9EWMMu9faVgrncjh4WaKpTJZqKfvTO",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "learnerId": learnerId,
            "taskId": taskId,
            "teacherId": teacherId,
          }),
        );

        if (seedResponse.statusCode == 200) {
          final seedData = jsonDecode(seedResponse.body);
          if (seedData["message"] == "Session Created Successfully") {
            print("✅ Session created successfully, redirecting...");
          } else {
            print("⚠ Failed to create session: $seedData");
          }
        } else {
          print("❌ Seed API failed: ${seedResponse.statusCode}");
        }
      } else {
        print("❌ Taskdetails API failed: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception in startAssignment: $e");
    }

    // ✅ Always redirect, regardless of API success/failure
    Get.toNamed("/student/practice-session");
  }

  Future<void> loadAssignmentCounts() async {
    try {
      final entityId = LocalStorage.getDBEntityID();
      if (entityId == null || entityId.isEmpty) {
        _clearCounts();
        return;
      }

      final statuses = ['Active', 'Pending Review', 'Graded'];
      final taskTypes = ['Assignment', 'Fingerprint'];

      _clearCounts();

      for (final taskType in taskTypes) {
        for (final status in statuses) {
          if (taskType == 'Fingerprint' && status != 'Active') continue;

          final response = await StudentService.getStudentAssignmentAPI(
            learnerId: entityId,
            status: status,
            taskType: taskType,
          );

          if (response != null && response.statusCode == 200) {
            final data = response.data['tasks_details'];
            final count = (data is List) ? data.length : 0;

            if (taskType == 'Assignment') {
              switch (status) {
                case 'Active':
                  _activeTasksCount.value = count;
                  break;
                case 'Pending Review':
                  _pendingReviewCount.value = count;
                  break;
                case 'Graded':
                  _gradedCount.value = count;
                  break;
              }
            } else if (taskType == 'Fingerprint' && status == 'Active') {
              _fingerprintCount.value = count;
            }
          }
        }
      }
    } catch (e) {
      _clearCounts();
    }
  }

  Future<void> loadTasksForTab(int index) async {
    try {
      isLoading(true);

      final entityId = LocalStorage.getDBEntityID();
      if (entityId == null || entityId.isEmpty) return;

      final status = getStatusFromIndex(index);
      final taskType = getTaskTypeFromIndex(index);

      final response = await StudentService.getStudentAssignmentAPI(
        learnerId: entityId,
        status: status,
        taskType: taskType,
      );

      if (response != null && response.statusCode == 200) {
        final map = response.data as Map<String, dynamic>;

        if (map['learner_summary'] != null &&
            (studentAssignmentData.value.learnerSummary == null ||
                studentAssignmentData.value.learnerSummary!.isEmpty)) {
          studentAssignmentData.value = StudentAssignmentModel.fromJson(map);
        }

        final list = (map['tasks_details'] as List<dynamic>? ?? [])
            .map((e) => AssignmentTask.fromJson(e))
            .toList();

        switch (index) {
          case 0:
            activeTasks.assignAll(list);
            _activeTasksCount.value = list.length;
            break;
          case 1:
            pendingReviewTasks.assignAll(list);
            _pendingReviewCount.value = list.length;
            break;
          case 2:
            gradedTasks.assignAll(list);
            _gradedCount.value = list.length;
            break;
          case 3:
            fingerprintTasks.assignAll(list);
            _fingerprintCount.value = list.length;
            break;
        }
      }
    } catch (_) {
      // Handle error silently
    } finally {
      isLoading(false);
    }
  }

  void _clearCounts() {
    _activeTasksCount.value = 0;
    _pendingReviewCount.value = 0;
    _gradedCount.value = 0;
    _fingerprintCount.value = 0;
  }

  String getStatusFromIndex(int index) {
    switch (index) {
      case 0:
        return 'Active';
      case 1:
        return 'Pending Review';
      case 2:
        return 'Graded';
      case 3:
        return 'Active';
      default:
        return 'Active';
    }
  }

  String getTaskTypeFromIndex(int index) {
    return index == 3 ? 'Fingerprint' : 'Assignment';
  }

  DateTime _parseTaskDate(AssignmentTask task, SortOrder sortOrder) {
    final dateStr = (task.dueDate ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
    String? timeStr = task.dueTime?.trim();

    if (dateStr.isEmpty) {
      return sortOrder == SortOrder.earliest ? DateTime(9999) : DateTime(0);
    }

    if (timeStr == null || timeStr.isEmpty) {
      timeStr = '11:59 PM';
    }

    final datetimeString = '$dateStr $timeStr';

    try {
      return DateFormat('MMMM d, yyyy hh:mm a').parse(datetimeString);
    } catch (_) {
      try {
        return DateFormat('MMMM d, yyyy hh:mm:ss a').parse(datetimeString);
      } catch (e) {
        return sortOrder == SortOrder.earliest ? DateTime(9999) : DateTime(0);
      }
    }
  }
}
