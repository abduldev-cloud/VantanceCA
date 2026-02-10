import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:binary_success/controller/my_controller.dart';
import 'package:binary_success/models/platform_support_model.dart';
import 'package:binary_success/helpers/services/platform_service.dart';
import 'package:binary_success/views/apps/platform_admin/admin_support_view.dart';

class AdminSupportController extends MyController {
  final RxInt selectedTabIndex = 0.obs;
  final PageController pageController = PageController();

  final RxList<SupportModel> tickets = <SupportModel>[].obs;
  final RxList<SupportModel> allTickets = <SupportModel>[].obs;
  final RxList<SupportModel> openTickets = <SupportModel>[].obs;
  final RxList<SupportModel> closedTickets = <SupportModel>[].obs;

  final RxInt totalCount = 0.obs;
  final RxInt openCount = 0.obs;
  final RxInt closedCount = 0.obs;

  final int pageSize = 10;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllTabs();
  }

  /// Switch tabs (Open / Closed / All)
  Future<void> switchTab(int index) async {
    selectedTabIndex.value = index;
    if (pageController.hasClients) {
      pageController.jumpToPage(index);
    }

    // Re-assign tickets based on tab
    tickets.assignAll(index == 0
        ? openTickets
        : index == 1
            ? closedTickets
            : allTickets);
  }

  /// Fetch all tickets (backend already gives status_counts)
  Future<void> fetchAllTabs() async {
    try {
      isLoading.value = true;

      final response = await SupportService.getSupportCases(
        status: "", // no filter → get all
      );

      if (response == null) {
        _clearData();
        return;
      }

      // Normalize + assign
      allTickets.assignAll(response.ticketList);
      openTickets.assignAll(allTickets.where((t) => t.status == "OPEN"));
      closedTickets.assignAll(allTickets.where((t) => t.status == "CLOSED"));

      // Counts (prefer backend values if provided)
      openCount.value = response.openCount;
      closedCount.value = response.closedCount;
      totalCount.value = response.allCount;

      // Default tab
      switchTab(selectedTabIndex.value);

      currentPage.value = 1;
      totalPages.value = _calculateTotalPages();
    } catch (e, s) {
      debugPrint("❌ fetchAllTabs error: $e");
      debugPrintStack(stackTrace: s);
      _clearData();
    } finally {
      isLoading.value = false;
    }
  }

  int _calculateTotalPages() {
    return (totalCount.value / pageSize).ceil().clamp(1, 9999);
  }

  void openTicket(SupportModel ticket) {
    Get.to(() => AdminSupportViewPage(ticket: ticket));
  }

  void _clearData() {
    tickets.clear();
    allTickets.clear();
    openTickets.clear();
    closedTickets.clear();
    totalCount.value = 0;
    openCount.value = 0;
    closedCount.value = 0;
    currentPage.value = 1;
    totalPages.value = 1;
  }
}
