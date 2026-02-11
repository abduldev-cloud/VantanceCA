import 'package:vantanceCA/controller/apps/admin/admin_support_controller.dart';
import 'package:vantanceCA/helpers/utils/my_shadow.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_card.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/views/apps/platform_admin/widget/admin_support_queue_widget.dart';
import 'package:vantanceCA/views/layouts/layout.dart';
import 'package:vantanceCA/widgets/comman_titlebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSupportTicketPage extends StatefulWidget {
  const AdminSupportTicketPage({super.key,});

  @override
  AdminSupportTicketPageState createState() => AdminSupportTicketPageState();
}

class AdminSupportTicketPageState extends State<AdminSupportTicketPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late AdminSupportController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AdminSupportController());
    controller.fetchAllTabs();
  }

  @override
  void dispose() {
    // Clean up controller if needed (especially for singleton/global usage)
    if (Get.isRegistered<AdminSupportController>()) {
      Get.delete<AdminSupportController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 7,
      child: Obx(() {
        // Counts for cards
        final openCount = controller.openCount.value;
        final closedCount = controller.closedCount.value;
        final totalCount = controller.totalCount.value;

        // Show spinner while loading
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommanTitlebar(
              contentTheme: contentTheme,
              title: "Support Queue",
              subTitle: "Manage submitted support tickets",
              buttonTitle: "",
            ).paddingOnly(right: MySpacing.fullWidth(context) * 0.04),

            // ==== Cards Row ====
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    splashFactory: NoSplash.splashFactory,
                    onTap: () => controller.switchTab(0),
                    child: buildCard(
                      openCount.toString(),
                      "Open Tickets",
                      controller.selectedTabIndex.value == 0,
                      contentTheme.k0A8041,
                    ),
                  ).paddingOnly(right: 40.w),
                ),
                Expanded(
                  child: InkWell(
                    splashFactory: NoSplash.splashFactory,
                    onTap: () => controller.switchTab(1),
                    child: buildCard(
                      closedCount.toString(),
                      "Closed Tickets",
                      controller.selectedTabIndex.value == 1,
                      contentTheme.orange,
                    ),
                  ).paddingOnly(right: 40.w),
                ),
                Expanded(
                  child: InkWell(
                    splashFactory: NoSplash.splashFactory,
                    onTap: () => controller.switchTab(2),
                    child: buildCard(
                      totalCount.toString(),
                      "Total Tickets",
                      controller.selectedTabIndex.value == 2,
                      contentTheme.darkPurple,
                    ),
                  ),
                ),
              ],
            ).paddingOnly(
                bottom: 10.h,
                left: 5.w,
                top: 17.h,
                right: MySpacing.fullWidth(context) * 0.04,
            ),

            // ==== PageView ====
            SizedBox(
              height: MySpacing.fullHeight(context) * 0.66,
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  AdminSupportWidget(
                    contentTheme: contentTheme,
                    filter: "OPEN",
                    status: "OPEN",
                    tickets: controller.openTickets,
                  ),
                  AdminSupportWidget(
                    contentTheme: contentTheme,
                    filter: "CLOSED",
                    status: "CLOSED",
                    tickets: controller.closedTickets,
                  ),
                  AdminSupportWidget(
                    contentTheme: contentTheme,
                    filter: "ALL",
                    status: "ALL",
                    tickets: controller.allTickets,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget buildCard(
      String count, String title, bool isGradiant, Color textColor) {
    return MyCard(
      shadow: isGradiant ? MyShadow(color: Colors.transparent) : null,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 25.w),
      color: isGradiant ? null : Colors.white,
      borderRadius: BorderRadius.circular(25.r),
      gradient: isGradiant
          ? const LinearGradient(
              colors: [Color(0xffEEECFF), Color(0xffEEECFF), Color(0xffDBEBFF)],
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            count,
            style: GoogleFonts.inter(
              fontSize: 35.sp,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
