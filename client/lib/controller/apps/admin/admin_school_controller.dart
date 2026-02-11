import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vantanceCA/models/platform_admin_school_model.dart';
import 'package:vantanceCA/helpers/network/api_service.dart';
import 'package:vantanceCA/helpers/constant/app_constant.dart';

class AdminSchoolController extends GetxController {
  RxList<InstituteDetail> institutes = <InstituteDetail>[].obs;
  List<InstituteDetail> allInstitutes = [];
  Rxn<InstituteSummaryCounts> summaryCounts = Rxn<InstituteSummaryCounts>();
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool hasMore = true.obs;

  RxBool isSorting = false.obs;

  var selectedIndex = 1.obs;
  final PageController pageController = PageController();
  int get pageSize => AppConstant.defaultPageSize;
  RxString instituteStatus = "ACTIVE".obs;

  RxString searchText = "".obs;
  RxString sortOrder = "A-Z".obs;

  int get totalCount {
    if (instituteStatus.value == "ACTIVE") {
      return summaryCounts.value?.activeInstitutes ?? 0;
    } else {
      return summaryCounts.value?.archivedInstitutes ?? 0;
    }
  }

  int get totalPages => (totalCount / AppConstant.defaultPageSize).ceil();

  @override
  void onInit() {
    super.onInit();
    // Use Future.delayed to ensure fetchInstitutes is called after the initial build
    // to avoid "setState() or markNeedsBuild() called during build" errors.
    Future.delayed(Duration.zero, () {
      fetchInstitutes(page: 1);
    });
  }

  Future<void> fetchInstitutes({int page = 1}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final response = await APIService.get(
        path:
            '/db/platform_admin/get_all_institute_summary/?institute_status=${instituteStatus.value}&page_number=$page&page_size=${AppConstant.defaultPageSize}', // <-- Changed
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        final resp = InstituteListResponse.fromJson(data);

        summaryCounts.value = resp.summaryCounts;
        allInstitutes = resp.instituteDetails;

        applySearchAndSort();

        hasMore.value =
            resp.instituteDetails.length == AppConstant.defaultPageSize;
        currentPage.value = page;
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      hasMore.value = false;
      print("❌ Error fetching institutes: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void applySearchAndSort() {
    List<InstituteDetail> filteredList = allInstitutes;

    if (searchText.value.isNotEmpty) {
      filteredList = filteredList.where((inst) {
        return inst.instituteName
            .toLowerCase()
            .contains(searchText.value.toLowerCase());
      }).toList();
    }

    if (sortOrder.value == "A-Z") {
      filteredList.sort((a, b) => a.instituteName.compareTo(b.instituteName));
    } else if (sortOrder.value == "Z-A") {
      filteredList.sort((a, b) => b.instituteName.compareTo(a.instituteName));
    }

    institutes.value = filteredList;
  }

  void onSearchTextChanged(String text) {
    searchText.value = text;
    applySearchAndSort();
  }

  void onSortOrderChanged(String order) async {
    isSorting.value = true;
    sortOrder.value = order;

    await Future.delayed(Duration(milliseconds: 100));

    applySearchAndSort();

    isSorting.value = false;
  }

  void fetchNextPage() {
    if (hasMore.value && !isLoading.value && currentPage.value < totalPages) {
      fetchInstitutes(page: currentPage.value + 1);
    }
  }

  void switchTab(int index) {
    selectedIndex.value = index;
    instituteStatus.value = (index == 0) ? "ACTIVE" : "ARCHIVED";
    fetchInstitutes(page: 1);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
