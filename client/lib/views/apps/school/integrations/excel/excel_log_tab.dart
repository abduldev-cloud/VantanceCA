import 'dart:async';

import 'package:vantanceCA/controller/apps/school/excel_integration_controller.dart';
import 'package:vantanceCA/controller/apps/school/lms_integration_controller.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'package:vantanceCA/helpers/utils/datetime_utils.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/views/apps/school/integrations/lms_tabs/widgets/header_text.dart';
import 'package:vantanceCA/views/apps/school/integrations/platforms.dart';
import 'package:vantanceCA/views/apps/school/integrations/widgets/last_sync_datetime.dart';
import 'package:vantanceCA/views/apps/school/integrations/widgets/logs_table.dart';
import 'package:vantanceCA/views/apps/school/widget/pagination_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ExcelLogTab extends StatefulWidget {
  ExcelLogTab({super.key});

  @override
  State<ExcelLogTab> createState() => _ExcelLogTabState();
}

class _ExcelLogTabState extends State<ExcelLogTab> with UIMixin {
  final ExcelIntegrationController controller =
      Get.put(ExcelIntegrationController());
  final LmsIntegrationController lmsController =
      Get.put(LmsIntegrationController());

  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (controller.bulkUploadLogs.value?.data.isNotEmpty == false) return;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    List<String>? bulkUploadIds = LocalStorage.getCsvBulkUploadIds();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (bulkUploadIds != null && bulkUploadIds.isNotEmpty) {
        controller.fetchCsvFilesLogs(query: query.trim());
      } else {
        controller.fetchBulkUploadLogs(1, query: query.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderText(
          title: "${Platforms.bulkUpload} - Log",
          subtitle: "Logs for import CSV integration are shown here",
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  "Log",
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: contentTheme.k142228,
                  ),
                ),
                SizedBox(height: 5),
                Obx(() {
                  final timestampStr = lmsController
                      .integrationMode.value?.lastIntegrationTimestamp;

                  DateTime? lastIntegrationTimestamp;
                  if (timestampStr != null && timestampStr.isNotEmpty) {
                    try {
                      lastIntegrationTimestamp =
                          DateTimeUtils.utcIsoToLocalDateTime(timestampStr);
                    } catch (_) {
                      lastIntegrationTimestamp = null;
                    }
                  }

                  return LastSyncDatetime(
                    title: "Last Used Date: ",
                    date: lastIntegrationTimestamp != null
                        ? DateFormat('dd-MM-yyyy')
                            .format(lastIntegrationTimestamp)
                        : "-",
                    time: lastIntegrationTimestamp != null
                        ? DateFormat('HH:mm:ss')
                            .format(lastIntegrationTimestamp)
                        : "-",
                  );
                })
              ],
            ),
            SizedBox(
              width: 225.w,
              height: 50.h,
              child: TextField(
                controller: searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: contentTheme.k7E7E7E,
                  ),
                  hintStyle: GoogleFonts.inter(color: contentTheme.k7E7E7E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: contentTheme.k7E7E7E),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: contentTheme.k7E7E7E),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Obx(() {
          final response = controller.bulkUploadLogs.value;
          final logs = response?.data ?? [];

          if (controller.isFetchingLogs.value) {
            return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                    color: contentTheme.onPrimary, size: 50));
          }

          if (logs.isEmpty ||
              lmsController.integrationMode.value?.lastIntegrationTimestamp ==
                  null) {
            return const Center(child: Text("No logs to show"));
          }

          return Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: LogsTable(logs: logs),
                  ),
                ),
                const SizedBox(height: 10),
                PaginationControls(
                  currentPage: response?.page ?? 1,
                  totalPages: response?.totalPages ?? 1,
                  onPageChanged: (newPage) {
                    List<String>? bulkUploadIds =
                        LocalStorage.getCsvBulkUploadIds();
                    if (bulkUploadIds != null && bulkUploadIds.isNotEmpty) {
                      controller.fetchCsvFilesLogs(
                          page: newPage,
                          isPageChange: true,
                          query: searchController.text.trim());
                    } else {
                      controller.fetchBulkUploadLogs(newPage,
                          isPageChange: true,
                          query: searchController.text.trim());
                    }
                  },
                ),
              ],
            ),
          );
        })
      ],
    );
  }
}
