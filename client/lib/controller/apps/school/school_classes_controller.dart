import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:binary_success/controller/my_controller.dart';
import 'package:binary_success/helpers/services/school_service.dart';
import 'package:binary_success/helpers/storage/local_storage.dart'; // Import LocalStorage
import 'package:flutter/widgets.dart';
import 'package:binary_success/models/create_class_model.dart';
import 'package:binary_success/helpers/services/teacher_service.dart';

class SchoolClassesController extends GetxController {
  TextEditingController className = TextEditingController();
  TextEditingController classDescription = TextEditingController();
  TextEditingController classGrade = TextEditingController();
  TextEditingController classStudents = TextEditingController();
  TextEditingController maxLearners = TextEditingController();
  TextEditingController classInviteCode = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();

  var students = <Map<String, dynamic>>[].obs;
  var filteredStudents = <Map<String, dynamic>>[].obs;

  RxString sortBy = 'Active'.obs;
  RxString searchQuery = ''.obs;

  RxInt activeCount = 0.obs;
  RxInt archivedCount = 0.obs;
  RxBool isLoading = false.obs;

  RxInt totalStudentsCount = 0.obs;

  // final CustomPopupMenuController popupMenuController = CustomPopupMenuController();

  final RxMap<String, dynamic> dataCache = <String, dynamic>{}.obs;

  final RxList<Map<String, dynamic>> learnersList =
      <Map<String, dynamic>>[].obs;

  RxString selectedGrade = 'Grade 7'.obs;
  final List<String> grades = [
    'Grade 7',
    'Grade 8',
    'Grade 9',
    'Grade 10',
    'Grade 11',
    'Grade 12'
  ];

  RxInt selectedIndex = 1.obs;

  PageController pageController = PageController();

  String get instituteId => LocalStorage.getDBInstituteID() ?? '';

  @override
  void onInit() {
    super.onInit();
    _loadCountsAndActive();
    filteredStudents.assignAll(students);
    fetchAllLearners();
  }

  Future<void> _loadCountsAndActive() async {
    if (instituteId.isEmpty) {
      debugPrint("❌ No instituteId found in LocalStorage");
      return;
    }

    isLoading.value = true;
    try {
      final resp = await SchoolService().fetchClasses(instituteId, "Active");

      final data = resp is Map<String, dynamic> ? resp : resp?.data;
      if (data != null) {
        dataCache["Active"] = data;

        final countList = data["class_status_count"];
        if (countList is List && countList.isNotEmpty) {
          activeCount.value =
              int.tryParse(countList[0]["active_classes"].toString()) ?? 0;
          archivedCount.value =
              int.tryParse(countList[0]["archived_classes"].toString()) ?? 0;
          totalStudentsCount.value =
              int.tryParse(countList[0]["total_students"].toString()) ?? 0;
        }
      }
    } catch (e) {
      debugPrint("Error loading counts & Active data: $e");
    }
    isLoading.value = false;
  }

  void onTabChanged(int index) {
    selectedIndex.value = index;
    pageController.jumpToPage(index - 1);
    fetchDataForTab(index);
  }

  Future<void> fetchDataForTab(int index) async {
    if (index == 1) {
      return;
    } else if (index == 2) {
      await _fetchActiveOrArchived("Archived");
    } else if (index == 3) {
      await _fetchAllLearners();
    }
  }

  Future<void> _fetchAllLearners() async {
    if (learnersList.isNotEmpty) return;

    if (instituteId.isEmpty) {
      debugPrint("❌ No instituteId found in LocalStorage");
      return;
    }

    isLoading.value = true;
    try {
      final resp = await SchoolService().fetchAllLearners(instituteId);

      final data = resp is Map<String, dynamic> ? resp : resp?.data;
      if (data != null && data["student_list"] != null) {
        learnersList
            .assignAll(List<Map<String, dynamic>>.from(data["student_list"]));

        sortStudents(sortBy.value);
      }
    } catch (e) {
      debugPrint("Error fetching learners: $e");
    }
    isLoading.value = false;
  }

  Future<void> _fetchActiveOrArchived(String status) async {
    if (dataCache.containsKey(status)) return;

    if (instituteId.isEmpty) {
      debugPrint("❌ No instituteId found in LocalStorage");
      return;
    }

    isLoading.value = true;
    try {
      final resp = await SchoolService().fetchClasses(instituteId, status);

      final data = resp is Map<String, dynamic> ? resp : resp?.data;
      if (data != null) {
        dataCache[status] = data;
      }
    } catch (e) {
      debugPrint("Error fetching $status data: $e");
    }
    isLoading.value = false;
  }

