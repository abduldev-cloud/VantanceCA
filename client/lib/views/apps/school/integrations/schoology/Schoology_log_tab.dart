import 'dart:async';

import 'package:vantanceCA/controller/apps/school/lms_integration_controller.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/views/apps/school/integrations/lms_tabs/widgets/header_text.dart';
import 'package:vantanceCA/views/apps/school/integrations/widgets/logs_table.dart';
import 'package:vantanceCA/views/apps/school/widget/pagination_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SchoologyLogTab extends StatefulWidget {
  const SchoologyLogTab({super.key});

  @override
  State<SchoologyLogTab> createState() => _SchoologyLogTabState();
}

class _SchoologyLogTabState extends State<SchoologyLogTab> with UIMixin {
  final LmsIntegrationController controller =
      Get.find<LmsIntegrationController>();

  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (controller.middlewareLogs.value?.data.isNotEmpty != false) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 500), () {
        controller.fetchMiddlewareLogs(
            controller.integrationData.value?.id ?? "", 1,
            query: query.trim());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (controller.integrationData.value != null) {
      controller.fetchMiddlewareLogs(controller.integrationData.value!.id, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderText(
            title: "Schoology - Connected",
            subtitle:
                "Schoology integration active – managing courses and grades in real time",
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 200,
                height: 50.h,
                child: TextField(
                  onChanged: _onSearchChanged,
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            final response = controller.middlewareLogs.value;
            final logs = response?.data ?? [];

            if (controller.isFetchingLogs.value) {
              return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                    color: contentTheme.onPrimary, size: 50),
              );
            }

            if (logs.isEmpty) {
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
                      controller.fetchMiddlewareLogs(
                          controller.integrationData.value!.id, newPage,
                          isPageChange: true,
                          query: searchController.text.trim());
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
