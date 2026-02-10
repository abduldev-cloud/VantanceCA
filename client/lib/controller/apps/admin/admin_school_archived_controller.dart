import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:binary_success/models/platform_admin_school_model.dart';
import 'package:binary_success/helpers/network/api_service.dart';

class AdminArchivedSchoolController extends GetxController {
  RxList<InstituteDetail> institutes = <InstituteDetail>[].obs;
  Rxn<InstituteSummaryCounts> summaryCounts = Rxn<InstituteSummaryCounts>();
  RxInt currentPage = 1.obs;
  final int pageSize = 10;
  RxBool isLoading = false.obs;
  RxBool hasMore = true.obs;

  final RxInt selectedIndex = 1.obs;
  final PageController pageController = PageController(initialPage: 0);

  RxString instituteStatus = "ARCHIVED".obs; // default ARCHIVED

  Future<void> fetchInstitutes({int page = 1}) async {
    isLoading.value = true;
    try {
      final response = await APIService.get(
        path: '/db/platform_admin/get_all_institute_summary/?institute_status=${instituteStatus.value}&page_number=$page&page_size=$pageSize',
      );
      print("✅ Fetched archived institutes: $response");
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        final resp = InstituteListResponse.fromJson(data);

        if (page == 1) {
          summaryCounts.value = resp.summaryCounts;
          institutes.value = resp.instituteDetails;
        } else {
          institutes.addAll(resp.instituteDetails);
        }

        hasMore.value = resp.instituteDetails.length == pageSize;
        currentPage.value = page;
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      hasMore.value = false;
      print("❌ Error fetching archived institutes: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void fetchNextPage() {
    if (hasMore.value && !isLoading.value) {
      fetchInstitutes(page: currentPage.value + 1);
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchInstitutes(page: 1);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}