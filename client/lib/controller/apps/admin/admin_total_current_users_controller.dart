import 'package:get/get.dart';
import 'package:binary_success/models/platform_total_users_model.dart';
import 'package:binary_success/helpers/network/api_service.dart';
import 'package:binary_success/helpers/constant/app_constant.dart'; 

  class PlatformUserController extends GetxController {

  final RxList<PlatformUser> allUsers = <PlatformUser>[].obs;
  final RxList<PlatformUser> filteredUsers = <PlatformUser>[].obs;
  final RxBool isLoading = false.obs;

  final RxInt totalCount = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;



  int get pageSize => AppConstant.defaultPageSize; 

  final RxString searchQuery = ''.obs;
  final RxString sortOption = 'active'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers(page: 1);


    debounce(searchQuery, (_) => applyFilters());
    debounce(sortOption, (_) => applyFilters());
  }


  Future<void> fetchUsers({int page = 1}) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final response = await APIService.get(
        path: '/db/platform_admin/get_all_platform_users/?page_number=$page&page_size=$pageSize',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        final resp = PlatformUserResponse.fromJson(data);

        allUsers.assignAll(resp.users);
        totalCount.value = resp.totalCount;
        totalPages.value = (totalCount.value / pageSize).ceil().clamp(1, 9999); 
        currentPage.value = page;

        applyFilters();
      } else {

        clearData();
      }
    } catch (e) {
      clearData();
      print("❌ Error fetching users: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    final q = searchQuery.value.toLowerCase().trim();

    List<PlatformUser> tempList = allUsers.where((user) {
      if (q.isEmpty) return true;
      return user.firstName.toLowerCase().contains(q) ||
             user.lastName.toLowerCase().contains(q) ||
             user.email.toLowerCase().contains(q);
    }).toList();

   switch (sortOption.value) {
  case 'Students (A - Z)':
    tempList.sort((a, b) =>
        (a.firstName + a.lastName).toLowerCase().compareTo(
            (b.firstName + b.lastName).toLowerCase()));
    break;

  case 'Students (Z - A)':
    tempList.sort((a, b) =>
        (b.firstName + b.lastName).toLowerCase().compareTo(
            (a.firstName + a.lastName).toLowerCase()));
    break;

  case 'Newest':
    tempList.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime); // newest first
    });
    break;

  case 'Oldest':
    tempList.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aTime.compareTo(bTime); // oldest first
    });
    break;

  case 'active':
    tempList.sort((a, b) {
      final aActive = a.statusCode.toLowerCase() == 'active' ? 0 : 1;
      final bActive = b.statusCode.toLowerCase() == 'active' ? 0 : 1;
      return aActive.compareTo(bActive);
    });
    break;

  case 'inactive':
    tempList.sort((a, b) {
      final aInactive = a.statusCode.toLowerCase() == 'inactive' ? 0 : 1;
      final bInactive = b.statusCode.toLowerCase() == 'inactive' ? 0 : 1;
      return aInactive.compareTo(bInactive);
    });
    break;

  default:
    break;
}


    filteredUsers.assignAll(tempList);
  }

  void clearData() {
    allUsers.clear();
    filteredUsers.clear();
    totalCount.value = 0;
    currentPage.value = 1;
    totalPages.value = 1;
  }
}
