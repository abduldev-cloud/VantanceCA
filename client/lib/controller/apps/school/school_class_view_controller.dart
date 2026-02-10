import 'package:binary_success/helpers/network/api_service.dart';
import 'package:get/get.dart';
import 'package:binary_success/models/school_view_details_model.dart';

class SchoolClassViewController extends GetxController {
  var isLoading = false.obs;

  var _allStudents = <SchoolStudent>[];

  var students = <SchoolStudent>[].obs;

  var searchQuery = ''.obs;

  var sortOption = 'Active'.obs;

  Future<void> fetchClassStudents(String teacherId, String classId) async {
    try {
      isLoading.value = true;
      students.clear();
      _allStudents.clear();

      final response = await APIService.get(
        path:
            "/db/teacher/get_class_tasks_stats_and_learners/?teacher_id=$teacherId&class_id=$classId",
      );
      print("✅ Fetched students: $response");

      final data = response is Map<String, dynamic> ? response : response.data;

      if (data != null && data['students_list'] != null) {
        _allStudents = (data['students_list'] as List)
            .map((e) => SchoolStudent.fromJson(e))
            .toList();
      }

      applyFilters();
    } catch (e) {
      print("❌ Error fetching students: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    List<SchoolStudent> filtered = [..._allStudents];

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((student) {
        final fullName =
            "${student.firstName} ${student.lastName}".toLowerCase();
        final email = (student.email ?? '').toLowerCase();
        final query = searchQuery.value.toLowerCase();
        return fullName.contains(query) || email.contains(query);
      }).toList();
    }

    switch (sortOption.value) {
      case 'Active':
        filtered.sort((a, b) {
          bool aActive = a.learnerStatus.toLowerCase() == 'active';
          bool bActive = b.learnerStatus.toLowerCase() == 'active';
          return (bActive ? 1 : 0).compareTo(aActive ? 1 : 0);
        });
        break;

      case 'Inactive':
        filtered.sort((a, b) {
          bool aInactive = a.learnerStatus.toLowerCase() != 'active';
          bool bInactive = b.learnerStatus.toLowerCase() != 'active';
          return (bInactive ? 1 : 0).compareTo(aInactive ? 1 : 0);
        });
        break;

      case 'Student (A - Z)':
        filtered.sort(
            (a, b) => ("${a.firstName} ${a.lastName}").toLowerCase().compareTo(
                  ("${b.firstName} ${b.lastName}").toLowerCase(),
                ));
        break;

      case 'Student (Z - A)':
        filtered.sort(
            (a, b) => ("${b.firstName} ${b.lastName}").toLowerCase().compareTo(
                  ("${a.firstName} ${a.lastName}").toLowerCase(),
                ));
        break;

      default:
        break;
    }

    students.value = filtered;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void setSortOption(String option) {
    sortOption.value = option;
    applyFilters();
  }
}
