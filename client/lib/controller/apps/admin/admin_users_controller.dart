import 'package:binary_success/helpers/constant/app_constant.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:binary_success/helpers/services/user_services.dart';
import 'package:binary_success/models/user_model.dart';
import 'package:dio/dio.dart';

class AdminUsersController extends GetxController {
  /// 🔹 Tabs: 0 = Active, 1 = Inactive, 2 = All
  final RxInt selectedTabIndex = 0.obs;
  late final PageController pageController;

  /// 🔹 State
  final RxBool isLoading = false.obs;

  /// 🔹 Data lists
  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxList<UserModel> activeUsers = <UserModel>[].obs;
  final RxList<UserModel> inactiveUsers = <UserModel>[].obs;

  /// 🔹 Counts
  final RxInt totalCount = 0.obs;
  final RxInt activeCount = 0.obs;
  final RxInt inactiveCount = 0.obs;

  /// 🔹 Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final int pageSize = 10;

  /// 🔹 Current filter
  String currentStatus = "active";
  String currentSearch = "";
  String currentSort = "Oldest";

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
    fetchUsers(status: currentStatus, pageNumber: 1);
  }



Future<bool> updateUserStatusOnServer({
  required String keycloakUserId,
  required String userId,
  required String status,
  required String updatedBy,
}) async {
  try {
    isLoading.value = true;
    final dio = Dio();
  final response = await dio.post(
  "${API.baseURl}/users/update-user-status",
  data: {
    "keycloak_user_id": keycloakUserId,
    "user_id": userId,
    "status": status,
    "updated_by": updatedBy,
  },
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    return response.statusCode == 200;
  } catch (e) {
    debugPrint("API update error: $e");
    return false;
  } finally {
    isLoading.value = false;
  }
}


  /// 🔹 Fetch users with pagination, search & sort
  Future<void> fetchUsers({
    String status = "",
    int pageNumber = 1,

  }) async {
    try {
      isLoading.value = true;


      final ApiResponse? response = await PlatformAdminService.getPlatformUsers(
        status: status,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      if (response == null || response.outStatus != "SUCCESS") {
        _clearData();
        return;
      }

      /// ✅ Assign all users
      allUsers.assignAll(response.userList);

      /// ✅ Categorize
      activeUsers.assignAll(
        allUsers.where((u) => (u.status ?? "").toUpperCase() == "ACTIVE"),
      );
      inactiveUsers.assignAll(
        allUsers.where((u) => (u.status ?? "").toUpperCase() == "INACTIVE"),
      );

      currentStatus = status;
      currentPage.value = pageNumber;

      /// ✅ Update counts
      if (response.userCounts.isNotEmpty) {
        final UserCount c = response.userCounts.first;
        activeCount.value = c.activeUsers;
        inactiveCount.value = c.inactiveUsers;
        totalCount.value = c.totalUsers;
      } else {
        activeCount.value = activeUsers.length;
        inactiveCount.value = inactiveUsers.length;
        totalCount.value = allUsers.length;
      }

      /// ✅ Pagination calculation
      totalPages.value = _calculateTotalPages(status);
    } catch (e, s) {
      debugPrint("❌ fetchUsers error: $e");
      debugPrintStack(stackTrace: s);
      _clearData();
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Calculate total pages safely
  int _calculateTotalPages(String status) {
    int count = status == "active"
        ? activeCount.value
        : status == "inactive"
            ? inactiveCount.value
            : totalCount.value;
    return (count / pageSize).ceil().clamp(1, 9999);
  }

  /// 🔹 Switch tabs and reload data
  Future<void> switchTab(int index) async {
    selectedTabIndex.value = index;

    String status;
    if (index == 0) {
      status = "active";
    } else if (index == 1) {
      status = "inactive";
    } else {
      status = ""; // fetch all
    }

    await fetchUsers(
      status: status,
      pageNumber: 1,
    );

    if (pageController.hasClients) {
      pageController.jumpToPage(index);
    }
  }

void updateUserStatus(String userId, String newStatus) {
  int index = allUsers.indexWhere((user) => user.userId == userId);
  if (index != -1) {
    // Create a new user object with updated status
    final updatedUser = allUsers[index].copyWith(status: newStatus);
    allUsers[index] = updatedUser;


    // Refresh filtered lists
    activeUsers.assignAll(allUsers.where((u) => (u.status ?? "").toUpperCase() == "ACTIVE"));
    inactiveUsers.assignAll(allUsers.where((u) => (u.status ?? "").toUpperCase() == "INACTIVE"));

    allUsers.refresh();
  }
}


  /// 🔹 Apply search or sort (tab-wise)
void applyFilters(String search, String sort) {
  String status;
  if (selectedTabIndex.value == 0) {
    status = "active";
  } else if (selectedTabIndex.value == 1) {
    status = "inactive";
  } else {
    status = ""; // All users
  }

  fetchUsers(
    status: status,
    pageNumber: 1,
  );
}


  /// 🔹 Reset state
  void _clearData() {
    allUsers.clear();
    activeUsers.clear();
    inactiveUsers.clear();
    totalCount.value = 0;
    activeCount.value = 0;
    inactiveCount.value = 0;
    currentPage.value = 1;
    totalPages.value = 1;
  }
}