  Future<void> fetchAllLearners() async {
    if (instituteId.isEmpty) return;

    isLoading.value = true;
    try {
      final resp = await SchoolService().fetchAllLearners(instituteId);
      final data = resp is Map<String, dynamic> ? resp : resp?.data;
      if (data != null && data["student_list"] != null) {
        final list = List<Map<String, dynamic>>.from(data["student_list"]);
        students.assignAll(list);
        filteredStudents.assignAll(list);
        totalStudentsCount.value = list.length;
        applyFilters();
      }
    } catch (e) {
      debugPrint("Error fetching learners: $e");
    }
    isLoading.value = false;
  }

  int get activeClassCount => activeCount.value;
  int get archivedClassCount => archivedCount.value;
  int get totalStudentCount => totalStudentsCount.value;

  List<dynamic> get classList {
    if (selectedIndex.value == 1) {
      return dataCache["Active"]?["class_details"] ?? [];
    } else if (selectedIndex.value == 2) {
      return dataCache["Archived"]?["class_details"] ?? [];
    }
    return [];
  }

  List<Map<String, dynamic>> get studentsList => learnersList;

  void resetForm() {
    className.clear();
    classDescription.clear();
    classGrade.clear();
    classStudents.clear();
    classInviteCode.clear();
    selectedGrade.value = grades.first;
  }

  Future<bool> createClass() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    isLoading(true);
    try {
      final entityId =
          LocalStorage.getDBUserID() ?? ''; // platform and school - getDBUserID
      final createdBy = LocalStorage.getDBUserID() ??
          entityId; // teacher and learner - getDBEntityID
      if (entityId.isEmpty) {
        print("❌ No entity ID found in local storage");
        return false;
      }

      final request = CreateClassRequest(
        instituteId: '3AD3B662A05D82C7E0631660000A4210',
        teacherId: '3AD392CB720D66CCE0631660000AE8DB',
        className: className.text,
        maxLearners: int.tryParse(maxLearners.text) ?? 30,
        gradeLevelId: selectedGrade.value,
        description: classDescription.text,
        term: "",
        createdBy: createdBy,
        inviteCode: classInviteCode.text.isNotEmpty ? classInviteCode.text : '',
      );

      final response = await SchoolService.createClassAPI(request);

      if (response != null && response.success) {
        return true;
      } else {
        print("❌ Failed to create class: ${response?.message}");
        return false;
      }
    } catch (e) {
      print("❌ Error creating class: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  void applyFilters() {
    List<Map<String, dynamic>> temp = [...students];

    if (searchQuery.value.isNotEmpty) {
      temp = temp.where((student) {
        final firstName = student['first_name'] ?? '';
        final lastName = student['last_name'] ?? '';
        final email = student['email'] ?? '';
        final fullName = '$firstName $lastName'.toLowerCase();
        final query = searchQuery.value.toLowerCase();
        return fullName.contains(query) || email.contains(query);
      }).toList();
    }

    switch (sortBy.value) {
      case 'Active':
        temp.sort((a, b) {
          final statusA = (a['learner_status'] ?? '').toString().toLowerCase();
          final statusB = (b['learner_status'] ?? '').toString().toLowerCase();

          if (statusA == 'active' && statusB != 'active') {
            return -1;
          } else if (statusA != 'active' && statusB == 'active') {
            return 1;
          } else {
            return 0;
          }
        });
        break;

      case 'Inactive':
        temp.sort((a, b) {
          final statusA = (a['learner_status'] ?? '').toString().toLowerCase();
          final statusB = (b['learner_status'] ?? '').toString().toLowerCase();

          if (statusA == 'inactive' && statusB != 'inactive') {
            return -1; // a before b
          } else if (statusA != 'inactive' && statusB == 'inactive') {
            return 1; // b before a
          } else {
            return 0;
          }
        });
        break;

      case 'Student (A - Z)':
        temp.sort((a, b) {
          final nameA =
              ((a['first_name'] ?? '') + (a['last_name'] ?? '')).toLowerCase();
          final nameB =
              ((b['first_name'] ?? '') + (b['last_name'] ?? '')).toLowerCase();
          return nameA.compareTo(nameB);
        });
        break;

      case 'Student (Z - A)':
        temp.sort((a, b) {
          final nameA =
              ((a['first_name'] ?? '') + (a['last_name'] ?? '')).toLowerCase();
          final nameB =
              ((b['first_name'] ?? '') + (b['last_name'] ?? '')).toLowerCase();
          return nameB.compareTo(nameA);
        });
        break;

      default:
        break;
    }

    filteredStudents.assignAll(temp);
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void sortStudents(String option) {
    sortBy.value = option;
    applyFilters();
  }
}
