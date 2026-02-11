import 'package:get/get.dart';
import 'package:vantanceCA/controller/my_controller.dart';
import 'package:vantanceCA/helpers/services/student_service.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'package:vantanceCA/models/student_class_model.dart';
import 'package:vantanceCA/models/student_view_class_model.dart';

class StudentDashboardController extends MyController {
  /// UI State
  RxInt selectedTabIndex = 0.obs;
  RxBool isLoading = false.obs;

  /// Student Classes
  Rx<StudentClassModel> studentClassData = StudentClassModel().obs;

  /// View Class - Tasks
  RxList<StudentViewClassModel> studentViewClassList =
      <StudentViewClassModel>[].obs;

  /// Selected Class Info
  RxString classID = "".obs;
  RxString className = "".obs;
  RxString learnerID = "".obs;
  RxString gradeName = "".obs;
  RxString classDescription = "".obs;

  /// ✅ Fetches all classes using entityId (learnerId)
  Future<void> getStudentClassData() async {
    isLoading(true);
    try {
      final entityId = LocalStorage.getDBEntityID();
      if (entityId == null || entityId.isEmpty) {
        print("❌ No entityId found in local storage");
        return;
      }

      final response =
          await StudentService.getStudentClassAPI(learnerId: entityId);

      if (response != null && response.data != null) {
        studentClassData(StudentClassModel.fromJson(response.data));

        learnerID.value =
            studentClassData.value.learnerSummary?[0].learnerId ?? "";
        gradeName.value =
            studentClassData.value.learnerSummary?[0].gradeName ?? "";

        print("✅ Student class data loaded.");
      } else {
        print("❌ No data received from Student Class API");
      }
    } catch (e) {
      print("❌ Error fetching student class data: $e");
    } finally {
      isLoading(false);
    }
  }

  /// ✅ Fetch all tasks and filter by selected classId
  Future<void> getStudentViewClassData({required String classId}) async {
    isLoading(true);
    try {
      final entityId = LocalStorage.getDBEntityID();
      if (entityId == null || entityId.isEmpty) {
        print("❌ No entityId found");
        return;
      }

//       final response = await StudentService.getStudentClassAPI(
//         learnerId: entityId,
//       );

//       if (response != null && response.data != null) {
//         print("✅ Full API Response: ${response.data}");

//         // Merge all task arrays into one list
//         List allTasks = [];
//         if (response.data["active_tasks"] != null) {
//           allTasks.addAll(response.data["active_tasks"]);
//         }
//         if (response.data["pending_review_tasks"] != null) {
//           allTasks.addAll(response.data["pending_review_tasks"]);
//         }
//         if (response.data["graded_tasks"] != null) {
//           allTasks.addAll(response.data["graded_tasks"]);

      /// ✅ Task types & statuses (case-sensitive)
      final taskTypes = ['Assignment', 'Finger Print'];
      final statuses = ['Active', 'Pending Review', 'Graded'];

      List allFetchedTasks = [];

      for (String type in taskTypes) {
        for (String status in statuses) {
          if (type == ' Fingerprint' && status!= 'Active') continue;

          final response = await StudentService.getStudentAssignmentAPI(
            learnerId: entityId,
            status: status,
            taskType: type,
          );

          if (response != null && response.data != null) {
            final tasks = response.data['tasks_details'];
            if (tasks != null && tasks is List) {
              allFetchedTasks.addAll(tasks);
              print("✅ ${tasks.length} tasks fetched for $type | $status");
            }
          } else {
            print("⚠ No tasks for $type | $status");
          }

        }
      }

      /// 🔎 Filter by class ID
      var filtered = allFetchedTasks.where((task) {
        return task["class_id"].toString().trim() == classId.trim();
      }).toList();

      if (filtered.isEmpty) {
        print("⚠ No tasks found for class_id: $classId");
      } else {
        print("✅ ${filtered.length} tasks matched class_id: $classId");
      }

      studentViewClassList.value =
          filtered.map((x) => StudentViewClassModel.fromJson(x)).toList();

    } catch (e) {
      print("❌ Error fetching view class data: $e");
    } finally {
      isLoading(false);
    }
  }

  /// ✅ Save selected class info for UI
  void setSelectedClass(String id, String name, String description) {
    classID.value = id;
    className.value = name;
    classDescription.value = description;
    print("✅ Selected Class Set → $name | $description");
  }

  @override
  void onInit() {
    getStudentClassData();
    super.onInit();
  }
}
