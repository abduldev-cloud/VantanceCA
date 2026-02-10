import 'package:binary_success/helpers/services/teacher_service.dart';
import 'package:get/get.dart';
import 'package:binary_success/controller/my_controller.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:binary_success/models/teacher_view_class_model.dart';

class TeacherClassViewController extends MyController {
  RxBool isLoading = false.obs;

  /// Students list for UI (filtered + sorted)
  RxList<Student> studentsList = <Student>[].obs;

  /// Original unmodified list from API
  List<Student> allStudentsList = [];

  Rxn<ClassSummary> classSummary = Rxn<ClassSummary>();

  /// For sort UI
  RxString selectedSort = "Active".obs;

  Future<void> fetchClassStudents(String teacherId, String classId) async {
    isLoading.value = true;

    try {
      final entityId = LocalStorage.getDBEntityID();
      if (entityId == null || entityId.isEmpty) {
        print("❌ No entityId found in local storage");
        return;
      }

      final response = await TeacherService.getTeacherViewClassAPI(
        teacherId: entityId,
        classId: classId,
      );

      if (response != null) {
        allStudentsList = response.studentsList ?? [];
        studentsList.assignAll(allStudentsList);
        classSummary.value = response.classSummary;
      } else {
        allStudentsList.clear();
        studentsList.clear();
        classSummary.value = null;
      }
    } catch (e) {
      print("❌ Error: $e");
      allStudentsList.clear();
      studentsList.clear();
      classSummary.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔍 Search filter
  void searchStudents(String query) {
    if (query.isEmpty) {
      studentsList.assignAll(allStudentsList);
    } else {
      studentsList.assignAll(
        allStudentsList.where((student) {
          final fullName =
              "${student.firstName ?? ""} ${student.lastName ?? ""}"
                  .toLowerCase();
          final email = (student.email ?? "").toLowerCase();
          return fullName.contains(query.toLowerCase()) ||
              email.contains(query.toLowerCase());
        }).toList(),
      );
    }
  }

  /// 🔽 Sort students
  void sortStudents(String criteria) {
    selectedSort.value = criteria;

    List<Student> sorted = [...studentsList];

    switch (criteria) {
      case "Active":
        sorted.sort((a, b) =>
            (b.learnerStatus?.toLowerCase() == "active" ? 1 : 0)
                .compareTo(a.learnerStatus?.toLowerCase() == "active" ? 1 : 0));
        break;

      case "Inactive":
        sorted.sort((a, b) => (b.learnerStatus?.toLowerCase() == "inactive"
                ? 1
                : 0)
            .compareTo(a.learnerStatus?.toLowerCase() == "inactive" ? 1 : 0));
        break;

      case "A to Z":
        sorted.sort((a, b) {
          final nameA =
              "${a.firstName ?? ""} ${a.lastName ?? ""}".trim().toLowerCase();
          final nameB =
              "${b.firstName ?? ""} ${b.lastName ?? ""}".trim().toLowerCase();
          return nameA.compareTo(nameB);
        });
        break;

      case "Z to A":
        sorted.sort((a, b) {
          final nameA =
              "${a.firstName ?? ""} ${a.lastName ?? ""}".trim().toLowerCase();
          final nameB =
              "${b.firstName ?? ""} ${b.lastName ?? ""}".trim().toLowerCase();
          return nameB.compareTo(nameA);
        });
        break;
    }

    studentsList.assignAll(sorted);
  }
}
